'''
File: pulsar_2.py
File Created: Tuesday, 28th January 2020 10:51:53 am
Author: David Dunkelman (david.dunkelman@sonovisiongroup.com)
-----
Last Modified: Thursday, 13th February 2020 3:23:22 pm
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

PULSAR II: Takes in 2 pdfs and highlights differences and similarities between them.
'''

import re
from tkinter.filedialog import askopenfilename
from tkinter import Tk
from pathlib import Path
from datetime import datetime
from fuzzywuzzy import fuzz
import fitz

try:
    from launchpad.views import update_status
except ModuleNotFoundError:
    pass

MATCH_THRESHOLD = 100.0 # Threshold for assuming line is the same
SIMILAR_THRESHOLD = 60.0 # Threshold for secondary similarity

HC_THRESHOLD = 30 # 30/40
MC_THRESHOLD = 15 # 15/40

HIGH_CONFIDENCE = [83/255, 255/255, 173/255]
MEDIUM_CONFIDENCE = [159/255, 205/255, 255/255]
LOW_CONFIDENCE = [182/255, 147/255, 255/255]

EXTRA_HIGHLIGHT = [1.0, 0.5, 0.5] # reddish

HEADER_Y = 85.0 # expected bottom of header
FOOTER_Y = 720.0 # expected top of footer
DEFAULT_STAGGER_VALUE = 50
PRINT_LOG = False

# keywords indicating a page should be ignored entirely
PATTERN_UNWANTED = re.compile(r'(?sm)TEMPORARY REVISION NO\.|Temporary Revision Number'
                              r'|TABLE OF CONTENTS'
                              r'|List of Effective Pages\n'
                              r'|LIST OF EFFECTIVE PAGES'
                              r'|Numerical Index\n'
                              r'|Blank Page'
                              r'|THIS PAGE INTENTIONALLY LEFT BLANK'
                              r'|^Equipment Designator Index\n')

def is_aligned_vertically(block1, block2, vertical_alignment_threshold=5):
    '''Returns whether two blocks of text are aligned in the same row'''
    return  abs(block1[5] - block2[5]) <= vertical_alignment_threshold or \
            abs(block1[7] - block2[7]) <= vertical_alignment_threshold or \
            block1[5] <= block2[5] and block1[7] >= block2[7] or \
            block2[5] <= block1[5] and block2[7] >= block1[7]

def is_overlapping_vertically(block1, block2, vertical_overlap_threshold=0):
    '''Returns whether two blocks of text are overlapping vertically'''
    return block2[7] - block1[5] >= vertical_overlap_threshold

def is_same_page(block1, block2):
    '''Returns whether two blocks of text are on the same page'''
    return block1[1] == block2[1]

def block_process(text):
    '''When a block is passed in, makes modifications to avoid flagging meaningless diffs'''
    text = re.sub(r'•|–', '-', text)
    text = re.sub(r'°', ' ', text)
    text = re.sub(r"’", "'", text)
    text = re.sub(r'”|“', '"', text)
    text = re.sub(r'Key for Fig', 'Key to Fig', text)
    text = re.sub(r'\((C|c)ont(inued)?\)', '(Continued)', text)
    text = re.sub(r'\s?\((?:IPL|PGBLK|GRAPHIC)\s+[–\-\w ]+\)', '', text)
    text = re.sub(r'\(Sheet 1 of 1\)', '', text)
    # text = re.sub(r' \.', '.', text)
    text = re.sub(r'-\s?(?:ITEM )?NOT ILLUSTRATED', '', text)
    text = re.sub(r'(?<=\S)- ', '-', text)
    text = re.sub(r'(?<!IPL )FIG\.?', 'IPL FIG', text)
    text = re.sub(r'(?:\.\s?)+(\s|$)', ' ', text)
    text = re.sub(r'[-_]+\*[-_]+', '--*-- ', text)
    text = re.sub(r'([a-zA-z])-([a-zA-z])', r'\1\2', text)
    return text

def average_y_alignment(textblocks):
    '''Average the top edge of textblocks that are in a single row so that they line up'''
    avg = ([], 0)
    for t in textblocks:
        if abs(t[5] - avg[1]) > 3:
            for a in avg[0]:
                a[5] = avg[1]

            avg = ([t], t[5])
        else:
            new_avg = (avg[1]* len(avg[0]) + t[5])/ (len(avg[0])+1)
            avg[0].append(t)
            avg = (avg[0], new_avg)

    for a in avg[0]:
        a[5] = avg[1]

    return textblocks

def parse_pdf(pdf_path, CAGE, cnv=True, has_table_of_highlights=False, output=False):
    '''Parse and process content from PDFs'''
    pdf_file = fitz.open(pdf_path)
    temp_textblocks = []
    reached_ipl = False
    reached_blocks = False


    for i, page in enumerate(pdf_file):
        page_text = page.getText('text')
        if cnv and CAGE is None and 'Page T-1' in page_text:
            CAGE = re.search(r'CAGE: (\w{5})', page_text)
            if CAGE is not None:
                CAGE = CAGE.group(1)

        if re.search(PATTERN_UNWANTED, page_text) is not None:
            continue

        page_textblocks = []
        if cnv and not has_table_of_highlights and re.search(r'(?m)^Table of Highlights', page_text) is not None:
            has_table_of_highlights = True

        for block in page.getTextBlocks():
            if not cnv and not has_table_of_highlights and re.match('Table of Highlights', block[4]):
                break

            if (block[3] < HEADER_Y or block[1] > FOOTER_Y) and i > 0:
                continue

            block_text = re.sub(r'([\-/])\n', r'\1', block[4])
            block_text = re.sub(r'\n|  ', r' ', block_text)
            block_text = block_process(block_text)
            if not block_text.strip():
                continue

            page_textblocks.append([block_text, i, block[5], 0, block[0], block[1], block[2], block[3]])
        sorted_textblocks = average_y_alignment(sorted(page_textblocks, key=lambda x: (x[5], x[4])))
        temp_textblocks.extend(sorted(sorted_textblocks, key=lambda x: (x[5], x[4])))
        
    if output:
        with open(f"output_raw_blks_{'cnv' if cnv else 'src'}.txt", 'w+', encoding='utf-8') as output:
            output.write('\n'.join([str(c[1]) + "_" + str(c[2]) + " | " +  c[0] + f" (X1:{c[4]} | X2:{c[6]} | Y1:{c[5]} Y2:{c[7]})" for c in temp_textblocks]))

    textblocks = [temp_textblocks[0]]
    ipl_idx = 0
    for tb in temp_textblocks[1:]:
        if not reached_ipl and re.match(r'(?m)^ILLUSTRATED PARTS LIST', tb[0]):      
            reached_ipl = True

        elif reached_ipl and not reached_blocks and re.match(r'(?m)^IPL Figure', tb[0]):
            reached_blocks = True
            ipl_idx = len(textblocks)
        elif reached_ipl and reached_blocks:
            tb[0] = re.sub(fr'\(V?{CAGE}\)\s*', '', tb[0])
            tb[0] = re.sub(r', ', ',', tb[0])

        if  is_same_page(tb, textblocks[-1]) and \
                (is_aligned_vertically(tb, textblocks[-1]) or \
                is_overlapping_vertically(tb, textblocks[-1])):
            merge_blocks(textblocks[-1], tb)
        else:
            if reached_blocks:
                textblocks[-1][0] = re.sub(r'(?m)\.+(\s|$)', '. ', textblocks[-1][0])
                textblocks[-1][0] = re.sub(r'\(SEE', '(REFER TO', textblocks[-1][0])
                textblocks[-1][0] = re.sub(r'\(REPL (?!BY)', '(REPLACES ', textblocks[-1][0])
                textblocks[-1][0] = re.sub(r'\(REPL BY', '(REPLACED BY', textblocks[-1][0])
            textblocks.append(tb)

    if reached_blocks:
        textblocks[-1][0] = re.sub(r'(?m)\.+(\s|$)', '. ', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(SEE', '(REFER TO', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(REPL (?!BY)', '(REPLACES ', textblocks[-1][0])
        textblocks[-1][0] = re.sub(r'\(REPL BY', '(REPLACED BY', textblocks[-1][0])


        textblocks = sort_ipl(textblocks, ipl_idx)
    return pdf_file, CAGE, has_table_of_highlights, textblocks

def sort_ipl(textblocks, ipl_idx):
    '''merge parts of entries in the ipl together'''
    ipl_textblocks, other_textblocks = textblocks[ipl_idx:], textblocks[:ipl_idx]

    found_ipl_block = False
    ipl_block = False
    for tb in ipl_textblocks:
        if tb[1] != other_textblocks[-1][1] or re.match(r'\d{1,2}[A-Z]?\s*$', tb[0]):
            ipl_block = False
        elif tb[4] < 200 and len(tb[0]) > 5:
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

def merge_blocks(parent, child):
    '''Merge two blocks of text'''
    parent[0] += (" " + child[0]) if parent[0][-1] != "-" else child[0]
    parent[4] = min(parent[4], child[4])

    parent[5] = min(parent[5], child[5])
    parent[6] = max(parent[6], child[6])
    parent[7] = max(parent[7], child[7])

def main(job_no, path_text, user, print_log=False, **inputs):
    '''main function for PULSAR II: Takes in 2 pdfs, saves copies of pdfs with similarities and differences highlighted.'''
    global PRINT_LOG
    PRINT_LOG = print_log

    if PRINT_LOG: text_log = ''

    if job_no is None:
        job_no = input('input job number: ')
    else:
        if PRINT_LOG: log_print(f'Job number: {job_no}', text_log)

    # take in 2 pdf files
    Tk().withdraw()
    pdf_file_cnv = inputs.get('cnv_pdf')
    if not pdf_file_cnv:
        pdf_file_cnv = askopenfilename(title='Select Converted PDF')
        if not pdf_file_cnv:
            print('ERROR: No Converted PDF file. Exiting...')
            return
    if Path(pdf_file_cnv).suffix.lower() != '.pdf':
        print('ERROR: File is not PDF. Exiting...')
        return

    pdf_file_src = inputs.get('src_pdf')
    if not pdf_file_src:
        pdf_file_src = askopenfilename(title='Select Source PDF')
        if not pdf_file_src:
            print('ERROR: No Source PDF file. Exiting...')
            return
    if Path(pdf_file_src).suffix.lower() != '.pdf':
        print('ERROR: File is not PDF. Exiting...')
        return

    if path_text and user:
        update_status(user, Path(path_text).name, 'Beginning...')
    start_time = datetime.now()

    # initialize different lists tracking similar and extra textblocks
    cnv_similar = []
    cnv_extra = []
    src_similar = []
    src_extra = []
    # holds the associated pairs of similar blocks
    similar_pairs = []
    HC_number = 1
    MC_number = 1
    LC_number = 1

    if path_text and user:
        update_status(user, Path(path_text).name, 'Parsing PDFS...')
    # Process Converted and Source PDFs.
    cnv_pdf, CAGE, has_toh, cnv_textblocks = parse_pdf(pdf_file_cnv, None)
    src_pdf, _, _, src_textblocks = parse_pdf(pdf_file_src, CAGE, cnv=False, has_table_of_highlights=has_toh)

    if path_text and user:
        update_status(user, Path(path_text).name, 'Examining PDFs for similarities and differences...')
    # Find similar and extra blocks
    stagger_value = DEFAULT_STAGGER_VALUE
    src_blk = 0
    for cnv_block in cnv_textblocks:
        most_similar = (0, None)
        breaker = False
        start = max(src_blk-stagger_value, 0)
        end = min(src_blk+stagger_value, len(src_textblocks))
        for i, src_block in enumerate(src_textblocks[start:end], start):
            if src_block[3] == 1:
                continue

            compare = fuzz.token_sort_ratio(cnv_block[0], src_block[0], full_process=False)
            if compare < SIMILAR_THRESHOLD:
                compare2 = fuzz.ratio(cnv_block[0], src_block[0])
                compare = compare if compare > compare2 else compare2
            if compare >= MATCH_THRESHOLD:
                src_blk = i
                stagger_value = DEFAULT_STAGGER_VALUE
                if PRINT_LOG: text_log = log_print(f'SAME: Page {cnv_block[1]}, block {cnv_block[2]} and page {src_block[1]} block {src_block[2]}', text_log)
                src_block[3] = 1
                breaker = True
                break
            elif compare > most_similar[0]:
                most_similar = (compare, src_block)

        if not breaker:
            stagger_value += 1
            if most_similar[0] >= SIMILAR_THRESHOLD:
                similarity_amount = most_similar[0]- SIMILAR_THRESHOLD
                if similarity_amount >= HC_THRESHOLD:
                    title = 'HC-' + str(HC_number)
                    HC_number += 1
                elif similarity_amount >= MC_THRESHOLD:
                    title = 'MC-' + str(MC_number)
                    MC_number += 1
                else:
                    title = 'LC-' + str(LC_number)
                    LC_number += 1
                similar_pairs.append([cnv_block, most_similar[1], similarity_amount, title])
                cnv_similar.append(cnv_block)
                src_similar.append(most_similar[1])
                most_similar[1][3] = 1
                if PRINT_LOG: text_log = log_print(f'SIMILAR: Page {cnv_block[1]}, block {cnv_block[2]} and page {most_similar[1][1]} block {most_similar[1][2]}', text_log)
            else:
                if PRINT_LOG: text_log = log_print(f'EXTRA: Page {cnv_block[1]}, block {cnv_block[2]}', text_log)
                cnv_extra.append(cnv_block)

    for blk in src_textblocks:
        if blk[3] == 0:
            if PRINT_LOG: text_log = log_print(f'EXTRA: Page {blk[1]}, block {blk[2]}', text_log)
            src_extra.append(blk)

    if path_text and user:
        update_status(user, Path(path_text).name, 'Generating Comments...')

    manifest = f'{HC_number-1} High Confidence\n{MC_number-1} Medium Confidence\n{LC_number-1} Low Confidence'

    sim_comments = get_comments(similar_pairs, None, None)
    cnv_ext_comments = get_comments(None, cnv_extra, 'CONVERTED')
    src_ext_comments = get_comments(None, src_extra, 'SOURCE')

    if path_text and user:
        update_status(user, Path(path_text).name, 'Highlighting PDFs...')

    c_sim_rects, c_ext_rects = get_rects(cnv_similar, cnv_extra, sim_comments, cnv_ext_comments)
    cnv_hl = highlight_doc(cnv_pdf, c_sim_rects, c_ext_rects, manifest, doc_type='Converted', job_no=job_no)

    s_sim_rects, s_ext_rects = get_rects(src_similar, src_extra, sim_comments, src_ext_comments)
    src_hl = highlight_doc(src_pdf, s_sim_rects, s_ext_rects, manifest, doc_type='Source', job_no=job_no)

    if path_text and user:
        update_status(user, Path(path_text).name, 'Done!')

    if PRINT_LOG:
        log_print(f'TOTAL DURATION: {round((datetime.now()-start_time).total_seconds(), 2)} seconds', text_log)
        Path(pdf_file_cnv+'_log.txt').write_text(text_log, encoding='utf-8')

    return cnv_hl, src_hl


def get_comments(sims, exts, doctype):
    '''returns comments for similar or extra, depending on what is present.'''
    other_doc = 'SOURCE' if doctype == 'CONVERTED' else 'CONVERTED'
    comments = []
    if sims:
        for pair in sims:
            text = word_diff(pair[0][0], pair[1][0])
            if text == 'IGNORE':
                comments.append(['IGNORE', LOW_CONFIDENCE, ''])
            else:
                # comments.append(['CONVERTED TEXT:\n{'+pair[0][0]+'}\nSOURCE TEXT:\n{'+pair[1][0]+'}'+text, pair[2], pair[3]])
                comments.append([text, pair[2], pair[3]])
    elif exts:
        for extra in exts:
            comments.append(['TEXT NOT FOUND IN '+ other_doc +':\n{'+extra[0]+'}'])

    return comments

def word_diff(cnv_entry, src_entry):
    '''takes in two blocks and outputs the words not shared'''

    # split both into a list of words
    cnv = re.split(r'\s+', cnv_entry)
    src = re.split(r'\s+', src_entry)

    # words in cnv, but not in src
    extra = []
    # words in src but not in cnv
    missing = []

    for word in cnv: # for each word in cnv
        if not word.strip():
            continue
        try: # if in src, remove it from src
            src.remove(word)
        except ValueError:
            extra.append(word) # if not in src, add to extra

    # all remaining words in src are missing from cnv
    for word in src:
        if not word.strip():
            continue
        missing.append(word)

    difference = ''
    # create string of word differences
    if extra == [] and missing == []:
        return 'IGNORE'
    if extra != []:
        difference += 'WORDS NOT IN SOURCE:\n{'
        difference += ', '.join(extra)
        difference += '}'
        if missing != []:
            difference += '\n'
    if missing != []:
        difference += 'WORDS NOT IN CONVERTED:\n{'
        difference += ', '.join(missing)
        difference += '}'

    return difference

def get_rects(similar, extra, sim_comments, ext_comments):
    '''make list of rects to make highlights'''

    sim_rects = [(block, comm) for comm, block in zip(sim_comments, similar)]
    ext_rects = [(block, comm) for comm, block in zip(ext_comments, extra)]

    return sim_rects, ext_rects

def highlight_doc(doc, sim_rect, ext_rect, manifest, doc_type='_', job_no='_'):
    '''highlight document'''

    def highlight_blocks(doc, rects, comment_type):
        extra_index = 1
        for rectangle in rects:
            if rectangle[1][0] == 'IGNORE':
                continue
            rect = rectangle[0]
            page = doc[rect[1]]
            
            if comment_type == 'similar':
                comment_code = rectangle[1][2]
                if rectangle[1][1] >= HC_THRESHOLD:
                    comment_colour = HIGH_CONFIDENCE
                elif rectangle[1][1] >= MC_THRESHOLD:
                    comment_colour = MEDIUM_CONFIDENCE
                else:
                    comment_colour = LOW_CONFIDENCE
            else:
                comment_code = 'E-' + str(extra_index)
                comment_colour = EXTRA_HIGHLIGHT
                extra_index += 1
                    
            highlight_rect = fitz.Rect(rect[4], rect[5], rect[6], rect[7])
            highlight = page.addHighlightAnnot(highlight_rect)
            highlight.setColors({'stroke': comment_colour})
            highlight.setInfo({'title': comment_code})
            highlight.setInfo({'content': rectangle[1][0]})
            highlight.update()
        if comment_type == 'extra':
            return extra_index

    highlight_blocks(doc, sim_rect, 'similar')
    extra_index = highlight_blocks(doc, ext_rect, 'extra')

    # manifest annot
    doc[0].addTextAnnot(fitz.Point(20, 20), manifest + f'\n{extra_index-1} Extra')

    hl = Path(doc.name).with_name(f'{job_no}_{doc_type}_HIGHLIGHT.pdf')
    doc.save(str(hl))

    return hl

def log_print(text, log_file):
    '''prints and adds to log'''
    print(text)
    log_file += '\n'
    log_file += text
    return log_file

if __name__ == '__main__':
    main(None, None, None, print_log=True)
