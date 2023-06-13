'''
Intended to check for on title page:

ATA Number
Publiation Number and/or D Number
Revision Number
Initial Date
Revised Date (if applicable)
Cage Code
ECCN
Title
Book Type
Part Numbers

'''
import re
from tkinter import Tk
from tkinter.filedialog import askopenfilename
from pathlib import Path
import fitz

PDF_INFO = [['ATA Number', 
'Publication Number', 
'Revision Number', 
'Initial Date', 
'Revised Date', 
'Cage Code', 
'ECCN', 
'Title', 
'Book Type', 
'Part Numbers']]
BOOKTYPES = [
    'Component Maintenance Manual',
    'COMPONENT MAINTENANCE MANUAL',
    'Light Maintenance Manual',
    'LIGHT MAINTENANCE MANUAL',
    'Engine Maintenance Manual',
    'ENGINE MAINTENANCE MANUAL',
    'Maintenance Manual',
    'MAINTENANCE MANUAL'
]
def search_pn(pdf_file, title_index):
    # find out if pages after page T-1 have part numbers
    words = []
    for i in range (1,5):
        text = pdf_file[title_index+i].getText()
        if re.search(r'Part Number', text):
            words += read_box(pdf_file[title_index+i], 0, 200, 100, 710)
    return words

    pass
def data_finder(regex_string, page_text):
    try:
       data = re.findall(regex_string, page_text)[0].strip()
    except IndexError:
        data = 'Not Found'
    return data

def scanner(pdf_path):
    if Path(pdf_path).suffix.lower() == '.pdf':
        # parse pdf
        pdf_file = fitz.open(pdf_path)
        for page in pdf_file:
            if re.search(r'(?m)Page T-{1,2}1$', page.getText()):
                text = page.getText()
                part_words = read_box(page, 0, 200, 250, 600)
                part_words += search_pn(pdf_file, page.number)
                break
        else:
            PDF_INFO.append(['NO TITLE', 'NO TITLE', 'NO TITLE', 'NO TITLE',
                             'NO TITLE', 'NO TITLE', 'NO TITLE', 'NO TITLE',
                             'NO TITLE', 'NO TITLE'])
            return
        # ATA NUMBER
        ATA = data_finder(r'\d\d-\d\d-\d\d', text)      
        
        # PUBLICATION NUMBER
        pub_num = data_finder(r'(?<=Publication Number )[A-Z0-9-]+', text,)
        
        
        # REVISION NUMBER
        rev_num = data_finder(r'(?<=Revision) \d+', text)
       

        # INITIAL DATE
        ini_date = data_finder(r'(?<=Initial )\d+ \w\w\w \d\d\d\d', text)
        
        if re.search(r'^\d ', ini_date):
            ini_date = '0'+ini_date

        # REV DATE
        rev_date = data_finder(r'(?<=Revised )\d+ \w\w\w \d\d\d\d', text)
        if re.search(r'^\d ', rev_date):
            rev_date = '0'+rev_date
            
        # CAGE
        CAGE = data_finder(r'(?<=CAGE: )\d+', text)
        
        # ECCN
        ECCN = data_finder(r'(?<=ECCN: )\w+', text)
     
        # BOOK TYPE        
        for btype in BOOKTYPES:
            if re.findall(btype, text):
                book_type = btype
                break
        else:
            book_type = 'Not Found'
        

        # TITLE
        try:
            title = re.search(fr'{book_type}\n(with Illustrated Parts List\n)?([\w -]+)\n', text).group(2)
        except AttributeError:
            title = 'Not Found'
                    
        # PART NUMBERS
        if part_words != []:
            part_numbers = []
            for word in part_words:
                if not re.search(r'^[A-Za-z]+$', word):
                    part_numbers.append(word)
            part_numbers = ', '.join(part_numbers)
        else:
            part_numbers = re.findall(r'\d{7,15}-\d{1,3}', text)
            if part_numbers != []:
                part_numbers = ', '.join(part_numbers)
            else:
                part_numbers = re.findall(r'\d{3}-\d{4}-\d{3}', text)
                if part_numbers != []:
                    part_numbers = ', '.join(part_numbers)
                else:
                    part_numbers = re.findall(rf'[\d-]+(?=\n{CAGE})', text)
                    if part_numbers != []:
                        part_numbers = ', '.join(part_numbers)
                    else:
                        part_numbers = 'Not Found'

        book_type = book_type.lower()
        PDF_INFO.append([ATA, pub_num, rev_num, ini_date, rev_date, CAGE, ECCN, title, book_type, part_numbers])
        pdf_file.close()
    else:
        PDF_INFO.append(['NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA', 'NA'])

def compare():
    result = []
    for i in range(0, 10):
        if PDF_INFO[1][i] == 'NA':
            result.append('Error: First document was not a PDF file.')
        if PDF_INFO[2][i] == 'NA':
            result.append('Error: Second document was not a PDF file.')
        if result != []:
            break
        if PDF_INFO[1][i] == 'NO TITLE':
            result.append('Error: Title page of first document could not be found.')
        if PDF_INFO[2][i] == 'NO TITLE':
            result.append('Error: Title page of second document could not be found.')
        if result != []:
            break
        if PDF_INFO[1][i] != PDF_INFO[2][i]:
            if PDF_INFO[0][i] == 'Part Numbers':
                result.append('Part Numbers do not match.')
            else:
                result.append(PDF_INFO[0][i] + ' does not match.')
    return result

def read_box(page, x0, x1, y0, y1):
    words = page.getTextWords()
    box_list = []
    for word in words:
        if word[0] >= x0:
            if word[1] >= y0:
                if word[2] <= x1:
                    if word[3] <= y1:
                        box_list.append(word[4])
    return box_list

def do_title_check(*args, book_1=None, book_2=None):
    reset_info()
    Tk().withdraw()
    if book_1 == None:
        pdf_path = askopenfilename(title='Choose Source PDF.')
    else:
        pdf_path = book_1
    scanner(pdf_path)

    if book_2 == None:
        pdf_path_2 = askopenfilename(title='Choose Converted PDF.')
    else:
        pdf_path_2 = book_2
    scanner(pdf_path_2)

    return compare()

def reset_info():
    try:
        PDF_INFO.remove(PDF_INFO[2])
        PDF_INFO.remove(PDF_INFO[1])
    except IndexError:
        return

if __name__ == "__main__":

    print(do_title_check())