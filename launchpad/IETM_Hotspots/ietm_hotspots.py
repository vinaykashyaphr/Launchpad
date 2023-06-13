from sonovision.s1000d_helper import get_working_directory, DataModule
from lxml import etree as ET
from lxml import html
import re
import logging
from logging import INFO, log, basicConfig

def main(modules_folder, graphics_folder, replace=True):
    # Insert Hotspots
    if not (modules_folder / "result").is_dir() and not replace:
        (modules_folder / "result").mkdir()

    total_callout_refs = 0
    total_hotspots = 0
    total_dms_modified = 0
    basicConfig(filename=str(modules_folder / "result.log"), level=logging.INFO, format="%(message)s")
    print("Running...")
    for dm in modules_folder.glob("DMC*.xml"):
        dm = DataModule(dm)
        log (logging.INFO, f"Processing {dm.filename}:")
        hotspot_dict = {}
        graphics = dm.root.findall(".//graphic[@infoEntityIdent]")
        if len(graphics) == 0:
            log(logging.INFO, "    No graphics found")
            continue
        has_hotspots = False
        for graphic in graphics:
            log(logging.INFO, f"    Adding hotspots to {graphic.attrib['infoEntityIdent']}")
            if len(graphic) > 0:
                # print(f"        Removing {len(graphic)} children")
                for child in graphic.iterchildren():
                    graphic.remove(child)

            if (hotspots_file := (graphics_folder / (graphic.attrib['infoEntityIdent'] + ".txt"))).is_file():
                hotspot_xml = html.parse(str(hotspots_file))
                hotspots = list(hotspot_xml.iter())
                if len(hotspots) > 2:
                    has_hotspots = True
                    total_dms_modified += 1
                    hotspot_dict[graphic.attrib['infoEntityIdent']] = {}
                    hotspots = hotspots[2:]
                    total_hotspots += len(hotspots)
                    log(logging.INFO, f"        Adding {len(hotspots)} hotspots.")
                    for hs in hotspots:
                        hs.tail = "\n"
                        graphic.append(hs)
                        hotspot_dict[graphic.attrib['infoEntityIdent']][hs.attrib['applicationstructurename']] = "_1" if hs.attrib['applicationstructurename'] in hotspot_dict[graphic.attrib['infoEntityIdent']] else ""
                        
                        # hotspot_dict[graphic.attrib['infoEntityIdent']].add(hs.attrib['applicationstructurename'])
                    if not replace:
                        dm.to_file(dest_file=(modules_folder / "result" / dm.filename))
                    else:
                        dm.to_file(dest_file=(modules_folder / dm.filename))
                else:
                    log(logging.INFO, "        No hotspots found in file.")
            else:
                log(logging.INFO, "        No hotspot file found.")
        
        if not has_hotspots:
            continue
        
        dm_hotspots_replaced = 0

        def insert_ref(match):
            nonlocal hotspot_dict
            nonlocal dm_hotspots_replaced
            text = match.group(0)
            for icn, d in hotspot_dict.items():
                if text in d:
                    suffix = d[text]
                    dm_hotspots_replaced += 1
                    icn = icn.split('-')[2]
                    return f'<internalRef internalRefId="hot-{text}{suffix}-{icn}" internalRefTargetType="irtt11"/>'
            else:
                log(logging.INFO, f"         Couldn't find hotspot '{text}' in data module {dm.filename}.")
                return text

        def insert_refs(match):
            return re.sub("\d+[A-Z]?", insert_ref, match.group(0))

        def check_text(match):
            text = match.group(1)
            text = re.sub(r"\(\d+[A-Z]?(?:,\s*\d+[A-Z]?)*\)", insert_refs, text)
            return f'>{text}<'
        log(logging.INFO, "    Adding callout references")
        if not replace:
            dm._source_file = (modules_folder / "result" / dm.filename)
        else:
            dm._source_file = (modules_folder / dm.filename)
        text = dm._source_file.read_text(encoding='utf-8')
        text = re.sub(r'>([^<]+)<', check_text, text)
        text = re.sub(r'<hotspot([^>]+?)/>', r'<hotspot\1></hotspot>', text)
        text = re.sub(r'applicationstructureident', 'applicationStructureIdent', text)
        text = re.sub(r'hotspottitle', 'hotspotTitle', text)
        text = re.sub(r'applicationstructurename', 'applicationStructureName', text)
        text = re.sub(r'hotspottype', 'hotspotType', text)
        log(logging.INFO, f"        Added {dm_hotspots_replaced} references")
        total_callout_refs += dm_hotspots_replaced
        dm._source_file.write_text(text, encoding="utf-8")

    log(logging.INFO, "\n\n======= FINAL REPORT ========")
    log(logging.INFO, f"Total DMs Modified:     {total_dms_modified}")
    log(logging.INFO, f"Total Hotspots Added:   {total_hotspots}")
    log(logging.INFO, f"Total References Added: {total_callout_refs}")

if __name__ == "__main__":
    main(get_working_directory(prompt="Input Job Folder: "), get_working_directory(prompt="Input Graphics Folder: "), replace=False)
    input("Completed. Check the Log file located in the DMs folder for more details.")