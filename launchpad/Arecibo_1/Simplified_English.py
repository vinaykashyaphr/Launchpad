import fitz
import re
import datetime
try:
    import launchpad.Arecibo_1.PDF_Edit as PDF_Edit
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit as PDF_Edit
    from ar_interface import jobs_in_progress as jip

def main(doc, error_code, offset, directory):
    jip[directory.name].log_print("Checking Simplified English...")
    for x in range(len(doc)):
        cPage = doc[x]
        mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "accessible", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Get access to\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 1] = error_code[offset + 1] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "accuracy", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"precision\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 2] = error_code[offset + 2] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Aeroplane", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Aircraft\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 3] = error_code[offset + 3] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Analyze ", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"Make an Analysis\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 4] = error_code[offset + 4] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Assign ", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"give\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 5] = error_code[offset + 5] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Authorize ", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"approve\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 6] = error_code[offset + 6] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Choose", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"use\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 7] = error_code[offset + 7] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Conform", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"agree\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 8] = error_code[offset + 8] + 1  #

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
                error_code[offset + 10] = error_code[offset + 10] + 1  #

            mat = 0

        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "ensure ", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"make sure\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 11] = error_code[offset + 11] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Identical", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"same\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 12] = error_code[offset + 12] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Immerse", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"put fully into\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 13] = error_code[offset + 13] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Indicate", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"show\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 14] = error_code[offset + 14] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Penetrate", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"go into or go through\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 15] = error_code[offset + 15] + 1  #

            mat = 0

        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "perform ", 1)  # Simplified English
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"do\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 16] = error_code[offset + 16] + 1  #
            mat = 0

        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Remedy", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"repair or correct\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 17] = error_code[offset + 17] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Rotate", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"turn\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 18] = error_code[offset + 18] + 1  #

            mat = 0
        mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Significant", 1)
        PDF_Edit.highlight_eng(cPage, simpeng, "Change to \"important\" as per simplified english")
        if mat != 0:  #
            for j in range(mat):  #
                error_code[14] = 1  #
                error_code[offset + 19] = error_code[offset + 19] + 1  #
    #     mat = 0
    # mat, nummat, simpeng = PDF_Edit.searchPAGE(doc, x, "Information", 1)
    # PDF_Edit.highlight(cPage, simpeng, "Change to \"data\" as per simplified english")
    # if mat != 0:  #
    #     for j in range(mat):  #
    #         error_code[14] = 1  #
    #         error_code[63] = error_code[63] + 1  #
    #####################################################################################################                   # Use the job variable to create searches specific to job.

    return doc, error_code
