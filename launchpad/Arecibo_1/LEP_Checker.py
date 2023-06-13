import os
import fitz
import re
import pandas as PD
from bs4 import BeautifulSoup as BS
from fuzzywuzzy import fuzz
try:
    import launchpad.Arecibo_1.PDF_Edit_MODIFIED as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except:
    import PDF_Edit_MODIFIED as PE
    from ar_interface import jobs_in_progress as jip

def main(doc, error_code, directory):
    ###Define Variables###
    Text_Pages = []
    Text_pages_full = []
    text = [""]*2
    date = []                                                                                                               #Most of the variable here are for the raw data method (**See Below)
    page_num = []
    asterisks = []
    i = -1
    num = 1
    pdf_page = 0
    new_print = 0   #This variable will be used to check whether this is a new print with rev bar designator or is a rev 0


    count = 0                                                                                                               #These are variables required for the Dataframe method
    k = 0
    y_pos = []
    test_text = []
    #Regular expressions
    reg_date = re.compile("[0-9]{1,2}.[A-z]{3}.[0-9]{4}") #Dates
    reg_dateATA100 = re.compile("[A-f, h-z]{3} [0-9]{2}/[0-9]{2}")
    reg_page1 = re.compile("Page [A-z]{1,3}-[0-9]{1,2}")  #Intro section
    reg_page2 = re.compile("[0-9]{4,5}")  #Regular pages
    reg_pageA100 = re.compile("[0-9]{1,3}")  #ATA 100 pages
    Weird_space = re.compile('(?<=[0-9]) (?<![0-9])(?=[0-9])')
    ATA = re.compile('[0-9]{2}-[0-9]{2}-[0-9]{2}')

    #PAGE NUMBERING TYPE
    Digits = re.compile('^[0-9]{2,5}$')
    Intro = re.compile('^[A-z]{2,5}-[0-9]{1,2}$')

    ###################

    ###Main Code###
    def remove_values_from_list(the_list, val):                                                                             #To get rid of all instances of a variable from an list
        return [value for value in the_list if value != val]

    pages1 = PE.searchPDF(doc, "Subject and Page")
    pages2 = PE.searchPDF(doc, "Subheading and Page")
    pages3 = PE.searchPDF(doc, "LIST OF EFFECTIVE PAGES (CONTINUED)")
    if pages3[0] != 0:
        pages3.insert(0, pages3[0]-1)
    LEPpages = pages1 + pages2 + pages3
    LEPpages = remove_values_from_list(LEPpages, 0)
    for x in LEPpages:
        Dlist = doc[x].getDisplayList()
        Text_Pages.append(Dlist.getTextPage())

    jip[directory.name].log_print("Getting LEP Pages and Information...")
    for x in Text_Pages:                                                                                                    #Gets the text from each specified display list
        HTML = x.extractHTML()
        #for y in HTML.strip().splitlines():
        #    print(y)

        soup = BS(HTML, "lxml")                                                                                             #Creates a formatted html block called 'soup'
        style = soup.find_all('p')
        i = i + 1
        num = num + 1
        for y in style:                                                                                                     #takes all the syle attributes and text and sorts them per their position on the page
            temp = y['style']
            list = temp.split(';')
            #vert_pos = ((list[4].replace("top:", "")).replace("pt", ""))
            y_pos.append(int((list[0].replace("top:", "")).replace("pt", "")))
            test_text.append(y.text.strip().replace(" 0", "0"))
            #if i == 0:
            #    vert_posTemp = (list[4].replace("top:", "")).replace("pt", "")                                             #Unsorted Raw data used from PDF to obtain LEP (**Current problem is PDF reading direction changes)
            #    text[i] = y.text.strip().replace(" 0", "0")
            #    i = i + 1
            #elif int(vert_pos) in range(int(vert_posTemp) - 2, int(vert_posTemp) + 2):
            #    vert_posTemp = vert_pos
            #    text[i] = text[i] + " " + y.text.strip().replace(" 0", "0")
            #elif y.text.strip() == "LIST OF EFFECTIVE PAGES" or y.text.strip() == "LIST OF EFFECTIVE PAGES (Cont)":
            #    text.append("###PAGE LEP-" + str(num) + "###")
            #    break
            #else:
            #    vert_posTemp = vert_pos
            #    text.append(y.text.strip().replace(" 0", "0"))
            #    i = i + 1

        df = PD.DataFrame({'Position': y_pos,                                                                               #Does the same thing as the code above but in a more organized method using pandas 'Dataframes'
                           'Text': test_text})
        for index, row in df.iterrows():
            para = row['Text'].strip().replace("  ", " ")
            para = re.sub(Weird_space, "", para)
            if count == 0:
                posTemp = row['Position']
                text[k] = para
                k = k + 1
            elif row['Position'] in range(posTemp-2, posTemp+2):
                text[k] = text[k] + " " + para
                posTemp = row['Position']
            else:
                text.append(para)
                posTemp = row['Position']
                k = k + 1
            count = count + 1
        y_pos = []          #Re-initializing the lists as it is being appended
        test_text = []

    #for z in text:      #For Testing
    #     #    print(z)

    jip[directory.name].log_print("Getting Pages and Dates From Body...")
    for x in range(0, len(doc)):
        Dlist = doc[x].getDisplayList()
        Text_pages_full.append(Dlist.getTextPage())

    for x in Text_pages_full:                                                                                               #Gets the text from each specified display list
        rev = 0
        pdf_page = pdf_page + 1
        HTML = x.extractHTML()
        soup = BS(HTML, "lxml")                                                                                             #Creates a formatted html block called 'soup'
        style = soup.find_all('p')
        page = doc[int(pdf_page)-1]
        rev = page.searchFor("_r_e_v")

        errorD = 0  # Check if page number and dates exist on page
        errorP = 0
        for y in style:                                                                                                     #This gets all the page numbers and their respective dates
            temp = y['style']
            list = temp.split(';')
            para = y.text.strip().replace(" 0", "0").replace("  ", " ")
            para = re.sub(Weird_space, "", para)
            vert_pos = int(((list[0].replace("top:", "")).replace("pt", "")))
            if vert_pos > 710:
                #print(para + " " + str(vert_pos))          #For Testing
                Found_page = re.search('Page', para)
                if Found_page:
                    errorP = 1
                    page_num.append(str(pdf_page) + "," + para)
                Found_date = re.search(reg_date, para)
                Found_dateATA100 = re.search(reg_dateATA100, para)
                if Found_date or Found_dateATA100:
                    errorD = 1
                    date.append(str(pdf_page) + "," + para)
                    break
        if errorD == 0:
            foldout = (re.search('/', page_num[len(page_num)-1]))
            if not foldout:
                comment = "There is an error on/after PDF Page " + page_num[len(page_num)-1] + ". There is no date\n"
                print(comment)
                page = doc[0]
                rect = [fitz.Rect(300, 0, 0, 0)]
                PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
                date.append("NO DATE FOUND")
                error_code[1] = 1  #
                error_code[51] = error_code[51] + 1  #
        elif errorP == 0:
            comment = "There is an error after PDF Page " + page_num[len(page_num)-1] + ". There is no page number\n"
            print(comment)
            page = doc[0]
            rect = [fitz.Rect(300, 0, 0, 0)]
            PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
            page_num.append('NO PAGE NUMBER FOUND')
            error_code[1] = 1  #
            error_code[52] = error_code[52] + 1  #

        if rev == []:
            page_num[len(page_num)-1] = page_num[len(page_num)-1] + ",0"
        else:
            new_print = new_print + 1                                                                                       #Both check if it is a new print but also counts the number of instances the 'rev tags are used in the xml)
            page_num[len(page_num)-1] = page_num[len(page_num)-1] + ",1"


    ##EXTRA CHECK (IF LAST PAGE IS AN EVEN PAGE)
    last_page = page_num[len(page_num)-1].split(",")[1]
    last_page = last_page.replace("Page ", "").replace("Pages", "").strip()
    jip[directory.name].log_print(last_page)
    try:
        if int(last_page) % 2 != 0:
            comment = "Page ends on a odd page, it should end on an even page"
            jip[directory.name].log_print(comment + " , Last Page is " + last_page)
            page = doc[len(doc)-1]
            rect = [fitz.Rect(300, 0, 0, 0)]
            PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
            error_code[12] = 1  #
            error_code[60] = error_code[60] + 1  #
    except:
        comment = "The last page is a foldout, it should be a blank page"
        page = doc[len(doc) - 1]
        rect = [fitz.Rect(300, 0, 0, 0)]
        PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
        error_code[12] = 1  #
        error_code[60] = error_code[60] + 1  #
        jip[directory.name].log_print(comment)

    ###Check consistency between LEP and Body of the document###
    if len(page_num) != len(date):                                                                                          #Logically should have been covered and is not supposed to occur
        jip[directory.name].log_print("ERROR 100: MISMATCH IN PAGE NUMBERS AND DATES")

    #for x in page_num:
    #    print(x)

    jip[directory.name].log_print("\nCommencing First LEP Check...")
    for x in range(0, len(page_num)):                                                                                   #Checks if all body pages are found in the LEP (1st check)
        countW = 0
        i = 0
        ignoredate = 0
        R1 = int(page_num[x].split(",")[2])
        PDF_PAGES = page_num[x].split(",")[0]
        try:
            temp_splitD = date[x].split(",")[1].strip()
        except IndexError:
            ignoredate = 1
        for y in text:
            if page_num[x] == "NO PAGE NUMBER FOUND":
                break
            temp_split = page_num[x].split(",")[1].replace("Page ", "").replace("Pages", "").strip()
            pages = re.sub(reg_date, "", y).strip()
            pages = re.sub(reg_dateATA100, "", pages).strip()
            found = fuzz.partial_ratio(temp_split, pages)
            foundDate = fuzz.partial_ratio(temp_splitD, y)
            foundREV = re.search('\*', y)
            mult_digits = re.search('[0-9]{3,5}', pages)
            found_ata = re.search(ATA, pages)
            if found_ata:
                pass
            elif found >= 95:                                                                                               #Check for page numbers throughout the LEP to see if it exists
                if mult_digits:
                    if len(temp_split) < len(mult_digits.group()):
                        pass
                    else:
                        jip[directory.name].log_print("PAGE: " + pages + " MATCH FOUND IN PDF!!@@@")
                        if ignoredate != 1:
                            if foundDate >= 95:
                                jip[directory.name].log_print("Date is correct")
                            elif int(page_num[x].split(",")[0]) == 1:
                                pass
                            else:
                                commentD = 'Date mismatch between Page and LEP'
                                page = doc[int(page_num[x].split(',')[0])-1]
                                rect = [fitz.Rect(526, 737, 549, 751)]
                                PE.TextAnnot_Once(page, rect, commentD, "LEP CHECKER")
                                jip[directory.name].log_print('Date is incorrect')
                                error_code[1] = 1  #
                                error_code[53] = error_code[53] + 1  #
                        if new_print != 0:
                            if foundREV and R1 == 0:
                                comment = "Remove Asterisks from LEP: There is no revision bar on PDF page " + PDF_PAGES \
                                          + ", Page " + temp_split
                                page = doc[LEPpages[0]]
                                rect = [fitz.Rect(300, 0, 0, 0)]
                                PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
                                jip[directory.name].log_print(comment)
                                error_code[1] = 1  #
                                error_code[54] = error_code[54] + 1  #
                            elif not foundREV and R1 == 1:
                                comment = "Missing Asterisk on LEP: There is a revision bar on PDF page " + PDF_PAGES \
                                          + ", Page " + temp_split
                                page = doc[int(PDF_PAGES)-1]
                                rect = [fitz.Rect(300, 0, 0, 0)]
                                PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
                                jip[directory.name].log_print(comment)
                                error_code[1] = 1  #
                                error_code[54] = error_code[54] + 1  #
                        text.remove(y)
                        jip[directory.name].log_print("Deleted: " + y)
                        jip[directory.name].log_print(temp_split)
                        countW = countW + 1
                        break
                elif len(pages) < len(temp_split):
                    pass
                else:
                    jip[directory.name].log_print("PAGE: " + pages + " MATCH FOUND IN PDF!!")
                    if foundDate >= 95:
                        jip[directory.name].log_print("Date is correct")
                    elif int(page_num[x].split(",")[0]) == 1:
                        pass
                    else:
                        commentD = 'Date mismatch between Page and LEP'
                        page = doc[int(page_num[x].split(',')[0])-1]
                        rect = [fitz.Rect(526, 737, 549, 751)]
                        PE.TextAnnot_Once(page, rect, commentD, "LEP CHECKER")
                        jip[directory.name].log_print('Date is incorrect')
                        error_code[1] = 1  #
                        error_code[53] = error_code[53] + 1  #
                    text.remove(y)
                    jip[directory.name].log_print("Deleted: " + y)
                    jip[directory.name].log_print(temp_split)
                    countW = countW + 1
                    break
            i = i + 1
        if countW == 0:
            comment = "Page: " + temp_split + " Match Not Found in LEP (Either Does Not Exist Or is a Duplicate)"
            jip[directory.name].log_print(comment)
            page = doc[int(page_num[x].split(',')[0])-1]
            rect = [fitz.Rect(300, 0, 0, 0)]
            PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
            error_code[1] = 1  #
            error_code[55] = error_code[55] + 1  #

    jip[directory.name].log_print("\nCommencing Second LEP Check...")
    for x in text:                                                                                                          #2nd Check (Checks if the remainder pages in the LEP exists in the body) **Does not do a date check as it is mostly checking pages that don't exist
        countW = 0
        countD = 0
        pages = re.sub(reg_date, "", x).strip()
        pages = (re.sub(reg_dateATA100, "", pages).strip()).replace("Page", "").replace('*', "").strip()
        f1 = re.search(Digits, pages)
        f2 = re.search(Intro, pages)
        foundREV = re.search('\*', x)
        if f1 or f2 or len(pages) == 1:
            for y in range(0, len(page_num)):
                temp_split = page_num[y].split(",")[1].replace("Page ", "").replace("Pages", "").strip()
                found = fuzz.partial_ratio(temp_split, pages)
                if len(temp_split) != len(pages):
                    pass
                elif found >= 95:
                    jip[directory.name].log_print("PAGE: " + pages + " MATCH FOUND IN PDF!!")
                    text.remove(x)
                    jip[directory.name].log_print(temp_split)
                    countW = countW + 1
                    break
            if countW == 0:
                comment = "Page: " + pages + " Match Not Found in PDF (Either Does Not Exist Or is a Duplicate)"
                jip[directory.name].log_print(comment)
                page = doc[LEPpages[0]]
                rect = [fitz.Rect(526, 737, 549, 751)]
                PE.TextAnnot_Once(page, rect, comment, "LEP CHECKER")
                text.remove(x)
                error_code[1] = 1  #
                error_code[55] = error_code[55] + 1  #

    return doc, error_code
