from pathlib import Path

from lxml import etree as ET
from lxml.builder import E
from sonovision.s1000d_helper import DataModule, get_working_directory


def cleanup(root, source_file):
    # Fixes
    if "-00NA-" in source_file.name:
        for t in root.xpath('./content/commonRepository/toolRepository/toolSpec[not(procurementData)]'):
            t.extend([E.procurementData(), E.techData(), E.toolAlts(E.tool(E.itemDescr()))])
    elif "-00WA-" in source_file.name:
        for t in root.xpath('./content/applicCrossRefTable/productAttributeList/productAttribute[@useForPartsList]'):
            t.attrib.pop('useForPartsList')
        crt = root.find('./content/applicCrossRefTable/condCrossRefTableRef')
        if crt is not None:
            crt.getparent().remove(crt)
    elif "-941A-" in source_file.name:
        for t in root.xpath('./content/illustratedPartsCatalog/catalogSeqNumber/itemSeqNumber/genericPartDataGroup'):
            for x in t.xpath('./genericPartData[genericPartDataValue[not(text()[normalize-space()])]]'):
                t.remove(x)
            if len(t) == 0:
                t.getparent().remove(t)
    elif "PMC" in source_file.name:
        lep = root.find("./content/pmEntry[@pmEntryType='pmt56']")
        if lep is not None and len(lep) == 1:
            lep.append(E.externalPubRef(E.externalPubRefIdent(), authorityDocument="LEP"))
        logo = root.find('./identAndStatusSection/pmStatus/logo')
        if logo is not None:
            logo.getparent().remove(logo)

        if 'logo' in root.attrib:
            root.attrib.pop('logo')

        for p in root.xpath('./content/pmEntry[not(node())]'):
            p.getparent().remove(p)
    else:
        procedure = root.find('./content/procedure')
        if procedure is not None:
            # Clean empty 'warningsAndCautionsRef'
            wcr = root.find('./content/warningsAndCautionsRef')
            if wcr is not None and not len(wcr):
                wcr.getparent().remove(wcr)

            # Clean empty Procedural Steps
            for x in procedure.xpath('./mainProcedure//proceduralStep[not(normalize-space())]'): x.getparent().remove(x)

            # Clean empty commonInfo tags
            for x in procedure.xpath("commonInfo[not(node())]"): x.getparent().remove(x)

            # Clean empty preliminary requirements
            p = procedure.find('preliminaryRqmts')
            if p is not None:
                for prelim_req in {("SupportEquips", "supportEquip"), ("Supplies", "supply"), ("Spares", "spare"), ("Safety", "")}:
                    req = p.find(f"req{prelim_req[0]}")
                    if req is not None:
                        descr_group = req.find(f'./{prelim_req[1]}DescrGroup')
                        if descr_group is not None:
                            for y in descr_group.xpath(f'{prelim_req[1]}Descr[not(normalize-space())]'):
                                descr_group.remove(y)
                            if not len(descr_group):
                                req.remove(descr_group)
                        if not len(req):
                            req.append(E(f"no{prelim_req[0]}"))

    # Changes languageIsoCode to 'sx' if it's 'en'
    lang = root.find('./identAndStatusSection/dmAddress/dmIdent/language')
    if lang is not None:
        lang.attrib['languageIsoCode'] = 'sx' if lang.attrib['languageIsoCode'] == "en" else lang.attrib['languageIsoCode']

    # Remove 'remarks' tag
    remarks = root.find('./identAndStatusSection/dmStatus/remarks')
    if remarks is not None:
        remarks.getparent().remove(remarks)

    # Changes issueNumber to '001' for all DMCs
    issue = root.find('./identAndStatusSection/dmAddress/dmIdent/issueInfo')
    if "DMC" in source_file.name and issue is not None:
            issue.attrib['issueNumber'] = '001'

    dmstatus = root.find('./identAndStatusSection/dmStatus')
    if dmstatus is not None:
        qa = dmstatus.find('qualityAssurance')
        if qa is not None:
            qa.clear()
            qa.append(E.firstVerification(verificationType="tabtop"))
            qa.tail = '\n'
        else:
            dmstatus.append(E.qualityAssurance(E.firstVerification(verificationType="tabtop")))
        
        b = E.dmRef(E.dmRefIdent(E.dmCode(
            assyCode="00",
            disassyCode="00",
            disassyCodeVariant="A",
            infoCode="022",
            infoCodeVariant="A",
            itemLocationCode="D",
            modelIdentCode="HONAERO",
            subSubSystemCode="0",
            subSystemCode="0",
            systemCode="00",
            systemDiffCode="A"
        )))
        
        brex = dmstatus.find('brexDmRef')
        if brex is not None:
            brex.clear()
            brex.append(b)
            brex.tail='\n'
        else:
            dmstatus.append(E.brexDmRef(b))

def main(path, with_cleanup=True):
    log = ""
    print("Validating XML")
    for source_file in path.glob('*MC*.xml'):
        dm = DataModule(source_file)
        root = dm.root

        if root is None:
            print(f"Could not find root in {source_file.name}. Skipping.")
            continue

        if with_cleanup:
            cleanup(root, source_file)
            dm.to_file()

        # Validation
        # dm.schema.validate(tree)
        results = validate(dm)
        if len(results):
            log_entry = '\n'.join(results + ['----------------------------------------------\n'])
            log += log_entry + '\n'

    if not log:
        log += "No Validation Errors"

    (path / 'validation_output.log').write_text(log, encoding='utf-8')

def validate(dm, *args, **kwargs):
    # Validation
    dm.schema.validate(dm.tree)
    return list(map(str, dm.schema.error_log.filter_from_errors()))

if __name__ == "__main__":
    main(get_working_directory(), with_cleanup=False)
    # input()