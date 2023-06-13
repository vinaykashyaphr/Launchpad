import re
from tkinter import Tk
from tkinter.filedialog import askopenfilename
from pathlib import Path
from datetime import datetime
import sys

import fitz


# later in the file certain short forms will
# be used to save variable name space:
# wds = words
# pgs = pages
# th = threshold
# alp = alpha doc
# bta = beta doc

debug_results = False
debug_steps = False
debug_process = False
debug_words = False
output_files = False
blindsight = False

time_start = datetime.now()

def main(**inputs):
    '''main function, returns percentage similar'''
    global debug_results
    if inputs.get('d_results') is not None:
        debug_results = inputs.get('d_results')
    global debug_steps
    if inputs.get('d_steps') is not None:
        debug_steps = inputs.get('d_steps')
    global debug_process
    if inputs.get('d_process') is not None:
        debug_process = inputs.get('d_process')
    global debug_words
    if inputs.get('d_words') is not None:
        debug_words = inputs.get('d_words')
    global output_files
    if inputs.get('o_files') is not None:
        output_files = inputs.get('o_files')
    global blindsight
    if inputs.get('blind') is not None:
        blindsight = inputs.get('blind')


    alpha = inputs.get('alpha')
    beta = inputs.get('beta')
    alp_file, bta_file, type_file = input_documents(alp_input=alpha, bta_input=beta)

    if type_file == '.pdf':
        if debug_steps: print('TYPE: PDF')
        if blindsight:
            alp, bta = blind_pdf_to_text(alp_file, bta_file)
        else:
            alp, bta = pdf_to_text(alp_file, bta_file)
    elif type_file == '.xml':
        if debug_steps: print('TYPE: XML')
        alp, bta = xml_to_text(alp_file, bta_file)
    elif type_file == '.txt':
        if debug_steps: print('TYPE: TXT')
        if blindsight:
            alp, bta = blind_text(alp_file, bta_file)
        else:
            alp, bta = text_process(alp_file, bta_file)
    else:
        print('TYPE: Unsupported type. Exiting...')
        return 0
    if alp == '' or bta == '':
        return 0
    result = accuracy_check(alp, bta)
    return result

def input_documents(**inputs):
    '''get in documents to be compared'''
    if debug_steps: print('STARTING...')

    if inputs.get('alp_input') and inputs.get('bta_input'):
        alp_file = inputs.get('alp_input')
        bta_file = inputs.get('bta_input')
    else:
        Tk().withdraw()
        if inputs.get('alp_input') is None:
            alp_file = askopenfilename(title='Select File A')
            if not alp_file:  # If no file selected, select default
                # alp_file = "PMC-HON59364-59364-00001-01_fresh.pdf"
                print('ERROR: No first file. Exiting...')
                sys.exit()
        if inputs.get('bta_input') is None:
            bta_file = askopenfilename(title='Select File B')
            if not bta_file:  # If no file selected, select default
                # bta_file = "275 49-52-43 41497r3.pdf"
                print('ERROR: No second file. Exiting...')
                sys.exit()

    alp_type = Path(alp_file).suffix.lower()

    bta_type = Path(bta_file).suffix.lower()

    if alp_type != bta_type:
        print('ERROR: provided documents are not the same type. Exiting...')
        sys.exit()

    global time_start
    time_start = datetime.now()
    if debug_steps: print(f'START TIME: {time_start}')

    return alp_file, bta_file, alp_type

def patterns_remove(input_text):
    '''remove patterns common to pdf and txt'''
    # get rid of (IPL/PGBLK XX-XX-XX-XXXX?)
    file_text = re.sub(r'\s?\((?:IPL|PGBLK|GRAPHIC)\s+[-\w]+\)',
                       '', input_text)
    # get rid of (sheet 1 of 1)
    file_text = re.sub(r'\(Sheet 1 of 1\)', '', file_text)
    # correct for different phrasing
    file_text = re.sub(r'\(REPL BY', 'REPLACED BY', file_text)
    file_text = re.sub(r'\(REPL ', 'REPLACES ', file_text)
    file_text = re.sub(r'°|−', ' ', file_text)
    file_text = re.sub(r'•', '–', file_text)
    file_text = re.sub(r'Key for Fig', 'Key to Fig', file_text)
    # for Illustrated Parts List

    file_text = re.sub(r'-\s?ITEM NOT ILLUSTRATED', '', file_text)
    file_text = re.sub(r'SEE\s+FIG\.', 'SEE IPL FIG.', file_text)

    return file_text

def pdf_to_text(pdf_path_alp, pdf_path_bta):
    '''input pdfs, output processed text'''

    pattern_unwanted = re.compile(r'(?s)TEMPORARY REVISION NO\.'
                                  r'|Table of Highlights|TABLE OF CONTENTS'
                                  r'|List of Effective Pages\n'
                                  r'|LIST OF EFFECTIVE PAGES'
                                  r'|List of Chapters|Numerical Index\n'
                                  r'|Blank Page|RECORD OF REVISIONS'
                                  r'|THIS PAGE INTENTIONALLY LEFT BLANK'
                                  r'|Equipment Designator Index\nEQUIPMENT')

    def check_page(page):
        '''if page contains one of a number of keywords, delete the page'''
        if re.search(pattern_unwanted, page):
            return ''
        if re.search(r'(?m)^Vendor$', page):
            page = re.sub(r'(?m)^V(\d{5})', r'\1', page)
        page_number = None
        page_number = re.search(r'(?m)^Page ((INTRO-|T-|SBL-|TI-)?[\d\.]+)\n', page)
        if page_number is not None:
            page_number = page_number.group(1)
            if page_number == 'T-1':
                # get rid of Export control info
                if debug_steps: print('  EXPORT CONTROL')
                if re.search(r'(?s)(?<=Export Control\n).*?(?=ECCN)', page):
                    if debug_steps: print('    option A')
                    page = re.sub(r'(?s)(?<=Export Control\n).*?(?=ECCN)',
                                  '', page)
                elif re.search(r'(?s)(Publication Number .*?\n)(.*?)(?=ECCN)', page):
                    if debug_steps: print('    option B')
                    page = re.sub(r'(?s)(Publication Number .*?\n)(.*?)(?=ECCN)',
                                  r'\1', page)
        return page


    def output_pdf_text(pdf, i):
        text = ''
        for page in pdf:
            text += page.getText('text')
        Path(f'{i}_pdf.txt').write_text(text, encoding='utf-8')
        

    headfoot_th = 0.9

    alp = ''
    bta = ''
    alp_pages = 0
    bta_pages = 0

    # get in pdf and prepare
    for i, pdf_file in enumerate([pdf_path_alp, pdf_path_bta]):
        pdf_file = fitz.open(pdf_file)
        # output_pdf_text(pdf_file, i)
        if debug_steps: print(f'READING DOCUMENT...{datetime.now()}')
        num_pages = len(pdf_file)
        read_text = ''
        for page in pdf_file:
            new_page = page.getText('text')
            new_page = check_page(new_page)  # remove unwanted pages
            if new_page == '':  # if page removed, reduce page count
                num_pages -= 1
                if debug_process: print('removing page')
            else:
                # if not removed, add to text file and add page break
                read_text += new_page
                read_text += chr(12)
                if debug_process: print('adding page')
        # read in text file and page count into appropriate file's variables
        if i == 0:
            alp = read_text
            alp_pages = num_pages

        else:
            bta = read_text
            bta_pages = num_pages

    if alp == '' or bta == '':
        print('PROBLEM: 1 or both processed documents have no text. Exiting...')
        return
    if debug_steps: print(f'PROCESSING DOCUMENTS...{datetime.now()}')
    for i, file_text in enumerate([alp, bta]):
        # print text outputs of the files at this stage
        if output_files:
            Path("alp.txt" if i == 0 else "bta.txt").write_text(file_text, encoding='utf-8')
        if debug_steps: print(f'REMOVING EXCESS HEADERS AND FOOTERS...{datetime.now()}')
        # for this block, remove all but one instance of the header/footer
        count_pages = alp_pages if i == 0 else bta_pages
        pgs_th = int(alp_pages * headfoot_th) if i == 0 else int(bta_pages * headfoot_th)
        lines = re.split(r'\n', file_text)  # split the file into lines
        page_start = -1
        for j, line in enumerate(reversed(lines)):  # work backwards
            if j == 0:  # want the second last page break so skip first
                continue
            if re.search(r'\x0C', line):  # find page break
                page_start = j  # get (reversed) index of page break
                break
        if page_start == -1:  # if couldn't find a page break, problem
            print('PROBLEM: Could not locate page break. Exiting...')
            return
        rev_lines = list(reversed(lines))
        for k in range(-8, 9):  # check area around page break
            if k == 0:
                # at page start, don't want to remove form feed,
                # so take out of text to be removed
                rev_lines[page_start] = re.sub(r'\x0C', '', rev_lines[page_start])
            headfoot = r'(?m)^\s*?'+re.escape(rev_lines[page_start+k])+r'\n'
            num_finds = len(re.findall(headfoot, file_text))
            # print(headfoot)
            if num_finds >= pgs_th:
                # if line appears within threshold of number of times expected for header
                count_remover = num_finds if num_finds < count_pages else count_pages
                if debug_process:
                    print(f'initially {len(re.findall(headfoot, file_text))}')
                    print(f'Attempting to remove header/footer ['
                          f'{headfoot}] {count_remover-1} times')
                # remove all but 1 instance of it
                file_text = re.sub(headfoot, '', file_text, count_remover-1)
                if debug_process: print(f'{len(re.findall(headfoot, file_text))} still remaining')

        if debug_steps: print(f'REMOVING EXCESS TABLE HEADERS...{datetime.now()}')
        # Beginning of excess table header removal block
        table_list = []
        # generate new list of lines that will be manipulated
        lines_2 = re.split(r'\n', file_text)

        # get table title locations
        for line_index, line in enumerate(lines_2):
            if re.search(r'^\s*?Table [\d\w-]+\..*?$', line):
                line = re.sub(r'\s*?\((C|c)ont(inued)?\)', '', line)
                table_list.append({'index' : line_index, 'content' : line})
                # print(f'{line}')

        found_table = ''
        current_table = ''
        end_tables = False

        while not end_tables:
            # will normally happen 'after' each loop
            # want to get rid of table entries of the current (already used) table
            table_list[:] = (value for value in table_list if value['content'] != current_table)
            # get next table to work with
            # (this may be redundantly designed due to changes elsewhere, but oh well)
            iterator = 0
            while found_table == current_table:
                try:
                    found_table = table_list[iterator]['content']
                    iterator += 1
                except IndexError:
                    end_tables = True
                    break
            if not end_tables:
                # set up table to check
                # print(f'found table: [{found_table}]')
                current_table = found_table
                table_instances = 0
                current_table_list = []
                # find the instances of that table
                for table in table_list:
                    if table['content'] == current_table:
                        table_instances += 1
                        current_table_list.append(table['index'])
                        # print(' new instance')
                    else:
                        break
                # if only 1 table instance, ignore because only removing excess table headers
                if table_instances > 1:
                    # remove titles except 1
                    # print('  removing text 1')
                    file_text = re.sub(re.escape(current_table), '', file_text, table_instances-1)
                    still_checking = True
                    offset = 0
                    #go through lines below the titles to see if they are part of the header
                    while still_checking:
                        offset += 1
                        check_instances = 0
                        try:
                            to_check = lines_2[int(current_table_list[0])+offset]
                            for c_table in current_table_list:
                                if lines_2[c_table+offset] == to_check:
                                    # print('   instance of line')
                                    check_instances += 1
                                else:
                                    break
                            # if same number as table titles, its part of the table and
                            # should also be deleted
                            if check_instances == table_instances:
                                # print('    removing text 2')
                                if debug_process:
                                    print(f'{len(re.findall(re.escape(to_check), file_text))}'
                                          f' initially')
                                    print(f'Attempting to remove table header ['
                                          f'{re.escape(to_check)}] {table_instances-1} times')
                                file_text = re.sub(r'(?m)^'+re.escape(to_check)+r'\n', '',
                                                   file_text, table_instances-1)
                                if debug_process:
                                    remain = len(re.findall(re.escape(to_check), file_text))
                                    print(f'{remain} still remaining')
                            else:
                                still_checking = False
                        except TypeError:
                            still_checking = False
        # end of exces table header removal block

        if debug_steps: print(f'FILTERING OUT TEXT...{datetime.now()}')

        if debug_steps: print('  PHRASES')
        file_text = patterns_remove(file_text)

        # for Illustrated Parts List
        if debug_steps: print('  IPL HEADER')
        file_text = re.sub(r'(?m)^(EFFECT|UNITS|FIG\.|AIRLINE'
                           r'|\(USE\)|PER|ITEM|PART NUMBER|PART NO\.'
                           r'|STOCK NO\.\s1234567|NOMENCLATURE'
                           r'|CODE|ASSY)\n', '', file_text)

        if debug_steps: print('  CONT')
        file_text = re.sub(r'\((C|c)ont(inued)?\)', '', file_text)
        if debug_steps: print('  PAGE NUMBER')
        file_text = re.sub(r'(?m)^Page (INTRO-|T-|SBL-|TI-)?[\d\.]+\n', '', file_text)
        file_text = re.sub(r'(?m)^Pages [\d\.]+\/(\n)?[\d\.]+$', '', file_text)
        if debug_steps: print('  BRACKETS')
        file_text = re.sub(r'[\(\)]', '', file_text)

        if i == 0:
            alp = file_text
        else:
            bta = file_text

    return alp, bta

def blind_pdf_to_text(pdf_path_alp, pdf_path_bta):
    '''input pdfs, straight to text no removing or changing'''
    for i, pdf_file in enumerate([pdf_path_alp, pdf_path_bta]):
        pdf_file = fitz.open(pdf_file)  
        read_text = ''
        for page in pdf_file:
            read_text += page.getText('text', flags=1|2)
        # read in text file
        if i == 0:
            alp = read_text
        else:
            bta = read_text
    return alp, bta

def search_file(regex, text):
    '''insurance against returning with an error'''
    try:
        return re.search(regex, text).group(0)
    except AttributeError:
        return ''

def xml_to_text(xml_path_alp, xml_path_bta):
    '''input xmls, output text'''

    alp = ''
    bta = ''
    for i, xml_path in enumerate([xml_path_alp, xml_path_bta]):
        try:
            xml_file = xml_path.read_text(encoding='utf-8')
        except AttributeError:
            xml = open(xml_path, encoding='utf-8')
            xml_file = xml.read()
            xml.close()
        
        xml_file = search_file(r'(?s)<(mainProcedure|description)>.*?</\1>', xml_file)
        if xml_file == '':
            return '', ''

        # xml_file = re.sub(r'<!DOCTYPE[^\]]+]>', '', xml_file, 1)
        xml_file = re.sub(r'<[^>]+>', ' ', xml_file)

        if i == 0:
            alp = xml_file
        else:
            bta = xml_file

    # return accuracy_check(alp, bta)
    return alp, bta

def text_process(txt_path_alp, txt_path_bta):
    '''process text files from Beyond Reproach'''

    pattern_table = re.compile(r'(?sm)^\s*(Table ((?:[A-Z]+-)?\d+)\.\s+'
                               r'([^\n]+)\n.*?(?=^\s{0,5}(\d{1,2}\.|[A-Z]'
                               r'{1,2}\.|\s*\(\w{1,2}\)|\s*?Table (?!\2)'
                               r'|Blank Page)))')

    # function to find extra instances of table headers and remove them
    def sub_headers(match):
        table = match.group(0)  # Get table
        # Get number of continues
        num_cont = len(re.findall(r'\(Cont(inued)?\)', table))
        # If no continues, get out
        if num_cont == 0:
            return table
        # Split lines
        list_of_lines = table.splitlines(True)
        # In some cases the table title is in the second line? get rid of it
        if re.search('Table', list_of_lines[1]):
            del list_of_lines[0]

        # Extract lines 2-6 (idx 1-5)
        # Compare number of appearances to number of continues
        # Starting from all lines combined and working down,
        # if Appearances is less than no. of continues, try again.
        # If same number, we have our header
        header_string = ''
        for i in range(2, len(list_of_lines)):  # from 5 to 1
            # create those potential header strings
            try_header_string = ''.join(list_of_lines[1:i])

            try_header_string = re.sub(r'(?m)^\s+', r'^\\s*?', try_header_string)
            try_header_string = re.sub(r'([)(])', r'\\\1', try_header_string)
            # print('Header String: ' + try_header_string)
            # how many times does this header string appear?
            num_search = len(re.findall(try_header_string, table, re.M))
            # if it appears 1 more time than #continues, it is the header
            # (it also appears under the original table title)
            if num_search != num_cont+1:
                # print(str(i-2) + ' lines in header')
                break

            header_string = try_header_string

        # Take those lines, combine them with Table ... (Cont) regex, and sub out
        # print('Header String Result: ' + header_string)
        # PROBLEM: Tests of this show that the gap between
        # table and (cont can be a whole table size
        regex = r"(?m)^\s*Table.*?\(Cont(inued)?\)\n?" + header_string
        # print(regex)
        table = re.sub(regex, '', table)
        return table

    pattern_unwanted = re.compile(r'(?s)TEMPORARY REVISION NO\.'
                                  r'|Table of Highlights|TABLE OF CONTENTS'
                                  r'|List of Effective Pages\n'
                                  r'|LIST OF EFFECTIVE PAGES'
                                  r'|List of Chapters|Numerical Index\n'
                                  r'|Blank Page|RECORD OF REVISIONS'
                                  r'|THIS PAGE INTENTIONALLY LEFT BLANK'
                                  r'|Equipment Designator Index\nEQUIPMENT')

    def check_page(page):
        '''if page contains one of a number of keywords, delete the page'''
        page = page.group(0)
        if re.search(pattern_unwanted, page):
            return ''
        return page

    alp = Path(txt_path_alp).read_text(encoding='utf-8')
    bta = Path(txt_path_bta).read_text(encoding='utf-8')

    for i, file_text in enumerate([alp, bta]):
        file_text = re.sub(r'(?s)PAGE NUMBER: \d+.*?(?=PAGE NUMBER: \d+|$)',
                           check_page, file_text)

        # find and remove excess table headers
        file_text = re.sub(pattern_table, sub_headers, file_text)
        # get rid of Export control info
        file_text = re.sub(r'(?s)(?<=Export Control\n).*?(?=ECCN)',
                           "", file_text)
        file_text = patterns_remove(file_text)
        file_text = re.sub(r'(?sm)^\s+EFFECT.*?NOMENCLATURE$\n\d+[A-Z]?',
                           '', file_text)
        file_text = re.sub(r'PAGE NUMBER: \d+[-\s]+', '', file_text)
        if i == 0:
            alp = file_text
        else:
            bta = file_text

    return alp, bta

def blind_text(txt_path_alp, txt_path_bta):
    '''input txt output text no removing/changing'''
    alp = Path(txt_path_alp).read_text(encoding='utf-8')
    bta = Path(txt_path_bta).read_text(encoding='utf-8')
    return alp, bta

def accuracy_check(text_alp, text_bta):
    '''take in two strings and output info on similarity'''
    if debug_steps: print(f'GETTING WORDS...{datetime.now()}')

    # formatting to print information about a given pageblock/file
    def print_compare(title, alp_e, bta_e, alp_t, bta_t):
        '''print results of comparison of two documents'''
        print(f"""
        {title}
        Extra words from Alpha: {alp_e}
         Extra words from Beta: {bta_e}
         Word Count from Alpha: {alp_t}
          Word Count from Beta: {bta_t}
         Percent similarity is: {round(
                    (((alp_t + bta_t) - (alp_e + bta_e))
                    / (alp_t + bta_t)) * 100, 2)}%
        """)

    if output_files:
        Path("alp_2.txt").write_text(text_alp, encoding='utf-8')
        Path("bta_2.txt").write_text(text_bta, encoding='utf-8')

    alp_wds = {}  # dictionary for words from alpha
    bta_wds = {}  # dictionary for words from beta

    for i, file_text in enumerate([text_alp, text_bta]):
        # |> 'word_dictionary' will contain either file's word dictionary
        word_dictionary = alp_wds if i == 0 else bta_wds
        for word in re.split(r'\s+', file_text):  # split into words
            word = word.rstrip('.')  # take out unwanted characters
            word = re.sub(r'’', "'", word)
            if word in ('', ' '):
                continue
            if word in word_dictionary:  # build dict of words
                word_dictionary[word] += 1
            else:
                word_dictionary[word] = 1
    if debug_steps: print(f'COMPARING WORDS...{datetime.now()}')
    alp_extra_wds = bta_extra_wds = 0  # initialize extra word count
    alp_total_wds = bta_total_wds = 0  # initialize total word count
    for key, alp_value in alp_wds.items():  # for each alpha word entry
        try:
            # difference between two documents in counts of word
            diff = alp_value - bta_wds[key]
        except KeyError:
            # if bta is missing the word
            diff = alp_value
        if diff > 0:
            # if alp has extra
            alp_extra_wds += diff

        elif diff < 0:
            # if bta has extra
            bta_extra_wds += abs(diff)
        if debug_words and diff != 0:
            print(f'{str(alp_value)} vs {str(alp_value-diff)} '
                  f'({str(diff)}): {str(key)}')
        # accumulate alp word count
        alp_total_wds += alp_value
    # check in bta to find words not in alp
    for key, bta_value in bta_wds.items():
        try:
            # does alp have this word?
            alp_wds[key]
        except KeyError:
            # if not, it is extra to bta
            bta_extra_wds += bta_value
            if debug_words:
                print(f'0 vs {str(bta_value)} (-{str(bta_value)}): {str(key)}')
        # accumulate bta word count
        bta_total_wds += bta_value
    # show information in console
    if debug_results:
        print_compare('',
                      alp_extra_wds, bta_extra_wds, alp_total_wds, bta_total_wds)
    result = round((((alp_total_wds + bta_total_wds) - (alp_extra_wds + bta_extra_wds)) 
                    / (alp_total_wds + bta_total_wds)) * 100, 2)
    time_end = datetime.now()
    if debug_steps: print(f'END TIME: {time_end}')       
    if debug_results: print(f'DURATION: {round((time_end-time_start).total_seconds(), 2)} seconds')
    return result


if __name__ == '__main__':
    result = main(d_results=True, d_words=False, d_steps=True, o_files=False, d_process=False, blind=False)
    input('Press Enter to Exit...')
