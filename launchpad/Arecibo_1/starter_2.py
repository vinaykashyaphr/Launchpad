'''
File: starter_2.py
File Created: Friday, 24th January 2020 9:11:23 am
Author: David Dunkelman (david.dunkelman@sonovisiongroup.com)
-----
Last Modified: Thursday, 24th September 2020 2:07:29 pm
Modified By: David Dunkelman (david.dunkelman@sonovisiongroup.com>)
-----
© 2020 Sonovision Canada Inc. All rights reserved.
This program/application and all related content are the copyright of
Sonovision Canada Inc. Unless expressly permitted, you may not
modify, copy, distribute, transmit, store, publicly display, perform,
reproduce, publish, license, create derivative works from, transfer or sell
any information, software products or services, in whole or in part,
obtained from the program/application and its contents without prior
written consent from Sonovision Canada Inc.

The purpose of this is to serve as a starter script for the Arecibo scripts outside of LAUNCHPAD.
'''


from tkinter import Tk
from tkinter.filedialog import askopenfilename
from pathlib import Path
from ar_interface import run_qa



def main():

    print("Welcome to the Wonderful World of ARECIBO!")

    Tk().withdraw()
    for i in range(0, 10):
        file_path = askopenfilename(title='Choose a PDF file to be QAed')
        file_path = Path(file_path)
        if file_path.suffix.lower() != '.pdf':
            print('File is not a PDF.')
            file_path = None
            continue
        break
    if file_path is None:
        print('ERROR: File is not a PDF.')
        return
    
    filename = file_path
    directory = Path(file_path).parents[0]


    for i in range(0, 10):
        print('Please enter the job number: ', end='')
        job_no = input()        
        if len(job_no) < 6 or len(job_no) > 7:
            print('Invalid input.')
            job_no = None
            continue
        break
    if job_no is None:   
        print('ERROR: job number format is invalid.')
        return
        
    for i in range(0, 10):
        print("Is the document a...")
        print("1. TR")
        print('2. SB, SIL etc.')
        print("3. OTHER (CMMs, EIPC, EM etc.)")
        file_type = input()
        if file_type not in ('1', '2', '3'):
            print('Invalid input.')
            file_type = None
            continue
        break
    if file_type is None:
        print('ERROR: valid type not entered.')
        return
    
    has_D = input('Is the D number the same as the publication number? (y/n): ')
    has_D = True if has_D in ('y', 'yes') else False
     
    print("Which tool would you like to use?")
    print("1. Automated QA")
    if file_type == '3':
        print("2. LEP Checker")
    print("3. Missing Graphic Check")
    print("4. Check the Acronym Table")
    print("5. Check Foldouts")
    print("6. Simplified English Check")
    if file_type != '1':
        print("7. Highlight Check")
    print("\n10. Run Full Quality Analysis")
    print('\n11. Exit')
    response = input()

    if response in ('1', '10'):
        auto_qa = True
    else:
        auto_qa = False
    
    if response in ('2', '10'):
        lep = True
    else:
        lep = False

    if response in ('3', '10'):
        graphic = True
    else:
        graphic = False
    
    if response in ('4', '10'):
        acronym = True
    else:
        acronym = False

    if response in ('5', '10'):
        foldouts = True
    else:
        foldouts = False

    if response in ('6'):
        simple_english = True
    else:
        simple_english = False

    if response in ('7', '10'):
        highlight = True
    else:
        highlight = False

    if response in ('11'):
        return





    user=None


    run_qa(job_no, file_type, directory, filename, has_D, user, auto_qa=auto_qa, lep=lep,
           graphic=graphic, acronym=acronym, foldouts=foldouts, 
           simple_english=simple_english, highlight=highlight)


if __name__ == '__main__':
    main()

    end = 0
    while end == 0:
        response = input('Would you like to run ARECIBO again? (y/n)')
        if response in ('yes', 'y'):
            main()
        else:
            end = 1
            print('Exiting...')