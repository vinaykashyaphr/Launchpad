import fitz
import re
import glob
import openpyxl
import webbrowser
from pathlib import Path


def open_pdf(directory, filename=None):
    """Open, return the fitz handle and the PDF file name"""
    filename = list(directory.glob("*.pdf"))[0] \
        if filename is None else filename
    doc = fitz.open(filename)
    return filename, doc


def highlight(page, rect, comment):
    ### HIGHLIGHT

     for inst in rect:
        markup = page.addHighlightAnnot(inst)
        info = markup.info
        info["title"] = "ARECIBO says"
        info["content"] = comment                                                                                       # These add the comment and Author to the program
        markup.setInfo(info)                                                                                            # This updates the highlight with the latest info.

def highlight_eng(page, rect, comment):
    ### HIGHLIGHT
     for inst in rect:
        markup = page.addHighlightAnnot(inst)
        info = markup.info
        info["title"] = "Simplified English"
        info["content"] = comment                                                                                       # These add the comment and Author to the program
        markup.setInfo(info)                                                                                            # This updates the highlight with the latest info.

def TextAnnot(page, rect, comment):
    ### HIGHLIGHT
    for inst in rect:
        markup = page.addTextAnnot(inst.tl, comment)
        info = markup.info
        info["title"] = "ARECIBO says"
        markup.update()                                                                                                 # This updates the highlight with the latest info.
        markup.setInfo(info)


def output(doc, filename, directory):
    """Create output PDF"""
    output_filename = Path(filename).stem + "_Output.pdf"
    doc.save(str(directory) + '/' +output_filename)


def searchPDF(doc, term):                                                                                               #Takes the Opened PDF document, "doc" and the search "term" and returns the pages it is found in PDF page number.
    pagenum = len(doc)
    i = 0
    pages = [0]*pagenum
    for x in range(pagenum):
        page = doc[x]
        rect = page.searchFor(term)
        if rect != []:
            pages[i] = x+1
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

def searchPage_2(doc, pagenum, term):
    page = doc[pagenum]
    rect = [0]*100
    for x in range(0, len(term)):
        rect[x] = page.searchFor(term[x])
    return rect