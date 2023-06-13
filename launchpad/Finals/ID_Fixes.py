from sonovision.s1000d_helper import DataModule,DmRef,get_working_directory
from pathlib import Path

from lxml import etree as ET
from lxml.builder import E

import os
import math
import re
from msvcrt import getch
parsed_dms = []

dm_ids = {}

global_ids = {
    "tool": {},
    "seq": {},
    "cons": {},
    "sup": {},
    "spa": {},
    # "warn": {},
    # "caut": {},
    # "tab": {},
    # "fig": {},
}

cir_search_strings = {
    "tool": ".//supportEquipDescr/toolRef/[@toolNumber]",
    "sup": ".//supplyDescrGroup/supplyDescr/supplyRef/[@supplyNumber]",
    "seq": ".//supportEquipDescrGroup/supportEquipDescr/[@id]",
    "cons": ".//supplyDescrGroup/supplyDescr/[@id]",
    "spa": ".//spareDescrGroup/spareDescr/[@id]",
    # "warn": ".//warningsAndCautionsRef/warningRef/[@warningIdentNumber]",
    # "caut": ".//warningsAndCautionsRef/cautionRef/[@cautionIdentNumber]",
    # "tab": ".//table/[@id]",
    # "fig": ".//figure/[@id]",
}


def digits(n):
    return int(math.log10(n))+1

def unique_ids(data_module):
    root = data_module.root
    ids = {}
    
    for key,search in {"tab": ".//table[@id]", "fig": ".//figure[@id]", "rfu": "./identAndStatusSection/dmStatus/reasonForUpdate[@id]", "gra": ".//graphic"}.items():
        counter = 1
        for elem in root.findall(search):
            new_id = f"{key}-{'0' * (4 - digits(counter))}{counter}"
            if 'id' in elem.attrib:
                ids[elem.attrib['id']] = new_id
            elem.attrib['id'] = new_id
            counter += 1
    # module_name = re.match(r'[PD]MC[^_.]+', data_module.filename).group(0)
    dm_ids[data_module.module_name] = ids

    for key in list(global_ids):
        for elem in root.findall(cir_search_strings[key]):
            attr = cir_search_strings[key].rsplit('/', 1)[1].strip('[]@')
            attr_value = elem.attrib[attr]
            if attr_value not in global_ids[key]:
                new_id = f"{key}-{'0' * (4 - digits(len(global_ids[key]) + 1))}{len(global_ids[key]) + 1}"
                global_ids[key][attr_value] = new_id
                elem.attrib[attr] = new_id
            else:
                elem.attrib[attr] = global_ids[key][attr_value]

def update_cirs(root, ident_xpath, key, attr):
    for ident in root.findall(ident_xpath):
        if (_id := global_ids[key].get(ident.attrib[attr])) is not None:
            ident.attrib['id'] = ident.attrib[attr] = _id
        else:
            # Resequence
            global_ids[key][ident.attrib[attr]] = ident.attrib['id'] = ident.attrib[attr] = f"{key}-{'0' * (4 - digits(len(global_ids[key]) + 1))}{len(global_ids[key]) + 1}"

def fix_refs(data_module):
    root = data_module.root
    # if data_module.schema.name == "comrep.xsd":
    if "00NA" in data_module.filename:
        update_cirs(root, ".//toolRepository/toolSpec/toolIdent", "tool", "toolNumber")
    elif "00LA" in data_module.filename:
        update_cirs(root, ".//supplyRepository/supplySpec/supplyIdent", "sup", "supplyNumber")
    # elif "012A" in data_module.filename:
    #     update_cirs(root, ".//warningRepository/warningSpec/warningIdent", "warn", "warningIdentNumber")
    # elif "012B" in data_module.filename:
    #     update_cirs(root, ".//cautionRepository/cautionSpec/cautionIdent", "caut", "cautionIdentNumber")
    else:
        for iref in root.findall(".//internalRef[@internalRefId]"):
            #for key in {"seq", "cons", "spa"}:
            for key in {"cons", "seq"}:
                if iref.attrib['internalRefId'] in global_ids[key]:
                    iref.attrib['internalRefId'] = global_ids[key].get(iref.attrib['internalRefId'])
                    break
            else:
                iref.attrib['internalRefId'] = dm_ids[data_module.module_name].get(iref.attrib['internalRefId'], iref.attrib['internalRefId'])

        for rfu_id in root.findall(".//*[@reasonForUpdateRefIds]"):
            rfu_id.attrib['reasonForUpdateRefIds'] = dm_ids[data_module.module_name].get(rfu_id.attrib['reasonForUpdateRefIds'], rfu_id.attrib['reasonForUpdateRefIds'])

        for dmref in root.findall(".//dmRef[@referredFragment]"):
            dmref_obj = DmRef().from_xml(dmref)
            dmref_name = dmref_obj.as_name
            if dmref_name not in dm_ids:
                print(f"Broken dmRef in {data_module.filename}. Data Module {dmref_name} does not exist in this directory.")
                continue
            dmref.attrib['referredFragment'] = dm_ids[dmref_name].get(dmref.attrib['referredFragment'], dmref.attrib['referredFragment'])

def main(working_directory, data_modules={}):
    print("Fixing IDs... Please Wait.")
    if not len(data_modules):
        data_modules = [DataModule(dm) for dm in working_directory.glob("DMC*.xml")]

    for dm in data_modules:
        unique_ids(dm)

    for dm in data_modules:
        fix_refs(dm)
        dm.to_file()

if __name__ == "__main__":
    main(get_working_directory())
    os.system('cls')
    print("Completed. Press any key to exit...")
    getch()