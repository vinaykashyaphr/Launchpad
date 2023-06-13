import re
from pathlib import Path
import os
from shutil import copy

from sonovision.s1000d_helper import DataModule

try:
    from launchpad import APP
    from launchpad.functions import log_print
except ImportError:
    print("Launchpad not found")
    def log_print(message, log_name, log_only=False):
        print(message)

def replace_entities(entities, text):
    text = re.sub(r"<!ENTITY ICN.*?>\n?", "", text)
    if "<!NOTATION cgm" not in text:
        entities += '<!NOTATION cgm SYSTEM "cgm">\n'
    text = re.sub(r"dmodule \[\s*", fr"dmodule [\n{entities}", text)
    return text

def get_unused_graphics(used_graphics, graphics):
    return [icn + suffix for suffix, icns in graphics.items() for icn in icns if icn not in used_graphics]

def update_graphics_dict(dict1, dict2):
    for key in dict1:
        dict1[key] = dict1[key].union(dict2[key])

def get_graphics_from_dir(path):
    graphics = {".tif": set([]), ".cgm": set([]), ".pdf": set([])}
    for img in path.iterdir():
        if img.is_dir():
            update_graphics_dict(graphics, get_graphics_from_dir(img))
        elif img.suffix in {".cgm", ".tif", ".pdf"}:
            graphics[img.suffix].add(img.stem)
    return graphics

def get_data_modules(working_directory):
    return [DataModule(dm) for dm in working_directory.glob("DMC*.xml")]

def generate_report(missing_pdf_tif, missing_cgm, unused_graphics):
    report = ""
    report += "\nMissing PDFs/TIFs:\n"
    if missing_pdf_tif:
        for m in missing_pdf_tif:
            report += m + '\n'
    else:
        report += "NONE\n"

    report += "\nMissing CGMs:\n"
    if missing_cgm:
        for m in missing_cgm:
            report += m + '\n'
    else:
        report += "NONE\n"

    report += "\nUnused Graphics:\n"
    if unused_graphics:
        for u in unused_graphics:
            report += u + '\n'
    else:
        report += "NONE\n"

    return report

def main(working_directory, data_modules=None, report_name="_cgm_converter_report.txt"):
    log_print("\n========== Image Validation ==========", str(working_directory / 'report.log'))
    if data_modules is None:
        data_modules = get_data_modules(working_directory)
    try:
        honeywell_graphics = Path(os.environ.get('HONEYWELL_GRAPHICS') or r"P:\\HPS\\Honeywell Templates\\graphics\\Output")
    except NameError:
        honeywell_graphics =  Path(r"P:\\HPS\\Honeywell Templates\\graphics\\Output")

    # Get Graphics Folder
    graphics_folder = working_directory / "Graphics"
    if not graphics_folder.is_dir():
        if (working_directory / "graphics").is_dir():
            graphics_folder = working_directory / "graphics"
        else:
            raise Exception("Graphics folder could not be found. Please ensure there is a Graphics folder in the working directory.")

    # Get All Graphics (CGM, TIF, PDF)
    graphics = get_graphics_from_dir(graphics_folder)
    used_graphics = set([])
    missing_pdf_tif = set([])
    missing_cgm = set([])
    honeywell_tifs = set(g.stem for g in honeywell_graphics.glob("*.tif"))
    honeywell_cgms = set(g.stem for g in honeywell_graphics.glob("*.cgm"))
    for dm in data_modules:
        entities = ""
        # Get Graphic References
        for graphic in dm.root.findall(".//*[@infoEntityIdent]"):
            infoEntityIdent = graphic.attrib['infoEntityIdent']
            entities += fr'<!ENTITY {infoEntityIdent} SYSTEM "{graphics_folder.stem}\\{infoEntityIdent}.cgm" NDATA cgm>\n'
            used_graphics.add(infoEntityIdent)
            # Check for missing CGM,TIF/PDF
            if not (infoEntityIdent in graphics['.cgm'] and (infoEntityIdent in graphics['.tif'] or infoEntityIdent in graphics['.pdf'])):
                if infoEntityIdent in graphics['.cgm']:
                    if infoEntityIdent in honeywell_tifs:
                        copy(str(honeywell_graphics / (infoEntityIdent+".tif")), str(graphics_folder / (infoEntityIdent+".tif")))
                    else:
                        missing_pdf_tif.add(infoEntityIdent)
                if infoEntityIdent in graphics['.tif'] or infoEntityIdent in graphics['.pdf']:
                    if infoEntityIdent in honeywell_cgms:
                        copy(str(honeywell_graphics / (infoEntityIdent+".cgm")), str(graphics_folder / (infoEntityIdent+".cgm")))
                    else:
                        missing_cgm.add(infoEntityIdent)
            
        dm._source_file.write_text(replace_entities(entities, dm._source_file.read_text(encoding='utf-8')), encoding='utf-8')


    # Check for unused CGM,TIF,PDF
    unused_graphics = get_unused_graphics(used_graphics, graphics)
    if unused_graphics:
        (graphics_folder / "unused").mkdir(exist_ok=True)
        for g in graphics_folder.glob('**/*'):
            if g.name in unused_graphics:
                g.rename(graphics_folder / "unused" / g.name)

    # Move CGMs to CGM folder (if not already there)
    (graphics_folder / "cgms").mkdir(exist_ok=True)
    for cgm in graphics_folder.glob("*.cgm"):
        cgm.rename(graphics_folder / "cgms" / cgm.name)

    log_print(generate_report(missing_pdf_tif, missing_cgm, unused_graphics), str(working_directory / 'report.log'))
    # Path(report_name).write_text(generate_report(missing_pdf_tif, missing_cgm, unused_graphics), encoding='utf-8')
    
def get_working_directory():
    while True:
        working_path = Path(input("Enter job folder, leave blank to use the current directory: ") or '.')
        if not working_path.is_dir():
            print("Invalid directory.")
            continue
        os.environ['WORKING_DIR'] = str(working_path.resolve())
        os.system('cls')
        return working_path

if __name__ == "__main__":
    main(get_working_directory())

