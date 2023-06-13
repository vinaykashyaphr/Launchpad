from spellchecker import SpellChecker as SC
import glob
import fitz
from bs4 import BeautifulSoup as BS
import pandas as PD
import re
from collections import Counter

try:
    import launchpad.Arecibo_1.PDF_Edit_MODIFIED as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    print('launchpad not found')
    import PDF_Edit_MODIFIED as PE
    from ar_interface import jobs_in_progress as jip

def main(doc, error_code, directory):
    
    # issues
    #   input not being gotten?


    def Add_comments(doc, temp, Total_ND_Words):
        # doc = PE.openPDF()
        temp.set_index('Page of Occurrence', inplace=True)
        Count = Counter(Total_ND_Words)            #Little logic used to avoid 100 instances of something that may be just a name not in our dictionary
        for key, value in Count.items():
            if value > 10:
                jip[directory.name].log_print("\"" + key + "\" occurs more than 10 times")
                #Highlight Variables
                page = doc[0]
                rect = [fitz.Rect(300, 300, 0, 0)]
                comment = "\"" + key + "\" is being flagged as a spelling mistake and occurs multiple times throughout book. Please confirm if is a mistake, if not please remove comment."
                PE.TextAnnot(page, rect, comment, "SPELL CHECKER")
                temp = temp[temp.Term != key]

        for pagenum, term in temp.iterrows():
            #Highlight Variables
            rect = 0
            page = doc[pagenum-1]
            comment = "Word \"" + term["Term"] + "\" is not found in the dictionary, possible spelling mistake. Please confirm."
            x, match, rect = PE.searchPAGE(doc, pagenum-1, term['Term'], 1)
            #print(term["Term"])
            #print(rect)
            PE.highlight(page, rect, comment, "SPELL CHECKER")

        # close = False
        # while not close:
        #     try:
        #         PE.output(doc)
        #         doc.close()
        #         close = True
        #     except (KeyError, RuntimeError):
        #         print('ERROR OUTPUT:\n Please close the previously output document')
        #         jip[directory.name].get_input("Press Enter To Continue.....")



    def word_exceptions(doc, df, Total_ND_Words):
        loop_end = "y"
        choice = "fgf"
        #DISPLAY VARIABLES
        jip[directory.name].log_print(df)

        ##MAIN CODE
        while loop_end != 1:
            choice = jip[directory.name].get_input("Do you want to add words to the dictionary? (Y/N): ")
            if not re.search('[yn]', str(choice).lower()) or len(choice) > 1:
                print("invalid character please try again.\n")
            else:
                loop_end = 1
        if choice.lower() == "y":
            jip[directory.name].log_print("Enter the corresponding number(s) for the words that is to be added to the dictionary.\n"
                "If multiple, seperate with commas (i.e 1,2,3). Enter \"n\" to end.\n"
                "Enter \"o\" to open current marked up PDF.\n ")
            exclude = jip[directory.name].get_input("ENTER HERE: ")
            end = str(exclude)
            while str(end).lower() != "n":
                if exclude.lower() == "o":
                    temp = df.copy()
                    Add_comments(doc, temp, Total_ND_Words)
                    doc = PE.openPDF()

                ex_words = exclude.split(",")
                try:
                    for x in ex_words:
                        write = (df.loc[int(x)]).get(key='Term')
                        with open(r'./launchpad/Arecibo_1/Dictionary/custom_dict.txt', 'a') as dict:
                            dict.write(write + '\n')
                        df = df[df.Term != write]
                        jip[directory.name].log_print(write + " ADDED TO EXCLUDED LIST")
                    df = df.reset_index(drop=True)
                except (ValueError, KeyError):
                    if exclude.lower() != 'o':
                        jip[directory.name].log_print("Invalid value, please try again\n")

                jip[directory.name].log_print(df)
                jip[directory.name].log_print("Enter the corresponding number(s) for the words that is to be added to the dictionary.\n"
                    "If multiple, seperate with commas (i.e 1,2,3). Enter \"n\" to end.\n"
                    "Enter \"o\" to open current marked up PDF.\n ")
                exclude = jip[directory.name].get_input("ENTER HERE(): ")
                end = exclude
        return df

    def spellcheck_PDF(doc):
        #VARIABLES
        Dictionary_path = glob.glob('.\launchpad\Arecibo_1\Dictionary\*.txt')
        jip[directory.name].log_print(Dictionary_path)
        spell = SC()
        for path in Dictionary_path:
            spell.word_frequency.load_text_file(path)
        # spell.word_frequency.load_text_file(r"C:\Users\smainuddin\Documents\GitHub\Spell Checker\Acronyms.txt")
        # spell.word_frequency.load_text_file(r"C:\Users\smainuddin\Documents\GitHub\Spell Checker\aptspell_24Jun2020.txt")
        # spell.word_frequency.load_text_file(r"C:\Users\smainuddin\Documents\GitHub\Spell Checker\usa.txt")
        # spell.word_frequency.load_text_file(r"C:\Users\smainuddin\Documents\GitHub\Spell Checker\en_full.txt")              ####OPTIONAL
        Text_Pages = []
        Total_ND_Words = []
        page_of_occurance = []


        #MAIN CODE
        def remove_values_from_list(the_list, val):                                                                         #To get rid of all instances of a variable from an list
            return [value for value in the_list if value != val]

        Tot_pages = len(doc)-1
        i = 0
        for page in range(0, Tot_pages):
            Dlist = doc[page].getDisplayList()
            Text_Pages.append(Dlist.getTextPage())

        jip[directory.name].log_print("Commencing Spell Check...")
        for x in Text_Pages:
            i = i + 1                                                                                                       #Gets the text from each specified display list
            test_text = []
            HTML = x.extractHTML()
            soup = BS(HTML, 'lxml')                                                                                         #Creates a formatted html block called 'soup'
            style = soup.find_all('p')

            #Picking Words to Check
            for y in style:
                sentence = re.split('\W+', y.text)
                for words in sentence:
                    uppercase = words[:-1]
                    #print(uppercase)                                                                                       #TESTING PURPOSE
                    if re.search("[0-9]", words):                                                                           #Will Skip words with numbers or special characters (will also skip uppercase words as those usually are names of connectors or what not) !!!Need to discuss with Scott
                        pass
                    elif uppercase.isupper():
                        if words[len(words)-1] == "s":
                            test_text.append(uppercase)
                    elif re.search("_", words) or len(words) == 1:
                        pass
                    else:
                        words = re.sub("[^A-z]", "", words).strip()
                        test_text.append(words)
                        #print(words)                                                                                       #TESTING PURPOSE

        #Iterating words found
            ND_Words = spell.unknown(test_text)
            #Words not found in the dictionary
            while ("" in ND_Words):                                                                                         #Removing blank spaces
                ND_Words.remove("")
            if len(ND_Words) != 0:
                #print("PAGE " + str(i))
                #print("---------------------------------------------------------------------------------------")
                for words in ND_Words:
                    #print(words)
                    Total_ND_Words.append(words)                                                                           #Creating a list of all words npt found in dictionary and their respective page numbers
                    page_of_occurance.append(i)
                #print(Counter(ND_Words))
                #print("---------------------------------------------------------------------------------------")


        df = PD.DataFrame({'Page of Occurrence': page_of_occurance,                                                         #Sorting Words of Interest and the page numbers where it cccurs
                        'Term': Total_ND_Words})
        # # add words to dict?
        # df = word_exceptions(doc, df, Total_ND_Words)
        Add_comments(doc, df, Total_ND_Words)


    # get in pdf

    # figure out what is error code in this context

    spellcheck_PDF(doc)

    return doc, error_code



