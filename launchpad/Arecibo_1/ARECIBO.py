import re
import glob
import fitz
import datetime
import getpass
try:
    import launchpad.Arecibo_1.TR_QA as TR_QA
    import launchpad.Arecibo_1.PDF_Edit as PDF_Edit
    import launchpad.Arecibo_1.General_QA as GQ
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import TR_QA as TR_QA
    import PDF_Edit as PDF_Edit
    import General_QA as GQ
    from ar_interface import jobs_in_progress as jip





def main(doc, Name, error_code, job, CR_info, type1, has_D, directory):

    if type1 == '3':
        type1 = '2'
    ### Calling and Initilizing Documents Required
    counter = 0
    buffer = 0
    page = doc[0]
    Dlist = doc[0].getDisplayList()
    Textpage = Dlist.getTextPage()
    wlist = page.getTextWords()

    #Front Matter
    pubnum = has_D # Does the source CMM for the TR have a D number as the Publication number?
    # try:
    #     job, pubnum = user_input(Name, CR_info[6], CR_info[7], job, type1)                             # User input function, returns the job number and type of document
    # except IndexError:
    #     job, pubnum = user_input(Name, CR_info[6], "0", job, type1)
    count = 0

    ### This applies to SB and CMM
    if type1 == "2":
        rect = Textpage.search(str(CR_info[0]))
        if rect == []:
            rect = page.searchFor("ECCN", 1, False)
            PDF_Edit.highlight(page, rect, "ECCN is incorrect or missing")
            error_code[18] = 1
            error_code[21] = error_code[21] + 1
        
        rect = Textpage.search(str(CR_info[1]))
        ata = str(CR_info[1])
        if rect == []:
            rect = [fitz.Rect(300, 0, 0, 0)]
            PDF_Edit.TextAnnot(page, rect, "ATA number is incorrect or Missing")
            error_code[18] = 1
            error_code[31] = error_code[31] + 1
        
        rect = Textpage.search(str(CR_info[2]))
        if str(CR_info[2]) == ata:
            if len(rect) < 2:
                rect = page.searchFor("Publication", 1, False)
                PDF_Edit.highlight(page, rect, "Publication Number is incorrect or Missing")
                error_code[18] = 1
                error_code[22] = error_code[22] + 1
        else:
            if rect == []:
                rect = page.searchFor("Publication", 1, False)
                PDF_Edit.highlight(page, rect, "Publication Number is incorrect or Missing")
                error_code[18] = 1
                error_code[22] = error_code[22] + 1


        rect = Textpage.search(str(CR_info[3]))
        if rect == []:
            rect = Textpage.search("BULLETIN", 1, False)
            PDF_Edit.TextAnnot(page, rect, "Title is incorrect")                                                        #Need to change type of annotation here
            error_code[18] = 1
            error_code[21] = error_code[21] + 1

        rect = Textpage.search(str(CR_info[4]), 1, False)
        if rect == []:
            rect = page.searchFor("ECCN", 1, False)
            PDF_Edit.highlight(page, rect, "ECCN is incorrect or Missing")
            error_code[18] = 1
            error_code[20] = error_code[20] + 1

        if job == "519":
            rect = page.searchFor("YYYY")
            if rect == []:
                rect = page.searchFor("Page", 1, False)
                PDF_Edit.TextAnnot(page, rect, "A general note (may not need action) "
                                               "519 jobs do not require a revision date")
                error_code[18] = 1
                error_code[23] = error_code[23] + 1
        else:
            rect = Textpage.search(str(CR_info[5]))
            if rect == []:
                rect = page.searchFor("Page", 1, False)
                PDF_Edit.TextAnnot(page, rect, "Date is incorrect or Missing it should be " + str(CR_info[5]))
                error_code[18] = 1
                error_code[23] = error_code[23] + 1

        GQ.General_QA(doc, job, error_code, directory)
    elif type1.lower() == "1":
        #Initialize Checklist
        error_code[0] = '-'
        error_code[1] = '-'
        error_code[4] = '-'
        error_code[5] = '-'
        error_code[6] = '-'
        error_code[9] = '-'

        for x in CR_info:
            rect = page.searchFor(x)
            if count == 0:
                pass
            if count == 1:                                                                                                  # This will look through the first page for 2 specific matches of the ATA one on the header other in footer.
                for y in wlist:
                    if buffer == 1:
                        if y[4].lower() == "revision" or y[4].lower() == "page":                                            # Checks the next word for either "revision" or "page" this determines whether this the footer or header
                            counter = counter + 1
                            buffer = 0
                    if y[4].replace(",", "") == x:
                        buffer = buffer + 1
                if counter < 2 or len(rect) < 2:
                    rect = page.searchFor("temporary", 1, False)
                    PDF_Edit.TextAnnot(page, rect, "ATA number is missing or incorrect in either the header or footer")
                    error_code[18] = 1
                    error_code[31] = error_code[31] + 1
            if count == 2:
                if pubnum == 0:
                    pass
                else:
                    if rect == []:
                        rect = page.searchFor("TEMPORARY", 1, False)
                        PDF_Edit.TextAnnot(page, rect, "Publication Number is incorrect or Missing")
                        error_code[18] = 1
                        error_code[22] = error_code[22] + 1
            if count == 3:
                pass
            if count == 4:
                ECCNPage = 0
                e_control = PDF_Edit.searchPDF(doc, "export control")
                ECCNPage = doc[e_control[0] - 1]
                rect = ECCNPage.searchFor(x)
                if rect == []:
                    rect = ECCNPage.searchFor("ECCN", 1, False)
                    PDF_Edit.highlight(ECCNPage, rect, "ECCN is incorrect or Missing")
                    error_code[18] = 1
                    error_code[20] = error_code[20] + 1
            if count == 5:
                if job == "519":
                    rect = page.searchFor("YYYY")
                    if rect == []:
                        rect = page.searchFor("Page", 1, False)
                        PDF_Edit.TextAnnot(page, rect, "Date is incorrect or Missing for 519 it should be DD Mmm YYYY")
                        error_code[18] = 1
                        error_code[23] = error_code[23] + 1
                else:
                    rect = page.searchFor(str(CR_info[5]))
                    if rect == []:
                        rect = page.searchFor("Page", 1, False)
                        PDF_Edit.TextAnnot(page, rect,
                                           "Date is incorrect or Missing it should be " + str(CR_info[5]))
                        error_code[18] = 1
                        error_code[23] = error_code[23] + 1
            count = count + 1


    #APPLIERS TO ALL
        checks_517 = 0
        checks_CFE = 0
        pages = PDF_Edit.searchPDF(doc, "Export")
        page = doc[pages[0]-1]
        wlist = page.getTextWords()

        for x in wlist:
            if x[4].lower() == "canadian":
                checks_517 = 1
        if job == "517" or job == "521":
            if checks_517 == 0:
                rect = page.searchFor("Export", 1, False)
                PDF_Edit.TextAnnot(page, rect, "Export statement is incorrect for the job, should have Canada included")
                error_code[13] = 1
                error_code[27] = error_code[27] + 1
        if job != "517" and job != "521":
            if checks_517 == 1:
                rect = page.searchFor("Export", 1, False)
                PDF_Edit.TextAnnot(page, rect, "Export statement is incorrect for the job, should not have Canada included")
                error_code[13] = 1
                error_code[27] = error_code[27] + 1

    #TR QA CODE MODULE
    if type1 == "1":
        error_code = TR_QA.TR_QAMain(doc, job, error_code, directory)                                                              # TR Checking module
    #SB QA CODE MODULE
    if type1 == "2":
        pass

    return doc, error_code