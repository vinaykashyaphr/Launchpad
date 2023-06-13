#  © 2019 Sonovision Canada Inc. All rights reserved.
#  This program/application and all related content are the copyright of Sonovision Canada Inc. Unless expressly permitted, you may not
#  modify, copy, distribute, transmit, store, publicly display, perform, reproduce, publish, license, create derivative works from, transfer or sell
#  any information, software products or services, in whole or in part, obtained from the program/application and its contents without prior
#  written consent from Sonovision Canada Inc.
#
#  -------------------
#  Last Modified: 2019-08-16, 9:59 a.m.
#  By: smainuddin
#
import os
import re
import ARECIBO as AR
import LEP_Checker as LEP
import Missing_Graphics as MG
import Acronym_checker as AC
import JIRA_READER as JR
import Foldout_checker as FC
import Simplified_English as SE
import CSV_MAKER as cm
import Highlight_checker as HC
import PDF_Edit
import getpass
import datetime


def doc_type():
    for x in range(0, 10):
        print("Is the document a...")
        print("1. TR")
        print('2. SB, SIL etc.')
        print("3. OTHER (CMMs, EIPC, EM etc.)")
        type1 = input()
        if type1 == "1" or type1 == "2" or type1 == '3':
            break
    return type1

### Data Declaration ###
for x in range(0, 10):
    try:
        Name, doc = PDF_Edit.openPDF()
        break
    except IndexError:
            print("The PDF is not in the same folder as the executable, please try again after moving the PDF")
            input("Press Enter to continue...")

end = 0
offset = 67  ##This is to establish at which location the simplified english begins (makes it easier when adding newer checks
### Creating Dataframe for the QA CSV
data, data2 = cm.QA_MAKER(offset)
error_code = [0] * len(data["Error Code"])
error_code[19] = '---'
error_code[offset] = '---'
Hostname = getpass.getuser()
current_date = datetime.date.today()
error_code[len(error_code) - 1] = Hostname
error_code[len(error_code) - 2] = current_date
error_code[len(error_code) - 3] = len(doc)

CR_info, job = JR.main()

type1 = doc_type()       #First gets the type of document
while end == 0:
    print("----------------------------------------------------------------------------------------------")
    print("Welcome to the Wonderful World of ARECIBO")
    print("Which tool would you like to use?")
    print("1. Automated QA")
    if type1 == '3':
        print("2. LEP Checker")
    print("3. Missing Graphic Check")
    print("4. Check the Acronym Table")
    print("5. Check Foldouts")
    print("6. Simplified English Check")
    if type1 != '1':
        print("7. Highlight Check")
    print("\n10. Run Full Quality Analysis")
    print("0. Output PDF")
    print("Enter \"end\" to quit")
    print("----------------------------------------------------------------------------------------------")
    Tool = input("Enter Here: ")
    if Tool == "1" or Tool.lower() == "automated qA":
        doc, error_code = AR.main(doc, Name, error_code, job, CR_info, type1)
    elif Tool == "2" or Tool == "LEP Checker":
        print(" ")
        print("RUNNING LEP CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = LEP.main(doc, error_code)
    elif Tool == "3" or Tool.lower() == "missing graphics check":
        print(" ")
        print("RUNNING MISSING GRAPHICS CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = MG.main(doc, error_code)
    elif Tool == "4" or Tool.lower() == "acronym table check":
        print(" ")
        print("RUNNING ACRONYM TABLE CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = AC.main(doc, error_code)
    elif Tool == "5" or Tool.lower() == "foldout check":
        print(" ")
        print("RUNNING FOLDOUT CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = FC.main(doc, error_code)
    elif Tool == "6" or Tool.lower() == "simplified english check":
        print(" ")
        print("RUNNING SIMPLIFIED ENGLISH CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = SE.main(doc, error_code, offset)
    elif Tool == "7" or Tool.lower() == "highlight check":
        print(" ")
        print("RUNNING HIGHLIGHT CHECK....")
        print("----------------------------------------------------------------------------------------------")
        doc, error_code = HC.main(doc, error_code)
    elif Tool == "10" or Tool.lower() == "all":
        print("RUNNING ARECIBO....")
        doc, error_code = AR.main(doc, Name, error_code, job, CR_info, type1)
        if type1 == "3":
            print("RUNNING LEP CHECK....")
            doc, error_code = LEP.main(doc, error_code)
        if type1 != "1":
            print("RUNNING MISSING GRAPHICS CHECK....")
            doc, error_code = MG.main(doc, error_code)
            print("RUNNING ACRONYM TABLE CHECK....")
            doc, error_code = AC.main(doc, error_code)
            print("RUNNING FOLDOUT CHECK....")
            doc, error_code = FC.main(doc, error_code)
            print("RUNNING HIGHLIGHT CHECK....")
            doc, error_code = HC.main(doc, error_code)
            #print("RUNNING SIMPLIFIED ENGLISH CHECK....")      #Going to keep this as individual check if necessary
            #doc, error_code = SE.main(doc, error_code, offset)
        print("PDF Output...")
        try:
            PDF_Edit.output(doc)
            print("Completed Successfully")

            # CSV FINALIZATION
            print("Creating Checklist...")
            cm.edit_Data(data, error_code, job)
            cm.edit_Data(data2, error_code, job)
            cm.Finalize(data, data2)
            break
        except RuntimeError:
            print("\nPlease close the output PDF and try again")
        except not RuntimeError:
            print("PDF WAS NOT LOADED CORRECTLY")
            input("Press Enter to continue...")
            break
    elif Tool == "0":
        print("PDF Output...")
        try:
            PDF_Edit.output(doc)
            print("Completed Successfully")

            # CSV FINALIZATION
            print("Creating Checklist...")
            cm.edit_Data(data, error_code, job)
            cm.edit_Data(data2, error_code, job)
            cm.Finalize(data, data2)
            break
        except RuntimeError:
            print("\nPlease close the output PDF and try again")
        except not RuntimeError:
            print("PDF WAS NOT LOADED CORRECTLY")
            input("Press Enter to continue...")
            break
    elif Tool == "end":
        break
    else:
        print("Wrong Input, Please try again.")
        print(" ")
#input("Press Enter to close...")
