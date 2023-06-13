import re
import glob
import fitz
try:
    import launchpad.Arecibo_1.PDF_Edit as PE
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except ModuleNotFoundError:
    import PDF_Edit as PE
    from ar_interface import jobs_in_progress as jip



def main(doc, error_code, directory):
#######Declared Variables########
    Text_Pages = []
    num = 0
    count = 0
##################################

#########Code Starts Here#########
    for x in range(0, len(doc)):                                                                                        # This seems to be messing up as there are multiple of the same Text_Pages
        Dlist = doc[x].getDisplayList()
        Text_Pages.append(Dlist.getTextPage())

    for x in Text_Pages:
        num = num + 1
        found = x.search("_missing_graphic_")

        if len(found) == 0:
            pass
        else:
            jip[directory.name].log_print("Missing page found on PDF page: " + str(num))

        if len(found) == 0:
            pass
        else:
            count = count + 1
            page = doc[num-1]
            PE.TextAnnot(page, found, "Missing Graphic")
            error_code[5] = 1  #
            error_code[56] = error_code[56] + 1  #
    if count == 0:
        jip[directory.name].log_print("\n\nNo missing graphics found ☺")
    else:
###This is to print a PDF if wanted by the user###
        jip[directory.name].log_print("\n\nWould you like to output the PDF marked up with comments?")
        jip[directory.name].log_print("1. Yes")
        jip[directory.name].log_print("2. No")
        choice = input("Enter Here: ")
        if str(choice) == "1":
            PE.output(doc, directory)
        else:
            pass

    return doc, error_code

   # lines = x.extractHTML().strip()                                                                                    #Extracts HTML with vertical and horizontal positioning
   # for y in lines.splitlines():
   #     print(y)