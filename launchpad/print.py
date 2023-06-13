from pathlib import Path
import subprocess
import os
from traceback import format_exc
import re

doctypes = {
    'CMM': {
        "CMM": 'cmm',
        "FMM": 'fmm',
        "IRM": 'irm',
        "ORIM": 'orim',
        "SPM": 'spm',
        "ACMM": 'acmm',
        "IPC": 'ipc',
        "GEM": 'gem',
        "MM": 'mm',
        "OHM": 'ohm',
        "Line MM": 'lnmm',
    },
    'EM': {
        "EM": 'em',
        "MM": 'emm',
        "LMM": 'lmm',
        "HMM": 'hmm',
        "OHM": 'eohm',
        "AMM": 'amm',
        "SPM": 'espm',
    },
    'SDOM': {
        "SDOM": 'sdom',
        "SDIM": 'sdim',
        "IM": 'im',
    },
    'EIPC': {
        'EIPC': 'eipc',
    }
}

def create_folder_structure(path):
    if path.is_dir():
        return

    for x in reversed(path.parents):
        if not x.is_dir():
            x.mkdir()
    path.mkdir()

def consolidate(path, print_dm_codes, manual_type, manual_variant):
    consolidated = None
    path = Path(path)
    # os.chdir(path)
    if not Path(os.environ['ARBORTEXT_HOME']).is_dir():
        raise NotADirectoryError("Could not locate Arbortext Editor")

    custom = os.environ.get('APTCUSTOM', "V:\\500\\00-Printing-Tools\Honeywell_Print-S1000D")
    print("Consolidating XML")
    nbpi = "nbpi" if manual_type in {'CMM', 'SDOM'} else "nbpi_EM"
    # Move the files
    subprocess.call([
        f"{custom}\custom\\doctypes\\S1000D-pm\\{nbpi}\\copy_scripts.bat",
        f"{custom}\custom\\doctypes\\S1000D-pm",
        str(path)])
    # Get the PMC and pass it to consolidate bat file
    file_name = list(path.glob("PMC*.xml"))[0]
    
    try:
        if (path / "00-S1000D-collect-files.bat").is_file():
            output = subprocess.check_output(f"start /wait cmd /c consolidate.bat {str(path)} {file_name.name} {manual_variant}, {'dmc' if print_dm_codes else 'std'}", shell=True)
            # output = subprocess.check_output([
            #         str(path / "00-S1000D-collect-files.bat"),
            #         str(file_name), 
            #         manual_variant, 
            #         'dmc' if print_dm_codes else 'std']
            #     , stderr=subprocess.STDOUT)
        else:
            raise FileNotFoundError("00-S1000D-collect-files.bat not found. Failed to copy files.")
    except Exception as e:
        print(e)
    else:
        consolidated = list(path.glob("*CONSOLIDATED.xml"))[0]
        # if b"Error" in output:
        #     print("Consolidation failed!")
        # else:
        #     print("Consolidation succeeded!")
    finally:
        print("Cleaning up...")
        for ext in [
                '*.ent', '*.xmx', '*.xmy', 'S1000D*.xml', '*.jar',
                '*.bat', '*.xsl', '*.ant', '0000*.log', '*.xqy']:
            files_to_delete = list(path.glob(ext))
            for f in files_to_delete:
                f.unlink()

    return consolidated

def print_PDF(path, consolidated, manual_type):
    if consolidated is None:
        return

    folder = f"_{manual_type}" if manual_type in {"EM", "EIPC"} else ""
    p = Path(f"{path}\Honeywell_XSL-FO")
    xml_input = p / f"S1000D{folder}_DRIVER\XML_INPUT\graphics"
    create_folder_structure(xml_input)

    pdf_output = p / f"S1000D{folder}_DRIVER\PDF_OUTPUT"
    create_folder_structure(pdf_output)

    temp = p / f"S1000D{folder}_DRIVER\TEMP"
    create_folder_structure(temp) 
    try:
        consolidated.replace(
            p / f"S1000D{folder}_DRIVER/XML_INPUT/{consolidated.name}")
        subprocess.check_output(f"start /wait cmd /c server_print.bat {Path(path).resolve()} {folder}", shell=True)
        # subprocess.call([
        #     f"{os.environ['XSL_PATH']}\\S1000D_DRIVER\\RUN_S1000D.bat",
        #     path + "\\Honeywell_XSL-FO\\S1000D_DRIVER\\"])
    except Exception as e:
        raise e
    # finally:
    #     os.chdir(launchpad_path)

    try:
        for f in (p / f"S1000D{folder}_DRIVER\\PDF_OUTPUT").glob("*"):
            f.rename(Path(path) / re.sub(r"(?i)\.xml\.CONSOLIDATED", "", f.name))

        for f in (p / f"S1000D{folder}_DRIVER\\TEMP").glob("*"):
            if f.suffix.lower() in [".xep", ".junk", ".xml", ".fo"]:
                f.unlink()

        for f in Path(path).glob("*.zip"):
            f.unlink()

    except Exception:
        print(format_exc())
        # input()


if __name__ == "__main__":
    cons = consolidate(Path('.'))
    print_PDF(Path('.'), cons)
