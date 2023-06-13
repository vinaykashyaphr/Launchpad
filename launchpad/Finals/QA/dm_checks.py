from pathlib import Path
from sonovision.s1000d_helper import DataModule, get_working_directory, DmRef
import re

TEMPLATE_PATH = r"V:\600\620 - Production & Department Meetings\621 - Ottawa Production Meetings\Data Conversion\Data Conversion Team\HON AERO S1000D Template\S1000D_Template_v1.13"
INFO_CODES = {"023A", "010A", "012A", "012B"}

def check_frontmatter_dms(*args, path=None, **kwargs):
    result = []
    if not Path(TEMPLATE_PATH).is_dir():
        raise Exception("Master DMs not found. Please ensure you are connected to the V: drive.")

    try:
        pmc = list(path.glob("PMC*.xml"))[0]
    except IndexError:
        result.append("No PMC located in specified path.")
        return result
    else:
        pmc = DataModule(pmc)

    master_files = {DmRef.from_filename(f.name).as_name: f for f in Path(TEMPLATE_PATH).glob("*.xml") if any(f"00-00-00-00A-{info_code}" in f.name for info_code in INFO_CODES)}
    front_matter_dmrefs = [DmRef().from_xml(fm).as_name for fm in pmc.root.findall('.//content//dmRef')[:4]]

    for fm in front_matter_dmrefs:
        if (normalized_filename := re.sub(r'-[A-Z]{3}-', r'-EAA-', fm)) in master_files:
            dm = list(path.glob(f"{fm}*.xml"))[0]
            text = re.search(r'(?s)<content.*?</content>', dm.read_text(encoding='utf-8')).group(0)
            text_master = re.search(r'(?s)<content.*?</content>', master_files[normalized_filename].read_text(encoding='utf-8')).group(0)
            if not re.sub('[\n\r]+', '', text) == re.sub('[\n\r]+', '', text_master):
                result.append(f"{fm} Needs Replacing")
                # print(f"{fm} Needs Replacing")
            del(master_files[fm])
        else:
            result.append(f"Can't find {fm}")
            # print(f"Can't find {fm}")
    return result

if __name__ == "__main__":
    print('\n'.join(check_frontmatter_dms(path=get_working_directory())))
