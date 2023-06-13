import os
import fitz
import re
import pandas as PD
from bs4 import BeautifulSoup as BS
from fuzzywuzzy import fuzz
import logging
import traceback
try:
    import launchpad.Arecibo_1.PDF_Edit_MODIFIED as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit_MODIFIED as PE
    from ar_interface import jobs_in_progress as jip


###MAIN CODE###
def remove_values_from_list(the_list, val):                                                                             #To get rid of all instances of a variable from an list
    return [value for value in the_list if value != val]

def errors(log, directory):
    jip[directory.name].log_print('An Exception has occurred...')
    jip[directory.name].log_print('Outputting error log...')
    logf = open("Error.log", "w")
    logf.write(str(log))
    logf.write("\n\n")
    jip[directory.name].log_print('Completed')

#Used to determine the location of the highlight and subtask numbers
def Determine_limits(x_pos, y_pos):                                                                                     #This will determine where the subtask and descriptions will begin in the highlights by the frequency of the position on the page.
    x_values = []
    y_values = []
    counter = []
    for i in x_pos:
        if i not in x_values:
            x_values.append(i)
    for i in y_pos:
        if i not in y_values:
            y_values.append(i)

    for x in x_values:
        count = 0
        for y in x_pos:
            if x == y:
                count = count + 1
        counter.append(count)

    df = PD.DataFrame({'X-Position': x_values,
                       'Counter': counter})
    df = df.sort_values(by=['Counter'], ascending=False)
    df = df.reset_index(drop=True)
    #print(x_values)                                                                                                    #FOR TESTING
    #print(df)                                                                                                          #FOR TESTING

    if df['X-Position'][0] > df['X-Position'][1]:
        desc_x = df['X-Position'][0]
        sub_x = df['X-Position'][1]
    else:
        desc_x = df['X-Position'][1]
        sub_x = df['X-Position'][0]
    return desc_x, sub_x                                                                                                #Returns the *Likely* positions of the subtasks and descriptions

#This will be used to check the highlight against the page to see if there is a rev bar
def Check_highlights(subtask, description, doc, error_code, directory):
    #Variable Declaration
    Text_Pages = []
    count = 0
    page = 0
    pdf_page = []
    test_text = []
    reg_pages = re.compile(r'Page[s]{0,1}.[0-9]{4}')
    re_graphic = re.compile(r'^Figure [0-9]{4}\.')
    re_para = re.compile(r'^Paragraph [0-9]\.[A-Z]\.')
    re_step = re.compile((r'Step \([0-9]{1,2}\)'))

    ### Function Code
    try:
        df = PD.DataFrame({'Subtask': subtask,
                           'Description': description})
        #print(df)
    except Exception as e:
        logging.exception(e)
        message = traceback.format_exc()
        errors(message, directory)
        jip[directory.name].log_print("Subtask: " + str(len(subtask)))
        jip[directory.name].log_print("Description: " + str(len(description)))
        # jip[directory.name].log_print("Press Enter To Continue")
    Tot_pages = len(doc)
    for x in range(0, Tot_pages):
        Dlist = doc[x].getDisplayList()
        Text_Pages.append(Dlist.getTextPage())

    for x in Text_Pages:
        y_pos = []
        x_pos = []

        HTML = x.extractHTML()
        #for y in HTML.strip().splitlines():                #For Testing
        #    print(y)
        soup = BS(HTML, 'lxml')  # Creates a formatted html block called 'soup'
        style = soup.find_all('p')

        for y in style:
            temp = y['style']
            list = temp.split(';')          #END: This portion of the code is used to get the attributes of the text
            #print(list[5])
            Page_true = re.search("Page", y.text.strip().replace(" 0", "0").replace("2 ", "2").replace(' .', '.'))
            if int(list[0].replace("top:", "").replace("pt", "").strip()) > 730 and Page_true:
                y_pos.append(int((list[0].replace("top:", "")).replace("pt", "")))
                x_pos.append(int((list[1].replace("left:", "")).replace("pt", "")))
                test_text.append(y.text.strip().replace(" 0", "0").replace("2 ", "2").replace(' .', '.'))
                pdf_page.append(count)
        count = count + 1

    PDF_and_Page = PD.DataFrame({'PAGE': test_text,
                                 'PDF PAGE': pdf_page})
    jip[directory.name].log_print(PDF_and_Page)

    i = 0
    for pages in subtask:
        highlight = description[i]
        cond_graphic = re.search(re_graphic, highlight)
        jip[directory.name].log_print(highlight)
        # jip[directory.name].log_print(cond_graphic)
        cond_para = re.search(re_para, highlight)
        try:
            page = re.search(reg_pages, pages).group(0)
        except AttributeError:
            pass
        for index, row in PDF_and_Page.iterrows():
            if row['PAGE'].lower().strip() == str(page).lower().strip():                                                #Finds the highlight page and matches with body pdf page
                jip[directory.name].log_print(str(row['PDF PAGE']) + " " + str(row['PAGE']))
                jip[directory.name].log_print(page)
                Dlist = doc[row['PDF PAGE']].getDisplayList()                                                           #Takes the the found page from above and reads the data on said page
                Text_Page = (Dlist.getTextPage())
                HTML = Text_Page.extractHTML()
                soup = BS(HTML, 'lxml')  # Creates a formatted html block called 'soup'
                style = soup.find_all('p')

                for y in style:
                    test_text.append(y.text.strip().replace(" 0", "0").replace("2 ", "2").replace(' .', '.'))
                    if cond_graphic:                                                                                    #This portion checks all graphic change rev bars by looking for rev bars before the title of the figure for the changed figure
                        figure = cond_graphic.group(0)
                        if re.search(figure.strip(), test_text[len(test_text)-1].strip()):
                            if re.search('^Figure', test_text[len(test_text)-1].strip()):
                                if re.search('_r_e_v', test_text[len(test_text)-2].strip()):
                                    jip[directory.name].log_print('Revbar Found!!!')
                                else:
                                    comment = 'Revision bar not found for the highlight: ' + '\"' + highlight + '\"'
                                    doc_page = doc[row['PDF PAGE']]                                                     # Makes a Page object need for the highlights for relevant page
                                    rect = [fitz.Rect(300, 0, 0, 0)]
                                    PE.TextAnnot_Once(doc_page, rect, comment, "HIGHLIGHT CHECKER")
                                    error_code[15] = 1
                                    error_code[63] = error_code[63] + 1                                                 #This is the Missing Graphics Highlight

                    if cond_para:
                        paragraph = cond_para.group(0)
                        cond_parastep = re.search(re_step, highlight)
        i += 1

## MAIN FUNCTION
def main(doc, error_code, directory):
    # Initial step to verify "_r_e_v" exists otherwise module is of no use
    Activate = PE.searchPDF(doc,"_r_")
    Activate = remove_values_from_list(Activate, 0)
    if Activate == []:
        pass
    else:
        ###Variable Declaration###
        Text_Pages = []
        count = 0
        subtask = []
        Description = []
        k = 0

        pages = PE.searchPDF(doc, "Table of Highlights")
        pages_remove = PE.searchPDF(doc, "Table TI-1.")

        pages = remove_values_from_list(pages, pages_remove[0])

        Tot_pages = pages   #All the pages that will be required for revision bar info in the Front matter
        Tot_pages = remove_values_from_list(Tot_pages, 0)

        for x in Tot_pages:
            Dlist = doc[x].getDisplayList()
            Text_Pages.append(Dlist.getTextPage())

        print("Getting Highlight Information...")
        for x in Text_Pages:                     ###START                                                                       #Gets the text from each specified display list
            df = 0
            y_pos = []
            x_pos = []
            test_text = []
            HTML = x.extractHTML()
            #for y in HTML.strip().splitlines():                #For Testing
            #    print(y)
            soup = BS(HTML, 'lxml')                                                                                             #Creates a formatted html block called 'soup'
            style = soup.find_all('p')

            for y in style:
                if y.text.strip().lower() != 'all':
                    temp = y['style']
                    list = temp.split(';')          #END: This portion of the code is used to get the attributes of the text
                    #print(list[5])
                    y_pos.append(int((list[0].replace("top:", "")).replace("pt", "")))
                    x_pos.append(int((list[1].replace("left:", "")).replace("pt", "")))
                    test_text.append(y.text.strip().replace(" 0", "0").replace("2 ", "2").replace(' .', '.'))

            df = PD.DataFrame({'Y-Position': y_pos,
                            'X-Position': x_pos,
                            'Text': test_text})
            df.sort_values(by=['X-Position', 'Y-Position'], inplace=True)
            desc_x, sub_x = Determine_limits(x_pos, y_pos)
            df = df.sort_values(by=['Y-Position', 'X-Position'])
            #print(df)

            for index, row in df.iterrows():
                para = row['Text'].strip().replace("  ", " ")
                if para.lower().strip() == "effectivity" or para.lower().strip() == "all":
                    pass
                else:
                    x = row['X-Position']
                    y = row['Y-Position']
                    if row['Y-Position'] >= 140:
                        if count == 0:
                            posTempY = row['Y-Position']
                            posTempX = row['X-Position']
                            subtask.append(para)
                        elif count == 1:
                            posTempY = row['Y-Position']
                            posTempX = row['X-Position']
                            Description.append(para)
                        elif x in range(sub_x - 5, sub_x + 5) and y not in range(posTempY - 13, posTempY + 13):
                            subtask.append(para)
                        elif x in range(desc_x - 5, desc_x + 5) and y not in range(posTempY - 13, posTempY + 13):
                            Description.append(para)
                            posTempY = row['Y-Position']
                            posTempX = row['X-Position']
                        elif x in range(sub_x - 5, sub_x + 5) and y in range(posTempY - 13, posTempY + 13):
                            subtask[len(subtask) - 1] = subtask[len(subtask) - 1] + " " + para
                            posTempY = row['Y-Position']
                            posTempX = row['X-Position']
                        elif x in range(desc_x - 5, desc_x + 5) and y in range(posTempY - 13, posTempY + 13):
                            Description[len(Description) - 1] = Description[len(Description) - 1] + " " + para
                            posTempY = row['Y-Position']
                            posTempX = row['X-Position']
                            k = k + 1
                        count = count + 1

        Check_highlights(subtask, Description, doc, error_code, directory)                                                                         #Calls the check highlight function that sees if rev bar exists.
    return doc, error_code
    #for z in Description:  # For Testing
    #    print(z)
