from sonovision.s1000d_helper import DataModule, get_working_directory
from pathlib import Path

irtts = {
    'figure' : 'irtt01',
    'table' : 'irtt02',
    'multimedia' : 'irtt03',
    'supplyDescr' : 'irtt04',
    'supportEquipDescr' : 'irtt05',
    'spareDescr' : 'irtt06',
    'levelledPara' : 'irtt07',
    'proceduralStep' : 'irtt08',
    'graphic' : 'irtt09',
    'multimediaObject' : 'irtt10',
    'hotspot' : 'irtt11',
    'parameter' : 'irtt12',
    'zoneRef' : 'irtt13',
    'workLocation' : 'irtt14',
    'materialSet' : 'irtt15',
    'accessRef' : 'irtt16',
}

def fix_irtt(dm):
    changed = False
    root = dm.root
    ids = {}
    for i in root.findall(f'.//*[@id]'):
        if i.attrib['id'] not in i:
            ids[i.attrib['id']] = i.tag
        else:
            print(f"Duplicate ID '{i.attrib['id']}' in {dm.filename}")

    for iref in root.findall('.//internalRef'):
        internal_ref_id  = iref.attrib.get('internalRefId')
        # irtt  = iref.attrib.get('internalRefTargetType')
        if internal_ref_id is None or not internal_ref_id:
            print(f"internalRef in {dm.filename} has no internalRefId.")
            continue

        if internal_ref_id not in ids:
            print(f"Broken internalRef in {dm.filename}. Could not find id='{internal_ref_id}'.")
            continue

        correct_irtt = irtts.get(ids[internal_ref_id])
        if correct_irtt is None:
            print(f'Invalid internalRefTarget in {dm.filename}: {ids[internal_ref_id]}')
        elif correct_irtt != iref.attrib.get('internalRefTargetType'):
            iref.attrib['internalRefTargetType'] = correct_irtt
            changed = True
    
    return changed

def main(working_directory, data_modules={}):
    if not len(data_modules):
        data_modules = [DataModule(dm) for dm in working_directory.glob("DMC*.xml")]

    for dm in data_modules:
        if fix_irtt(dm):
            dm.to_file()

if __name__ == "__main__":
    main(get_working_directory())

