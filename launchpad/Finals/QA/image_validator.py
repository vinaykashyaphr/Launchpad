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
        info_entity_idents = set([])

        images = get_images(path)
        # print(images)
        for source_file in source_files:
            dm = DataModule(source_file)

            try:
                dm.parse()
            except ET.ParseError as e:
                errors = True
                output.write('\n' + source_file.name + " - Parse Error: " + e + '\n')
                continue
            
            missing_images = validate_images(dm, info_entity_idents, images)

        #print(*info_entity_idents, sep="\n")
            if missing_images:
                errors = True
                output.write('\n' + source_file.name + ":\n")
                output.write('\n'.join(missing_images) + '\n')

        ug = unused_graphics(info_entity_idents, images)
        if ug:
            errors = True
            output.write("\nUnreferenced Graphics:\n")
            output.write('\n'.join(ug) + '\n')

        if not errors:
            output.write("Success - No errors detected!")

def get_images(path):
    if (path / "Graphics").is_dir():
        return {x.stem for x in (path / "Graphics").iterdir() if x.is_file() and x.suffix.lower() in {'.pdf', '.tif', '.cgm'}}
    else:
        raise NotADirectoryError("No folder labeled 'Graphics' exists")

def validate_images(dm, *args, ieis=None, imgs=None, **kwargs):
    if imgs is None:
        raise Exception("No Graphics folder found.")

    errors = []
    for image in dm.root.xpath(".//@infoEntityIdent"):
        if image not in imgs:
            errors.append(f"Image '{image}' not found.")
        ieis.add(image)

    return errors
    # print(image)

def unused_graphics(*args, imgs=None, ieis=None, **kwargs):
    if imgs is None:
        raise Exception("No Graphics folder found.")

    return sorted(imgs - ieis)

if __name__ == "__main__":
    main(Path('.'), "image_validation.log")