import os
from functools import partial
import tkinter as tk
from tkinter import filedialog
import openpyxl
from openpyxl import Workbook

# yes = {'yes', 'y', 'Y'}
# no = {'no', 'n', 'N'}
SUBFOLDERS = ('A_Source', 'B_Illustrations/1_Markup', 'B_Illustrations/2_Pickup', 'B_Illustrations/3_Ouput', 'C_Production', 'D_Customer Review/01_Delivery', 'D_Customer Review/01_Returned Comments', 'E_Finals')

# def create_individual():
#     print("Please Enter the Following Information:")
#     job_number = input("     Job Number (513005-XXXX): ")
#     d_number = input("     D Number (D000000000000): ")
#     rev_number = input("     Rev Number (R000): ")
#     cage_code = input("     CAGE Code: ")

#     usca = input("\nIs this job USCA? (y/n): ").lower()
#     if usca in yes:
#         drive = "//172.16.15.22/usca/513 - Honeywell - Other Sites/513005 - Conversion"
#     elif usca in no:
#         itar = input("\nIs this job ITAR? (y/n): ").lower()
#         if itar in yes:
#             drive = os.getcwd()
#         elif itar in no:
#             drive = "//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion"   

#     path_job = "%s/%s - %s - %s - %s" % (drive, job_number, d_number, rev_number, cage_code)

#     try:
#         os.makedirs(path_job)
#     except OSError:
#         print("\n     Error Creating Directory: %s " % path_job)
#     else:
#         print("\n     Successfully Created Directory: %s " % path_job)
#     def makefolders(root_dir, subfolders):
#         concat_path = partial(os.path.join, root_dir)
#         makedirs = partial(os.makedirs, exist_ok=True) 
#         for path in map(concat_path, subfolders):
#             makedirs(path)
#     if __name__=='__main__':
#         root_dir = '%s/%s - %s - %s - %s' % (drive, job_number, d_number, rev_number, cage_code)
#         subfolders = ('A_Source', 'B_Illustrations/1_Markup', 'B_Illustrations/2_Pickup', 'B_Illustrations/3_Ouput', 'C_Production', 'D_Customer Review/01_Delivery', 'D_Customer Review/01_Returned Comments', 'E_Finals')
#         makefolders(root_dir, subfolders)

def makefolders(root_dir, subfolders):
        concat_path = partial(os.path.join, root_dir)
        makedirs = partial(os.makedirs, exist_ok=True)
        for path in map(concat_path, subfolders):
            makedirs(path)
def create_multiple(file_path, directory):
    '''Gets sent here from launchpad, takes in excel sheet and makes directories'''
    itar = False
    errors = ''
    messages = ''
    work_book = openpyxl.load_workbook(file_path)
    work_sheet = work_book["Sheet1"]
    row = 2
    while work_sheet['A%s' % row].value is not None:
        job_number = work_sheet['A%s' % row].value
        d_number = work_sheet['B%s' % row].value
        rev_number = work_sheet['C%s' % row].value
        cage_code = work_sheet['D%s' % row].value
        security_level = work_sheet['E%s' % row].value
        if security_level == "USCA":
            drive = "//172.16.15.22/usca/513 - Honeywell - Other Sites/513005 - Conversion"
        elif security_level == "ITAR":
            itar = True
            # get xlsx location and generate folders there
            drive = directory

            # drive = os.getcwd()
        elif security_level == "UNCLASSIFIED":
            drive = "//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion"

        path_job = '%s/%s - %s - %s - %s' % (drive, job_number, d_number, rev_number, cage_code)

        try:
            os.makedirs(path_job)
        except OSError:
            errors += "\nError Creating Directory: %s " % path_job
            # print("\n     Error Creating Directory: %s " % path_job)
        else:
            messages += "\nSuccessfully Created Directory: %s " % path_job
            # print("\n     Successfully Created Directory: %s " % path_job)
            makefolders(path_job, SUBFOLDERS)
        row = row + 1
    return errors, messages, itar

# file_exists = os.path.isfile('./Create_Multiple_Job_Folders.xlsx')
# if file_exists:
#     spreadsheet = input("'Create_Multiple_Job_Folders.xlsx' deletected. Would you like to proceed using this spreadsheet? (y/n): ").lower()
#     if spreadsheet in yes:
#         create_multiple()
#     elif spreadsheet in no:
#         print("")
#         create_individual()
# else:
#     create_individual()

# input("\nPress ENTER to Exit.")	