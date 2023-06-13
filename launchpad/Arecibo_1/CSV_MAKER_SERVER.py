#  © 2019 Sonovision Canada Inc. All rights reserved.
#  This program/application and all related content are the copyright of Sonovision Canada Inc. Unless expressly permitted, you may not
#  modify, copy, distribute, transmit, store, publicly display, perform, reproduce, publish, license, create derivative works from, transfer or sell
#  any information, software products or services, in whole or in part, obtained from the program/application and its contents without prior
#  written consent from Sonovision Canada Inc.
#
#  -------------------
#  Last Modified: 2019-07-16, 9:45 a.m.
#  By: smainuddin
#

import pandas as pd
import glob
import os

ARECIBO_CHECKLISTS = os.environ.get('ARECIBO_CHECKLISTS', 'V:/500/500 - Catch All/TECHWRITE/Shawn/Arecibo Checklist2')

def create_Dataframe(columns):                                                                                          # Receives name and Dict with the columns headings and creates CSV

    data = pd.DataFrame(columns)

    return data


def edit_Data(data, new_column, new_colname):                                                                           # Receives a dataframe and adds columns of data to it, make sure the length of the changes matches the # of columns

    data[new_colname] = new_column

    return data


def Finalize(data, data2):                                                                                              # Outputs to a CSV.
    print("Checklist Output...")
    data.to_csv(f"{ARECIBO_CHECKLISTS}/Arecibo Checklist.csv",
               index=False, encoding='utf-8')
    PDFname = glob.glob('*.pdf')
    data2.to_csv(PDFname[0].replace(".pdf", "") + ".csv", index=False, encoding='utf-8')


def QA_MAKER():
    path = f"{ARECIBO_CHECKLISTS}/Arecibo Checklist.csv"
    csv_name = glob.glob(f"{ARECIBO_CHECKLISTS}/*.csv")
    errors = {'Error Code': ['CID-1', 'CID-2',
                             'CRF-1', 'DPL-3',
                             'Fig-1', 'Fig-2',
                             'Fig-3', 'MEA-1',
                             'NOM-1', 'PN-1',
                             'SRC-1', 'TBL-1 ',
                             'TBL-2', 'TEM-1',
                             'TXT-1', 'TXT-2',
                             'WC-1', 'OTH-1',
                             'OTH-2',
                             '-----',
                             'ERR-1', 'ERR-2', 'ERR-3', 'ERR-4', 'ERR-5', 'ERR-6', 'ERR-7', 'ERR-8', 'ERR-9',
                             'ERR-10', 'ERR-11', 'ERR-12', 'ERR-13', 'ERR-14', 'ERR-15', 'ERR-16', 'ERR-17',
                             'ERR-18', 'ERR-19', 'ERR-20', 'ERR-21', 'ERR-22', 'ERR-23', 'ERR-24', 'ERR-25',
                             'ERR-26', 'ERR-27', 'ERR-28', 'ERR-29', 'ERR-30', 'ERR-31', '---', 'ERR-32',
                             'ERR-33', 'ERR-34', 'ERR-35', 'ERR-36', 'ERR-37', 'ERR-37', 'ERR-38', 'ERR-39',
                             'ERR-40', 'ERR-41', 'ERR-42', 'ERR-43',  'ERR-44',  'ERR-45',  'ERR-46',  'ERR-47',
                             'ERR-48', 'ERR-49', 'ERR-50', 'Total Page Number',
                             'Date', 'Name'],
              'Error': ['Missing Highlight/Revision bar', 'Incorrect LEP', 'Incorrect/Missing Cross Reference',
                        'Issues in the IPL', 'Incorrect Illustration', 'Missing Illustration',
                        'Misplaced Illustration',
                        'Units used incorrectly/Missing', 'Part Name is incorrect', 'PN is incorrect',
                        'Source incorporated incorrectly/Missing', 'Table is Placed incorrectly/Missing',
                        'Incorrectly Formatted', 'Incorrect Template', 'Text is Incorrect',
                        'Grammatically Incorrect Text',
                        'Incorrect or Missing Warning/Caution', 'Technical Error Not Listed',
                        'Format Error Not Listed',
                        '---TYPE OF ERRORS---',
                        'ECCN', 'Document Title', 'Publication Number', 'Date(Post-Author)', 'Manual Reference',
                        'TR Number', 'Page References', 'Export Control Statement', 'Confidential Statement',
                        'Copyright Statement', 'Copyright Statement (Footer)',
                        'Copyright Year', 'Chapter/Footer Reference', '\"To holders Statement\" ATA Check',
                        'Double Spaces', 'Double Periods', 'Space Brackets', 'Space Period', 'Space Comma',
                        'Space Semicolon', 'Page Consistency',
                        'TR Replacement Statement', 'Page Count', 'Facing or Following',
                        'Allied Signal References', 'Site Check',
                        'Gauss Check', 'Total Page Consistency',
                        'CAPU TPCR Statement', 'Check PDF Name Format', 'Replace Volts and Watts',
                        '--Simplified English Check--', '\"Accessible\"', '\"Accuracy\"', '\"Aeroplane\"',
                        '\"Analyze\"', '\"Assign\"', '\"Authorize\"', '\"Choose\"', '\"Conform\"', '\"Duplicate\"',
                        '\"Eliminate\"', '\"Ensure\"', '\"Identical\"', '\"Immerse\"', '\"Indicate\"',
                        '\"Information\"', '\"Penetrate\"', '\"Perform\"', '\"Remedy\"', '\"Rotate\"',
                        '\"Significant\"',
                        '-', "-", "-"]}

    try:
        if csv_name[0].lower() == path.lower():
            data = pd.read_csv(csv_name[0], delimiter=',')
            data2 = create_Dataframe(errors)
        else:
            data = create_Dataframe(errors)
            data2 = data
    except IndexError:
        data = create_Dataframe(errors)
        data2 = data
    return data, data2

#D1,D2 = QA_MAKER()
#column = [0]*74
#column[31] = 1
#print(len(D1))
#column[0] = '-'
#column[1] = '-'
#column[4] = '-'
#column[5] = '-'
#column[6] = '-'
#column[9] = '-'
#D1 = edit_Data(D1,column, "521456")
#print(D1)