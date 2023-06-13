import re
from sonovision.s1000d_helper import get_working_directory, DataModule
from lxml.builder import E
from launchpad.functions import log_print

def fix_00W(dm, dmref_00p):
    if (cond_crt_ref := dm.root.find(".//condCrossRefTableRef")) is not None:
        cond_crt_ref.getparent().remove(cond_crt_ref)

    if (product_crt_ref := dm.root.find(".//productCrossRefTableRef")) is not None:
        product_crt_ref.clear()
        product_crt_ref.append(dmref_00p.as_xml)
        # product_crt_ref.attrib['infoCode'] = "00P"
        

def fix_00P(dm):
    if (refs := dm.root.find(".//content/refs")) is not None:
        refs.getparent().remove(refs)

def fix_pmc(dm, dmref_00w, working_directory):
    # Ensure CAGE code is in PMC (Check)
    orig = dm.root.find(".//originator")
    rpc = dm.root.find(".//responsiblePartnerCompany")
    if orig is not None and rpc is not None:
        if not orig.attrib.get('enterpriseCode', "") and not rpc.attrib.get('enterpriseCode', ""):
            log_print("CAGE code missing in PMC. Please ensure responsiblePartnerCompany@enterpriseCode and originator@enterpriseCode are filled out correctly.", str(working_directory/ 'report.log'))
            # cage = input("CAGE code missing in PMC. Enter CAGE now: ").upper()
            # while re.match('[A-Z0-9]{5}$', cage) is None:
            #     cage = input("Invalid CAGE code. Please enter a valid CAGE code (5 alphanumeric characters): ").upper()
            # orig.attrib['enterpriseCode'] = rpc.attrib['enterpriseCode'] = cage

    # Add 00W ref to the PMC (Check)
    if dmref_00w is not None:
        dmref_00w = dmref_00w.as_xml
        acrtref = dm.root.find(".//applicCrossRefTableRef")
        if acrtref is not None:
            acrtref.clear()
            acrtref.append(dmref_00w)
        else:
            acrtref = E.applicCrossRefTableRef(dmref_00w)
            if orig is not None:
                op = orig.getparent()
                op.insert(op.index(orig) + 1, acrtref)

def fix_tables(dm):
    for entry in dm.root.findall(".//table//entry"):
        para = None
        if not len(entry) and not entry.text:
            continue

        if entry.text is not None:
            if entry.text.strip():
                para = E.para(entry.text)
                entry.append(para)
                entry.text = ""

        for e in entry:
            if e.tag in {"internalRef", "dmRef", "randomList", "sequentialList"}:
                if para is not None:
                    para.append(e)
                else:
                    entry.insert(entry.index(e), E.para(e))
                continue
            if e.tail is not None:
                if e.tail.strip():
                    entry.insert(entry.index(e) + 1, E.para(e.tail))
                    e.tail = ""

            if e.tag in {"para", "note", "warning", "caution"}:
                para = None

if __name__ == "__main__":
    for f in get_working_directory().glob("*.xml"):
        dm = DataModule(f)
        fix_tables(dm)
        dm.to_file()