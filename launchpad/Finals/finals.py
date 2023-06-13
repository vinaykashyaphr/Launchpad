from sonovision.s1000d_helper import DataModule, DmRef, get_working_directory
from .misc_fixes import fix_00W, fix_00P, fix_pmc, fix_tables
from .wcr_generator import generate_wcr, get_warn_caut_repos
from .ID_Fixes import unique_ids, fix_refs
from ._Fix_IRTT import fix_irtt
from ._Final_Assembly import main as final_assembly, manual_types
from ._File_Cleaner_v2_01 import main as file_cleaner
from ._CGM_Converter_v2_00 import main as cgm_converter
from .xref_validation import main as xref_validation
# from qa import main as qa_report


from launchpad.functions import log_print
dm_ids = {}


def get_manual_type():
    while True:
        print('\nPlease Select the Manual Type:   \n')
        print("      1. CMM")
        print("      2. EIPC")
        print("      3. EM")
        print("      4. LMM")
        print("      5. HMM")
        print("      6. MM")
        print("      7. OHM")
        print("      8. IRM")
        print("      9. SPM")
        print("      10. SDIM")
        print("      11. AMM")
        print("      12. IM/IMM")
        print("      13. OH/IPL")
        print("      14. ORIM")
        try:
            manType = int(input('\nManual Type:   '))
        except TypeError:
            continue
        if manType not in range(1,len(manual_types)+1):
            print("\n   Invalid choice. Please try again:   \n")
        else:
            break
    return list(manual_types)[manType]

def main(working_directory, job_number=None, manual=None, modellic=None, cage=None, ata_number=None, data_type=None):
    # filelog = logging.getLogger(__name__)
    # logging.basicConfig(filename='report.log', filemode='a', format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s', datefmt='%H:%M:%S', level=logging.INFO)
    log_path = str(working_directory / 'report.log')
    w = pmc = p = None
    modules = [DataModule(dm) for dm in working_directory.glob("*.xml")]
    warn_dmref, caut_dmref = get_warn_caut_repos(modules, working_directory)
    
    # Pass 1
    for dm in modules:
        try:
            schema = dm.schema.name
            
            if schema == "appliccrossreftable.xsd":
                w = DmRef().from_filename(dm.filename)
            elif schema == "prdcrossreftable.xsd":
                fix_00P(dm)
                p = DmRef().from_filename(dm.filename)
            else:
                unique_ids(dm)
        except:
            continue

    # Pass 2
    log_print("\n========== DM Fixes ==========", str(working_directory/ 'report.log'))
    for dm in modules: 
        if dm.schema.name == "pm.xsd" and w is not None:
            fix_pmc(dm, w, working_directory)
        elif dm.schema.name == "appliccrossreftable.xsd" and p is not None:
            fix_00W(dm, p)

        fix_refs(dm)
        fix_irtt(dm)
        fix_tables(dm)
        generate_wcr(dm.root, warn_dmref, caut_dmref, working_directory)

        dm.to_file()

        # Add "DMC-" to file if it's missing (Check)
        if dm.schema.name != "pm.xsd" and dm.filename[0:4] != "DMC-":
            log_print(f"Adding 'DMC' to {dm.filename}", log_path)
            dm._source_file.rename(dm.rename("DMC-" + dm.filename))
    cgm_converter(working_directory, modules)
    success = all([file_cleaner(working_directory, modules), xref_validation(working_directory)])
    if not success:
        log_print("Errors detected during file cleaning and cross-reference validating. Please fix issues and try again.", log_path)
        # while input().upper() != "CONTINUE":
        #     continue
    log_print("\n========== FINAL ASSEMBLY ==========", log_path)
    
    
    final_assembly(working_directory, job_number=job_number, manual=manual, modellic=modellic, cage=cage, ata_number=ata_number, data_type=data_type)
    # QA Tool
    # print("Running QA Validation Check...\n")
    
    # qa_report(working_directory, job_number=job_number, doctype=manual_type)

if __name__ == "__main__":
    job_number = input("Please enter the job number: ")
    manual = get_manual_type()
    modellic=input("Modellic: ")
    cage=input("CAGE: ")
    ata_number=input("ATA Number: ")
    main(get_working_directory(), job_number=None, manual=None, modellic=None, cage=None, ata_number=None)