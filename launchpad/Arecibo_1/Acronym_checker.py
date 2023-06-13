import os
import fitz
import re
import pandas as PD
from bs4 import BeautifulSoup as BS
from fuzzywuzzy import fuzz
try:
    import launchpad.Arecibo_1.PDF_Edit_MODIFIED as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit_MODIFIED as PE
    from ar_interface import jobs_in_progress as jip

def main(doc, error_code, directory):
    ###Variable Declaration###
    Text_Pages = []
    test_text = []
    Acronyms = []
    Full_Term = []
    vert = []
    y_pos = []
    x_pos = []
    ignor = []


    #Regular expressions
    reg_date = re.compile(r"[0-9]{1,2}.[A-z]{3}.[0-9]{4}") #Dates
    reg_dateATA100 = re.compile(r"[A-f, h-z]{3} [0-9]{2}/[0-9]{2}")
    reg_page1 = re.compile(r"Page [A-z]{1,3}-[0-9]{1,2}")  #Intro section
    reg_page2 = re.compile(r"[0-9]{4,5}")  #Regular pages
    reg_pageA100 = re.compile(r"[0-9]{1,3}")  #ATA 100 pages
    Only_digits = re.compile(r"^([\s\d]+)$")
    ATA = re.compile('[0-9]{2}-[0-9]{2}-[0-9]{2}')



    ###MAIN CODE###
    def remove_values_from_list(the_list, val):                                                                             #To get rid of all instances of a variable from an list
        return [value for value in the_list if value != val]

    pages1 = PE.searchPDF(doc, "List of Acronyms and Abbreviations")
    pages2 = PE.searchPDF(doc, "Full Term")
    pages2 = [x for x in pages2 if x not in pages1]
    Tot_pages = pages1 + pages2   #All the pages that will be required for revision bar info in the Front matter
    Tot_pages = remove_values_from_list(Tot_pages, 0)

    for x in Tot_pages:
        Dlist = doc[x].getDisplayList()
        Text_Pages.append(Dlist.getTextPage())

    jip[directory.name].log_print("Getting Acronyms and Abbreviations...")
    for x in Text_Pages:                            ###START                                                                #Gets the text from each specified display list
        y_pos = []      #Resets the variable after each page, so data is a bit more manageable
        x_pos = []
        test_text = []
        HTML = x.extractHTML()       

        soup = BS(HTML, 'lxml')                                                                                             #Creates a formatted html block called 'soup'
        style = soup.find_all('p')

        for y in style:
            temp = y['style']
            list = temp.split(';')                  #END: This portion of the code is used to get the attributes of the text
            #print(list[5])
            y_pos.append(int((list[0].replace("top:", "")).replace("pt", "")))
            x_pos.append(int((list[1].replace("left:", "")).replace("pt", "")))
            test_text.append(y.text.strip().replace(" 0", "0").replace("2 ", ""))

        df = PD.DataFrame({'Y-Position': y_pos,
                           'X-Position': x_pos,
                           'Text': test_text})
        df.sort_values(by=['Y-Position', 'X-Position'], inplace=True)
        df = df.reset_index(drop=True)
        #print(df)
        start = 0
        AClocation = 0
        FTlocation = 0
        for i in range(0, len(df["Text"])):                                                                                 #Uses position of "Term" and "Full Term" to determine which is a acronym and which is regular texr
            if df['Text'][i] == "Full Term":
                FTlocation = df['X-Position'][i]
            if len(df['Text'][i]) <= 7 and start == 1 and df['X-Position'][i] in range(AClocation-2, AClocation+2):
                Acronyms.append(df['Text'][i] + ";" + str(df['Y-Position'][i]) + ';' + str(df['X-Position'][i]))
                vert.append(df["Y-Position"][i])

                for index, row in df.iterrows():
                    temp1 = df["Y-Position"][i]
                    temp2 = df["Text"][i]
                    if row["Y-Position"] in range(temp1-2, temp1+2) and row["Text"] != temp2 \
                            and row["X-Position"] in range(FTlocation-2, FTlocation+2):
                        Full_Term.append(row["Text"] + ";" + str(row["Y-Position"]) + ";" + str(row["X-Position"]))
            if df['Text'][i] == "Term":
                start = 1
                AClocation = df['X-Position'][i]


    for x in range(0, len(Full_Term)):
        if x in ignor:
            pass
        else:
            temp = Full_Term[x].split(';')
            wordtemp = temp[0]
            for y in range(0, len(Full_Term)):
                compare = fuzz.ratio(wordtemp, Full_Term[y].split(';')[0])
                compare2 = fuzz.partial_ratio(wordtemp, Full_Term[y].split(';')[0])
                if x == y:
                    pass
                elif compare2 in range(90, 99) and compare >= 95:
                    ignor.append(y)
                    comment = wordtemp + ", is repeated in the Acronyms Table"
                    jip[directory.name].log_print(comment)
                    for z in Tot_pages:
                        page = doc[z]
                        rect = page.searchFor(wordtemp)
                        if rect != []:
                            PE.TextAnnot_Once(page, rect, comment, "ACRONYM CHECKER")
                            error_code[14] = 1  #
                            error_code[57] = error_code[57] + 1  #
                            break
                elif compare2 == 100 and compare == 100:
                    ignor.append(y)
                    comment = wordtemp + ", is repeated in the Acronyms Table"
                    jip[directory.name].log_print(comment)
                    for z in Tot_pages:
                        page = doc[z]
                        rect = page.searchFor(wordtemp)
                        if rect != []:
                            PE.TextAnnot_Once(page, rect, comment, "ACRONYM CHECKER")
                            error_code[14] = 1  #
                            error_code[57] = error_code[57] + 1  #
                            break
    ignor = []
    jip[directory.name].log_print("-------------------------------------------------------")
    for x in range(0, len(Acronyms)):
        if x in ignor:
            pass
        else:
            temp = Acronyms[x].split(';')
            wordtemp = temp[0]
            for y in range(0, len(Acronyms)):
                compare = fuzz.ratio(wordtemp, Acronyms[y].split(';')[0])
                compare2 = fuzz.partial_ratio(wordtemp, Acronyms[y].split(';')[0])
                if x == y:
                    pass
                elif compare2 >= 90 and compare >= 95:
                    ignor.append(y)
                    comment = wordtemp + ", is repeated Acronyms Table"
                    jip[directory.name].log_print(comment)
                    for z in Tot_pages:
                        page = doc[z]
                        rect = page.searchFor(wordtemp)
                        if rect != []:
                            PE.TextAnnot_Once(page, rect, comment, "ACRONYM CHECKER")
                            error_code[14] = 1  #
                            error_code[57] = error_code[57] + 1  #
                            break
    return doc, error_code

