import fitz
import re
import datetime
try:
    import launchpad.Arecibo_1.PDF_Edit as PDF_Edit
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except:
    import PDF_Edit as PDF_Edit
    from ar_interface import jobs_in_progress as jip

def General_QA(doc, job, error_code, directory):
    jip[directory.name].log_print("Checking Copyright...")
    copyPage = PDF_Edit.searchPDF(doc,
                                  "Copyright")  # Uses the created search function to provide the page number of the copyright section **CHECK FOR CONSISTENCY**
    page = doc[copyPage[0] - 1]
    wlist = page.getTextWords()
    x = 0
    Ydate = datetime.datetime.now()
    Ydate2 = Ydate.strftime("%Y")
    while x <= len(wlist) - 1:  # loops the page to find the placement of the year and checks if it is current year
        if wlist[x][4] == "Copyright":
            if wlist[x + 1][4] != Ydate2 and wlist[x + 1][4] != "-":
                Year = wlist[x + 1]
                r = fitz.Rect(Year[:4])
                markup = page.addHighlightAnnot(r)
                info = markup.info
                info["title"] = "ARECIBO says"
                info["content"] = "The year is incorrect it should say " + Ydate2  # This adds the comment and Author to the program
                markup.setInfo(info)
                error_code[14] = 1
                error_code[30] = error_code[30] + 1
        x = x + 1
        break

    #for x in range(len(doc)):  # Go through the document and find random grammatical errors                            #TEMPORARILY STRIKING THIS OUT (TOO MANY FALSE POSITIVES)
    #    cPage = doc[x]
    #    if x > 0:
    #        wlist = cPage.getTextWords()
    #        for wordcount in range(len(wlist)):
    #            if wlist[wordcount][4] == "Service":
    #                if wlist[wordcount + 1][4] == "Bulletin" or wlist[wordcount + 1][4] == "bulletin":
    #                    check = wlist[wordcount + 2][4]
    #                    SBNum = re.search("[0-9].-", check)
    #                    if (SBNum):
    #                        service = wlist[wordcount + 2]
    #                        r = fitz.Rect(service[:4])
    #                        markup = cPage.addHighlightAnnot(r)
    #                        info = markup.info
    #                        info["title"] = "Service Bulletin"
    #                        info[
    #                            "content"] = "It should be SB when referencing the service bulletin ATA"
    #                        markup.setInfo(info)
    #                        error_code[18] = 1
    #                        error_code[24] = error_code[24] + 1
    #                    else:
    #                        service = wlist[wordcount]
    #                        r = fitz.Rect(service[:4])
    #                        markup = cPage.addHighlightAnnot(r)
    #                        info = markup.info
    #                        info["title"] = "Service Bulletin"
    #                        info[
    #                            "content"] = "Service bulletin is written lowercase"  # This adds the comment and Author to the program
    #                        markup.setInfo(info)
    #                        error_code[18] = 1
    #                        error_code[24] = error_code[24] + 1
    jip[directory.name].log_print("Checking Grammar...")
    for x in range(len(doc)):
        cPage = doc[x]
        cond, nummat, condition = PDF_Edit.searchPAGE(doc, x, "....", 1)
        cond2, nummat, condition = PDF_Edit.searchPAGE(doc, x, "1234567", 1)
        if cond == 0 and cond2 == 0:
            mat, nummat, period = PDF_Edit.searchPAGE(doc, x, "..", 1)  #
            PDF_Edit.highlight(cPage, period, "Double periods remove")  #
            if mat != 0:  #
                for j in range(int(mat / 2)):  #
                    error_code[15] = 1  #
                    error_code[35] = error_code[35] + 1  #
            mat = 0  #
            mat, nummat, spaceper = PDF_Edit.searchPAGE(doc, x, " .", 1)  #
            PDF_Edit.highlight(cPage, spaceper, "Remove space")  #
            if mat != 0:  #
                for j in range(int(mat / 2)):  #
                    error_code[15] = 1  #
                    error_code[37] = error_code[37] + 1  #
            mat = 0  #
        mat, nummat, spacecom = PDF_Edit.searchPAGE(doc, x, " ,",
                                                    1)  # I think this could be it's own module that we could use for all documents (this portion or the entire function.
        PDF_Edit.highlight(cPage, spacecom, "Remove space")  #
        if mat != 0:  #
            for j in range(int(mat / 2)):  #
                error_code[15] = 1  #
                error_code[38] = error_code[38] + 1  #
        mat = 0  #
        mat, nummat, semi = PDF_Edit.searchPAGE(doc, x, " :", 1)  #
        PDF_Edit.highlight(cPage, semi, "Remove space")  #
        if mat != 0:  #
            for j in range(int(mat / 2)):  #
                error_code[15] = 1  #
                error_code[39] = error_code[39] + 1  #
        mat = 0  #
        mat, nummat, spbrack = PDF_Edit.searchPAGE(doc, x, " )", 1)  #
        PDF_Edit.highlight(cPage, spbrack, "Remove space")  #
        if mat != 0:  #
            for j in range(int(mat / 2)):  #
                error_code[15] = 1  #
                error_code[36] = error_code[36] + 1  #
        mat = 0  #
        mat, nummat, spbrackl = PDF_Edit.searchPAGE(doc, x, "( ", 1)  #
        PDF_Edit.highlight(cPage, spbrackl, "Remove space")  #
        if mat != 0:  #
            for j in range(int(mat / 2)):  #
                error_code[15] = 1  #
                error_code[36] = error_code[36] + 1  #

    jip[directory.name].log_print("Checking conformity with Style Guide and Template...")
    for x in range(len(doc)):
        cPage = doc[x]
        if job == "521":
            mat, nummat, International = PDF_Edit.searchPAGE(doc, x, "Honeywell International", 1)  #
            PDF_Edit.highlight(cPage, International, "Replace with Limited")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[45] = error_code[45] + 1  #
            mat = 0  #
        if job != "521":
            mat, nummat, Limit = PDF_Edit.searchPAGE(doc, x, "Honeywell Limited", 1)  #
            PDF_Edit.highlight(cPage, Limit, "Replace with International Inc.")
            if mat != 0:  #
                for j in range(mat):  #
                    error_code[14] = 1  #
                    error_code[45] = error_code[45] + 1  #
            mat = 0  #
        mat, nummat, International = PDF_Edit.searchPAGE(doc, x, "allied signal", 1)  #
        PDF_Edit.highlight(cPage, International, "Replace with Honeywell")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[44] = error_code[44] + 1  #

            mat = 0
        mat, nummat, Gauss = PDF_Edit.searchPAGE(doc, x, "10 Gauss", 1)  # Gauss check
        PDF_Edit.highlight(cPage, Gauss, "According to \"Quality_Alert_Honeywell_09-25-18\" all 10 Gauss should be"
                                         " changed to 3 Gauss")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[46] = error_code[46] + 1  #

            mat = 0
        # mat, nummat, VoWa = PDF_Edit.searchPAGE(doc, x, "Volts ", 1)  # Gauss check
        # PDF_Edit.highlight(cPage, VoWa, "According to the stylesheet Volts should be replaced with V "
        #                                 "but check consistency with CMM first")
        # if mat != 0:  #
        #     for j in range(mat):  #
        #         error_code[14] = 1  #
        #         error_code[50] = error_code[50] + 1  #
        #     mat = 0

        # mat, nummat, VoWa = PDF_Edit.searchPAGE(doc, x, "Watts ", 1)  # Gauss check
        # PDF_Edit.highlight(cPage, VoWa, "According to the stylesheet Watts should be replaced with W "
        #                                 "but check consistency with CMM first")
        # if mat != 0:  #
        #     for j in range(mat):  #
        #         error_code[14] = 1  #
        #         error_code[50] = error_code[50] + 1  #

        matchver = 0
        matchver, nummat, Vertable = PDF_Edit.searchPAGE(doc, x, "Verification Data", 1)  # Verification Table check
        if matchver != 0:  #
            matchcon, nummat, Vertable2 = PDF_Edit.searchPAGE(doc, x, "Engineering Technical Review", 1)
            matchTest, nummat, Vertable2 = PDF_Edit.searchPAGE(doc, x, "Testing and Fault Isolation", 1)
            if matchcon == 0 and matchTest != 0:
                rect = [fitz.Rect(300, 0, 0, 0)]
                PDF_Edit.TextAnnot(cPage, rect,
                                   '"Engineering Technical Review" is missing in the verification table')
                for j in range(mat):  #
                    error_code[13] = 1  #
                    error_code[60] = error_code[60] + 1  #

        mat, nummat, VoTBD = PDF_Edit.searchPAGE(doc, x, "TBD", 1)
        PDF_Edit.highlight(cPage, VoTBD, "There should not be any TBD in the Finals of the document.\n"
                                         "Please fix if this is a Final check,"
                                         "otherwise confirm if engineer has knowledge of this."
                                         "\nEither TBD exist with their request or we are asking for further info.")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[61] = error_code[61] + 1  #

        mat, nummat, webLink = PDF_Edit.searchPAGE(doc, x, "myaerospace.", 1)
        PDF_Edit.highlight(cPage, webLink, "This is the incorrect website, please refer to the templates for the correct website link.")
        if mat != 0:
            for j in range(mat):
                error_code[14] = 1
                error_code[66] = error_code[66] + 1
        

        mat, nummat, VoAsca = PDF_Edit.searchPAGE(doc, x, "Honeywell ASCa", 1)
        PDF_Edit.highlight(cPage, VoAsca, '"Please change to Honeywell Limited."')
        if mat != 0:  #
            for j in range(mat):  #
                error_code[13] = 1  #
                error_code[62] = error_code[62] + 1  #

    ##Checking Copyright Year
        matcopy =0
        matyear =0
        matcopy, nummat, VoCopy = PDF_Edit.searchPAGE(doc, x, "Copyright - Notice", 1)
        current_year = str(datetime.date.today().year)
        if matcopy != 0:  #
            matyear, nummat, VoYear = PDF_Edit.searchPAGE(doc, x, current_year, 1)
            if matyear < 2:
                PDF_Edit.highlight(cPage, VoCopy, 'Please update the copyright year to reflect current date')
                for j in range(mat):  #
                    error_code[12] = 1  #
                    error_code[31] = error_code[31] + 1  #

    jip[directory.name].log_print("Checking Site Specific Verbiage...")
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

    check_page_dims(doc)

    return error_code


def check_page_dims(doc):
    for page in doc:
        dims = f"{int(page.rect.width)} x {int(page.rect.height)}"
        if dims == "792 x 612" and page.rotation == 0:
            print(f"Page {page.number + 1}: Incorrect landscape page dimensions.")
            PDF_Edit.TextAnnot(page, [page.bound()], "Incorrect landscape page dimensions")
        elif page.rotation in {90, 180}:
            print(f"Page {page.number + 1}: Incorrect page rotation.")
            PDF_Edit.TextAnnot(page, [page.bound()], "Incorrect page rotation")
