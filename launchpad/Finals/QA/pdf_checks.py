import fitz

from tkinter import Tk
from tkinter.filedialog import askopenfilename
from pathlib import Path

H_THRESHOLD = 80


# Check for Broken References
def broken_ref_finder(*args, page_text=[], **kwargs):
    result = []
    for pg_num, page in enumerate(page_text, 1):
        if '[[[ Unmatched' in page:
            result.append(f"Broken link on page {pg_num}")
    return result


# Check for Missing Graphics
def missing_graphics_finder(*args, page_text=[], **kwargs ):
    result = []
    for pg_num, page in enumerate(page_text, 1):
        if '_missing_graphic_' in page:
            result.append(f"Missing graphic on page {pg_num}")
    return result

# Check for Blank Pages (No text at all)
# specifically the 'regularly' proportioned pages, not the wide blanks ones.
def blank_finder(*args, page_text=[], pdf_file=[], missing_blank=False, **kwargs):
    '''check for empty pages that are not part of foldouts.'''
    result = []
    non_empty = {'Blank', 'Figure', 'Table', 'NOTE:', 'CAUTION:', 'WARNING:'}
    for pg_num, (page, text) in enumerate(zip(pdf_file, page_text), 1):
        page_rect = page.bound()
        if text == '': # empty page
            if page_rect.width < page_rect.height: # is it a 'regular' proportion?
                result.append(f'Page {pg_num} is empty.', ) # its a wrong empty page
        elif missing_blank:
            if any(sub_string in text for sub_string in non_empty):
                continue
            blocks = page.getText('dict')["blocks"]
            for block in blocks:
                if block['type'] == 1:
                    continue
                # if block is within the headers, not blank
                if block['bbox'][1] > page_rect.y0+H_THRESHOLD and block['bbox'][3] < page_rect.y1-H_THRESHOLD:
                    break
                # if block stretches up into header
                if block['bbox'][1] < page_rect.y0+H_THRESHOLD and block['bbox'][3] > page_rect.y0+H_THRESHOLD:
                    break
                # if block stretches down into header
                if block['bbox'][1] < page_rect.y1-H_THRESHOLD and block['bbox'][3] > page_rect.y1-H_THRESHOLD:
                    break
                # if stretches over whole page
                if block['bbox'][1] < page_rect.y0+H_THRESHOLD and block['bbox'][3] > page_rect.y1-H_THRESHOLD:
                    break
            else:
                # if it is missing the 'blank page' text when it should have it
                result.append(f'Missing "Blank Page" text on page {pg_num}')

    return result


def pdf_checker(pdf_path):
    '''takes in a file path to a pdf'''
    if Path(pdf_path).suffix.lower() == '.pdf':
        # parse pdf
        pdf_file = fitz.open(pdf_path)

        page_text = [page.getText() for page in pdf_file]

        blank_result = blank_finder(page_text, pdf_file, True)

        broken_result = broken_ref_finder(page_text)

        graphics_result = missing_graphics_finder(page_text)

        # spaces_result = missing_spaces_finder(pdf_file)

        pdf_file.close()
        return blank_result, broken_result, graphics_result
    result = ['FILE NOT PDF']
    return result, result, result

if __name__ == "__main__":

    Tk().withdraw()
    pdf_path = askopenfilename(title='Choose PDF to check.')

    a, b, c = pdf_checker(pdf_path)

    print(a)
    print(b)
    print(c)

    