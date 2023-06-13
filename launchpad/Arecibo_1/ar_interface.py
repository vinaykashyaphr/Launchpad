import datetime
import getpass
from functools import partial
import traceback
import sys
from pathlib import Path

jobs_in_progress = {}

try:
    from launchpad.functions import ConversionClient
    import launchpad.Arecibo_1.ARECIBO as AR
    import launchpad.Arecibo_1.LEP_Checker as LEP
    import launchpad.Arecibo_1.Missing_Graphics as MG
    import launchpad.Arecibo_1.Acronym_checker as AC
    import launchpad.Arecibo_1.JIRA_READER as JR
    import launchpad.Arecibo_1.Foldout_checker as FC
    import launchpad.Arecibo_1.Simplified_English as SE
    import launchpad.Arecibo_1.CSV_MAKER as cm
    import launchpad.Arecibo_1.Highlight_checker as HC
    import launchpad.Arecibo_1.PDF_Edit as PDF_Edit
    import launchpad.Arecibo_1.SPELL_CHECK as SC
except ModuleNotFoundError:
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
    import SPELL_CHECK as SC

def exit_handler_partial(logText, status=0, filename="log.txt", cc=None):
    if cc is not None:
        cc.exit_handler(status)
    elif len(logText) > 0:
        try:
            log = '\n'.join(logText)
            Path(filename).write_text(log, encoding='utf-8')
        except Exception:
            print(traceback.format_exc())
            if status == 0:
                status = 1
        finally:
            input("Press any key to continue")
            sys.exit(status)
    else:
        input("Press any key to continue")
        sys.exit(status)
        


def log_print_partial(logText, message, printToLogOnly=False, cc=None):
    if cc is not None:
        cc.log_print(message, printToLogOnly)
    else:
        if(not printToLogOnly):
            print(message)
        logText.append(str(message))


# Gets input using Launchpad or generic method
def get_input_partial(message, default=None, cc=None):
    if not cc:
        return input(message)
    else:
        return cc.get_user_input(message, default)

class Arecibo():
    def __init__(self, cc, logText, log_file_name):
        self.get_input = partial(get_input_partial, cc=cc)
        self.log_print = partial(log_print_partial, logText, cc=cc)
        self.exit_handler = partial(exit_handler_partial, logText,
                            filename=log_file_name, cc=cc)

def run_qa(job_no, file_type, directory, filename, has_D, user, **checks):
    job_type = job_no[:3]
    log_file_name = "arecibo_log.txt"
    try:
        cc = ConversionClient(directory, user, log_file_name)
    except Exception:
        print("Warning: Launchpad not found")
        cc = None
    
    logText = []
    dir = directory
    directory = Path(directory)
    jobs_in_progress[directory.name] = Arecibo(cc, logText, log_file_name)
    

    # get_input = partial(get_input_partial, cc=cc)
    # log_print = partial(log_print_partial, logText, cc=cc)
    # exit_handler = partial(exit_handler_partial, logText,
    #                     filename=log_file_name, cc=cc)

    # read file
    pdf_name, doc = PDF_Edit.open_pdf(dir, filename)

    offset = 67  ##This is to establish at which location the simplified english begins (makes it easier when adding newer checks
    data, data2 = cm.QA_MAKER(offset)
    error_code = [0] * len(data["Error Code"])
    error_code[19] = '---'
    error_code[offset] = '---'
    # Hostname = getpass.getuser()
    Hostname = user
    current_date = str(datetime.date.today())
    error_code[len(error_code) - 1] = Hostname
    error_code[len(error_code) - 2] = current_date
    error_code[len(error_code) - 3] = len(doc)
    # try:
    CR_info = JR.main(job_no, directory)
    # except:
        # CR_info = [None]
        # jobs_in_progress[directory.name].log_print('Error retrieving data from Jira.')
        # jobs_in_progress[directory.name].exit_handler(1)

    if len(CR_info) == 1:
        jobs_in_progress[directory.name].log_print("Job Number not found on Jira. Please ensure you've entered the correct job number.")
        jobs_in_progress[directory.name].exit_handler(1)
    

    if checks.get('auto_qa'):
        # run automated qa
        try:
            doc, error_code = AR.main(doc, pdf_name, error_code, job_type, CR_info, file_type, has_D, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running automatic QA.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('lep') and file_type == '3':
        # run lep checker
        try:
            doc, error_code = LEP.main(doc, error_code, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running LEP Checker.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('graphic'):
        # run missing graphic check
        try:
            doc, error_code = MG.main(doc, error_code, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running missing graphic check.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('acronym'):
        # run check on acronym table
        try:
            doc, error_code = AC.main(doc, error_code, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running acronym check.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('foldouts'):
        # run foldout check
        try:
            doc, error_code = FC.main(doc, error_code, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running foldout check.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('simple_english'):
        # run simplified english check
        try:
            doc, error_code = SE.main(doc, error_code, offset, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running simplified english check.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('highlight') and file_type != '1':
        # run highlight check
        try:
            doc, error_code = HC.main(doc, error_code, directory)
        except:
            jobs_in_progress[directory.name].log_print('Error running highlight check.')
            # jobs_in_progress[directory.name].exit_handler(1)
    if checks.get('spelling'):
        # run spell check
        # try: 
        doc, error_code = SC.main(doc, error_code, directory)
        # except:
            # jobs_in_progress[directory.name].log_print('Error running spelling check.')

    # output pdf
    PDF_Edit.output(doc, pdf_name, dir)
    doc.close()
    # output csv
    cm.edit_Data(data, error_code, job_no)
    cm.edit_Data(data2, error_code, job_no)
    cm.Finalize(data, data2, filename, directory)
    jobs_in_progress[directory.name].log_print("QA Completed.")
    jobs_in_progress[directory.name].exit_handler(0)
    

