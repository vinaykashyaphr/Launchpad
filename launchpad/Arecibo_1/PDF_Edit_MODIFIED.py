import fitz
import re
import glob
import openpyxl
import webbrowser



def openPDF():                                                                                                          #Open the named PDF, "PDFname"
    name = glob.glob("*.pdf")
    PDFname = name[0]
    doc = fitz.open(PDFname)
    return doc


def highlight(page, rect, comment, name):
    ### HIGHLIGHT

     for inst in rect:
        markup = page.addHighlightAnnot(inst)
        info = markup.info
        info["title"] = name +" Says"
        info["content"] = comment                                                                                       # These add the comment and Author to the program
        markup.setInfo(info)                                                                                            # This updates the highlight with the latest info.

def TextAnnot(page, rect, comment, name):
    ### HIGHLIGHT
    for inst in rect:
        markup = page.addTextAnnot(inst.tl, comment)
        info = markup.info
        info["title"] = name +" Says"
        markup.update()                                                                                                 # This updates the highlight with the latest info.
        markup.setInfo(info)

def TextAnnot_Once(page, rect, comment, name):
    ### HIGHLIGHT
    inst = rect[0]
    markup = page.addTextAnnot(inst.tl, comment)
    info = markup.info
    info["title"] = name +" Says"
    markup.update()                                                                                                 # This updates the highlight with the latest info.
    markup.setInfo(info)


def output(doc):                                                                                                        #Takes the opened document "doc" and closes and saves it
    name = glob.glob("*.pdf")
    PDFname = name[0]
    PDFname = PDFname.replace(".pdf", "")
    doc.save(PDFname + "_Output.pdf")
    webbrowser.open(PDFname + "_Output.pdf")

def searchPDF(doc, term):                                                                                               #Takes the Opened PDF document, "doc" and the search "term" and returns the pages it is found in PDF page number.
    pagenum = len(doc)
    i = 0
    pages = [0]*pagenum
    for x in range(pagenum):
        page = doc[x]
        rect = page.searchFor(term)
        if rect != []:
            pages[i] = x
            i = i+1
    return pages


def searchPAGE(doc, pagenum, term, matchnum):                                                                           # This function takes in the page number of the document and searches term to see if it matches the provided amounts of time
    page = doc[pagenum]
    rect = page.searchFor(term)
    match = len(rect)
    if match == matchnum:
        x = 1
    elif match > matchnum:
        x = 2
    else:
        x = 0
    return x, match, rect                                                                                               # Returns 1 if it matches, 2 if matches more than it should and 0 if it doesn't match and provide the location and # of matches