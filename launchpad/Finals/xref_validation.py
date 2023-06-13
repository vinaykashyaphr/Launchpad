from pathlib import Path
from sonovision.s1000d_helper import DataModule, DmRef, get_xpath, get_working_directory
from lxml import etree as ET
from launchpad.functions import log_print

def main(path:Path):
    """Main function"""
    source_files = path.glob("*MC*.xml")
    errors = False
    log_path = str(path / "report.log")
    data_modules={}
    for source_file in source_files:
        dm = DataModule(source_file)
        try:
            dm.parse()
        except ET.ParseError as e:
            errors = True
            log_print(source_file.name + " - Parse Error: " + e + '\n', log_path)
            continue

        data_modules[source_file.stem.split('_')[0]] = dm
    refs = set([])
    # Validations:
    for name, module in data_modules.items():
        broken_refs = broken_xrefs(module, refs, dms=data_modules)

        if broken_refs:
            errors = True
            log_print(name + ":", log_path)
            log_print('\n'.join(broken_refs) + '\n', log_path)
        
    unused = unused_files(None, refs, dms=data_modules)

    if not errors:
        log_print("Success - No errors detected!", log_path)
        
    return not errors

def broken_xrefs(dm, refs, *args, dms={}, **kwargs) -> list:
    """
    Checks all cross-references to see if the referenced module and referred fragment (if applicable) exist

    : dm : Data Module object \n
    : refs : Set of referenced Data Modules. \n
    : dms : A dictionary of Data Module objects using the module name as a key\n
    : return : A list of all broken references
    """

    broken_refs = []
    for dmref in dm.root.findall(".//dmRef"):
        if dmref.getparent().tag == "brexDmRef":
            continue
        dmref_obj = DmRef.from_xml(dmref)
        refs.add(dmref_obj.as_name)
        if dmref_obj.as_name in dms:
            if dmref_obj.referredFragment and dmref_obj.referredFragment not in dms[dmref_obj.as_name].ids:
                broken_refs.append(f'Invalid reference to referredFragment"{dmref_obj.referredFragment}" ({dmref_obj.as_name}): that ID does not exist in the Data Module.')
        else:
            broken_refs.append(f"Invalid reference to Data Module '{dmref_obj.as_name}': that Data Module does not exist. ({get_xpath(dmref)})")
    return broken_refs

def unused_files(dm, refs, *args, dms={}, **kwargs) -> list:
    """
    Checks all cross-references to see if the referenced module and referred fragment (if applicable) exist

    : dm : Data Module object \n
    : refs : Set of referenced Data Modules. \n
    : dms : A dictionary of Data Module objects using the module name as a key \n
    : return : 
    """
    return [f for f in set(dms.keys()) - refs if f[0:3] != "PMC"]

if __name__ == "__main__":
    working_directory = get_working_directory()
    main(working_directory, "_xref_validation_report.txt")