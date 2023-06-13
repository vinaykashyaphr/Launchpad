from pathlib import Path
from sonovision.s1000d_helper import DataModule
from collections import Counter
from lxml import etree as ET

def main(path:Path, out_file="output.txt"):
    """Main function"""
    source_files = path.glob("*MC*.xml")
    errors = False
    # (path/out_file).write_text("")
    with open(path / out_file, 'w') as output:
        for source_file in source_files:
            dm = DataModule(source_file)

            try:
                dm.parse()
            except ET.ParseError as e:
                errors = True
                output.write('\n' + source_file.name + " - Parse Error: " + e + '\n')
                continue
            
            dups = id_duplicates(dm)
            
            miss = missing_id(dm)

            if dups or miss:
                errors = True
                output.write(source_file.name + ":\n")
                output.write('\n'.join(dups) + '\n')
                output.write('\n'.join(miss) + '\n')
        if not errors:
            output.write("Success - No errors detected!")


def id_duplicates(dm, *args, **kwargs) -> list:
    """Checks for duplicate IDs\n
    : dm : Data Module object \n
    : return : list of error strings"""

    return [f"ID '{k}' is multiply defined ({v} times)" for k,v in Counter(dm.ids).items() if v > 1]


def missing_id(dm, *args, **kwargs) -> list:
    """Checks for references to non-existant IDs\n

    : dm : Data Module object \n
    : return : \n 
    """

    wc_refs = {j for sub in [ref.split() for ref in dm.root.xpath("*//@cautionRefs | *//@warningRefs")] for j in sub}
    all_refs = wc_refs.union(dm.root.xpath("*//@internalRefId"))
    return [f"ID '{i}' is referenced but does not exist" for i in all_refs - set(dm.ids)]

if __name__ == "__main__":
    main(Path('.'))