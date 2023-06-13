'''
File: beyond_measure_0_4_wcn.py
File Created: Friday, 28th February 2020 11:33:22 am
Author: David Dunkelman (david.dunkelman@sonovisiongroup.com)
-----
Last Modified: Tuesday, 29th September 2020 1:56:37 pm
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

isolate textblocks, categorize into what sort of thing, store what page
built to fit into Launchpad
'''

import re
from tkinter.filedialog import askopenfilename
from tkinter import Tk
from pathlib import Path
import fitz

# list of categories the textblocks will be sorted into.
# content in each entry is as follows: 
#   regex to find the category
#   title of category
#   minimum expected left x coord
#   maximum expected left x coord
#   minimum expected top y coord (0 is top of page)
#   maximum expected top y coord
#   list to hold found textblocks
types = [
        (r'^[0-9]{1,2}\. [A-Z][a-z]', 'step-1', 0, 100, 0, 800, []), # finds
        (r'^[A-Z]{1,2}\. ', 'step-2', 50, 150, 0, 800, []), # finds
        (r'^\([0-9]{1,2}\) ', 'step-3', 80, 200, 0, 800, []), # finds
        (r'^\([a-z]{1,2}\) ', 'step-4', 100, 200, 0, 800, []),
        (r'^[0-9]{1,2}\s[A-Z][a-z]', 'step-5', 120, 250, 0, 800, []), #captures unwanted stuff
        (r'^[a-z]{1,2}\s[A-Z][a-z]', 'step-6', 200, 400, 0, 800, []), #captures unwanted stuff
        (r'^\s?(-|—|•|−|-)\s', 'bullet', 100, 400, 0, 800, []),
        (r'^(NOTE|NOTES):', 'note', 0, 400, 0, 800, []),
        (r'^WARNING:? ', 'warning', 0, 400, 0, 800, []),
        (r'^CAUTION:? ', 'caution', 0, 400, 0, 800, []),
        (r'^[A-Z\s]+$', 'sectionTitle', 100, 400, 0, 100, []),
        (r'^(Figure|Fig) [A-Z]*?-?[0-9]+\. ', 'figureTitle', 0, 400, 0, 800, []),
        (r'^Table [A-Z0-9]*?-?[0-9]+\. ', 'tableTitle', 0, 400, 0, 800, []),
        (r'^Key (to|for) Figure ', 'legendTitle', 0, 400, 0, 800, []),
        (r'^KEY (TO|FOR) FIGURE [0-9]{1,4}', 'legendTitle', 0, 400, 0, 800, []),
        (r'\d\d\d\s[A-Z][a-z]', 'MTOSS-def', 0, 400, 0, 800, []),
        ('', 'Unidentified', 0, 500, 0, 800, [])
    ]
full_list = []

VERTICAL_ALIGNMENT_THRESHOLD = 14 # adjusted for each book
VERTICAL_OVERLAP_THRESHOLD = 0
HORIZONTAL_CLOSE_THRESHOLD = 3
AVERAGE_THRESHOLD = 3 # for determining averaging y coordinate

HEADER_Y = 85.0 # expected bottom of header
FOOTER_Y = 720.0 # expected top of footer

# if found, ignore that page
PATTERN_UNWANTED = re.compile(r'(?sm)List of Effective Pages\n'
                              r'|LIST OF EFFECTIVE PAGES'
                              r'|Numerical Index\n'
                              r'|^Equipment Designator Index\n'
                              r'|Page T- ?\d+' # front matter
                              r'|Page LEP- ?\d+'
                              r'|Page TOC- ?\d+'
                              r'|Page TC- ?\d+'
                              r'|Blank Page'
                              r'|TEMPORARY REVISION NO.'
                              r'|THIS PAGE INTENTIONALLY LEFT BLANK')



def main(**inputs):
    '''take in pdf, output text file with sorted textblocks'''
    reset_blocks()
    if inputs.get('pdf'):
        pdf_file = inputs.get('pdf')
    else:
        Tk().withdraw()
        pdf_file = askopenfilename(title='Select PDF to be converted to text.')
        if pdf_file is None:
            print('Error: No PDF file provided.')
            return None
        if pdf_file.strip('.pdf').strip('.PDF') == pdf_file:
            print('Error: PDF file must be selected.')
            return None

    pdf = fitz.open(pdf_file)

    find_para_gap(pdf)

    text = printout(parse(pdf))

    text = text_process(text)
    # blocks = output_blocks()
    # u_blocks = output_unordered_blocks()
    # text_filename = pdf_file.strip('.pdf').strip('.PDF') + '_blocks.txt'
    # Path(text_filename).write_text(blocks, encoding='utf-16')
    
    # text_filename_2 = pdf_file.strip('.pdf').strip('.PDF') + '_text.txt'
    # Path(text_filename_2).write_text(text, encoding='utf-16')
    
    # u_block_filename = pdf_file.strip('.pdf').strip('.PDF') + '_labelled.txt'
    # Path(u_block_filename).write_text(u_blocks, encoding='utf-16')
    
    for line in full_list:
        line[2] = text_process(line[2])
    

    return full_list

def find_para_gap(pdf):
    '''figure out the gap between lines in a paragrpah is'''

    
    # get most common gap on the page which should correspond to normal text spacing

    gaps = {} # will store gaps and the count of each
    
    # find page T-2 (a page with a lot of lines of normal text)
    checkpage = pdf[0]
    for page in pdf:
        page_text = page.getText('text')
        if re.search(r'Page T-2', page_text):
            checkpage = page
            break
    else:
        return
    words = checkpage.getTextWords()

    
   
    prev_pos = 0 # stores top of word above
    # for each word, get the space between it and the previous.
    # if the gap is an actual gap, store it in dict
    for word in words:
        word_pos = word[1]
        gap = round(word_pos - prev_pos, 2)
        if gap > 1:
            if gap in gaps:
                gaps[gap] += 1
            else:
                gaps[gap] = 1
        # prev_pos = word_pos
        prev_pos = word[3]
            
    # at end, pick most common
    chosen_gap = 0
    most = 0
    for gap in gaps:
        if gaps[gap] > most:
            most = gaps[gap]
            chosen_gap = gap
    
    # set the global variable
    global VERTICAL_ALIGNMENT_THRESHOLD
    VERTICAL_ALIGNMENT_THRESHOLD = chosen_gap



def output_blocks():
    # put out different types
    file_content = ''
    for t in types:
        for line in t[6]:
            file_content += f'{t[1]} | PAGE {line[0]} | {line[1]}\n'

    return file_content

def output_unordered_blocks():
    file_content= ''
    for line in full_list:
        file_content += f'{line[0]} | PAGE {line[1]} | {line[2]}\n'

    return file_content


def text_process(text):
    text = re.sub(r'(?m)^[\w\s\. ,-]+\(Continued\)\n[\w\. ]+$', '', text)
    text = re.sub(r'\(GRAPHIC\s*\w+-\s*\w+-\s*\w+-\s*\w+-\s*\w+-\s*\w+\)', '', text)
    text = re.sub(r'\((PGBLK|IPL)\s*\w+-\s*\w+-\s*\w+-\s*\w+\)', '', text)
    text = re.sub(r'\((TASK|Subtask|SUBTASK)\s*(\w+)\s*-\s*(\w+)\s*-\s*(\w+)\s*-\s*(\w+)\s*-\s*(\w+)\s*-\s*(\w+)\)', '', text)
    return text

def parse(pdf):
    temp_textblocks = []
    textblocks = []
    for i, page in enumerate(pdf):
        page_text = page.getText('text')
        if re.search(PATTERN_UNWANTED, page_text) is not None:
            continue
        table_of_contents = False
        if re.search(r'(?sm)TABLE OF CONTENTS', page_text):
            table_of_contents = True

        words = page.getTextWords()
        words = sorted(words, key=lambda x: (x[3], x[2]))
        formatted_words = []
        for word in words:
            formatted_words.append([word[4], i+1, word[5], word[0], word[1], word[2], word[3], 0 if not table_of_contents else 1])
        formatted_words = average_y_alignment(formatted_words)
        formatted_words = sorted(formatted_words, key=lambda x: (x[4], x[3]))

        word_block = None
        for word in formatted_words:
            if (word[6] < HEADER_Y or word[4] > FOOTER_Y) and i > 0:
                continue

            if word_block is None:
                word_block = word
            
            else:
                # if is_aligned_vertically(word, word_block):
                #     merge_blocks(word_block, word)
                if table_of_contents and is_aligned_vertically(word, word_block):
                    merge_blocks(word_block, word)

                elif not table_of_contents and (is_aligned_vertically(word, word_block) or is_overlapping_vertically(word, word_block)):
                    merge_blocks(word_block, word)
                
                else:
                    block_text = word_block[0]
                    block_text = block_process(block_text, word_block[3], word_block[4], i+1)
                    if table_of_contents:
                       block_text = re.sub(r'\.+(\s+)?(INTRO-\d+|\d+\/\d+|\d+)', '', block_text)
                    word_block[0] = block_text
                    temp_textblocks.append(word_block)
                    word_block = word
        if word_block is not None:
            block_text = word_block[0]
            block_text = block_process(block_text, word_block[3], word_block[4], i+1)
            if table_of_contents:
                block_text = re.sub(r'\.+(\s+)?(INTRO-\d+|\d+\/\d+|\d+)', '', block_text)
            word_block[0] = block_text
            temp_textblocks.append(word_block)



    reached_ipl = False
    reached_blocks = False

    textblocks = [temp_textblocks[0]]
    ipl_idx = 0
    for block in temp_textblocks[1:]:
        if not reached_ipl and block[7] != 1 and re.match(r'(?m)^(\s+)?ILLUSTRATED PARTS LIST(\s+)?$', block[0]):
            reached_ipl = True
        elif reached_ipl and not reached_blocks and re.match(r'(?m)^(\s+)?IPL Figure', block[0]):
            reached_blocks = True
            ipl_idx = len(textblocks)

        if reached_blocks:
            # textblocks[-1][0] = re.sub(r'(?m)\.+(\s|$)', '. ', textblocks[-1][0])
            textblocks[-1][0] = re.sub(r'\(SEE', '(REFER TO', textblocks[-1][0])
            textblocks[-1][0] = re.sub(r'\(REPL (?!BY)', '(REPLACES ', textblocks[-1][0])
            textblocks[-1][0] = re.sub(r'\(REPL BY', '(REPLACED BY', textblocks[-1][0])
            textblocks[-1][0] = re.sub(r'( )?\.{2,}( )?', ' . ', textblocks[-1][0])
        textblocks.append(block)
    if reached_blocks:
        # textblocks[-1][0] = re.sub(r'(?m)\.+(\s|$)', '. ', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(SEE', '(REFER TO', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(REPL (?!BY)', '(REPLACES ', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(REPL BY', '(REPLACED BY', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'( )?\.{2,}( )?', ' . ', textblocks[-1][0])

        textblocks = sort_ipl(textblocks, ipl_idx)

        
    
    return textblocks

def sort_ipl(textblocks, ipl_idx):
    ipl_textblocks, other_textblocks = textblocks[ipl_idx:], textblocks[:ipl_idx]
    found_ipl_block = False
    ipl_block = False
    for tb in ipl_textblocks:
        if tb[1] != other_textblocks[-1][1] or re.match(r'\d{1,2}[A-Z]?\s*$', tb[0]):
            ipl_block = False
        elif tb[3] < 200 and len(tb[0]) > 5:
            ipl_block = False
            found_ipl_block = True

        if is_same_page(tb, other_textblocks[-1]) and ipl_block:
            merge_blocks(other_textblocks[-1], tb)
        else:
            other_textblocks.append(tb)

        if found_ipl_block:
            ipl_block = True
            found_ipl_block = False
    return other_textblocks


def block_process(text, x0, y0, page_no):
    
    indent = int(x0 // 4)
    indent -= 11
    if indent < 0:
        indent = 0

    
    text = re.sub(r'•|–', '-', text)
    text = re.sub(r'°', ' ', text)
    text = re.sub(r"’", "'", text)
    text = re.sub(r'”|“', '"', text)
    text = re.sub(r'\s', ' ', text)
    
    # text = re.sub(r'( )?-( )?', ' - ', text)
    # text = re.sub(r'( )?\/( )?', ' / ', text)
    # text = re.sub(r'\((TASK|Subtask|IPL|PGBLK|GRAPHIC)\s(\w+)\s-\s(\w+)\s-\s(\w+)\s-\s(\w+)\s-\s(\w+)\s-\s(\w+)\)', r'(\1 \2-\3-\4-\5-\6-\7)', text)
    text = re.sub(r'\. \.', '..', text)
    text = re.sub(r'\. \.', '..', text)

    text = re.sub(r'\((PGBLK|IPL)\s(\w+)\s-\s(\w+)\s-\s(\w+)\s-\s(\w+)\)', '', text)
    text = re.sub(r'INTRO - (\d+)', r'INTRO-\1', text)
    text = re.sub(r'(?m)(^|\s)([A-Z]|[1-9]+)\.', r'\1\2.', text)
    text = re.sub(r'-\s+-\s+-\s+\*\s+-\s+-\s+-', '___*___', text)

    text = re.sub(r'Key for Fig', 'Key to Fig', text)
    text = re.sub(r'\((C|c)ont(inued)?\)', '(Continued)', text)
    
    text = re.sub(r'(?<!IPL )FIG\.?', 'IPL FIG', text)
    text = re.sub(r'\(Sheet 1 of 1\)', '', text)

    new_content = ''
    

    type = 'Unknown'
    for t in types:
        search = re.match(t[0], text)
        if search is not None:
            if t[2] <= x0 <= t[3]:
                if t[4] <= y0 <= t[5]:
                    type = t[1]
                    t[6].append([page_no, text])
                    full_list.append([t[1], page_no, text]) # type, page no, text
                    break
        


    # text = str(round(x0, 2))+ ', ' +str(round(y0, 2))+ ' '+ type + ': ' + text
    # text = type +': ' + text
 
    if page_no == 1:
        line_list = text.splitlines()
        for line in line_list:
            word_list = line.split(' ')
            count = 0
            for word in word_list:
                if word not in ('', ' '):
                    count += 1
            if count > 20:
                word_line = ' '*indent
                for i, word in enumerate(word_list):
                    word_line += f'{word} '
                    if i != 0 and i % 20 == 0:
                        word_line += '\n'
                        word_line += ' '*indent
                        # print(f'line: {word_line}')
                new_content += word_line
                new_content += '\n'
            else:
                new_content += ' '*indent
                new_content += line
                new_content += '\n'
    else:
        line_list = text.splitlines()
        for line in line_list:
            new_content += ' '*indent
            new_content += line
            new_content += '\n'
   
    return new_content

def printout(textblocks):
    page = 0
    text = ''

    for block in textblocks:
        if block[1] != page:
            text += f'\nPAGE NUMBER: {block[1]}\n'
            page = block[1]
        text += f'{block[0]}'

    return text

def merge_blocks(parent, child):
    '''Merge two blocks of text'''
    if not is_aligned_vertically(child, parent):
        parent[0] += '\n'+ child[0]
    else:
        parent[0] += (" " + child[0]) if parent[0][-1] != "-" else child[0]

        
    
    parent[3] = min(parent[3], child[3])
    parent[4] = min(parent[4], child[4])

    parent[5] = max(parent[5], child[5])
    parent[6] = max(parent[6], child[6])
    

def average_y_alignment(textblocks):
    '''Average the top edge of textblocks that are in a single row so that they line up'''
    avg = ([], 0)
    for t in textblocks:
        if abs(t[4] - avg[1]) > AVERAGE_THRESHOLD:
            for a in avg[0]:
                a[4] = avg[1]

            avg = ([t], t[4])
        else:
            new_avg = (avg[1]* len(avg[0]) + t[4])/ (len(avg[0])+1)
            avg[0].append(t)
            avg = (avg[0], new_avg)

    for a in avg[0]:
        a[4] = avg[1]

    return textblocks

def is_aligned_vertically(block1, block2, alignment=VERTICAL_ALIGNMENT_THRESHOLD):
    '''Returns whether two blocks of text are aligned in the same row'''
    return  abs(block1[4] - block2[4]) <= alignment or \
            abs(block1[6] - block2[6]) <= alignment or \
            (block1[4] <= block2[4] and block1[6] >= block2[6]) or \
            (block2[4] <= block1[4] and block2[6] >= block1[6])

def is_overlapping_vertically(block1, block2, overlap=VERTICAL_OVERLAP_THRESHOLD):
    '''Returns whether two blocks of text are overlapping vertically'''
    return block2[6] - block1[4] >= overlap

def is_same_page(block1, block2):
    '''Returns whether two blocks of text are on the same page'''
    return block1[1] == block2[1]

def is_horizontally_close(block1, block2, close=HORIZONTAL_CLOSE_THRESHOLD):
    '''Returns whether two blocks of text are close horizontally'''
    difference = min(abs(block1[5] - block2[3]), abs(block1[3] - block2[5]))
    if difference <= close:
        return True, 0
    return False, max(int(difference // 4), 1)

def reset_blocks():
    full_list.clear()
    for t in types:
        t[6][:] = []
    return

def get_direct(pdf):
    content = main(pdf=pdf)

    return content



if __name__ == '__main__':
    print('Beyond Measure')
    check = 'y'
    while check.strip() not in ('n', 'N', 'No'):
        t_file = main()
        check = input('Complete. Process another PDF? (y/n): ')

    