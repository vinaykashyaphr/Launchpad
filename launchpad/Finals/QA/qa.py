import os
import re
from datetime import datetime
from pathlib import Path
import sqlite3
from tkinter import Tk
from tkinter.filedialog import askopenfilename
from traceback import format_exc
from typing import Any, Callable, List

import fitz
from lxml import etree as ET
from lxml.builder import E

from dm_checks import check_frontmatter_dms
from id_checker import id_duplicates, missing_id
from image_validator import get_images, unused_graphics, validate_images
from pdf_checks import blank_finder, broken_ref_finder, missing_graphics_finder
from sonovision.accuracy_checker import (accuracy_check, check_pages,
                                         pages_to_text)
from sonovision.s1000d_helper import Brex, DataModule, DmRef, validate_module
from validate_s1000D import validate as validate_s1kd
from xref_validation import broken_xrefs, unused_files
import concurrent.futures
from threading import Lock
from title_check import do_title_check
from wcn_check import do_wcn_check
# import timing

DOCTYPE = None
MODELLIC = None

ACCURACY_THRESHOLD = 90
DIFF_CODES = {
    "CMM/IPL": "EAA",
    "CMM": "EAA",
    "ACMM": "EAA",
    "AMM": "EAB",
    "EIPC": "EAC",
    "IPC": "EAC",
    "EM": "EAD",
    "MM": "EAF",
    "HMM": "EAG",
    "LMM": "EAG",
    "IM": "EAH",
    "IMM": "EAH",
    "IR": "EAI",
    "IRM": "EAI",
    "OHM": "EAJ",
    "OH": "EAK",
    "OH/IPL": "EAK",
    "ORIM": "EAL",
    "SDOM": "EAM",
    "SDIM": "EAM",
    "SPM": "EAN",
}


html_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta http-equiv="X-UA-Compatible" content="ie=edge"/>
    <title>QA Validation Report</title>
    <style>
        *{
            box-sizing: border-box;
        }
        .check{
            margin: 10px 0;
        }

        .summary{
            border: 1px solid black;
            display: flex;
        }

        .details{
            display: none;
            border: 1px solid black;
            padding: 10px;
        }

        .pass{
            background-color: lightgreen;
        }

        .warning{
            background-color: palegoldenrod;
        }

        .fail{
            background-color: lightsalmon;
        }

        .verify{
            background-color: #F39C12;
        }

        .error{
            background-color: lightcoral;
        }

        .expand{
            display: inline-block;
            width: 7%;
        }
        
        .active:hover{
            cursor: pointer;
        }

        .active{
            font-weight: 700;
            text-align: center;
            /* margin: auto; */
        }

        .desc{
            display: inline-block;
            width: 78%;
        }

        .status{
            display: inline-block;
            text-align: center;
            width: 15%;
        }

        body{
            max-width: 980px;
            margin: 0 auto;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-weight: 500;
            overflow-y: scroll;
            padding: 27px 10px 0;
        }

        p{
            font-size: 17px;
        }

        .details>p, .details li{
            font-size: 15px;
        }

        .details li{
            font-weight: 400;
            list-style-type: circle;
        }

        .details li:hover{
            cursor: pointer;
        }

        table{
            width: 100%;
            border-spacing: 0 10px;
        }

        td{
            border: 1px solid black;
            width: 100px;
            padding: 5px;
        }

        td:nth-child(3){
            border: 0;
            width: 10px;
        }

        td:nth-child(3n-1){
            border-left: 0;
        }
    </style>
</head>
<body>
    <h2>QA Inspection Report</h2>
    <table>
        <tr>
            <td><b>Reviewer</b></td>
            <td id="user"></td>
            <td></td>
            <td><b>Job Number</b></td>
            <td id="job_no"></td>
        </tr>
        <tr>
            <td><b>Date</b></td>
            <td id="date"></td>
            <td></td>
            <td><b>Status</b></td>
            <td id="state"></td>
        </tr>
        <tr>
            <td><b>Time</b></td>
            <td id="time"></td>
            <td></td>
            <td><b>Accuracy</b></td>
            <td id="accuracy"></td>
        </tr>
        <tr>
            <td><b>CAGE Code</b></td>
            <td id="cage"></td>
            <td></td>
            <td><b></b></td>
            <td id=""></td>
        </tr>
    </table>
</body>
<script>
    function expand(target){
        var details = target.parentNode.parentNode.nextElementSibling;
        if(target.innerHTML == "[+]"){
            target.innerHTML = "[–]";
            details.style = "display: block;"
        } else{
            target.innerHTML = "[+]";
            details.style = "display: none;"
        }
    }
    
    function check(target){
        if(target.style.listStyleType == "circle" || target.style.listStyleType == ""){
            target.style.listStyleType = "disc";
        } else{
            target.style.listStyleType = "circle";
        }
    }
</script>
</html>"""

def CLASS(*args):
    return {"class": ' '.join(args)}

class Check():
    def __init__(self, check: Callable[[Any, Any], List[str]], name:str, needs_verification=False) -> None:
        self.name = name
        self._check = check
        self.results = {}
        self.state = "Pass"
        self.needs_verification = needs_verification

    def validate(self, dm_name:str, *args, **kwargs):
        """
        Run the check method that was passed during initialization. Append the results of the method and modify the check state\n
        : dm_name : Name of the data module being checked\n 
        """
        try:
            results = self._check(*args, **kwargs)
        except Exception as e:
            results = [format_exc()]
            self.state = "Error"
        else:
            if self.state != "Error" and isinstance(results, list) and len(results):
                self.state = "Fail" if not self.needs_verification else "Verify"
        finally:
            if isinstance(results, list) and len(results):
                self.results[dm_name] = results
            return results

    def generate_report(self) -> ET._Element:
        """Generates a report summary in the form of an HTML element"""
        summary = E.div(
            E.div(CLASS("expand")),
            E.p(self.name, CLASS("desc")),
            E.p(self.state, CLASS("status")),
            CLASS("summary", f"{self.state.lower()}"))

        report = E.div(summary, CLASS("check"))

        if self.results:
            summary[0].append(E.p("[+]", CLASS("active"), onclick="expand(this)"))
            details = E.div(CLASS("details"))
            for dmc,results in self.results.items():
                p = E.p(dmc, E.ul())
                for r in results:
                    p[0].append(E.li(r, onclick="check(this)"))
                details.append(p)
            report.append(details)
        return report

def dm_parse(dm, *args, **kwargs):
    try:
        dm.parse()
    except ET.ParseError as e:
        raise Exception(str(e))
    else:
        if dm.root is not None:
            return dm.root
        else:
            return ["Parse Failed - Root not found"]

def match_dmcode(dm, *args, **kwargs):
    if re.match("DMC", dm._source_file.stem) is None:
        return []
    dmcode = dm.root.find("./identAndStatusSection/dmAddress/dmIdent/dmCode")

    if dmcode is None:
        return ["DmCode not found."]

    dmcode_as_name = DmRef.from_xml(dmcode).as_name

    if re.match(dmcode_as_name, dm._source_file.stem) is None:
        return [f"DmCode ({dmcode_as_name}) does not match filename ({dm._source_file.stem.split('_')[0]})"]
    
    return []

def check_schema(dm, *args, **kwargs):
    if re.match("DMC", dm._source_file.stem) is None:
        return []
    comps = dm._source_file.stem.split('-')
    info_code = comps[7][0:3]
    schema = dm.schema.name

    if info_code == "941":
        if schema != "ipd.xsd":
            return ['Data Module with infoCode="941" should have schema "ipd.xsd"']
    elif re.match(r'[1-9]', info_code[0]) is not None:
        if schema != "proced.xsd":
            return ['Data Module with infoCode starting with digits [1-9] should have schema "proced.xsd"']
    elif info_code[0] == "0":
        if info_code.isnumeric():
            if not (info_code == "012" and any(c != "00" for c in comps)) and schema != "descript.xsd":
                return ['Data Module with infoCode starting with "0" should have schema "descript.xsd"']
            elif info_code == "012" and all(c == "00" for c in comps) and schema != "comrep.xsd":
                return [f'Data Module with infoCode="{info_code}" should have schema "comrep.xsd"']
        elif info_code in ["00N", "00L"]:
            if schema != "comrep.xsd":
                return [f'Data Module with infoCode="{info_code}" should have schema "comrep.xsd"']
    return[]

def check_consolidate(*args, path=None, **kwargs):
    cons = list(path.glob("consolidate.log"))
    if not len(cons):
        return []
    
    cons = cons[0].read_text(encoding='utf-8')
    err = re.search(r"(?ms)^Error.*", cons)
    
    if err is not None:
        return [err.group(0)]

    return []

# 07217
def check_cage(dm, *args, cage="", **kwargs):
    if "023A" not in dm._source_file.name and "021A" not in dm._source_file.name:
        return []

    hnywell = set(map(lambda s: s.lower(), re.findall(r'(?i)honeywell (limited|international)', dm.root.xpath("string()"))))

    if cage == "07217" and 'international' in hnywell:
        return ["'Honeywell International Inc.' should be changed to 'Honeywell Limited' for Toronto publications (CAGE 07217)."]
    elif cage != "07217" and 'limited' in hnywell:
        return ["'Honeywell Limited' should be changed to 'Honeywell International Inc.' for non-Toronto publications."]

    return []

def get_brexes():
    brex_path = Path(os.getenv("BREX_PATH", "\\\\OTFS01\\Folders\\600\\620 - Production & Department Meetings\\621 - Ottawa Production Meetings\\Data Conversion\\Data Conversion Team\\Brex"))
    brexes = list(map(Brex, brex_path.glob("*022A*.xml")))
    while not brex_path.is_dir() or len(brexes) == 0:
        
        err_msg = f"The Brex directory ({str(brex_path)}) is not a valid directory, or it does not contain any Brex modules. "\
            "Please ensure at least one Brex module is in the given directory and restart the program, or enter a new directory: "
        
        brex_path = Path(input(err_msg))
        brexes = list(map(Brex, brex_path.glob("*022A*.xml")))
    return brexes

def search_non_utf8(dm, *args, **kwargs):
    string = ET.tostring(dm.tree, encoding='utf-8', xml_declaration=True).decode(encoding='utf-8')
    illegal_characters = []
    if not illegal_characters:
        return []
    chars = re.findall('|'.join(illegal_characters))
    # chars = re.findall(r'(?:(?:(?:[\x00-\x7F]|[\xC0-\xDF][\x80-\xBF]|[\xE0-\xEF][\x80-\xBF]{2}|[\xF0-\xF7][\x80-\xBF]{3})+)|(?:[\x80-\xBF])|(?:[\xC0-\xFF]))(.)?', string)
    return list(map(lambda x: f"Illegal character '{x}' ({hex(ord(x))}) detected.", filter(None, chars)))

def get_from_db(job_no, cage, man_type=None):
    finals_db = Path(os.getenv("FINALS_DB", "\\\\OTFS01\\Folders\\600\\620 - Production & Department Meetings\\621 - Ottawa Production Meetings\\Data Conversion\\Data Conversion Team\\Final Assembly\\data_conversion_finals.db"))
    if not finals_db.is_file() or finals_db.suffix != ".db":
        raise FileNotFoundError(f"{finals_db} is not a valid database file. Please set the 'FINALS_DB' environment variable to a valid DB file.")
    
    db = sqlite3.connect(str(finals_db))
    cur = db.cursor()
    try:
        modellic = None
        doctype = None
        modellic, doctype = cur.execute(f'SELECT modellic, type FROM main."Delivery Info" WHERE job="{job_no}"').fetchone()
        if modellic is None:
            print("Modellic not set: using CAGE code instead.")
            modellic = cage
        if doctype is None:
            doctype = man_type or input("Enter the Manual Type (i.e 'CMM', 'EM', 'OHM', etc.): ")
    except TypeError:
        print("Error getting info from database. Setting data manually.")
        modellic = cage
        doctype = man_type or input("Enter the Manual Type (i.e 'CMM', 'EM', 'OHM', etc.): ")
    finally:
        cur.close()
        db.close()
        return modellic.upper(), doctype.upper()

def verify_dm_names(dm, *args, modellic="", doctype="", **kwargs):
    if "PMC" in dm.filename:
        return []

    problems = []
    mod = dm.filename.split('-')[1]
    if mod not in {"HONAERO", "HONAVIONICS", "HONENGAPU", "HONMECHANICAL", "HONNAV", f"HON{modellic}"}:
        problems.append(f"Incorrect modellic. Modellic must be 'HON{modellic}' or 'HONAERO'.")

    while doctype not in DIFF_CODES:
        doctype = input("Doctype not valid, please enter a valid doctype").upper()

    sdc = dm.filename.split('-')[2]

    if not any(x == sdc for x in {DIFF_CODES[doctype], 'A'}):
        problems.append(f"Incorrect System Diff Code: Must be '{DIFF_CODES[doctype]}' in '{doctype}'-type manuals.")

    return problems

checks = [
    
    Check(dm_parse, "Data Modules Parse"),
    Check(match_dmcode, "DmCode Matches Filename"),
    Check(id_duplicates, "No Duplicate IDs"),
    Check(missing_id, "No Missing IDs"),
    Check(broken_xrefs, "Validate Cross References"),
    Check(validate_s1kd, "Schema Validation"),
    Check(validate_module, "Brex Validation"),
    Check(check_schema, "Correct Schema/Infocode"),
    Check(validate_images, "No Missing Graphics"),
    Check(check_cage, "Correct Organisation Name"),
    Check(search_non_utf8, "No Invalid Characters"),
    Check(verify_dm_names, "Correct DM names (modellic, systemDiffCode)"),
    Check(check_frontmatter_dms, "Front Matter Boilerplate Up To Date"),
    Check(do_wcn_check, "Warnings/Cautions/Notes match", needs_verification=True),
    Check(do_title_check, "Title Page Information Matches Source", needs_verification=True),
    Check(check_consolidate, "No Consolidation Errors"),
    Check(unused_graphics, "No Unreferenced Graphics"),
    Check(broken_ref_finder, "PDF: No Broken Links"),
    Check(missing_graphics_finder, "PDF: No Missing Graphics"),
    Check(blank_finder, "PDF: No Incorrect Blank Pages"),
    Check(unused_files, "No Unused files"),
]

completed = 0
lock = Lock()
def run_module_checks(name, module, refs, data_modules, images, info_entity_idents, cage, brexes, modellic, doctype):
    global completed
    global lock
    for check in checks[1:-9]:
        check.validate(name, module, refs, dms=data_modules, imgs=images, ieis=info_entity_idents, cage=cage, brexes=brexes, modellic=modellic, doctype=doctype)
    with lock:
        completed += 1
        print(f"\tRunning module checks... {completed}/{len(data_modules)}", end="\r")

def main(path:Path, out_file="validation.html", job_number=None, doctype=None):
    """Main function"""
    cage = None
    
    job_no = job_number or input("Enter the job number: ")
    if job_no:
        out_file = f'{job_no}_validation.html'
    print("Getting Brex files... ", end="\r")
    brexes = get_brexes()
    print("Getting Brex files... Done!")
    print("Please select PDFs")
    # Tk().withdraw()
    root = Tk()
    root.withdraw()
    root.wm_attributes('-topmost', 1)
    pdf_path = askopenfilename(parent=root, initialdir=str(path), title='Choose Converted PDF.', filetypes=(("PDF Files", "*.pdf"), ("All Files", "*.*")))
    source_pdf_path = askopenfilename(parent=root, initialdir=str(path), title='Choose Source PDF.', filetypes=(("PDF Files", "*.pdf"), ("All Files", "*.*")))
    print("Collecting source files...", end="\r")
    source_files = list(path.glob("*MC*.xml"))
    print("Collecting source files... Done!")
    ####
    print("Preparing HTML Template...", end="\r")
    parsed_template = ET.fromstring(html_template)
    head = parsed_template.find("head")
    head.find("title").text = f'{job_no} QA Validation'

    body = parsed_template.find("body")
    body.find("table/tr/td[@id='time']").text = datetime.now().strftime("%H:%M:%S")
    body.find("table/tr/td[@id='date']").text = datetime.now().strftime("%B %d, %Y")
    body.find("table/tr/td[@id='user']").text = os.getlogin()
    body.find("table/tr/td[@id='job_no']").text = job_no
    data_modules = {}
    print("Preparing HTML Template... Done!")
    ####
    print("Gathering images...", end="\r")
    try:
        images = get_images(path)
    except NotADirectoryError:
        images = None
        print("Gathering images... Error: No images found.")
    else:
        print("Gathering images... Done!")
    ###
    info_entity_idents = set([])
    with open(path / out_file, 'w') as output:
        for i,source_file in enumerate(source_files):
            print(f"Parsing Data Modules: {i}/{len(source_files)}", end="\r")
            dm = DataModule(source_file)
            try:
                root = checks[0].validate(source_file.name, dm)
            except:
                print(format_exc())

            if isinstance(root, list) or root is None:
                continue

            data_modules[source_file.stem.split('_')[0]] = dm
            
            if "PMC" in source_file.name:
                cage = dm.root.find("identAndStatusSection/pmAddress/pmIdent/pmCode[@pmIssuer]").attrib['pmIssuer']
        if cage is None:
            cage = input("CAGE not found. Please ensure there is a PMC file with the CAGE code listed, or input it here: ")
        print(f"Parsing Data Modules: {len(source_files)}/{len(source_files)}")
        ####
        print("Getting Modellic and Doctype from DB...", end='\r')
        modellic, doctype = get_from_db(job_no, cage, man_type=doctype)
        print("Getting Modellic and Doctype from DB... Done!")
        ####
        print("Running validation checks... ")
        refs = set([])
        # Validations:
        print(f"\tRunning module checks... 0/{len(data_modules)}", end="\r")
        with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
            for i, (name, module) in enumerate(data_modules.items()):
                executor.submit(run_module_checks, name, module, refs, data_modules, images, info_entity_idents, cage, brexes, modellic, doctype)
                # run_module_checks(name, module, refs, dms=data_modules, imgs=images, ieis=info_entity_idents, cage=cage, brexes=brexes, modellic=modellic, doctype=doctype)

        print(f"\tRunning module checks... {len(data_modules)}/{len(data_modules)}")
        print(f"\tRunning global checks... ", end="\r")
        # for name, module in data_modules.items():
        #     for check in checks[1:-8]:
        #         check.validate(name, module, refs, dms=data_modules, imgs=images, ieis=info_entity_idents, cage=cage, brexes=brexes, modellic=modellic, doctype=doctype)
        
        checks[-1].validate("Unused Files: ", None, refs, dms=data_modules)
        # with fitz.open(pdf_path) as pdf_file:
        #     page_text = [page.getText() for page in pdf_file]
        #     checks[-2].validate("Blank Pages: ", None, page_text=page_text, pdf_file=pdf_file)
        #     checks[-3].validate("Missing Graphics: ", None, page_text=page_text)
        #     checks[-4].validate("Broken Links: ", None, page_text=page_text)
        pdf_file = fitz.open(pdf_path)
        page_text = [page.getText() for page in pdf_file]
        checks[-2].validate("Blank Pages: ", None, page_text=page_text, pdf_file=pdf_file)
        checks[-3].validate("Missing Graphics: ", None, page_text=page_text)
        checks[-4].validate("Broken Links: ", None, page_text=page_text)
        checks[-5].validate("Unreferenced Graphics: ", None, imgs=images, ieis=info_entity_idents)
        pdf_file.close()
        checks[-6].validate("Consolidation Error: ", None, path=path)
        
        # with fitz.open(source_pdf_path) as source_pdf_file:
            # source_page_text = [page.getText() for page in source_pdf_file]
            # alp, bta = pages_to_text(check_pages(page_text), check_pages(source_page_text))
        checks[-7].validate("Title Page Information: ", None, book_1=pdf_path, book_2=source_pdf_path)
        checks[-8].validate("Warnings/Cautions/Notes: ", None, pdf_path_1=pdf_path, pdf_path_2=source_pdf_path)
        checks[-9].validate("Modules Need Replacing: ", None, path=path)
        source_pdf_file = fitz.open(source_pdf_path)
        source_page_text = [page.getText() for page in source_pdf_file]
        alp, bta = pages_to_text(check_pages(page_text), check_pages(source_page_text))
        source_pdf_file.close()
        accuracy = accuracy_check(alp, bta)
        print(f"\tRunning global checks... Done!")
        # print("Running validation checks... Done!")
        print("Writing report... ", end="\r")
        for check in checks:
            body.append(check.generate_report())
        e_acc = body.find("table/tr/td[@id='accuracy']")
        e_acc.append(E.b(str(accuracy) + "%" if isinstance(accuracy, float) else "Error"))
        if isinstance(accuracy, float):
            e_acc.attrib['class'] = "pass" if accuracy >= ACCURACY_THRESHOLD else "warning"
        else:
            e_acc.attrib['class'] = "error"

        e_stat = body.find("table/tr/td[@id='state']")
        if any(c.state != "Pass" for c in checks):
            if any(c.state == "Fail" for c in checks):
                e_stat.text = "Fail"
            elif any(c.state == "Verify" for c in checks):
                e_stat.text = "Verify"
            else:
                e_stat.text = "Error"
        else:
            e_stat.text = "Pass"
        e_stat.attrib['class'] = "pass" if e_stat.text == "Pass" else "fail"
        e_cage = body.find("table/tr/td[@id='cage']")        
        e_cage.text = cage
        output.write(ET.tostring(parsed_template, method='html').decode(encoding="utf-8"))
        print("Writing report... Done!")
    print('Complete.')
if __name__ == "__main__":
    path = input("Input the path of the job folder. (Leave blank to use current directory): ")
    while path:
        if Path(path).is_dir():
            break
        path = input("Invalid directory. Input the path of the job folder. (Leave blank to use current directory): ")

    main(Path(path or '.'))
