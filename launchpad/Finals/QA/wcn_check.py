# compares warnings, cautions, and notes

#issues
#   -wcn cut off between pages sometimes
#   -normally errant spaces, so I removed spaces. That might be a problem
#   -commas, periods sometijmes inconsistent. Remove??

import re
from tkinter import Tk
from tkinter.filedialog import askopenfilename
from pathlib import Path
import fitz
from beyond_measure_0_4_wcn import get_direct
from fuzzywuzzy import fuzz


def get_wcn(lines):
    '''Processes Beyond Measure output into just wcns, attempts to grab the entire wcn if it is over multiple lines'''
    wcns = [] # initialize to blank
    tick = False # whether or not it will continue to try and grab the next line for the current wcn
    temp = '' # the temporary storage of the multiline wcn 
    bullet = False # if it thinks it is a bullet point, it will check next line
    for line in lines:
        if line[0] in ('warning', 'caution', 'note'): # if wcn            
            if line[2].strip() in ('WARNING:', 'CAUTION:', 'NOTE:') or re.search(r'NOTES:', line[2]): # if continues on another line
                temp = line[2] # start a temp wcn which will be added to
                tick = True # check next line
            else:
                # reset variables related to multiline (in case it 'thought' it was multiline but instead was missing)
                if temp != '':
                    wcns.append([temp,line[1]])
                    temp = ''
                tick = False
                
                wcns.append([line[2],line[1]]) # if not multiline, just add it to the list
                
                
        elif tick: # if not wcn but flag for multiline wcn is set
            if line[0] == 'bullet' or re.search(r'^\d',line[2]): # if it is a bullet, we expect multiple lines of it
                temp += '\n'+line[2]
                bullet = True
            elif bullet: # if not bullet but bullet is set, it means the bullet list has ended
                # now that the bullet is complete, it should be appended and variables rest
                bullet = False
                wcns.append([temp,line[1]])
                tick = False
                temp = ''
                continue
            else: # if tick and not bullet it means that this is a non-bullet line continuing a wcn
                # ASSUMPTION: Nonbullet continuations take up 1 line only
                temp += '\n'+line[2]
                wcns.append([temp,line[1]])
                tick = False
                temp = ''
                continue
    return wcns

def do_wcn_check(*args, pdf_path_1=None, pdf_path_2=None):
    # get 2 pdfs
    if not pdf_path_1:
        pdf_path_1 = askopenfilename(title='Choose Source PDF')
    if not pdf_path_2:
        pdf_path_2 = askopenfilename(title='Choose Converted PDF')
    if not pdf_path_1 or not pdf_path_2:
        # print('ERROR: 2 PDFS Required.')
        return ['Missing PDF(s)']
    if Path(pdf_path_1).suffix.lower() != '.pdf' or Path(pdf_path_2).suffix.lower() != '.pdf':
        # print('ERROR: 2 PDFS Required.')
        return ['Invalid File(s)']

    # get the two sets of warnings, cautions, notes (wcns)
    lines_1 = get_direct(pdf_path_1) # use beyond measure
    wcns_1 = get_wcn(lines_1) # process to just wcns
    lines_2 = get_direct(pdf_path_2)
    wcns_2 = get_wcn(lines_2)
    
    output = []

    flag = False
    flag2 = False
    if len(wcns_1) != len(wcns_2):
        flag = True
        output.append('Non equal list')
    length = len(wcns_1) if len(wcns_1) < len(wcns_2) else len(wcns_2)
    for i in range (0, length):
        wcn_test = process_wcn(wcns_1[i][0])
        wcn_test_2 = process_wcn(wcns_2[i][0])
        if wcn_test != wcn_test_2:
            # print(wcns_1[i] + '\n!=\n' + wcns_2[i])
            if not flag2:
                # if not fuzz.partial_ratio(wcn_test, wcn_test_2) > 0.3:  
                if not similar(wcns_1[i][0], wcns_2[i][0]):
                    output.append('First misaligned set of entries:\nPAGE: '+ str(wcns_1[i][1])+', '+ wcns_1[i][0] + '\n!=\nPAGE: ' + str(wcns_2[i][1]) +', ' + wcns_2[i][0])   
                    flag2 = True                 
            flag = True      

    if output == []:
        if flag:
            return ['Not consistent.']        
        else:
            return []
    else:
        return output
    

def process_wcn(input):
    text = re.sub(r'\s|\.','', input)
    # text = re.sub(r'(?<=\d)\.', '', text)

    return text

def similar(text1, text2):
    '''check how similar, roughly, two lines of text are'''
    # turn new lines into spaces and split by spaces
    text1 = re.sub(r'\n', ' ', text1)
    text2 = re.sub(r'\n', ' ', text2)
    words1 = text1.split(' ')
    words2 = text2.split(' ')
    # get the shorter length of the two lists because want to check if it is 
    # the 'same' wcn. Not trying in this function to check if match, instead 
    # trying to see if it is ALIGNED. The wcn may be cut off but that is checked
    # elsewhere.
    count = 0
    total = len(words1) if len(words1) <= len(words2) else len(words2)
    # simple check to see how similar the overlapping parts of both wcns are
    for i in range(0, total):
        if words1[i] == words2[i]:
            count += 1
    return count/total > 0.3


if __name__ == '__main__':
    print(do_wcn_check())
    



