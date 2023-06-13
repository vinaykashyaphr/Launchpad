from sonovision.s1000d_helper import DataModule, DmRef
from pathlib import Path
from lxml.builder import E
from copy import copy
from launchpad.functions import log_print

def get_warn_caut_repos(modules, path):
    warn_dmref = caut_dmref = None
    for m in modules:
        if m.schema.name == "comrep.xsd":
            if m.root.find(".//warningRepository") is not None:
                warn_dmref = DmRef.from_filename(m.filename).as_xml
            elif m.root.find(".//cautionRepository") is not None:
                caut_dmref = DmRef.from_filename(m.filename).as_xml
        if caut_dmref is not None and warn_dmref is not None:
            break

    if warn_dmref is None:
        log_print("Could not find Warning repository.", str(path/ 'report.log'))
        # while not (warn_file := path / input("Could not find Warning repository. Please input the file manually, or leave blank if it doesn't exist: ")).is_file():
        #     if warn_file == path:
        #         break
        #     continue

        # if warn_file == path:
        #     warn_dmref = None
        # else:
        #     warn_dmref = DmRef.from_filename(warn_file.name).as_xml

    if caut_dmref is None:
        log_print("Could not find Caution repository.", str(path/ 'report.log'))
        # while not (caut_file := path / input("Could not find Caution repository. Please input the file manually, or leave blank if it doesn't exist: ")).is_file():
        #     if caut_file == path:
        #         break
        #     continue

        # if caut_file == path:
        #     caut_dmref = None
        # else:
        #     caut_dmref = DmRef.from_filename(caut_file.name).as_xml

    return warn_dmref, caut_dmref
    
def generate_wcr(root, warn_dmref, caut_dmref, path):
    if root is None:
        log_print(f"Could not find root in {dm.filename}. Skipping.", str(path/ 'report.log'))
        return False
        
    wc_refs = {j for sub in [ref.split() for ref in root.xpath("*//@cautionRefs | *//@warningRefs")] for j in sub}

    if not len(wc_refs):
        return False

    wcr = root.find('./content/warningsAndCautionsRef')
    if wcr is not None:
        wcr.clear()
    else:
        content = root.find('./content')
        if content is not None:
            wcr = E.warningsAndCautionsRef()
            content.insert(0, wcr)
        else:
            log_print(f"Could not generate Warnings and Cautions refs in {dm.filename}: No 'content' element could be found.", str(path/ 'report.log'))
            return False

    for r in wc_refs:
        if "warn" in r and warn_dmref is not None:
            wr = E.warningRef(copy(warn_dmref), id=r, warningIdentNumber=r)
            wr.tail = '\n'
            wcr.insert(0, wr)
        elif "caut" in r and caut_dmref is not None:
            wc = E.cautionRef(copy(caut_dmref), id=r, cautionIdentNumber=r)
            wc.tail = '\n'
            wcr.append(wc)

    return True

def main(path):
    modules = [DataModule(dm) for dm in path.glob('*MC*.xml')]
    warn_dmref, caut_dmref = get_warn_caut_repos(modules, path)
    if warn_dmref is None and caut_dmref is None:
        log_print("No Warning or Caution repositories found. Skipping...", str(path/ 'report.log'))
        return

    for dm in modules:
        root = dm.root
        if generate_wcr(root, warn_dmref, caut_dmref, path):
            dm.tostring()

if __name__ == "__main__":
    main(Path('.'))