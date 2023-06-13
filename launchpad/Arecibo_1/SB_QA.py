import fitz
import re
import datetime
import subprocess
from bs4 import BeautifulSoup
import glob
from pathlib import Path
try:
    import launchpad.Arecibo_1.PDF_Edit as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit as PE
    from ar_interface import jobs_in_progress as jip


def search_SB(name, doc, job, error_code, directory):
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

    pages = PE.searchPDF(doc, "Highlights")
    for x in pages:
        if x == 0:
            pass
        else:
            y = subprocess.call("java -jar lib/pdfbox-app-2.0.15.jar PDFSplit -startPage 5 -endPage 6 " + name +
                                " -outputPrefix TEMP")
            if y == 0:
                name = "TEMP-1.pdf"
                subprocess.call("java -jar lib/pdfbox-app-2.0.15.jar  -html -ignoreBeads " + name + " " +
                                name.replace(".pdf", "") + ".html")

            HTMLname = glob.glob("TEMP-1.html")
            with open(HTMLname[0]) as fp:
                soup = BeautifulSoup(fp, "lxml")
            text = soup.find_all("p")
            string = [0]
            doc_text = []
            Highlights = []
            count = 0
            summary = []
            write = 0

            for x in text:
                string.append(x.string)
            for x in string:
                condition1 = re.search("publication number", str(x).lower())
                condition2 = re.search("honeywell international", str(x).lower())
                if str(x).lower().strip() == "none":
                    pass
                elif condition1:
                    pass
                elif condition2:
                    pass
                else:
                    doc_text.append(str(x).replace("All", ""))

            for x in range(len(doc_text)):
                #print(doc_text[x])
                condition_sum = re.search("•", doc_text[x])
                if condition_sum:
                    summary.append(str(doc_text[x]).replace("• ", "").strip())
                if doc_text[x].lower().strip() == "page description effectivity":
                    write = 1
                    pass
                elif write == 1 and doc_text[x].lower().strip() == "":
                    pass
                elif write == 1:
                    Highlights.append(doc_text[x].strip())

            jip[directory.name].log_print("---------------------------------------------------------------------------")
            for x in Highlights:
                jip[directory.name].log_print(x)
            print("---------------------------------------------------------------------------")
            for x in summary:
                jip[directory.name].log_print(x)


name, doc = PE.open_PDF()
error_code = [0]*75
search_SB(name, doc, "519456", error_code, Path(''))
