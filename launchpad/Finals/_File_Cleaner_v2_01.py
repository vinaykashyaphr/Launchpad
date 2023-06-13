from sonovision.s1000d_helper import DmRef, DataModule, get_working_directory
from msvcrt import getch
import re
try:
    from launchpad.functions import log_print
except ImportError:
    def log_print(message, log_file="file_cleaner_report.log", log_only=False):
        if not log_only:
            print(message)
        with open(log_file, "w") as f:
            f.write(message + "\n")

LANG_AREA_SUFFIX = "_sx-US"

def report(s, word, log_path):
    if len(s):
        log_print(f"\n{word} files:", log_path)
        for f in s:
            log_print(f.replace(".XML", f"{LANG_AREA_SUFFIX}.XML"), log_path)
    else:
        log_print(f"\nNo {word} Files", log_path)

def backup_or_delete(working_path, unused_modules, data_modules, key='2'):
    def cleanup_module(module):
        if key == '1':
            (working_path / module).unlink(missing_ok=True)
        elif key == '2':
            (working_path / module).rename(working_path / 'Backup' / module)

        for dm in list(data_modules):
            if dm.filename.lower() == module.lower():
                data_modules.remove(dm)
    if not key in {'1', '2', '3'}:
        print("\nWhat would you like to do with the Unused files?\n[1] - Delete\n[2] - Back Up\n[3] - Ignore")
        while (key := getch().decode(encoding='utf-8')) not in {'1', '2', '3'}:
            continue

    # os.system('cls')
    if key != "3":
        if key == '2':
            (working_path / "Backup").mkdir(exist_ok=True)

        for module in unused_modules:
            try:
                cleanup_module(module)
            except:
                cleanup_module(module.replace(".XML", f"{LANG_AREA_SUFFIX}.XML"))
        
        if key == '1':
            log_print("Unused Files Deleted", str(working_path / "report.log"))
        elif key == '2':
            log_print("Unused Files Backed Up", str(working_path / "report.log"))
    else:
        log_print("Unused Files Ignored", str(working_path / "report.log"))

def trim_filename(filename):
    filename = re.sub(r"\.xml", r".XML", filename)
    filename = re.sub(r"_001-00", r"", filename)
    filename = re.sub(r"_[a-z]{2}-[A-Z]{2}", r"", filename)
    return filename

def main(working_path, data_modules=[], unused_files_default_action='2'):
    log_path = str(working_path / 'report.log')
    log_print("\n========== FILE CLEANER ==========", log_path)
    if not data_modules:
        data_modules = [DataModule(f) for f in working_path.glob("*.xml")]
    filenames = {trim_filename(module.filename) : module.schema.name for module in data_modules if module.filename[0:3] != "PMC"}
    used_files = set({})
    missing_files = set({})

    pmc = list(working_path.glob("PMC*.xml"))
    if len(pmc) != 1:
        if len(pmc) == 0:
            log_print("No PMC found.")
        else:
            log_print("Multiple PMCs found. Please ensure only one PMC exists in the directory.")
        return

    for dmcode in DataModule(pmc[0]).root.findall(".//dmCode"):
        dmref = DmRef().from_xml(dmcode)
        dmref_name = dmref.as_name + ".XML"
        try: 
            del filenames[dmref_name]
            used_files.add(dmref_name)
        except KeyError:
            if dmref_name not in used_files and "022A" not in dmref_name and dmref_name_sxus not in used_files:
                missing_files.add(dmref_name)

    for f, s in list(filenames.items()):
        if s in {"comrep.xsd", "prdcrossreftable.xsd"}:
             del filenames[f]

    for s, word in [(missing_files, "Missing"), (filenames, "Unused")]:
        report(s, word, log_path)

    if len(filenames):
        backup_or_delete(working_path, filenames, data_modules, key=unused_files_default_action)

    return not len(missing_files)

if __name__ == "__main__":
    main(get_working_directory(), unused_files_default_action=None)