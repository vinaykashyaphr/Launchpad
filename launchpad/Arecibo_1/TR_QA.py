#  © 2019 Sonovision Canada Inc. All rights reserved.
#  This program/application and all related content are the copyright of Sonovision Canada Inc. Unless expressly permitted, you may not
#  modify, copy, distribute, transmit, store, publicly display, perform, reproduce, publish, license, create derivative works from, transfer or sell
#  any information, software products or services, in whole or in part, obtained from the program/application and its contents without prior
#  written consent from Sonovision Canada Inc.
#
#  -------------------
#  Last Modified: 2019-05-31, 11:45 a.m.
#  By: smainuddin
#

import fitz
import re
import datetime
try:
    import launchpad.Arecibo_1.PDF_Edit as PDF_Edit
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit as PDF_Edit
    from ar_interface import jobs_in_progress as jip


def TR_QA(doc, directory):                                                                                                         # TR QA Module

### Variable declarations
    jip[directory.name].log_print("Checking the Page Reference Table....")
    text = [0]
    location = [0]
    i = 0
    page = doc[i]
    wlist = page.getTextWords()                                                                                         # Gets the list of words from the PDF on the page required
    num = len(wlist)
    npage = 0
    for x in range(num):
        if wlist[x][4] =="REVISION":
            if wlist[x+1][4] == "NO.":
                TR_NUM = wlist[x+2][4]
        if (wlist[x][4]).lower() == "page":
            if (wlist[x+1][4].lower()) == "number":                                                                     # Searches for the placement of "Page Number" in the PDF to find the TR number and pages with.
                break
    y = x + 3
    i = 0
    reset = 0
    pagenum = [0]*len(doc)
### Procedural Code Starts here

    # check = wlist[x+3][4]                                                                                             # This will be used to check the format of the page reference (Can be deleted, use as example)
    # LMM = re.search("[0-9][0-9]-[0-9][0-9]-[0-9][0-9]", check)
    # MM = re.search("[a-zA-Z]", check)
    # if (LMM):
    #     iterate = 3
    # elif (MM):
    #     iterate = 3
    # else:
    #     iterate = 1

    while (y <= num-1):
        if wlist[y][4].lower() == "export":                                                                             # Thsese are some loop break conditions, it will make it so that it will stop reading at the end of the table
            break                                                                                                       #
        if wlist[y][4].lower() == "page":                                                                               # This skips the word 'page', This make comparison easier as page is the most inconsistent word in these references
            y = y + 1                                                                                                   #
        if wlist[y][4].strip() == TR_NUM.strip():                                                                       # Accounts for special case scenario in which the TR number is repeated when the page table spans more than one page
            y = y + 1
        try:
            if reset == 0:                                                                                              #
                text[i] = wlist[y][4]                                                                                   #
                location[i] = wlist[y]                                                                                  #
                pagenum[i] = npage                                                                                      #
                reset = reset + 1                                                                                       #
            else:
                text[i] = text[i] + " " + wlist[y][4]
        except IndexError:
            jip[directory.name].log_print("IndexError: Comments or Watermarks need to removed from document")

        try:
            if int(wlist[y][3]) != int(wlist[y+1][3]):                                                                  # Checks Y coordinate of current word and next word to see if words are one the same line
                i = i + 1
                text.append(" ")
                location.append(0)
                reset = 0
        except IndexError:
            jip[directory.name].log_print("IndexError: Comments or Watermarks need to removed from document")                                   # **Need to write error log**
        if y == num - 2:
            text[i] = text[i] + " " + wlist[num-1][4]
            location[i] = wlist[num-1]
            npage = npage + 1
            page = doc[npage]
            wlist = page.getTextWords()
            num = len(wlist)
            for x in range(num):
                if (wlist[x][4]).lower() == "page":
                    if (wlist[x + 1][4].lower()) == "number":                                                           # Searches for the placement of "Page Number" in the PDF to find the TR number and pages with.
                        break
            y = x + 1
            i = i + 1
            text.append(" ")
            reset = 0
            location.append(0)

        # check = (wlist[y+3][4]).lower()
        # condBreak = re.search("export|control|these|items", check)
        # if condBreak:
        #     break
        # condExt = ("[0-9][0-9]-[0-9][0-9]-[0-9][0-9]", check)
        # if (condExt):
        #     if ((wlist[y+4][4]).lower()) == "description":
        #         iterate = 5
        # if (wlist[y][4]).lower() != "export":
        #     if (iterate == 3):                                                                                        Use this code for searching through document
        #         text.append((wlist[y + 3][4] + " " + wlist[y + 4][4] + " " + wlist[y + 5][4]))
        #         location.append(wlist[y + 3])
        #         y = y + 2
        #     elif (iterate == 5):
        #         text.append((wlist[y + 3][4] + " " + wlist[y + 4][4] + " " + wlist[y + 5][4] + " " +
        #                      wlist[y + 6][4] + " " + wlist[y + 7][4]))
        #         location.append(wlist[y + 3])
        #         iterate = 3
        #         y = y+4
        #     elif (iterate == 1):
        #         text.append(wlist[y + 3][4])
        #         location.append(wlist[y + 3])
        # elif y == num:
        #     i = i + 1
        #     page = doc[i]
        #     wlist = page.getTextWords()
        y = y + 1
    return text, location, pagenum


###############################################
def TR_QA2(doc, error_code, directory):                                                                                            # Matches the page numbers in the body of the TR
    jip[directory.name].log_print("Checking the Body....")
    text = [0]
    location = [0]
    pages = [0]
    i = 0
    reset = 0
    TR_list = []
    TR_Page = []
    for x in range(len(doc)):
        page = doc[x]
        wlist = page.getTextWords()
        num = len(wlist)
        for y in range(num):
            if (wlist[y][4]) == "FACING" or (wlist[y][4]) == "FOLLOWING" and (wlist[y+1][4]) == "PAGE":                 # This is a better loop than the one commented out to accomplish task of finding page numbers
                found = y + 1
                if i == 0:
                    location[0] = wlist[y+1]
                    pages[0] = x
                else:
                    location.append(wlist[y+1])
                    pages.append(x)
                for counter in range(found, num):
                    if int(wlist[y][3]) != int(wlist[counter][3]):
                        reset = 0
                        i = i + 1
                        text.append(" ")
                        break
                    if (wlist[counter][4]) != "PAGE" and (wlist[counter][4]) != "PAGES":
                        if reset == 0:
                            text[i] = wlist[counter][4]
                            reset = reset + 1
                        else:
                            text[i] = text[i] + " " + wlist[counter][4]

                test = wlist[y+1][4].replace(",", "")
                ATAfound = re.search("[0-9][0-9]-[0-9][0-9]-[0-9][0-9]", test)
                if (ATAfound):
                    rect = page.searchFor(test)
                    if len(rect) < 2:
                        PDF_Edit.highlight(page, rect, "This ATA does not match the ATA on the page")
                        error_code[14] = 1
                        error_code[24] = error_code[24] + 1

            if (wlist[y][4]) == "replace":                                                                              # Checks through document for all replace TR statements and returns TR number and page
                if wlist[y+1][4] == "TR":
                    TR_list.append(wlist[y+2])
                    TR_Page.append(x)

                    # check = wlist[y+1][4]
                    # LMM = re.search("[0-9][0-9]-[0-9][0-9]-[0-9][0-9]", check)
                    # MM = re.search("[a-zA-OQ-Z]", check)
                    # CMM = re.search("PAGE", check)
                    # if (LMM):
                    #     if (wlist[y+2][4]).lower() == "description":
                    #         text.append((wlist[y + 1][4] + " " + wlist[y + 2][4] + " " + wlist[y + 3][4] + " " +
                    #                      wlist[y + 4][4] + " " + wlist[y + 6][4]))
                    #         location.append(wlist[y + 1])
                    #     else:
                    #         text.append(wlist[y+1][4] + " " + wlist[y+2][4] + " " + wlist[y+4][4])
                    #         location.append(wlist[y + 1])
                    # elif (CMM):
                    #     text.append((wlist[y+2][4]))
                    #     location.append(wlist[y + 2])
                    # elif (MM):
                    #     text.append(wlist[y + 1][4] + " " + wlist[y + 2][4] + " " + wlist[y + 3][4])
                    #     location.append(wlist[y + 1])
    return text, location, TR_list, TR_Page, pages, error_code



def TR_Searchterms(doc, job, error_code, directory):
    jip[directory.name].log_print("Searching for Grammatical and Template Errors...")
### Variable Declaration
    mat = 0
    page = doc[0]
    wlist = page.getTextWords()
    x = 0
    found = 0
    tNum = "AllFor1"

### Process
    while x <= len(wlist)-1:                                                                                            # This loop is used to find the TR number and then to see whether 2 instances of it exists in the first page.
        if wlist[x][4] == "REVISION":
            if (wlist[x+1][4]) == "NO.":
                tNum = wlist[x + 2]
        test = tNum[4].replace("-", "")
        numbers = re.search("^[0-9][0-9]+$", test)
        if wlist[x][4] == tNum[4]:
            found = found + 1
        x = x + 1
    if numbers:
        if found != 2:
            term = tNum[4]
            rect = page.searchFor(term)
            PDF_Edit.highlight(page, rect, "The TR number is not matching in the table it should be " + term)
            error_code[14] = 1
            error_code[25] = error_code[25] + 1
    else:
        rect = page.searchFor("temporary revision no.")
        PDF_Edit.highlight(page, rect, "The TR number should be all integers")
        error_code[14] = 1
        error_code[25] = error_code[25] + 1

    copyPage = PDF_Edit.searchPDF(doc, "Copyright")                                                                     # Uses the created search function to provide the page number of the copyright section **CHECK FOR CONSISTENCY**
    page = doc[copyPage[0]-1]
    wlist = page.getTextWords()
    x = 0
    Ydate = datetime.datetime.now()
    Ydate2 = Ydate.strftime("%Y")
    while x <= len(wlist)-1:                                                                                            #loops the page to find the placement of the year and checks if it is current year
        if wlist[x][4] == "Copyright":
            if wlist[x+1][4] != Ydate2 and wlist[x+1][4] != "-":
                Year = wlist[x+1]
                r = fitz.Rect(Year[:4])
                markup = page.addHighlightAnnot(r)
                info = markup.info
                info["title"] = "ARECIBO says"
                info["content"] = "The year is incorrect it should say " + Ydate2                                       # This adds the comment and Author to the program
                markup.setInfo(info)
                error_code[14] = 1
                error_code[30] = error_code[30] + 1
        x = x + 1
        break

    for x in range(len(doc)):                                                                                          # Go through the document and find random grammtical errors
        cPage = doc[x]
        if x > 0:
            wlist = cPage.getTextWords()
            for wordcount in range(len(wlist)):
                if wlist[wordcount][4] == "Service":
                    if wlist[wordcount+1][4] == "Bulletin" or wlist[wordcount+1][4] == "bulletin":
                        check = wlist[wordcount+2][4]
                        SBNum = re.search("[0-9].-", check)
                        if (SBNum):
                            service = wlist[wordcount+2]
                            r = fitz.Rect(service[:4])
                            markup = cPage.addHighlightAnnot(r)
                            info = markup.info
                            info["title"] = "Service Bulletin"
                            info[
                                "content"] = "It should be SB when referencing the service bulletin ATA"
                            markup.setInfo(info)
                            error_code[18] = 1
                            error_code[24] = error_code[24] + 1
                        else:
                            service = wlist[wordcount]
                            r = fitz.Rect(service[:4])
                            markup = cPage.addHighlightAnnot(r)
                            info = markup.info
                            info["title"] = "Service Bulletin"
                            info[
                                "content"] = "Service bulletin is written lowercase"                                    # This adds the comment and Author to the program
                            markup.setInfo(info)
                            error_code[18] = 1
                            error_code[24] = error_code[24] + 1
                            
        cond, nummat, condition = PDF_Edit.searchPAGE(doc, x, "....", 1)
        cond2,nummat, condition = PDF_Edit.searchPAGE(doc, x, "1234567", 1)
        if cond == 0 and cond2 == 0:
            mat, nummat, period = PDF_Edit.searchPAGE(doc, x, "..", 1)                                                  #
            PDF_Edit.highlight(cPage, period, "Double periods remove")                                                  #
            if mat != 0:                                                                                                #
                for j in range(int(mat/2)):                                                                             #
                    error_code[15] = 1                                                                                  #
                    error_code[35] = error_code[35] + 1                                                                 #
            mat = 0                                                                                                     #
            mat, nummat, spaceper = PDF_Edit.searchPAGE(doc, x, " .", 1)                                                #
            PDF_Edit.highlight(cPage, spaceper, "Remove space")                                                         #
            if mat != 0:                                                                                                #
                for j in range(int(mat/2)):                                                                             #
                    error_code[15] = 1                                                                                  #
                    error_code[37] = error_code[37] + 1                                                                 #
            mat = 0                                                                                                     #
        mat, nummat, spacecom = PDF_Edit.searchPAGE(doc, x, " ,", 1)                                                    # I think this could be it's own module that we could use for all documents (this portion or the entire function.
        PDF_Edit.highlight(cPage, spacecom, "Remove space")                                                             #
        if mat != 0:                                                                                                    #
            for j in range(int(mat/2)):                                                                                 #
                error_code[15] = 1                                                                                      #
                error_code[38] = error_code[38] + 1                                                                     #
        mat = 0                                                                                                         #
        mat, nummat, semi = PDF_Edit.searchPAGE(doc, x, " :", 1)                                                        #
        PDF_Edit.highlight(cPage, semi, "Remove space")                                                                 #
        if mat != 0:                                                                                                    #
            for j in range(int(mat/2)):                                                                                 #
                error_code[15] = 1                                                                                      #
                error_code[39] = error_code[39] + 1                                                                     #
        mat = 0                                                                                                         #
        mat, nummat, spbrack = PDF_Edit.searchPAGE(doc, x, " )", 1)                                                     #
        PDF_Edit.highlight(cPage, spbrack, "Remove space")                                                              #
        if mat != 0:                                                                                                    #
            for j in range(int(mat/2)):                                                                                  #
               error_code[15] = 1                                                                                       #
               error_code[36] = error_code[36] + 1                                                                      #
        mat = 0                                                                                                         #
        mat, nummat, spbrackl = PDF_Edit.searchPAGE(doc, x, "( ", 1)                                                    #
        PDF_Edit.highlight(cPage, spbrackl, "Remove space")                                                             #
        if mat != 0:                                                                                                    #
            for j in range(int(mat/2)):                                                                                 #
                error_code[15] = 1                                                                                      #
                error_code[36] = error_code[36] + 1                                                                     #

        if job == "521":
            mat, nummat, International = PDF_Edit.searchPAGE(doc, x, "Honeywell International", 1)  #
            PDF_Edit.highlight(cPage, International, "Replace with Limited")
            if mat != 0:                                                                                                #
                for j in range(mat):                                                                                    #
                    error_code[14] = 1                                                                                  #
                    error_code[45] = error_code[45] + 1                                                                 #
            mat = 0                                                                                                     #
        if job != "521":
            mat, nummat, Limit = PDF_Edit.searchPAGE(doc, x, "Honeywell Limited", 1)  #
            PDF_Edit.highlight(cPage, Limit, "Replace with International Inc.")
            if mat != 0:                                                                                                #
                for j in range(mat):                                                                                    #
                    error_code[14] = 1                                                                                  #
                    error_code[45] = error_code[45] + 1                                                                 #
            mat = 0                                                                                                     #
        mat, nummat, International = PDF_Edit.searchPAGE(doc, x, "Allied", 1)#
        PDF_Edit.highlight(cPage, International, "Replace with Honeywell")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[44] = error_code[44] + 1  #

            mat = 0
        mat, nummat, Gauss = PDF_Edit.searchPAGE(doc, x, "10 Gauss", 1)                                                 # Gauss check
        PDF_Edit.highlight(cPage, Gauss, "According to \"Quality_Alert_Honeywell_09-25-18\" all 10 Gauss should be"
                                         "changed to 3 Gauss")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[46] = error_code[46] + 1  #

            mat = 0
        mat, nummat, VoWa = PDF_Edit.searchPAGE(doc, x, "Volts ", 1)                                                    # Gauss check
        PDF_Edit.highlight(cPage, VoWa, "According to the stylesheet Volts should be replaced with V "
                                        "but check consistency with CMM first")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[50] = error_code[50] + 1  #
            mat = 0

        mat, nummat, VoWa = PDF_Edit.searchPAGE(doc, x, "Watts ", 1)                                                    # Gauss check
        PDF_Edit.highlight(cPage, VoWa, "According to the stylesheet Watts should be replaced with W "
                                        "but check consistency with CMM first")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[50] = error_code[50] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "perform ", 1)  # Simplified English
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"do\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[68] = error_code[68] + 1  #
                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "ensure ", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"make sure\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[62] = error_code[62] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "accessible", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Get access to\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[52] = error_code[52] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "accuracy", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"precision\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[53] = error_code[53] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Aeroplane", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Aircraft\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[54] = error_code[54] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Analyze ", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Make an Analysis\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[55] = error_code[55] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Assign ", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"give\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[56] = error_code[56] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Authorize ", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"approve\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[57] = error_code[57] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Choose", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"use\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[58] = error_code[58] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Conform", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"agree\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[59] = error_code[59] + 1  #

                #    mat = 0
                # mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Duplicate ", 1)
                # PDF_Edit.highlight(cPage, simpeng, "Change to \"copy\" as per simplified english")
                # if mat != 0:  #
                #    for j in range(mat):  #
                #        error_code[14] = 1  #
                #        error_code[60] = error_code[60] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Eliminate", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"delete\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[61] = error_code[61] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Identical", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"same\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[63] = error_code[63] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Immerse", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"put fully into\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[64] = error_code[64] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Indicate", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"show\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[65] = error_code[65] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Penetrate", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"go into or go through\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[67] = error_code[67] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Remedy", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"repair or correct\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[69] = error_code[69] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Rotate", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"turn\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[70] = error_code[70] + 1  #

                mat = 0
            mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Significant", 1)
            PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"important\" as per simplified english")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[71] = error_code[71] + 1  #

        for x in range(len(doc)):  # Go through the document and find random grammatical errors
            cPage = doc[x]
            if x > 0:
                wlist = cPage.getTextWords()
                for wordcount in range(len(wlist)):
                    if wlist[wordcount][4] == "Service":
                        if wlist[wordcount + 1][4] == "Bulletin" or wlist[wordcount + 1][4] == "bulletin":
                            check = wlist[wordcount + 2][4]
                            SBNum = re.search("[0-9].-", check)
                            if (SBNum):
                                service = wlist[wordcount + 2]
                                r = fitz.Rect(service[:4])
                                markup = cPage.addHighlightAnnot(r)
                                info = markup.info
                                info["title"] = "Service Bulletin"
                                info[
                                    "content"] = "It should be SB when referencing the service bulletin ATA"
                                markup.setInfo(info)
                                error_code[18] = 1
                                error_code[24] = error_code[24] + 1
                            else:
                                service = wlist[wordcount]
                                r = fitz.Rect(service[:4])
                                markup = cPage.addHighlightAnnot(r)
                                info = markup.info
                                info["title"] = "Service Bulletin"
                                info[
                                    "content"] = "Service bulletin is written lowercase"  # This adds the comment and Author to the program
                                markup.setInfo(info)
                                error_code[18] = 1
                                error_code[24] = error_code[24] + 1
       #     mat = 0
       # mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Information", 1)
       # PDF_Edit.highlight(cPage, simpeng, "Change to \"data\" as per simplified english")
       # if mat != 0:  #
       #     for j in range(mat):  #
       #         error_code[14] = 1  #
       #         error_code[63] = error_code[63] + 1  #
#####################################################################################################                   # Use the job variable to create searches specific to job.
    checks_519 = 0
    checks_517 = 0
    pages = PDF_Edit.searchPDF(doc, "Confidential")
    page = doc[pages[0] - 1]
    wlist = page.getTextWords()

    for x in wlist:
        if x[4].lower() == "expression":
            checks_519 = 1
        if x[4].lower() == "limited":
            checks_517 = 1
    if job != "518" and job != "519":
        if checks_519 == 1:
            rect = page.searchFor("Confidential", 1, False)
            PDF_Edit.TextAnnot(page, rect, "Confidential statement is incorrect, it is currently for the "
                                           "518 and 519 jobs")
            error_code[14] = 1
            error_code[40] = error_code[40] + 1

    if job == "518" and job == "519":
        if checks_519 == 0:
            rect = page.searchFor("Confidential", 1, False)
            PDF_Edit.TextAnnot(page, rect, "Confidential statement is incorrect, use the one for 518 and 519")
            error_code[14] = 1
            error_code[40] = error_code[40] + 1

    if job != "517" and job != "521":
        if checks_517 != 0:
            rect = page.searchFor("Confidential", 1, False)
            PDF_Edit.TextAnnot(page, rect, "Change \"Honeywell Limited\" to \"Honeywell International\"")
            error_code[14] = 1
            error_code[40] = error_code[40] + 1

    return error_code

###############################################################
def TR_QAMain(doc, job, error_code, directory):
    jip[directory.name].log_print("Placing comments...")
    text, loc, pagenum = TR_QA(doc, directory)
    text2, loc2, TR_list, TR_page, pages, error_code = TR_QA2(doc, error_code, directory)
    #for x in text:
    #    print(x)
    #print("---------")
    #print("---------")
    #for y in text2:
    #   print(y)
    counter = 0
    lCount = 1
    for x in range(len(loc)):
        count = 0
        word2 = str(text[x]).replace(",", "").lower().strip()
        for word in text2:                                                                                     # loops through both sets of values (Table and Body) to se if they exist within each other (**need a loop for the reverse**)
            word = str(word)
            word = word[:-1].replace(",", "").lower().strip()
            #print("In Body: " + word)
            #print("         " + word2)
            #print("------------------------------")
            if word2 == word:
                #print("Found: " + word)
                #print("==========================")
                count += 1
                break
        if count == 0:
            location = str(loc[lCount-1])
            try:
                r = fitz.Rect(location[:4])
            except ValueError:
                r = fitz.Rect(0, 0, 10, 10) ## maybe not actually tr
            page = doc[pagenum[lCount-1]]
            markup = page.addHighlightAnnot(r)
            info = markup.info
            info["title"] = "ARECIBO says"
            info["content"] = f"{text[x]} is not referenced correctly in the body"                                      # These add the comment and Author to the program
            markup.setInfo(info)
            error_code[14] = 1
            error_code[26] = error_code[26] + 1
        lCount = lCount + 1

    lCount = 1                                                                                                          #Initilize counter
    for x in range(len(loc2)):                                                                                          # Reverse loop from the above to see if body references exists in table
        count = 0
        word2 = str(text2[x])
        word2 = word2[:-1].replace(",", "").lower().strip()
        for y in range(len(text)):
            word = str(text[y]).replace(",", "").lower().strip()
           #print("In Table: " + word)
           #print("         " + word2)
           #print("------------------------------")
            if word2 == word:
                #print("Found: " + word2 + " == " + word)
                #print("==========================")
                count = count + 1
                break
        if count == 0:
            location = str(loc2[lCount-1])
            try:
                r = fitz.Rect(location[:4])
            except ValueError:
                r = fitz.Rect(0, 0, 10, 10) ## maybe not actually tr
            page = doc[pages[x]]
            markup = page.addHighlightAnnot(r)
            info = markup.info
            info["title"] = "ARECIBO says"
            info["content"] = f"{text2[x]} is not referenced correctly on the title page"                               # These add the comment and Author to the program
            markup.setInfo(info)
            error_code[14] = 1
            error_code[26] = error_code[26] + 1
        lCount = lCount + 1

    page = doc[0]
    for x in TR_list:
        rect = page.searchFor(x[4])
        if rect == []:
            r = fitz.Rect(x[:4])
            Relpage = doc[TR_page[counter]]
            markup = Relpage.addHighlightAnnot(r)
            info = markup.info
            info["title"] = "ARECIBO says"
            info["content"] = "TR " + str(x[4]) + " is not referenced correctly on the title page"                           # These add the comment and Author to the program
            markup.setInfo(info)                                                                                        # **Currently does not account for line breaks**
            error_code[10] = 1
            error_code[41] = error_code[41] + 1
        counter = counter + 1



#############################                                                                                           # This function searches various elements that needs to be in the TR
    error_code = TR_Searchterms(doc, job, error_code, directory)
    return error_code


