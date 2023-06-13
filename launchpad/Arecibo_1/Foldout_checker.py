#  © 2019 Sonovision Canada Inc. All rights reserved.
#  This program/application and all related content are the copyright of Sonovision Canada Inc. Unless expressly permitted, you may not
#  modify, copy, distribute, transmit, store, publicly display, perform, reproduce, publish, license, create derivative works from, transfer or sell
#  any information, software products or services, in whole or in part, obtained from the program/application and its contents without prior
#  written consent from Sonovision Canada Inc.
#
#  -------------------
#  Last Modified: 2019-11-04, 9:46 a.m.
#  By: smainuddin
#


import fitz
import re

from bs4 import BeautifulSoup as BS
try:
    import launchpad.Arecibo_1.PDF_Edit_MODIFIED as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit_MODIFIED as PE
    from ar_interface import jobs_in_progress as jip


def main(doc, error_code, directory):
    ###Variable Declaration###
    Text_Pages = []
    page_num = []
    pdf_page = 0
    blank = 0
    count = 0

    reg_page2 = re.compile("Page[s]{0,3} [0-9]{4,5}/[0-9]{4,5}")  #Regular pages
    reg_pageA100 = re.compile("Page[s]{0,3} [0-9]{1,3}/[0-9]{1,3}")  #ATA 100 pages
    Weird_space = re.compile('(?<=[0-9]) (?<![0-9])(?=[0-9])')
    ATA = re.compile('[0-9]{2}-[0-9]{2}-[0-9]{2}')

    ###MAIN CODE###
    for x in range(0, len(doc)):
        Dlist = doc[x].getDisplayList()
        Text_Pages.append(Dlist.getTextPage())

    for x in Text_Pages:
        pdf_page = pdf_page + 1
        y_pos = []      #Resets the variable after each page, so data is a bit more manageable
        x_pos = []
        test_text = []
        HTML = x.extractHTML()
        #for y in HTML.strip().splitlines():
        #    print(y)

        soup = BS(HTML, "lxml")                                                                                             #Creates a formatted html block called 'soup'
        style = soup.find_all('p')
        for y in style:                                                                                                     #This gets all the page numbers and their respective dates
            temp = y['style']
            list = temp.split(';')
            para = y.text.strip().replace(" 0", "0").replace("  ", " ")
            para = re.sub(Weird_space, "", para)
            vert_pos = int(((list[0].replace("top:", "")).replace("pt", "")))
            if vert_pos > 710:
                Found_page = re.search(reg_page2, para)
                Found_page2 = re.search(reg_pageA100, para)
                if Found_page or Found_page2:
                    blank = 1
                    page_num.append(str(pdf_page) + "," + para)
                if blank == 1:
                    page = doc[pdf_page]
                    rect = page.searchFor("Page")
                    if rect != []:
                        comment = "Foldouts require blank pages after them, it is missing after " + para
                        jip[directory.name].log_print(comment)
                        page = doc[pdf_page-1]
                        rect = [fitz.Rect(300, 0, 0, 0)]
                        PE.TextAnnot(page, rect, comment, "FOLDOUT CHECKER")
                        error_code[12] = 1  #
                        error_code[58] = error_code[58] + 1  #
                    blank = 0
    for y in page_num:
        #print(y)    #For Testing
        count = count + 1
        page = y.split(',')
        temp = page[1].split('/')
        check = temp[0].replace("Page ", "").replace("Pages ", "")
        if int(check) % 2 == 0:
            comment = "The first page of a foldout should be an odd number"
            jip[directory.name].log_print(comment)
            page = doc[int(y.split(",")[0])]
            rect = page.searchFor("Page ")
            PE.TextAnnot(page, rect, comment, "FOLDOUT CHECKER")
            error_code[12] = 1  #
            error_code[59] = error_code[59] + 1  #
    return doc, error_code
