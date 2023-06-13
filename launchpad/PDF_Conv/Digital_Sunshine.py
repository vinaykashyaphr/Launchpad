import os
import re
from os import listdir
from os.path import isfile, join
import sys
import string
import traceback
import csv
import shutil
from pathlib import Path
import functools

try:
    from launchpad.functions import ConversionClient
except ImportError:
    pass

pattern_table = re.compile(r'^Table (\d+)\.\s+([^\n]+)\n.*?(?=^([A-Z]\.|\(\w\)|Table (?!\1)))', re.DOTALL | re.MULTILINE)	
#Lines will be checked for these words before being tagged , if an entry is present in a line it will not be given the tag that continences with the list title   
figure_deny= ["Refer", "refer", "Using", "NOTE", "<proceduralStep>" ,"as shown in", "depending", "channel takes on" , "shown in" , "Dimensions for" , "See Detail" , "Preload of the bearing",
    "Distance from DIM"	, "Preload on the bearing", "to end of shaft","is displayed below the" , "of the following functions", "illustrates a simplified" , "shows the",
    "illustrates the", "Inspect for", "No cracks or dents", "provided remaining threads", "Adjust the", "Remove access", "Use an", "reset the"]
dmc_deny= ["TEST CELL NO.", "PARA.  	RESULTS", "DES.", "SUBASSY.", "CAUTION:", "WARNING:"]
table_deny= ["is a manual test", "It is the Honeywell", "shows the", "gives information", "lists probable causes and remedies", "lists torque values", "lists the possible results"
    ,"contains a series of examples", "list and describe the", "provides a summary", "provides the", "provide connection details", "provides details" , "lists the equipment",
    "lists and describes", "shows all", "gives the specific conditions", "gives the", "lists some common"]
section_deny=["(Cont)", "LIST OF SECTIONS", "Figure", "TABLE OF CONTENTS" , "(GRAPHIC", "(TASK ", "Title  	Page", "Not Applicable" , "LIST OF"]
second_level_deny=["Refer to Table", "Not provided" , "<table>", "Least significant 8 bits are", " Validity bit (LSB or Flag) is set", "WSP = word sequence position", "On extended data field"]


def exit_handler_partial(logText, status, filename="log.txt", cc=None):
    if cc is not None:
        cc.exit_handler(status)
    elif len(logText) > 0:
        try:
            log = ""
            for l in logText:
                log += l + '\n'
            Path(filename).write_text(log.strip('\n'))
        except Exception:
            print(traceback.format_exc())
            if status == 0:
                status = 1
        finally:
            input("Press any key to continue")
            sys.exit(status)
    else:
        input("Press any key to continue")
        sys.exit(status)


def log_print_partial(logText, message, printToLogOnly=False, cc=None):
    if cc is not None:
        cc.log_print(message, printToLogOnly)
    else:
        if(not printToLogOnly):
            print(message)
        logText.append(str(message))


#Gets input using Launchpad or generic method
def get_input_partial(message, default=None, cc=None):
    if not cc:
        return input(message)
    else:
        return cc.get_user_input(message, default)

def cleanup_files(path_name):
    for f in path_name.glob("*_pt.txt"):
        f.unlink()
    for f in path_name.glob('*.csv'):
        f.unlink()

    dmc_files = [f for f in listdir(path_name) if isfile(join(path_name, f)) and (f[0:7] == "IPL SEC" or f[0:6] == "Unused" or f[0:6] == "Edited") and f[-4:].lower() == ".txt"]
    for files in dmc_files:
        (path_name / files).unlink()

    try:
        (path_name / "Shared_edited2.xml").unlink()
    except:
        pass
    try:
        (path_name / "Shared_edited1.xml").unlink()
    except:
        pass
    try:
        (path_name / "sl_entries.txt").unlink()
    except:
        pass

def add_leading_zero(number: [int, str], digits: [int, str]):
    return "0" * (digits - len(str(number))) + str(number)

#This writes out the edited text to the different section files and applies more corrections 
def treatment_sections(all_text, file_handle):	
    is_sl=False
    #Fix cautions, warnings, and notes 
    all_text = re.sub(r'<underline>(CAUTION|WARNING):?</underline>:?\s?(.*?)(?=\n)', r"<note><notePara>\1: \2</notePara></note>", all_text)
    all_text = re.sub(r'<underline>NOTE:?</underline>:?\s?(.*?)(?=\n)', r"<note><notePara> \1</notePara></note>", all_text)
    all_text = re.sub('     ', '  	', all_text) #Fix spacing

    split_lines = all_text.splitlines()
    for line_num, line in enumerate(split_lines):
        if line_num>1 :
            #Table prep 
            if "<table>" in split_lines[line_num-1]:
                line=line.replace ("	", "</para></entry><entry><para>")
                line="<entry><para>"+line
                line=line.replace ("<entry><para><entry><para>", "<entry><para>")
            #Fix subsub steps that are unmarked
            if "<para><u/>" in  split_lines[line_num-1] and "<para>" not in line and "CAUTION" not in line and "<figure>" not in  line and "<SECOND LEVEL>" not in line:
                space_pt=line.find(" ")
                if line[0:space_pt].isdigit() == True :
                    line="<proceduralStep><para><u/>"+line+"</t></r></si>"
            #fix second level because of figure keys
            if "<SECOND LEVEL>" in line and "KEY TO FIGURE" in split_lines[line_num-1]  :
                line=line.replace("<SECOND LEVEL>","")
                line=line.replace("</SECOND LEVEL>","")
                a=line_num
                a=a+1
                #Some lines do not start with a number so they must be skipped over
                if "(IPC" in split_lines[a][0:5] or "(PN" in split_lines[a][0:5]or ata_start.match(split_lines[a]):
                    if re.search(r"\(IPC(.*?)\)\s+", split_lines[a]) :
                        ipc_moved=re.search("\(IPC(.*?)\)\s+", split_lines[a])
                        if "	" in line:
                            line=re.sub("([A-Z]) 	", "\g<1> "+ipc_moved.group(0), line, 1)
                            if ipc_moved.group(0) not in split_lines[a-1]:
                                split_lines[a-1]=split_lines[a-1] +ipc_moved.group(0)
                        else :
                            line=re.sub("([A-Z]) ", "\g<1> "+ipc_moved.group(0), line, 1)
                        split_lines[a]=split_lines[a].replace(ipc_moved.group(0), "")
                    a += 1
                if "Test" in split_lines[a] :
                        is_sl=True
                while "<SECOND LEVEL>" in split_lines[a] and is_sl == False:
                    split_lines[a]=split_lines[a].replace("<SECOND LEVEL>","")
                    split_lines[a]=split_lines[a].replace("</SECOND LEVEL>","")
                    if "(IPC" in split_lines[a+1][0:5] or "(PN" in split_lines[a+1][0:5] or ata_start.match(split_lines[a+1]):
                        a += 1
                        if re.search("\(IPC(.*?)\)\s+", split_lines[a]) :
                            ipc_moved=re.search("\(IPC(.*?)\)\s+", split_lines[a])
                            if "	" in split_lines[a-1]:
                                split_lines[a-1]=re.sub("([A-Z]) 	", "\g<1> "+ipc_moved.group(0), split_lines[a-1], 1)
                                if ipc_moved.group(0) not in split_lines[a-1]:
                                    split_lines[a-1]=split_lines[a-1] +ipc_moved.group(0)
                            else :
                                split_lines[a-1]=re.sub("([A-Z]) ", "\g<1> "+ipc_moved.group(0), split_lines[a-1], 1)
                            split_lines[a]=split_lines[a].replace(ipc_moved.group(0), "")

                        split_lines[a]=split_lines[a].replace("<SECOND LEVEL>","")
                        split_lines[a]=split_lines[a].replace("</SECOND LEVEL>","")
                    a += 1
            #fix steps marked as figures
            if "<proceduralStep><para><u/>" in split_lines[line_num-1] and "<figure><title>" in line :
                space_pt1=split_lines[line_num-1].find(" ")
                under_pt=split_lines[line_num-1].find("<u/>")
                space_pt2=line.find(" ")
                title_pt1=line.find("<title>")
                if split_lines[line_num-1][under_pt+4:space_pt1].isdigit() == True and line[title_pt1+7:space_pt2].isdigit() == True:
                    line=line.replace("<figure><title>","<proceduralStep><para><u/>")
                    line=line.replace("</title><graphic infoEntityIdent=\"Original\"></graphic></figure>","</t></r></si>")
            #fix steps marked as dmcs
            if any(deny in line for deny in dmc_deny) and "<mainProcedure> <proceduralStep><para>" in line:
                line=line.replace("<mainProcedure> <proceduralStep><para>", "")
                line=line.replace("</t></r></si>", "")

            #####Check for missed steps 
            #missed underline step
            if "<para>" not in line and "<proceduralStep><para>(" in split_lines[line_num-1] :
                space_pt=line.find(" ")
                if line[0:space_pt].isdigit() == True :
                    line="<proceduralStep><para><u/>"+line+"</t></r></si>"
            #missed dmc step
            if "<para>" not in line and "<SECOND LEVEL>" in split_lines[line_num-1]  and "<figure>" not in line :
                if "NOTE" in line or "<note>" in  line:
                    #print(line+ " option1")
                    a=line_num+1
                    #print(split_lines[a]+ " option2")
                    while "<mainProcedure>" not in split_lines[a] :
                        a += 1
                        if a+2 > len(split_lines):
                            break
                    #print(split_lines[a]+ " option3")	
                    dmc_titles=re.search("[A-Z]\. (.*?)</t>", split_lines[a])
                    #print(dmc_titles.group(0))
                    if dmc_titles!=None :
                        split_lines[a]=""					
                        dmc_title=dmc_titles.group(0).replace("</t>", "")
                        file_handle.write("<mainProcedure> <proceduralStep><para>"+dmc_title+"</t></r></si>\n")
                        if "<note>" not in line:
                            line="<note><notePara>"+line+"</notePara></note>"
                else:
                    line="<mainProcedure> <proceduralStep><para>A.  "+line+"</t></r></si>"

        if line_num+1 <len(split_lines) :
            #Missed steps but looking backwards
            if "<proceduralStep><para><u/>" in split_lines[line_num+1] :
                space_pt=line.find(" ")
                if line[0:space_pt].isdigit() == True :
                    line="<proceduralStep><para><u/>"+line+"</t></r></si>"
            #Put sheets together
            if "<figure><title>" in split_lines[line_num+1] and  "<figure><title>" in line and   split_lines[line_num+1] == line:
                a=line_num+1
                text_orig=line
                while  a<len(split_lines) and  "<figure><title>" in split_lines[a]  and split_lines[a] == text_orig:
                    line =line.replace("<graphic infoEntityIdent=\"Original\"></graphic>","<graphic infoEntityIdent=\"Original\"></graphic><graphic infoEntityIdent=\"Original\"></graphic>" , 1)
                    split_lines[a]=""
                    a += 1
        #Prints line to text
        if line.strip() !="":
            file_handle.write(line+"\n")
    file_handle.write("<end_of_file>\n")		
#####################################################################################################################################################################################################################	
#######################################               Start of main process              ######################################################	
#################################################################################################################################################################################################
def DigitalSunshine(filename, directory, cc, debug_mode=False):
    log_file_name = "digital_sunshine_log.txt"

    if cc is None:
        print("Warning: Launchpad Not Found")
    else:
        cc.log_name = log_file_name

    logText = []
    errors = False
    
    #Define partials. Makes function calls a little cleaner so cc doesn't need to be passed in each call.
    log_print = functools.partial(log_print_partial, logText, cc=cc)
    get_input = functools.partial(get_input_partial, cc=cc)
    exit_handler = functools.partial(exit_handler_partial, logText, filename=log_file_name, cc=cc)
    
    path_name =  Path(directory)
    
    #########Regex for part 1 #################################################################
    ####Step markers ############################
    section_title=re.compile("^[\w+/]\s?")
    second_level=re.compile("^(\d+\.) ")
    dmc_level=re.compile("^([A-Z]{1,2}\.) ")
    dmc_level2=re.compile("^\s+([A-Z]{1,2}\.) ")
    sub_level=re.compile("^\(\d+\) ")
    sub_level2=re.compile("^\s+\(\d+\) ")
    subsub_level=re.compile("^\([a-z]+\) ")
    subsub_level2=re.compile("^\s+\([a-z]+\) ")
    subsubsub_level=re.compile("^<underline>\d+</underline>")
    sub4_level=re.compile("^<underline>[a-z]</underline> ")
    ###Type markers #################
    table_marker=re.compile("^ +Table \d+")
    table_marker2=re.compile("^Table \d+")
    table_marker3=re.compile("^Table INTRO-\d+")
    note_marker=re.compile("^NOTE:")
    note_marker2=re.compile("^<underline>NOTE</underline>:")
    figure_marker1=re.compile("^(.*?)(?<!IPL )Figure \d+")
    figure_marker2=re.compile("^(.*?)Figure \d+ \(Sheet(.*?)\)")
    figure_marker3=re.compile("^(.*?)Figure INTRO-\d+")
    ####Fix double marked lines ####
    second_and_dmc=re.compile("^\d+\.\s+[A-Z]\.\s+")
    dmc_and_sub=re.compile("^[A-Z]\.\s+\(\d+\)\s+")
    dmc_and_sub2=re.compile("^\s+[A-Z]\.\s+\(\d+\)\s+")
    sub_and_subsub=re.compile("^\(\d+\)\s+\([a-z]\)\s+")
    subsub_and_sub3=re.compile("^\([a-z]\)\s+<underline>\d+</underline>\s+")
    subsub_and_sub3_2=re.compile("^\([a-z]\)\s{2,}\d+\s{2,}")
    ####Error fixes######################
    #Error in second levels
    second_underline=re.compile("^<underline>\d+\. </underline>")
    #Ata numbers
    ata_start=re.compile("^\d{2}-\d{2}-\d{2}")
    ata_start2=re.compile("^(.*?)\d{2}-\d{2}-\d{2}")

    #figure key has spacing before it 
    key_space=re.compile("^\s+KEY TO FIGURE")
    #Find file path
    #path_name = os.path.dirname(os.path.realpath(__file__))
    alphabet= list(string.ascii_uppercase)

    #List of section titles for book will be split up based on this and then those sections will be converted to data modules
    #The list used for the conversion will be based on user input 
    sectiontitles_CMM = ["TRANSMITTAL INFORMATION","RECORD OF REVISIONS","RECORD OF TEMPORARY REVISIONS",
        "SERVICE BULLETIN LIST","INTRODUCTION", "DESCRIPTION AND OPERATION", "TESTING AND FAULT ISOLATION", 
        "SCHEMATIC AND WIRING DIAGRAMS", "CLEANING", "CHECK", "REPAIR" , "SPECIAL PROCEDURES",
        "FITS AND CLEARANCES", "SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES", "ILLUSTRATED PARTS LIST",
        "STORAGE", "INSPECTION/CHECK" , "REWORK (SERVICE BULLETIN ACCOMPLISHMENT PROCEDURES)",
        "SERVICING ", "APPENDIX 1", "ASSEMBLY (WITH STORAGE)", "FITS AND CLEARANCES" , "SPECIAL TOOLS, FIXTURES AND EQUIPMENT",
        "TESTING AND TROUBLE SHOOTING", "ILLUSTRATED PARTS LIST","DISASSEMBLY" ,"SPECIAL TOOLS, FIXTURES AND EQUIPMENT",
        "ROTATING COMPONENTS", "ASSEMBLY (With Storage)", "ATLAS TEST SPECIFICATION" , "ASSEMBLY (INCLUDING STORAGE)", "ASSEMBLY" ,
        "TESTING AND TROUBLESHOOTING", "REMOVAL" ,"INSTALLATION", "SERVICING", "REWORK", "STORAGE (INCLUDING TRANSPORTATION)", "APPENDIX 1"]
    sectiontitles_SDIM = ["INTRODUCTION", "SYSTEM DESCRIPTION", "SYSTEM OPERATION", "INSTALLATION" , "TEST AND FAULT ISOLATION", "MAINTENANCE AND REPAIR",
        "APPENDIX A INMARSAT SATELLITE BEAM COVERAGE" , "APPENDIX B TROUBLESHOOTING CHECKLIST" , "APPENDIX C INSTALLATION PLANNING CHECKLIST",
        "APPENDIX D INSTALLATION CHECKLIST", "APPENDIX E INMARSAT CAUSE CODES", "APPENDIX F SETTING UP SBB", "SECTION I - GENERAL INFORMATION" ,
        "SECTION II - INSTALLATION", "SECTION III - SYSTEM INTERCONNECT", "SECTION IV - POST-INSTALLATION CONFIGURATION, CALIBRATION, AND CHECKOUT",
        "SECTION V - DOCUMENTATION REQUIREMENTS", "APPENDIX A - ENVIRONMENTAL QUALIFICATION FORMS", "DESCRIPTION AND OPERATION", "TESTING AND FAULT ISOLATION",
        "APPENDIX A RETURN MATERIAL AUTHORIZATION", "APPENDIX B 1428-K-0001-02, 1428-K-1001-02 AMT-700 HGA INSTALLATION INFORMATION SHEET",
        "APPENDIX C OUTLINE AND INTERCONNECT DRAWINGS" ,"INSTALLATION AND MAINTENANCE", "DIAGNOSTIC APPENDICES", "FAULT ISOLATION"]
    sectiontitles_SDOM=["INTRODUCTION", "SECTION 1 SYSTEM DESCRIPTION", "SECTION 2 COMPONENT DESCRIPTION", "SECTION 3 SYSTEM OPERATION", "SECTION 3 SYSTEM OPERATIONS",
        "SECTION 5 FAULT ISOLATION", "SECTION 6 INTERCONNECTS", "SECTION 7 SYSTEM SCHEMATICS", "SECTION 8 REMOVAL/REINSTALLATION AND ADJUSTMENT", "SECTION 4 MAINTENANCE PRACTICES",
        "SECTION 6 HONEYWELL SUPPORT", "SECTION 3 SYSTEM INTERCONNECTS"]
    sectiontitles_IM = ["INTRODUCTION", "SYSTEM DESCRIPTION", "PERFORMANCE SPECIFICATIONS", "ELECTRICAL POWER REQUIREMENTS", "COOLING AIR REQUIREMENTS",
        "AHRS MODES OF OPERATION", "INTERFACE DEFINITION AND WIRING DATA", "INSTALLATION AND REMOVAL", "ALIGNMENT AND CALIBRATION", "OPERATIONAL CHECKOUT",
        "TROUBLESHOOTING", "MAINTENANCE AND REPAIR", "PACKING AND SHIPPING", "APPENDIX A - SOFTWARE UPGRADE", "APPENDIX B - SPECIAL TOOLS AND FIXTURES"]
    sectiontitles_EM=	["INTRODUCTION"]

    #In an effort to make digital sunshine a stand alone program many files were copied into the code.	
    #All required info from template 	
    prelim_info= """<pmEntry pmEntryType="pmt77"><pmEntryTitle>Proprietary Information</pmEntryTitle>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="023" infoCodeVariant="A" itemLocationCode="D"
modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent></dmRef>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="010" infoCodeVariant="A" itemLocationCode="D"
modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent></dmRef>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="012" infoCodeVariant="A"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent></dmRef>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="012" infoCodeVariant="B"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent></dmRef>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="021" infoCodeVariant="A"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent></dmRef>
</pmEntry><pmEntry pmEntryType="pmt52"><pmEntryTitle>TRANSMITTAL INFORMATION</pmEntryTitle>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="003" infoCodeVariant="A"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent>
</dmRef></pmEntry><pmEntry pmEntryType="pmt53"><pmEntryTitle>RECORD OF REVISIONS</pmEntryTitle>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="003" infoCodeVariant="B"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent>
</dmRef></pmEntry><pmEntry pmEntryType="pmt54"><pmEntryTitle>RECORD OF TEMPORARY REVISIONS</pmEntryTitle>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="003" infoCodeVariant="C"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent>
</dmRef></pmEntry><pmEntry pmEntryType="pmt55"><pmEntryTitle>SERVICE BULLETIN LIST</pmEntryTitle>
<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="008" infoCodeVariant="A"
itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAB"/></dmRefIdent>
</dmRef></pmEntry><pmEntry pmEntryType="pmt56"><pmEntryTitle>LIST OF EFFECTIVE PAGES</pmEntryTitle>
</pmEntry>\n"""

    #All info needed to make a pmc	
    PMC_Shell="""<?xml version="1.0" encoding="UTF-8"?><!--Arbortext, Inc., 1988-2014, v.4002--><!DOCTYPE pm><?Pub Inc?>
<pm xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/pm.xsd">
<identAndStatusSection> <pmAddress> <pmIdent>
<pmCode modelIdentCode="HON99193" pmIssuer="CAGE" pmNumber="00001" pmVolume="01"/>
<language countryIsoCode="US" languageIsoCode="sx"/> <issueInfo inWork="00" issueNumber="001"/></pmIdent>
<pmAddressItems><issueDate day="10" month="09" year="2018"/>
<pmTitle>BOOK TITLE</pmTitle><shortPmTitle>SHORT TITLE </shortPmTitle>
<externalPubCode pubCodingScheme="CMP">ATA NUMBER</externalPubCode>
<externalPubCode pubCodingScheme="INT">PUBLICATION NUMBER</externalPubCode>
</pmAddressItems></pmAddress>
<pmStatus issueType="new"><security securityClassification="01"/>
<dataRestrictions><restrictionInstructions>
<dataDistribution></dataDistribution>
<exportControl>
<exportRegistrationStmt>
<simplePara>This document contains technical data and is subject to
U.S. export regulations. These commodities, technology, or software
were exported from the United States in accordance with the export
administration regulations. Diversion contrary to U.S. law is prohibited.</simplePara>
<simplePara>ECCN: &amp;ECCN-USML;.</simplePara>
</exportRegistrationStmt>
</exportControl></restrictionInstructions>
<restrictionInfo>
<copyright><copyrightPara>Honeywell International Inc. Do not copy without express permission of Honeywell.</copyrightPara>
</copyright></restrictionInfo></dataRestrictions><responsiblePartnerCompany enterpriseCode=""></responsiblePartnerCompany><originator enterpriseCode=""></originator>
<applicCrossRefTableRef><dmRef><dmRefIdent><dmCode assyCode="87" disassyCode="00" disassyCodeVariant="A" infoCode="00W" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HON72914" subSubSystemCode="1" subSystemCode="4" systemCode="33" systemDiffCode="EAA"/></dmRefIdent></dmRef>
</applicCrossRefTableRef>
<applic><displayText><simplePara>ALL</simplePara></displayText></applic>
<brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0"
subSystemCode="0" systemCode="00" systemDiffCode="AAA"/></dmRefIdent></dmRef></brexDmRef><qualityAssurance><unverified/></qualityAssurance>
<remarks></remarks></pmStatus>
</identAndStatusSection>
<content>

</content></pm>
"""	
    #All info need to make a dmc
    DMC_shell="""<?xml version="1.0" encoding="UTF-8"?>
<!--Arbortext, Inc., 1988-2014, v.4002-->
<!DOCTYPE dmodule [ 
<!NOTATION tif SYSTEM "tiff">
<!NOTATION cgm SYSTEM "cgm">
<!ENTITY % ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
%ISOEntities; 
]>
<dmodule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/proced.xsd">
<identAndStatusSection>
<dmAddress>
<dmIdent>
<dmCode assyCode="07" disassyCode="01" disassyCodeVariant="A" infoCode="700" infoCodeVariant="D" itemLocationCode="C" modelIdentCode="HON55939" subSubSystemCode="5" subSystemCode="4" systemCode="45" systemDiffCode="EAA"/>
<language countryIsoCode="US" languageIsoCode="sx"/>
<issueInfo inWork="00" issueNumber="001"/></dmIdent>
<dmAddressItems>
<issueDate day="10" month="09" year="2018"/>
<dmTitle>
<techName>TECHNAME</techName><infoName>Procedure</infoName>
</dmTitle>
</dmAddressItems></dmAddress>
<dmStatus issueType="new"><security securityClassification="01"/>
<responsiblePartnerCompany enterpriseCode="99193">
</responsiblePartnerCompany><originator enterpriseCode="99193"></originator>
<applic><displayText><simplePara>ALL</simplePara></displayText></applic>
<brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="AAA"/></dmRefIdent></dmRef></brexDmRef><qualityAssurance><unverified/></qualityAssurance><remarks>
<simplePara>Orinal cmm element: subtask key=cmm112481424025354696
sns=-- revdate= func=400 seq= confltr= varnbr= pgblknbr= confnbr=</simplePara></remarks></dmStatus>
</identAndStatusSection>
<content><procedure><preliminaryRqmts>
<reqCondGroup>
<noConds/></reqCondGroup>
<reqSupportEquips>
<noSupportEquips/></reqSupportEquips>
<reqSupplies>
<noSupplies/></reqSupplies>
<reqSpares>
<noSpares/></reqSpares>
<reqSafety>
<noSafety/></reqSafety>
</preliminaryRqmts>
<mainProcedure>
"""
    #All info need to make a 00P
    P_shell= """<?xml version="1.0" encoding="UTF-8"?>
<!--Arbortext, Inc., 1988-2014, v.4002-->
<!DOCTYPE dmodule [
<!ENTITY % ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
%ISOEntities; ]> <?Pub Inc?>
<dmodule xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/prdcrossreftable.xsd" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<identAndStatusSection>
<dmAddress>
<dmIdent>
<dmCode assyCode="87" disassyCode="00" disassyCodeVariant="A" infoCode="00P" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HON72914" subSubSystemCode="1" subSystemCode="4" systemCode="33" systemDiffCode="EAA"/>
<language countryIsoCode="US" languageIsoCode="sx"/>
<issueInfo inWork="00" issueNumber="006"/></dmIdent>
<dmAddressItems>
<issueDate day="04" month="05" year="2017"/>
<dmTitle><techName>BOOK TITLE</techName><infoName>Product Cross-reference Table (PCT)</infoName></dmTitle>
</dmAddressItems></dmAddress>
<dmStatus issueType="new">
<security securityClassification="01"/>
<responsiblePartnerCompany enterpriseCode="72914"></responsiblePartnerCompany>
<originator enterpriseCode="72914"></originator>
<applic id="app-0001">
<displayText>
<simplePara>ALL</simplePara>
</displayText>
</applic>
<brexDmRef><dmRef><dmRefIdent>
<dmCode assyCode="00" disassyCode="00" disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="AAA"/>
</dmRefIdent></dmRef></brexDmRef>
<qualityAssurance>
<firstVerification verificationType="tabtop"/></qualityAssurance></dmStatus>
</identAndStatusSection>
<content>
<productCrossRefTable>

</productCrossRefTable>
</content>
</dmodule>"""
    #All info need to make a 00W
    w_shell= """<?xml version="1.0" encoding="UTF-8"?>
<!--Arbortext, Inc., 1988-2014, v.4002-->
<!DOCTYPE dmodule [
<!ENTITY % ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
%ISOEntities;]> <?Pub Inc?>
<dmodule
xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/appliccrossreftable.xsd" xmlns:dc="http://www.purl.org/dc/elements/1.1/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<?MENTORPATH ?>
<identAndStatusSection>
<dmAddress>
<dmIdent>
<dmCode assyCode="87" disassyCode="00" disassyCodeVariant="A" infoCode="00W" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HON72914" subSubSystemCode="1" subSystemCode="4" systemCode="33" systemDiffCode="EAA"/>
<language countryIsoCode="US" languageIsoCode="sx"/>
<issueInfo inWork="00" issueNumber="006"/></dmIdent>
<dmAddressItems>
<issueDate day="04" month="05" year="2017"/>
<dmTitle><techName>BOOK TITLE</techName><infoName>Applicability Cross-reference Table (ACT)</infoName></dmTitle>
</dmAddressItems></dmAddress><dmStatus issueType="new"><security securityClassification="01"/>
<responsiblePartnerCompany enterpriseCode="59364"></responsiblePartnerCompany>
<originator enterpriseCode="59364"></originator>
<applic id="app-0001"><displayText><simplePara>ALL</simplePara></displayText></applic> 
<brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="0" infoCode="022" infoCodeVariant="A" itemLocationCode="C" modelIdentCode="HON99193" subSubSystemCode="0"
subSystemCode="0" systemCode="00" systemDiffCode="A"/></dmRefIdent></dmRef></brexDmRef><qualityAssurance><unverified/></qualityAssurance></dmStatus></identAndStatusSection>
<content>
<applicCrossRefTable>
<productAttributeList>
<productAttribute id="PN" productIdentifier="primary"
useForPartsList="yes">
<name>Part Number</name><?Pub Caret 11?>
<displayName>Part Number</displayName>
<descr>Part Number</descr>
</productAttribute>
<productAttribute id="cage" productIdentifier="primary"
useForPartsList="yes">
<name>CAGE</name>
<displayName>CAGE</displayName>
<descr>CAGE</descr>
</productAttribute>
</productAttributeList>
<productCrossRefTableRef><dmRef><dmRefIdent>
<dmCode assyCode="87" disassyCode="00" disassyCodeVariant="A" infoCode="00P" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HON72914" subSubSystemCode="1" subSystemCode="4" systemCode="33" systemDiffCode="EAA"/>
</dmRefIdent></dmRef></productCrossRefTableRef>
</applicCrossRefTable>
</content>
</dmodule>
<?INMEDLNG sx-US?>
"""
    
    #Select sharedstrings file
    if filename is None:
        files = list(path_name.glob("parsed*.txt"))
        if len(files) == 0:
            raise FileNotFoundError
        file = Path(files[0])
    else:
        file = filename

    option = get_input("What type of book are you converting:\nCMM=1 SDIM=2 IM=3 SDOM=4 EM=5  ", "1")

    #Based on user input it assigns which section title list to use for the rest of the process 
    if int(option) == 1:
        correct_section=sectiontitles_CMM
    elif int(option) == 2:
        correct_section=sectiontitles_SDIM
    elif int(option) == 3:
        correct_section=sectiontitles_IM
    elif int(option) == 4:
        correct_section=sectiontitles_SDOM	
        option=2
    elif int(option) == 5:
        correct_section=sectiontitles_EM	
        option=2	
    
    log_print("Conversion in progress")
    
    try:
        #Read view content into a string
        text = file.read_text(encoding="utf-8")
        text = re.sub(re.compile(r'TABLE OF CONTENTS.*?INTRODUCTION.*?INTRODUCTION', re.DOTALL), "INTRODUCTION", text)
        #Replace special characters with entities
        text=re.sub(" ", " ",text)
        text=text.replace("˚", "&deg;")	
        text=text.replace("’", "'")		
        text=text.replace("―", "-")
        text=text.replace("–", "-")
        text=text.replace("   -   ", "   -  ")
        text=text.replace("   -  ", "\n- ")
        text=text.replace("", "&plusmn;")	
        text=text.replace(">±", ">&plusmn;")	
        text=text.replace("±", "&plusmn;")		
        text=text.replace("", "&delta;")
        text=text.replace("°", "&deg;")
        text=text.replace("â€“", "-")	
        text=text.replace("⁰", "&deg;")	
        text=text.replace("", "•")	
        text=text.replace("", "•")
        text=text.replace("Â ", " ")	
        text=text.replace("�", "\"")	
        text=text.replace("Â ", " ")		
        text=text.replace("", "&delta;")
        text=text.replace("⁰", "&deg;")	
        text=text.replace("", "&deg;")	
        text=text.replace("", "·")	
        text=text.replace("", "·")
        text=text.replace("“", "\"")
        text=text.replace("& ", "&amp; ")
        text=text.replace("<", "&lt; ")
        text=text.replace("&lt; /underline>", "</underline>")
        text=text.replace("&lt; underline>", "<underline>")
        text=text.replace("µ", "&mu;")
        text=text.replace("&lt; superscript>", "<superscript>")
        text=text.replace("&lt; /superscript>", "</superscript>")
        text=text.replace("”", "\"")	
        text=text.replace(")	", ")  	")
        text=text.replace(".	", ".  	")	
        text=re.sub("(\d)	", r"\1  	", text )
        text=re.sub("</underline>		", "</underline>  	", text )	
        text=text.replace("	", "  	")	
        text=text.replace("  	  	", "  	")	
        text=re.sub("NOTES:\n(\d+\.)", r"NOTE:\1", text )
        text=re.sub("<underline>\s*</underline>", "", text )
        re.sub("<superscript>\s*</superscript>", " ", text)
        text=text.replace("Legend for Figure", "KET TO FIGURE")		
        #Replace useless word 
        text=text.replace("THIS PAGE INTENTIONALLY LEFT BLANK", "")
        text=text.replace("THIS PAGE IS INTENTIONALLY LEFT BLANK", "")
        text=text.replace("Blank Page", "")
        text=text.replace("© Honeywell International Inc. Do not copy without express permission of Honeywell.", "")
        #Split text into lines 
        split_text=text.splitlines()	
        #Blank entries for the pmc info that needs to be gathered
        cage_code=""
        ata_code=""
        book_title=""
        parts=""
        ECCN_num=""
        part_cage=[]
        #Pre-treat the text file file
        with (path_name / "Shared_edited1.xml").open('w+', encoding="utf-8") as shared_str :		
            for i in range(len(split_text)):	

                #Find cage code 
                if "CAGE:" in split_text[i] and i <20 :
                    cage_pt=split_text[i].find("CAGE:")
                    cage_code=split_text[i][cage_pt+5:cage_pt+12].replace(" " ,"")
                    print("CAGE code found: " +cage_code)
                #Find cage code 
                if "(CAGE " in split_text[i] and i <20 :
                    cage_pt=split_text[i].find("(CAGE ")
                    cage_code=split_text[i][cage_pt+6:cage_pt+11].replace(" " ,"")
                    print("CAGE code found: " +cage_code)
                #Find ata 
                if "ATA NO." in split_text[i] and i <20 :
                    ata_pt=split_text[i].find("ATA NO.")
                    ata_code=split_text[i][ata_pt+8:ata_pt+16].replace(" " ,"")
                    print("ATA NO. found: " +ata_code)
                #Find ata 
                if ata_start2.match(split_text[i]) and i <20 :
                    ata_num=re.search("\d{2}-\d{2}-\d{2}", split_text[i])
                    ata_code=ata_num.group(0).replace(" ", "")
                    print("ATA NO. found: " +ata_code)
                #Find book title
                if int(option) == 1 and "Component Maintenance Manual" in split_text[i] and i<20 and book_title == "" :
                    book_title=split_text[i+1]
                    book_title=book_title.replace("Part Number", "")
                    book_title=book_title.replace("CAGE", "")			
                    print("Book title is :"+book_title)
                    split_text[i+1]=split_text[i+1].replace(book_title, "")
                #Find parts list 
                if "Part Number  	CAGE" in split_text[i]  and parts == "":
                    split_text[i+1]=split_text[i+1].replace("	","")
                    parts=split_text[i+1].split(" ")
                    parts = list(filter(None, parts))
                    num_parts=len(parts)/2
                    num_parts=int(num_parts)
                    for a in range(num_parts):					
                        entry=[ parts[a] ,parts[a+num_parts]]
                        part_cage.append(entry)
                # find	ECCN	
                if "ECCN:" in split_text[i] and i <20 :
                    ECCN_pt=split_text[i].find("ECCN:")
                    ECCN_num=split_text[i][ECCN_pt+5:].replace(" ","")
                    ECCN_num=ECCN_num.replace(".","")
                    print(ECCN_num)
                # find	ECCN
                if "ECCN " in split_text[i] and i <20 :
                    ECCN_pt=split_text[i].find("ECCN ")
                    ECCN_num=split_text[i][ECCN_pt+5:ECCN_pt+10].replace(" ","")
                    ECCN_num=ECCN_num.replace(".","")
                    print(ECCN_num)

                #If something is not found ask for user input 
                if i>20 and cage_code == "":
                    cage_code = get_input("Cage code not found, please enter it now: ")
                if i>20 and ECCN_num == "":
                    ECCN_num=get_input("ECCN not found, please enter it now: ")
                if i>20 and ata_code == "":
                    ata_code=get_input("ATA no. not found, please enter it now: ")
                if i>20 and book_title == "":
                    book_title = get_input("Book title not found, please enter it now: ", "TITLE")

                ########Fix errors made from double marked lines e.g:   B. (4)   This valve needs.....
                #Fix second and dmcs errors
                if second_and_dmc.match(split_text[i]):
                    split_text[i]=re.sub("\d+\.\s+", "", split_text[i])
                #Fix second and underline 
                if second_underline.match(split_text[i]):
                    split_text[i]=re.sub("<underline>", "", split_text[i])
                    split_text[i]=re.sub("</underline>", "", split_text[i])
                #Fix dmc and sub errors
                if dmc_and_sub.match(split_text[i]) or dmc_and_sub2.match(split_text[i]):
                    split_text[i]=re.sub("[A-Z]\.\s+", "", split_text[i])			
                #Fix sub and subsub  errors
                if sub_and_subsub.match(split_text[i]) :
                    split_text[i]=re.sub("\(\d+\)\s+", "", split_text[i])
                #Fix subsub and sub3  errors
                if subsub_and_sub3.match(split_text[i]) or subsub_and_sub3_2.match(split_text[i]):
                    split_text[i]=re.sub("\([a-z]+\)\s+", "", split_text[i])
                    if "underline" not in split_text[i]:
                        space_pt=split_text[i].find(" ")
                        split_text[i]="<underline>"+split_text[i][0:space_pt]+"</underline>"+split_text[i][space_pt:]

                #Fix spaced out keys 
                if key_space.match(split_text[i]) :
                    split_text[i]=re.sub("\s+KEY", "KEY", split_text[i])
                #Remove pages`
                if "Page" in split_text[i][0:6] :
                    split_text[i]=""
                #REmove continue 
                if "(Cont)" in split_text[i] :
                    split_text[i]=""
                if "Table" in split_text[i] and "(cont)" in split_text[i] :
                    split_text[i]=""
                if split_text[i]!= " " and  split_text[i]!= "" :
                    shared_str.write(split_text[i]+"\n")

        shared_str.close
        text = (path_name / "Shared_edited1.xml").read_text(encoding="utf-8")
        def tag_titles(match):
            if match.group(1) in correct_section or any(section in match.group(1) for section in correct_section):
                print("Tagged {} as section title".format(match.group(1)))
                return "<SECTION TITLE>{}</SECTION TITLE>".format(match.group(1).strip())
            return match.group(0)
        text = re.sub(re.compile(r"^(.*?)(?=\n1\.)", re.MULTILINE), tag_titles, text)
        split_text=text.splitlines()
        #Apply style
        #Tag section titles 
        with (path_name / "Shared_edited2.xml").open('w+', encoding="utf-8") as shared_str1 :		
            for i in range(len(split_text)):		
                #KEEP THIS. There's definitely some edge cases in here that I might need to reference later
                # if (section_title.match(split_text[i]) or "<underline>" in split_text[i]) and "CAUTION" not in split_text[i] and "REPAIRABLE LIMITS" not in split_text[i]:				
                    # if any(titles in split_text[i] for titles in correct_section)	:
                        # checker=split_text[i].replace("<underline>", "")
                        # checker=checker.replace("</underline>", "")
                        # checker=re.sub("\s+", " ", checker)
                        # if any(titles in checker[0:55] for titles in correct_section) and any(char.isdigit() for char in checker[0:5]) == False and "</SECTION TITLE>" not in split_text[i]:
                            # split_text[i]=split_text[i].replace("<underline>", "")
                            # split_text[i]=split_text[i].replace("</underline>", "")
                            # split_text[i]="<SECTION TITLE>"+split_text[i]+"</SECTION TITLE>"
                            # split_text[i]=split_text[i].replace("  </SECTION TITLE>", "</SECTION TITLE>")
                            # split_text[i]=split_text[i].replace(" </SECTION TITLE>", "</SECTION TITLE>")
                            # accurate_section=False
                            # for titles in correct_section:
                                # if "<SECTION TITLE>"+titles in split_text[i] :
                                    # accurate_section=True
                            # if accurate_section == False:
                                # split_text[i]=split_text[i].replace("</SECTION TITLE>", "")
                                # split_text[i]=split_text[i].replace("<SECTION TITLE>", "")
                #tag second level
                if second_level.match(split_text[i])  and any(deny in split_text[i] for deny in second_level_deny) == False:
                    split_text[i]=split_text[i].replace("<underline>", "")
                    split_text[i]=split_text[i].replace("</underline>", "")
                    split_text[i]="<SECOND LEVEL>"+split_text[i]+"</SECOND LEVEL>"

                #tag dmcs level
                if dmc_level.match(split_text[i]) or  dmc_level2.match(split_text[i]) and any(deny in split_text[i] for deny in dmc_deny) == False :
                    split_text[i]="<mainProcedure> <proceduralStep><para>"+split_text[i]+"</t></r></si>"
                #tag sub level
                if sub_level.match(split_text[i]) or  sub_level2.match(split_text[i]) :
                    split_text[i]="<proceduralStep><para>"+split_text[i]+"</t></r></si>"
                #tag subsub level
                if subsub_level.match(split_text[i]) or subsub_level2.match(split_text[i]):
                    split_text[i]="<proceduralStep><para>"+split_text[i]+"</t></r></si>"
                #tag subsubsub level
                if subsubsub_level.match(split_text[i]) :
                    split_text[i]=split_text[i].replace("<underline>", "")
                    split_text[i]=split_text[i].replace("</underline>", "")
                    split_text[i]="<proceduralStep><para><u/>"+split_text[i]+"</t></r></si>"
                if sub4_level.match(split_text[i]) :
                    split_text[i]=split_text[i].replace("<underline>", "")
                    split_text[i]=split_text[i].replace("</underline>", "")
                    split_text[i]="<proceduralStep><para><u/>"+split_text[i]+"</t></r></si>"	
                #tag table
                if (table_marker.match(split_text[i]) or table_marker2.match(split_text[i]) or table_marker3.match(split_text[i])) and any(deny in split_text[i] for deny in table_deny) == False:
                    split_text[i]=re.sub(table_marker,"",split_text[i])
                    split_text[i]=re.sub(table_marker2,"",split_text[i])
                    split_text[i]=re.sub(table_marker3,"",split_text[i])
                    split_text[i]="<table><title>"+split_text[i]+"</title>"
                    split_text[i]=re.sub("<title>\.\s+","<title>",split_text[i])
                #tag notes
                if note_marker.match(split_text[i])  or note_marker2.match(split_text[i]):
                    split_text[i]=re.sub(note_marker,"",split_text[i])
                    split_text[i]=re.sub(note_marker2,"",split_text[i])
                    split_text[i]=re.sub("	"," ",split_text[i])
                    split_text[i]=re.sub("	"," ",split_text[i])
                    split_text[i]=re.sub("\s{2,}"," ",split_text[i])
                    split_text[i]="<note><notePara>"+split_text[i]+"</notePara></note>"
                #tag figures
                if (figure_marker1.match(split_text[i]) or figure_marker2.match(split_text[i]) or figure_marker3.match(split_text[i]) )  and any(deny in split_text[i] for deny in figure_deny) == False  :
                    if figure_marker1.match(split_text[i]):
                        split_text[i]=re.sub("(?<!IPL )Figure \d+","",split_text[i])
                    elif figure_marker2.match(split_text[i]):
                        split_text[i]=re.sub("(?<!IPL )Figure \d+ \(Sheet(.*?)\)","",split_text[i])	
                    split_text[i]=re.sub(figure_marker3,"",split_text[i])
                    if "<note>" not in split_text[i]:
                        split_text[i]=re.sub("\(Sheet(.*?)\)","",split_text[i])
                        split_text[i]=re.sub("\(GRAPHIC (.*?)\)","",split_text[i])					
                        split_text[i]="<figure><title>"+split_text[i]+"</title><graphic infoEntityIdent=\"Original\"></graphic></figure>"
                        split_text[i]=re.sub("<title>\.\s+","<title>",split_text[i])
                if split_text[i].strip() != "":
                    shared_str1.write(split_text[i]+"\n")

        text = (path_name / "Shared_edited2.xml").read_text(encoding='utf-8')
        def split_ipl(match):
            print("Splitting IPL")
            def tag_ipl_figures(match):
                return "<figure><title>{}</title><sheets>{}</sheets><fignum>{}</fignum></figure>\n".format(match.group(3), match.group(2), match.group(1))
            text = re.sub(re.compile("IPL Figure (\d+\w?)\.?\s*\(Sheet \d+ of (\d+)\)\s*([^\n]+).*?(?=EFFECT)", re.DOTALL), tag_ipl_figures, match.group(0))
            (path_name / "ILLUS_941_pt.txt").write_text(text + "\n<end_of_file>")
            return "<end_of_file>"
        
        #Split IPL into separate file
        text = re.sub(re.compile(r'^<SECOND LEVEL>\d\.\s+Detailed Parts List.*', re.DOTALL | re.MULTILINE), split_ipl, text)
        split_text=text.splitlines()

        #Creates list of titles
        title_entries=[]
        for s in re.finditer(re.compile("^<SECTION TITLE>.*?(?=<SECTION TITLE>|<end_of_file>)", re.DOTALL | re.MULTILINE), text):
            title = re.sub(r"\s{2,}", " ", re.match(r"^<SECTION TITLE>(.*?)</SECTION TITLE>", s.group(0)).group(1).strip())
            if title in correct_section or any(t for t in correct_section if t in title):
                title_entries.append(title)
                print("Started section:" + title)
                file_name = title.replace("/", "_") + "_pt.txt"
                if "SPECIAL PROCEDURE" in file_name:
                    file_name = "SPROC_pt.txt"
                with (path_name / file_name).open('w+', encoding="utf-8") as part_file:
                    treatment_sections(s.group(0), part_file)
                #(path_name / file_name).write_text(content, encoding="utf-8")
                print("Completed section:" + title)	
    except Exception as e:
        log_print("Something went wrong")
        log_print(traceback.format_exc(), True)

    ##################################################      Initial PMC build phase        #################################################################
    #Creates the pmc file and places the section titles
    try:	
        pmc_name="PMC-"+cage_code+"-"+ata_code+".xml"
        with (path_name / pmc_name).open("w+",  encoding="utf-8") as PMC:
            #Replaces the placeholder information with the book specific information
            PMC_Shell=PMC_Shell.replace("ATA NUMBER",ata_code)	
            PMC_Shell=PMC_Shell.replace("BOOK TITLE",book_title)	
            PMC_Shell=PMC_Shell.replace("CAGE",cage_code)
            PMC_Shell=PMC_Shell.replace("&amp;ECCN-USML;",ECCN_num)

            split_pmc_shell=PMC_Shell.splitlines()
            for i in range(len(split_pmc_shell)):				
                #Prints required text for procedural dm (precontent)
                if "<applicCrossRefTableRef" in  split_pmc_shell[i] :
                    zerow_name="DMC-HON"+cage_code+"-EAA-"+ata_code+"-00A-00WA-D.xml"
                    name=zerow_name.split("-")
                    dmcode="<dmCode assyCode=\""+name[5]+"\" disassyCode=\""+name[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name[7][0:3]+"\" infoCodeVariant=\""+name[7][3:]+"\" itemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/>\n"	
                    split_pmc_shell[i]="<applicCrossRefTableRef><dmRef><dmRefIdent>"+dmcode+"</dmRefIdent></dmRef>"
                if split_pmc_shell[i].find("<content>")!=-1 :
                    PMC.write(split_pmc_shell[i])
                    split_pmc_shell[i]=""
                    #Write generic front mater files
                    PMC.write(prelim_info)
                    for title in title_entries :
                        title=title.replace("E>", "")
                        title=title.replace("</S", "")
                        if int(option) == 1  :
                            if   title[0:5].lower() == "descr":
                                pmtcode = "pmt59"
                            elif title[0:5].lower() == "intro":
                                pmtcode = "pmt58"
                            elif title[0:5].lower() == "testi":
                                pmtcode	= "pmt60"				
                            elif title[0:5].lower() == "schem":
                                pmtcode = "pmt61"			
                            elif title[0:5].lower() == "disas":
                                pmtcode	= "pmt62"			
                            elif title[0:5].lower() == "clean":
                                pmtcode = "pmt63"									
                            elif title[0:5].lower() == "check" or title[0:5].lower() == "inspe":
                                pmtcode	= "pmt64"										
                            elif title[0:5].lower() == "repai":
                                pmtcode = "pmt65"											
                            elif title[0:5].lower() == "assem":
                                pmtcode	= "pmt66"		
                            elif title[0:5].lower() == "fits&" or title[0:5].lower() == "fits ":
                                pmtcode	= "pmt67"									
                            elif "special tools" in title.lower():
                                pmtcode	= "pmt68"								
                            elif title[0:5].lower() == "illus":
                                pmtcode	= "pmt75"							
                            elif title[0:5].lower() == "stora":
                                pmtcode	= "pmt73"
                            elif title[0:5].lower() == "speci":
                                pmtcode	= "pmt69"
                            elif title[0:5].lower() == "remov":
                                pmtcode	= "pmt70"
                            elif title[0:5].lower() == "insta":
                                pmtcode	= "pmt71"
                            elif title[0:5].lower() == "servi":
                                pmtcode	= "pmt72"
                            elif title[0:5].lower() == "rewor":
                                pmtcode	= "pmt74"
                            else :
                                pmtcode = "pmt58"
                            if title!= "TRANSMITTAL INFORMATION" and title!="RECORD OF REVISIONS" and title!="RECORD OF TEMPORARY REVISIONS" and title!= "SERVICE BULLETIN LIST":
                                PMC.write("<pmEntry pmEntryType=\""+pmtcode+"\"><pmEntryTitle>"+title+"</pmEntryTitle>\n</pmEntry>\n")
                        else :
                            pmtcode="pmt58"	
                            PMC.write("<pmEntry pmEntryType=\""+pmtcode+"\"><pmEntryTitle>"+title+"</pmEntryTitle>\n</pmEntry>\n")
                PMC.write(split_pmc_shell[i]+"\n")			
            print("PMC completed")							
    except Exception as e:
        log_print("Initial PMC structure failed")
        log_print(traceback.format_exc(), True)
        errors = True

    #####Create the 00P	  ######################################
    try :
        zerop_name="DMC-HON"+cage_code+"-EAA-"+ata_code+"-00A-00PA-D.xml"
        P_shell=P_shell.replace("ATA NUMBER",ata_code)	
        P_shell=P_shell.replace("BOOK TITLE",book_title)	
        ##TO DO: 'with Path.open()' instead of 'with open(string)'
        with (path_name / zerop_name).open("w+", encoding="utf-8") as zeroP:
            split_pmc_shell=P_shell.splitlines()
            name=zerop_name.split("-")
            dmcode="<dmCode assyCode=\""+name[5]+"\" disassyCode=\""+name[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name[7][0:3]+"\" infoCodeVariant=\""+name[7][3:]+"\" itemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/>\n"	
            for i in range(len(split_pmc_shell)):
                if "<dmCode " in split_pmc_shell[i] and "<brexDmRef>" not in split_pmc_shell[i] :
                    split_pmc_shell[i]=dmcode
                if "<productCrossRefTable>" in split_pmc_shell[i] :
                    zeroP.write(split_pmc_shell[i]+"\n")	
                    split_pmc_shell[i]=""
                    if part_cage!=[] :
                        for a in range(len(part_cage)) :	
                            zeroP.write("<product><assign applicPropertyIdent=\"PN\" applicPropertyType=\"prodattr\" applicPropertyValue=\""+part_cage[a][0]+"\"/>\n")
                            zeroP.write("<assign applicPropertyIdent=\"cage\" applicPropertyType=\"prodattr\" applicPropertyValue=\""+part_cage[a][1]+"\"/></product>\n")
                    else :
                        zeroP.write("<product><assign applicPropertyIdent=\"PN\" applicPropertyType=\"prodattr\" applicPropertyValue=\"missing\"/>\n")
                        zeroP.write("<assign applicPropertyIdent=\"cage\" applicPropertyType=\"prodattr\" applicPropertyValue=\"missing\"/></product>\n")	
                zeroP.write(split_pmc_shell[i]+"\n")	

    except Exception as e:
        log_print("Failed while writing 00P file")
        log_print(traceback.format_exc(), True)
        errors = True

    ####Create the 00w   ########################################################
    try :
        zerow_name="DMC-HON"+cage_code+"-EAA-"+ata_code+"-00A-00WA-D.xml"
        w_shell=w_shell.replace("ATA NUMBER",ata_code)	
        w_shell=w_shell.replace("BOOK TITLE",book_title)	
        with (path_name / zerow_name).open("w+",  encoding="utf-8") as zeroW:
            split_pmc_shell=w_shell.splitlines()
            name=zerow_name.split("-")
            dmcode="<dmCode assyCode=\""+name[5]+"\" disassyCode=\""+name[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name[7][0:3]+"\" infoCodeVariant=\""+name[7][3:]+"\" itemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/>\n"	
            namep=zerop_name.split("-")
            for i in range(len(split_pmc_shell)):
                if "<dmCode " in split_pmc_shell[i] and "<brexDmRef>" not in split_pmc_shell[i] :
                    split_pmc_shell[i]=dmcode
                    if "<productCrossRefTableRef" in split_pmc_shell[i-1] :
                        dmcodep="<dmCode assyCode=\""+namep[5]+"\" disassyCode=\""+namep[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+namep[7][0:3]+"\" infoCodeVariant=\""+namep[7][3:]+"\" itemLocationCode=\"C\" modelIdentCode=\""+namep[1]+"\" subSubSystemCode=\"" +namep[4][1:]+"\" subSystemCode=\""+namep[4][0:1]+"\" systemCode=\""+namep[3]+"\" systemDiffCode=\"EAA\"/>\n"	
                        split_pmc_shell[i]=dmcodep

                zeroW.write(split_pmc_shell[i]+"\n")	

    except Exception as e:
        log_print("Failed while writing 00W file")
        log_print(traceback.format_exc(), True)
        errors = True

    #####################################################################################################################
    #################################                    Part 2                       #############################################
    ######################################################################################################################

    #Generic declarations 

    techname=""
    sl_entries=[] 
    infocount=1
    counter=0
    zero1A="01A"
    ipl_start=True 	
    #Regex paterns 
    new_dmc = re.compile("^<mainProcedure> <proceduralStep><para>[A-Z]{1,2}\. ")
    second_level=re.compile("^<SECOND LEVEL>(\d+\.)\s+", re.MULTILINE)
    new_level = re.compile("^<proceduralStep><para>\(\d+\)\s+")
    new_sublevel=re.compile("^<proceduralStep><para>\([a-z]+\)\s+")
    new_subsublevel=re.compile("^<proceduralStep><para><u/>\d+\s+")
    new_subsubsublevel=re.compile("^<proceduralStep><para><u/>[a-z]\s+")
    new_sub_times_4_level=re.compile("^<proceduralStep><para><u/>\(\d+\)\s+")
    figure_placement = re.compile("^<figure><title>")
    figure_key1=re.compile("^Key for Figure")
    figure_key2=re.compile("^KEY TO FIGURE")
    key_entries=re.compile("^\d+")
    table_placement=re.compile("^<table><title>")
    blank_line=re.compile("^\n")
    period_start=re.compile("^·")
    period_start1=re.compile("^•")
    dash_start=re.compile("^- ")
    warning_placement=re.compile("^WARNING:")
    caution_placement=re.compile("^CAUTION:")
    note_placement=re.compile("^<note><notePara> ")

    Mid_level= re.compile("[a-z] \d+ [A-Z]+")	

    #Function to make lists 
    def list_treatment(split_section, i):	
        MODULE.write("<randomList>")
        while period_start.match(split_section[i]) or period_start1.match(split_section[i]) or dash_start.match(split_section[i]) :																									
            split_section[i]=re.sub(period_start,"<listItem><para>",split_section[i])
            split_section[i]=re.sub(period_start1,"<listItem><para>",split_section[i])
            split_section[i]=re.sub(dash_start,"<listItem><para>",split_section[i])
            split_section[i]=split_section[i]+"</para></listItem>\n"							
            MODULE.write(split_section[i])				
            if i+1 >=len(split_section) :	
                break
            if ("·" not in split_section[i+1][0:5]) and ("." not in split_section[i+1][0:5]) and ("-" not in split_section[i+1][0:5])and ("•" not in split_section[i+1][0:5]):
                break
            i += 1	
        MODULE.write("</randomList>")
        split_section[i]=""
        return i

    #Function to make tables 
    def table_treatment(split_section ,i) :
        num_colum=0
        colum_changed=False	
        MODULE.write(split_section[i])
        i += 1
        #Count entry tags to determine number of columns 
        num_colum=split_section[i].count("<entry>")
        #Check to see if first and second row are the same length	
        line=split_section[i+1].replace ("	", "</para></entry><entry><para>")
        line="<entry><para>"+line
        line=line.replace ("<entry><para><entry><para>", "<entry><para>")
        line=re.sub("<entry><para>\s+</para></entry>", "", line)
        line=re.sub("<entry><para></para></entry>", "", line)
        line=line.replace ("<entry></entry>", "")
        line=line.replace ("<entry><para><entry><para>", "<entry><para>")
        num_column2=line.count("<entry>")
        #if the second row has more columns use that number
        if num_column2>num_colum:
            num_colum=num_column2
        #Max number of columns is 15 , no table has more than 15 columns , if the detected number of columns is 
        # more than 15 it is due to a line merging error
        if num_colum>15 :
            num_colum=15
        if infocode == "200" and "Cleaning Methods" in split_section[i]:
            num_colum=11
        if num_colum == 0:
            num_colum=1
            colum_changed=True
        header="<tgroup cols=\""+str(num_colum)+"\">"
        #Creates columns names 
        for header_count in range(num_colum)	:						
            header += "<colspec colname=\"col"+str(header_count+1)+"\"/>"								
            header_count += 1									
        #Creates header row						
        header += "<thead><row>\n"	
        MODULE.write(header)
        if	colum_changed == True :
            MODULE.write("<entry><para></para></entry>\n")
        else:
            #Write header row 
            split_section[i]=split_section[i].replace("   ", "</para><para>")
            split_section[i]=re.sub("<underline>", "", split_section[i])
            split_section[i]=re.sub("</underline>", "", split_section[i])
            split_section[i]=re.sub("<superscript>", "", split_section[i])
            split_section[i]=re.sub("</superscript>", "", split_section[i])
            split_section[i] += "</para></entry>"
            #Make sure the header has the correct amount of entries .This is based on the previously defined number of columns
            if split_section[i].count("<entry>")<num_colum :
                while split_section[i].count("<entry>")<num_colum:
                    split_section[i] += "<entry><para></para></entry>"

            MODULE.write(split_section[i])
            #print("Header :"+split_section[i])		
            Header_line=split_section[i]
        header="</row></thead><tbody>\n"		
        MODULE.write(header)		
        i += 1
        #Populate table entries 

        #Start of loop through table rows 
        while "<proceduralStep>" not in split_section[i]:		
            #print(split_section[i])
            table_row="<row>"
            treat_line=True
            #only try to create entries if the number of columns is more than zero
            if num_colum >0 :					
                # if row has these things in it break the loop
                if "<figure>" in split_section[i]:
                    break

                #Normal for treatment 
                split_section[i]=split_section[i].replace("	", "</para></entry><entry><para>")
                split_section[i]="<entry><para>"+split_section[i]
                split_section[i] += "</para></entry>"
                entry_count=split_section[i].count("<entry>")			
                split_section[i]=re.sub("<underline>", "", split_section[i])
                split_section[i]=re.sub("</underline>", "", split_section[i])
                split_section[i]=re.sub("<superscript>", "", split_section[i])
                split_section[i]=re.sub("</superscript>", "", split_section[i])
                split_section[i]=split_section[i].replace("   ", "</para><para>")
                if entry_count!=num_colum :									
                    #print(split_section[i])
                    #print(entry_count)
                    #print(num_colum)
                    if entry_count<num_colum :
                        while entry_count!=num_colum :
                            split_section[i] += "<entry><para></para></entry>"
                            entry_count=split_section[i].count("<entry>")
                            if entry_count>=20 :
                                break

                    #if x times more entries found than column rows
                    if (entry_count/num_colum).is_integer() and  (entry_count/num_colum)>1:
                        n=0
                        checker_pt=0
                        time=1
                        while time <int(entry_count/num_colum) :
                            while n !=num_colum :
                                checker_pt_new=split_section[i][checker_pt:].find("</entry>")		
                                checker_pt=checker_pt+checker_pt_new+8
                                n += 1
                            split_section[i]=split_section[i].replace(split_section[i][checker_pt:], "</row>\n<!--new--><row>"+split_section[i][checker_pt:], 1)				
                            n=0
                            time += 1
                    #If x time more entries but not an integer
                    elif (entry_count/num_colum)>1:
                        while (entry_count/num_colum).is_integer() == False :
                            split_section[i] += "<entry><para></para></entry>"
                            entry_count=split_section[i].count("<entry>")
                        if (entry_count/num_colum).is_integer() and  (entry_count/num_colum)>1:
                            n=0
                            checker_pt=0
                            time=1
                            while time <int(entry_count/num_colum) :
                                while n !=num_colum :
                                    checker_pt_new=split_section[i][checker_pt:].find("</entry>")		
                                    checker_pt=checker_pt+checker_pt_new+8
                                    n += 1
                                split_section[i]=split_section[i].replace(split_section[i][checker_pt:], "</row>\n<!--new--><row>"+split_section[i][checker_pt:], 1)				
                                n=0
                                time += 1	
                #Check for repetitions of the header
                if Header_line == split_section[i]:
                    #If header is repeated the line is removed
                    split_section[i]=""
                table_row += split_section[i]
                if i+1>len(split_section):
                    i=i-1	
                i += 1
            else : 
                table_row += "<entry><para></para></entry>"
            table_row += "</row>\n"	
            if table_row == "<row></row>\n":
                table_row=""
            MODULE.write(table_row)	
            #print(table_row)
            #If end of section break
            if i+1 >=len(split_section):
                break															
            elif warning_placement.match(split_section[i]) :
                break
            elif caution_placement.match(split_section[i]) :
                break	
            elif new_dmc.match(split_section[i]) :
                break
            elif new_level.match(split_section[i]):
                break
            elif second_level.match(split_section[i]):
                break		
            elif table_placement.match(split_section[i]):
                break		
            elif figure_key1.match(split_section[i]):
                break	
            elif figure_key2.match(split_section[i]):
                break
            elif figure_placement.match(split_section[i]):
                break
            elif "<figure>" in split_section[i]:
                break	
            i+1
        MODULE.write("</tbody></tgroup></table>\n")		
        return i

    #Get the path for this script
    #path_name = os.path.dirname(os.path.realpath(__file__))

    #Get a list of all DMCs in the directory
    #files = [f for f in listdir(path_name) if isfile(join(path_name, f))  and f[-6:] == "pt.txt" ]
    files = list(path_name.glob('*pt.txt'))
    #Open dmc shell
    split_dmc=DMC_shell.splitlines()	
    #Mark when a number has been used
    used_100=False
    try:
        for file in files:		
            #Reset counters for every file
            counter=0
            zero1A="01A"
            infocount=1
            #Read file 
            text = file.read_text(encoding='utf-8')
            
            second_levels = re.findall(re.compile(r'^<SECOND LEVEL>.*?(?=<(?:SECOND LEVEL|end_of_file)>)', re.DOTALL | re.MULTILINE), text)
            for sl in second_levels:
                dm_count = sl.count('<mainProcedure>' if file.name != "ILLUS_941_pt.txt" else '<figure>')
                second_level_title = re.match(r'<SECOND LEVEL>\d+\.\s+(.*?)</SECOND LEVEL>', sl)
                if "Vendor Code List" == second_level_title.group(1) and dm_count == 0: #VCL doesn't have any procedural steps. We need to add one for it to be picked up as a DM
                    text = re.sub(r"(<SECOND LEVEL>.*?Vendor Code List.*?\n)", r"\1{}".format("<mainProcedure> <proceduralStep><para>A.    	Vendor Code List</t></r></si>\n"), text)
                    dm_count = 1
                    #file.write_text(text, encoding='utf-8')
                sl_entries.append({"count" : dm_count, "name" : file.name[0:5], "title" : second_level_title.group(1).replace("�", " ") if second_level_title is not None else "Missing Title"})
            
            split_section=re.sub("<SECOND LEVEL>.*?</SECOND LEVEL>", "", text).splitlines()									
            #Loops through all the lines in a file
            for i in range(len(split_section)) : #TO DO: Split each file into second levels and iterate through those line by line, instead of the whole file
                #Create separate files for each section	
                if new_dmc.match(split_section[i]):
                    #Reset step counters and values
                    open_level=0
                    closed_level=0
                    open_sublevel=0
                    closed_sublevel=0
                    open_subsublevel=0
                    closed_subsublevel=0
                    new_level_counter=0
                    sublevel_counter=0
                    subsublevel_counter=0
                    subsubsublevel_counter=0
                    mismatch1_counter=0
                    prior_step=0
                    open_subsubsublevel=0 
                    closed_subsubsublevel=0
                    sublevel_created=False
                    subsublevel_created=False
                    subsubsublevel_created=False
                    new_sub_times_4_created=False
                    new_level_created=False
                    prior_dmc=False
                    new_note=False
                    new_table=False
                    new_figure=False
                    new_list=False
                    new_dmc_created=False
                    #If line is less than 3 character long merge it with the next line 
                    #and make the next line blank
                    if len(split_section[i]) <= 3 :
                        split_section[i] += split_section[i+1]
                        split_section[i+1]= ""
                    #Get ATA NUMBER and cage
                    #Determines infocode based on file title 
                    #Should push naming to sub function
                    if int(option) == 1:
                        if file.name[0:5].lower() == "descr":
                            infocode="100"
                            techname="DESCRIPTION"
                        elif file.name[0:5].lower() == "intro":
                            infocode="018"	
                            techname="INTRODUCTION"
                        elif file.name[0:5].lower() == "testi" or "fault" in file.name.lower(): 
                            infocode="400"	
                            techname="TESTING AND FAULT ISOLATION"
                        elif file.name[0:5].lower() == "schem":
                            infocode="051"
                            techname="SCHEMATIC AND WIRING DIAGRAMS"
                        elif file.name[0:5].lower() == "disas":
                            infocode="500"	
                            techname="DISASSEMBLY"
                        elif file.name[0:5].lower() == "clean":
                            infocode="200"
                            techname="CLEANING"
                        elif file.name[0:5].lower() == "check" or file.name[0:5].lower() == "inspe":
                            infocode="300"	
                            techname="CHECK"
                        elif file.name[0:5].lower() == "repai":
                            infocode="600"	
                            techname="REPAIR"
                        elif file.name[0:5].lower() == "assem":
                            infocode="700"	
                            techname="ASSEMBLY"
                        elif file.name[0:5].lower() == "fits&" or file.name[0:5].lower() == "fits ":
                            infocode="711"
                            techname="FITS AND CLEARANCES"
                        elif file.name[0:5].lower() == "speci":
                            infocode="900"
                            techname="SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES"
                        elif file.name[0:5].lower() == "illus":
                            infocode="018"
                            if ipl_start == True :
                                counter=19
                                ipl_start=False
                            techname="ILLUSTRATED PARTS LIST"
                        elif file.name[0:5].lower() == "stora":
                            infocode="800"	
                            techname="STORAGE (INCLUDING TRANSPORTATION)"	
                        elif "RECORD_OF_REVISIONS_plain" in file.name :
                            infocode="003"
                            counter=0
                            techname="RECORD OF REVISIONS"
                        elif "RECORD_OF_TEMPORARY" in file.name :
                            infocode="003"
                            counter=1
                            techname="RECORD OF TEMPORARY REVISIONS"
                        elif "ROTATING" in file.name :
                            infocode="019"
                            techname="ROTATING"  
                        else : 
                            infocode="910"	
                            techname="ENGINE"
                            zero1A="0"+str(infocount)+"A"
                        if counter == 26 : 	
                            infocount += 1	
                            if infocount<10 :
                                zero1A="0"+str(infocount)+"A"
                            else 	:
                                zero1A=str(infocount)+"A"
                            counter=0
                    if int(option) == 2 :	
                        if "INSPECTION" in file.name :
                            infocode="500"
                            techname="INSPECTION"
                        elif "DISASSEMBLY" in file.name  :
                            infocode="400"	
                            techname="DISASSEMBLY"
                        elif "REMOVAL" in file.name :
                            infocode="450"	
                            techname="REMOVAL"
                        elif "CLEANING" in file.name or "MAINTENANCE_PRACTICES" in file.name or "CHECK" in file.name:
                            infocode="300"	
                            techname="CLEANING"	
                        elif "DOCUMENTS" in file.name: 
                            infocode="350"	
                            techname="DOCUMENTS"	
                        elif "REPAIR" in file.name :
                            infocode="600"	
                            techname="REPAIR"
                        elif "INTRODUCTION" in file.name :
                            infocode="018"	
                            techname="INTRODUCTION"	
                        elif "GENERAL" in file.name :
                            infocode="020"	
                            techname="GENERAL"	
                        elif "DESCRIPTION" in file.name :
                            if used_100 == False :
                                infocode="100"	
                                techname="DESCRIPTION"	
                                used_100=True
                                used_100_file=file.name
                            elif used_100 == True and used_100_file!=file.name	:
                                infocode="101"	
                                techname="DESCRIPTION"	
                                used_100=True
                        elif "INSTALLATION" in file.name and "APPENDIX" not in file.name and "CHECK" not in file.name:
                            infocode="700"	
                            techname="INSTALLATION"	
                        elif "FAULT ISOLATION" in file.name or "SYSTEM_INTERCONNECT" in file.name or "FAULT" in file.name:
                            infocode="250"	
                            techname="FAULT ISOLATION"				
                        elif "APPENDIX_A" in file.name :
                            infocode="915"	
                        elif "APPENDIX_B" in file.name :
                            infocode="920"	
                            techname="APPENDIX_B"	
                        elif "APPENDIX_C" in file.name :
                            infocode="930"	
                            techname="APPENDIX_C"	
                        elif "APPENDIX_D" in file.name :
                            infocode="940"	
                            techname="APPENDIX_D"
                        elif "APPENDIX_E" in file.name :
                            infocode="950"	
                            techname="APPENDIX_E"
                        elif "APPENDIX_F" in file.name :
                            infocode="960"	
                            techname="APPENDIX_F"		
                        else : 
                            infocode="910"	
                            techname="ENGINE"
                            if infocount<=9 :
                                zero1A="0"+str(infocount)+"A"
                            else :
                                zero1A=str(infocount)+"A"
                        if counter == 26 : 	
                            infocount += 1	
                            if infocount<=9 :
                                zero1A="0"+str(infocount)+"A"
                            else :
                                zero1A=str(infocount)+"A"
                            counter=0	
                    if int(option) == 3 :	
                        if "INTRODUCTION" in file.name :
                            infocode="018"	
                            techname="INTRODUCTION"	
                        elif "WIRING" in file.name :
                            infocode="051"	
                            techname="WIRING"	
                        elif "GENERAL" in file.name :
                            infocode="020"	
                            techname="GENERAL"	
                        elif "DESCRIPTION" in file.name :
                            infocode="100"	
                            techname="DESCRIPTION"	
                        elif "OPERATION" in file.name :
                            infocode="120"	
                            techname="OPERATION"
                        elif "PERFORMANCE" in file.name :
                            infocode="130"	
                            techname="PERFORMANCE"
                        elif "ELECTRICAL_POWER" in file.name :
                            infocode="140"	
                            techname="ELECTRICAL_POWER"	
                        elif "COOLING" in file.name :
                            infocode="150"	
                            techname="COOLING"		
                        elif "ALIGNMENT" in file.name :
                            infocode="220"	
                            techname="ALIGNMENT"	
                        elif "FAULT ISOLATION" in file.name or "SYSTEM_INTERCONNECT" in file.name:
                            infocode="250"	
                            techname="FAULT ISOLATION"

                        elif "CLEANING" in file.name or "MAINTENANCE_PRACTICES" in file.name or "CHECK" in file.name:
                            infocode="300"	
                            techname="CLEANING"	
                        elif "DOCUMENTS" in file.name: 
                            infocode="350"	
                            techname="DOCUMENTS"	
                        elif "TROUBLESHOOTING" in file.name  :
                            infocode="400"	
                            techname="TROUBLESHOOTING"
                        elif "REMOVAL" in file.name :
                            infocode="450"	
                            techname="REMOVAL"
                        elif "INSPECTION" in file.name :
                            infocode="500"
                            techname="INSPECTION"
                        elif "REPAIR" in file.name :
                            infocode="600"	
                            techname="REPAIR"

                        elif "INSTALLATION" in file.name and "APPENDIX" not in file.name and "CHECK" not in file.name:
                            infocode="700"	
                            techname="INSTALLATION"	
                        elif "PACKING" in file.name :
                            infocode="800"	
                            techname="PACKING"		
                        elif "APPENDIX_B" in file.name :
                            infocode="920"	
                            techname="APPENDIX_B"	
                        elif "APPENDIX_C" in file.name :
                            infocode="930"	
                            techname="APPENDIX_C"	
                        elif "APPENDIX_D" in file.name :
                            infocode="940"	
                            techname="APPENDIX_D"
                        elif "APPENDIX_E" in file.name :
                            infocode="950"	
                            techname="APPENDIX_E"
                        elif "APPENDIX_F" in file.name :
                            infocode="960"	
                            techname="APPENDIX_F"		
                        else : 
                            infocode="910"	
                            techname="ENGINE"
                            if infocount<=9 :
                                zero1A="0"+str(infocount)+"A"
                            else :
                                zero1A=str(infocount)+"A"
                        if counter == 26 : 	
                            infocount += 1	
                            if infocount<=9 :
                                zero1A="0"+str(infocount)+"A"
                            else :
                                zero1A=str(infocount)+"A"
                            counter=0	
                    name="DMC-HON"+cage_code+"-EAA-"+ata_code+"-"+zero1A+"-"+infocode+alphabet[counter]+"-C.xml"	
                    if int(option) == 2 or int(option) == 3 :				
                        name=file.name[0:-15]+"__"+name

                    counter += 1
                    #Create dmc with name based on file name
                    with (path_name / name).open("w+",  encoding='utf-8') as MODULE:
                        #Prints required text for procedural dm (pre-content)
                        for a in range(len(split_dmc)) :
                            #Changes tech name for each dm
                            if split_dmc[a].find("<techName>")>=0 :
                                split_dmc[a]=split_dmc[a].replace("ASSEMBLY", techname)
                                split_dmc[a]=split_dmc[a].replace("TECHNAME", techname)
                            MODULE.write(split_dmc[a]+"\n")		

                        #Print module info while no new dmc match is found
                        while True:  							
                            ##################################################
                            #####How each modules is treated 
                            #####################################################
                            new_line=False

                            #Creates procedural steps and title at every ^[A-Z]\.
                            if new_dmc.match(split_section[i]) :
                                #Actions done to 
                                split_section[i]=re.sub(new_dmc, "<proceduralStep><title>",split_section[i])		
                                split_section[i]=re.sub("</t></r></si>", "</title>",split_section[i])		
                                #List of status to set 
                                new_dmc_created=True
                                new_table=False
                                new_note=False
                                new_list=False
                                new_figure=False
                                sublevel_created=False
                                subsublevel_created=False
                                subsubsublevel_created == False
                                new_sub_times_4_created=False

                            #Creates procedural steps at every ^[(]\d*[)] value 
                            if new_level.match(split_section[i]) :																					
                                if new_dmc_created == True :
                                    MODULE.write("<!--new level:new_dmc_created == True-->")
                                elif new_table == True or new_figure == True or new_note == True:
                                    #MODULE.write("<!--new level: table or figure or note -->")
                                    MODULE.write("</proceduralStep>\n")
                                    new_table=False	
                                    new_figure=False	
                                    new_note=False
                                    if sublevel_created == True :
                                        MODULE.write("<!--new level:sublevel_created == True and table-->")
                                        MODULE.write("</proceduralStep>\n")	
                                    elif subsublevel_created == True :
                                        MODULE.write("<!--new level:subsublevel_created == True-->")
                                        MODULE.write("</proceduralStep></proceduralStep>\n")
                                    elif subsubsublevel_created == True : 	
                                        MODULE.write("<!--new level:subsubsublevel_created == True-->")
                                        MODULE.write("</proceduralStep></proceduralStep></proceduralStep>\n")	
                                elif sublevel_created == True :
                                    MODULE.write("<!--new level:sublevel_created == True-->")
                                    MODULE.write("</para></proceduralStep></proceduralStep>\n")	
                                    closed_sublevel += 1	
                                elif subsublevel_created == True : 	
                                    MODULE.write("<!--new level:subsublevel_created == True-->")
                                    MODULE.write("</para></proceduralStep></proceduralStep></proceduralStep>\n")	

                                elif subsubsublevel_created == True : 	
                                    MODULE.write("<!--new level:subsubsublevel_created == True-->")
                                    MODULE.write("</para></proceduralStep></proceduralStep></proceduralStep></proceduralStep>\n")	

                                elif new_level_created == True :
                                    MODULE.write("<!--new level:new_level_created == True-->")
                                    MODULE.write("</para></proceduralStep>\n")															
                                split_section[i]=re.sub(new_level, "<proceduralStep><para>", split_section[i])
                                split_section[i]=re.sub("</t></r></si>",  "",split_section[i])
                                #Change all conditions to false except this one 
                                new_table=False
                                new_note=False
                                new_list=False
                                new_figure=False
                                new_dmc_created=False
                                new_level_created=True
                                sublevel_created=False
                                subsublevel_created=False
                                subsubsublevel_created == False
                                new_sub_times_4_created=False

                            #Creates procedural steps at every ^[(][a-z]*[)] value 
                            if new_sublevel.match(split_section[i]) :
                                # If there are more opened steps then closed ones it adds a closing tag													
                                if subsublevel_created == True:
                                    if new_note == False and new_figure == False:
                                        MODULE.write("<!--new_sublevel :subsublevel_created == True ,no note and no figure -->")
                                        MODULE.write("</para></proceduralStep></proceduralStep>\n")
                                    if new_note == True or new_figure == True:
                                        MODULE.write("<!--new_sublevel :subsublevel_created == True ,new note or new figure  -->")
                                        MODULE.write("</proceduralStep></proceduralStep>\n")
                                #If previous step was 2 further indented 	
                                elif subsubsublevel_created == True:
                                    MODULE.write("<!--new_sublevel :subsubsublevel_created == True -->")
                                    MODULE.write("</para></proceduralStep></proceduralStep>\n")						
                                elif sublevel_created == True and new_note == False  :
                                    MODULE.write("<!--new_sublevel:sublevel_created == True-->")
                                    MODULE.write("</para></proceduralStep>\n")	
                                elif sublevel_created == True and new_note == True  :
                                    MODULE.write("<!--new_sublevel : sublevel_created == True new_note == True-->")
                                    MODULE.write("</proceduralStep>\n")

                                elif new_level_created == True and new_note == False :
                                    MODULE.write("<!--new_sublevel:new_level_created == True-->")
                                    MODULE.write("</para>\n")	
                                split_section[i]=re.sub(new_sublevel, "<proceduralStep><para>", split_section[i])
                                open_sublevel += 1
                                #Change all conditions  to false except this one 
                                new_note=False
                                new_list=False
                                new_table=False
                                sublevel_created=True
                                new_figure=False
                                subsublevel_created=False
                                new_level_created=False
                                subsubsublevel_created=False
                                new_dmc_created=False
                                new_sub_times_4_created=False

                            #Creates step at every ^\d option 1
                            if new_subsublevel.match(split_section[i]) :	
                                #If last line was also at this level add just para	
                                if subsublevel_created == True and new_note == False :
                                    MODULE.write("<!--subsublevel: subsublevel_created == True , note false-->")
                                    MODULE.write("</para></proceduralStep>\n")	
                                elif subsublevel_created == True and new_note == True :
                                    MODULE.write("<!--subsublevel: subsublevel_created == True , note true-->")
                                    MODULE.write("</proceduralStep>\n")	
                                elif sublevel_created == True and new_note == False :
                                    MODULE.write("<!--subsublevel: sublevel_created == True-->")
                                    MODULE.write("</para>")		

                                elif subsubsublevel_created == True:
                                    MODULE.write("<!--subsublevel: subsubsublevel_created == True-->")
                                    MODULE.write("</para></proceduralStep></proceduralStep>")	
                                elif new_figure == True:
                                    MODULE.write("<!--subsublevel: last line figure-->")
                                    MODULE.write("</proceduralStep>\n")			

                                elif new_subsublevel == True :
                                    MODULE.write("<!--subsublevel: new_subsublevel == True-->")
                                    MODULE.write("</para></proceduralStep>\n")	

                                split_section[i]=re.sub(new_subsublevel, "<proceduralStep><para>", split_section[i])
                                #Change all conditions 
                                new_list=False
                                subsublevel_created=True
                                new_table=False
                                new_note=False
                                new_figure=False
                                new_dmc_created=False
                                sublevel_created=False
                                subsubsublevel_created=False
                                new_sub_times_4_created=False

                            #Creates step at every <u/>[a-z] option 1 						
                            if new_subsubsublevel.match(split_section[i]) :								
                                # If there are more opened steps then closed ones it adds a closing tag							
                                if new_figure == True or new_note == True :
                                    MODULE.write("<!-- new_subsubsublevel: new_figure == True or new note -->")
                                    MODULE.write("</proceduralStep>\n")	
                                elif subsublevel_created == True :
                                    MODULE.write("<!-- new_subsubsublevel: subsublevel_created == True-->")	
                                    MODULE.write("</para>\n")	
                                elif new_sub_times_4_created == True:
                                    MODULE.write("<!-- new_subsubsublevel: new_sub_times_4_created == True-->")	
                                    MODULE.write("</para></proceduralStep>")
                                elif subsubsublevel_created == True :
                                    MODULE.write("<!-- new_subsubsublevel: new_subsubsublevel == True-->")	
                                    MODULE.write("</para></proceduralStep>")
                                split_section[i]=re.sub(new_subsubsublevel, "<proceduralStep><para>", split_section[i])
                                open_subsubsublevel += 1	
                                #Change all conditions to false except current one 
                                new_list=False
                                new_note=False
                                new_figure=False
                                subsubsublevel_created=True
                                new_table=False
                                new_dmc_created=False
                                sublevel_created=False
                                new_sub_times_4_created=False
                                subsublevel_created=False

                            # If level match (1) underlined 
                            if new_sub_times_4_level.match(split_section[i]):
                                if new_sub_times_4_created == True :
                                    MODULE.write("<!-- new_sub_times_4_level: new_sub_times_4_created == True-->")	
                                    MODULE.write("</para></proceduralStep>")
                                elif subsubsublevel_created == True:
                                    MODULE.write("<!-- new_sub_times_4_level: subsubsublevel_created == True-->")
                                    MODULE.write("</para>")
                                split_section[i]=re.sub(new_sub_times_4_level, "<proceduralStep><para>", split_section[i])
                                #Change all conditions to false except current one 
                                new_list=False
                                new_note=False
                                new_figure=False
                                subsubsublevel_created=False
                                new_table=False
                                new_dmc_created=False
                                sublevel_created=False
                                new_sub_times_4_created=True
                                new_line=False

                            if figure_placement.match(split_section[i]):								
                                #Captures the figure title 
                                figure_title= re.sub("\(Sheet (.*?)\)","", split_section[i])
                                if new_figure == True or new_table == True or new_dmc == True:							
                                    split_section[i]=figure_title
                                else:
                                    split_section[i]="</para>"+figure_title
                                #Fixes an error with figure text
                                if i+1 <len(split_section):								
                                    #Create legend for figure if it exists 
                                    if figure_key1.match(split_section[i+1]) or figure_key2.match(split_section[i+1]) :
                                        split_section[i+1]="<legend><definitionList>\n"
                                        split_section[i]=split_section[i][:-9]+"\n"
                                        MODULE.write(split_section[i]+split_section[i+1])
                                        i += 2
                                        key_entries_found=False
                                        while key_entries.match(split_section[i]) :
                                            key_entries_found=True
                                            split_section[i]="<definitionListItem><listItemTerm></listItemTerm><listItemDefinition><para>"+split_section[i]+"</para></listItemDefinition></definitionListItem>\n"
                                            split_section[i]=split_section[i].replace("	", "</para></listItemDefinition></definitionListItem><definitionListItem><listItemTerm></listItemTerm><listItemDefinition><para>")
                                            split_section[i]=re.sub("</listItemTerm><listItemDefinition><para>(\d+\.)", "\g<1></listItemTerm><listItemDefinition><para>",split_section[i])
                                            split_section[i]=split_section[i].replace(".</listItemTerm>","</listItemTerm>")
                                            MODULE.write(split_section[i])
                                            i += 1
                                        if key_entries_found == False:
                                            MODULE.write("<definitionListItem><listItemTerm></listItemTerm><listItemDefinition><para></para></listItemDefinition></definitionListItem>\n")
                                        MODULE.write("</definitionList></legend></figure>\n")
                                        new_line=True
                                #Change all conditions 
                                new_note=False
                                new_list=False
                                new_table=False
                                new_figure=True

                            #Creates lists if current line and next line start with periods 
                            if i+1 <len(split_section) :
                                if (period_start.match(split_section[i]) and period_start.match(split_section[i+1])) or (period_start1.match(split_section[i]) and period_start1.match(split_section[i+1]))or (dash_start.match(split_section[i]) and dash_start.match(split_section[i+1])):
                                    i=list_treatment(split_section, i)															
                                    #Change all conditions 
                                    new_list=True
                                    new_figure=False
                                    new_dmc_created=False
                                    new_sub_times_4_created=False
                                #if only current line has a period start treat it as a para and 
                                elif (period_start.match(split_section[i]) or period_start1.match(split_section[i])  ) and new_dmc_created == True:
                                    split_section[i]=re.sub(period_start, "<para>",split_section[i])
                                    split_section[i]=re.sub(period_start1, "<para>",split_section[i])
                                    split_section[i]=re.sub("</t></r></si>",  "",split_section[i])

                            #Creates tables 	
                            if table_placement.match(split_section[i])  :							
                                if subsublevel_created == True or sublevel_created == True or new_level_created == True and new_table == False and new_note == False:
                                    #Next line must remain commented out , causes error . Error : extra /para appears before table
                                    #MODULE.write("<!--table: some level == True: -->")	
                                    MODULE.write("</para>")								
                                i= table_treatment(split_section,i)
                                new_table=True
                                new_line=True
                                new_note=False
                                new_figure=False

                            #Create table for key 
                            if figure_key1.match(split_section[i]) or  figure_key2.match(split_section[i]):
                                if subsublevel_created == True or sublevel_created == True or new_level_created == True:
                                    MODULE.write("<!--table subsublevel_created == True: -->")	
                                    MODULE.write("</para>")			
                                split_text[i]="<table><title>"+split_text[i]+"</title>"
                                split_text[i]=re.sub("<title>\.\s+","<title>",split_text[i])
                                i= table_treatment(split_section,i)
                                new_table=True
                                new_line=True
                                new_note=False
                                new_figure=False
                                new_dmc_created=False 
                                new_level_created == False	

                            #Place holder for warnings and cautions  currently using note tag
                            if warning_placement.match(split_section[i]) or caution_placement.match(split_section[i]) or note_placement.match(split_section[i]):
                                if new_table == False and new_dmc_created == False and new_note == False :
                                    #MODULE.write("<!--note added para -->")	
                                    MODULE.write("</para>")
                                if new_dmc_created == True :
                                    prior_dmc=True
                                else :
                                    prior_dmc=False
                                if warning_placement.match(split_section[i]) or caution_placement.match(split_section[i]):
                                    split_section[i]="<note><notePara>"+split_section[i]+"</notePara></note>"
                                new_note=True
                                new_table=False
                                new_figure=False						
                                new_list=False							

                            #####Special rules for different sections 
                            if infocode == "018" :							
                                #Create list of Acronyms and Abbreviations
                                if "List of Acronyms and Abbreviations" in split_section[i]:
                                    MODULE.write("</para><table><title>"+split_section[i]+"</title>\n")
                                    MODULE.write("<tgroup cols=\"2\"><colspec colname=\"col1\"/><colspec colname=\"col2\"/><tbody>")
                                    while i<=len(split_section):
                                        if second_level.match(split_section[i]):
                                            new_table=True
                                            new_line= True
                                            break
                                        split_section[i]= "<row><entry><para>"+split_section[i]+"</para></entry></row>"
                                        split_section[i]= re.sub("\s{2,}","</para></entry><entry><para>", split_section[i])
                                        split_section[i]= re.sub(" 	","</para></entry><entry><para>", split_section[i])
                                        if "Acronyms and Abbreviations" in split_section[i] or "(cont)" in split_section[i] :
                                            split_section[i]=""
                                        MODULE.write(split_section[i]+"\n")									

                                        if i+1>=len(split_section):
                                            split_section[i]=""
                                            new_table=True
                                            break			
                                        if new_dmc.match(split_section[i+1]) :
                                            break
                                        i += 1
                                    MODULE.write("</tbody></tgroup></table>\n")
                                    new_line=True

                                if "The section(s) shown below has(have) been performance checked at the" in split_section[i] and "<underline>Section</underline>" in split_section[i+1]:
                                    split_section[i+1]=" </para><table><tgroup cols=\"2\"><colspec colname=\"col1\"/><colspec colname=\"col2\"/><tbody><row>"
                                    split_section[i+1] += "<entry><para>Section</para></entry><entry><para>Date</para></entry></row>"
                                    split_section[i+2]="<row><entry><para>"+split_section[i+2]+"</para></entry></row></tbody></tgroup></table>"
                                    split_section[i+2]=split_section[i+2].replace("	","</para></entry><entry><para>")
                                    split_section[i+2]=split_section[i+2].replace("   ","</para><para>")
                                    new_table=True

                            #Add missing paras part 1
                            if new_dmc_created == True and ">" not in split_section[i] and "</para>" in split_section[i-1]:
                                split_section[i]="<para>"+split_section[i] 

                            #If curent i has not been checked by all options loop again
                            if not new_line:	
                                #Remove extra tags from conversion
                                split_section[i]=split_section[i].replace("</t></r></si>", "")	
                                split_section[i]=re.sub("<underline>", "", split_section[i])
                                split_section[i]=re.sub("</underline>", "", split_section[i])
                                split_section[i]=re.sub("<superscript>", "", split_section[i])
                                split_section[i]=re.sub("</superscript>", "", split_section[i])
                                split_section[i]=re.sub("</t></r>", "", split_section[i])
                                if split_section[i].strip() != "":
                                    MODULE.write(split_section[i]+"\n")
                                i += 1
                                
                            if i >=len(split_section) - 1 : 			
                                break
                                
                            if new_dmc.match(split_section[i]) : 			
                                break	
                        #Write in closing tags	

                        if (new_figure == True or new_table == True or new_note == True ) and new_dmc_created == False:							
                            #MODULE.write("<!-- figure or table at previous line -->")	
                            final_line=("</para></proceduralStep>\n")	

                            new_figure=False	
                            if subsublevel_created == True :
                                final_line += "</proceduralStep></proceduralStep>\n"
                                subsublevel_created=False
                            if sublevel_created == True:
                                final_line += "</proceduralStep>\n"
                            sublevel_created=False	
                        elif (new_figure == True or new_table == True or new_note == True ) and new_dmc_created == True:	
                            final_line=("</para>\n")	

                        elif new_dmc_created == True or prior_dmc == True:
                            final_line=("\n")	

                        else:

                            #MODULE.write("<!--no figure or table at previous line -->")	
                            final_line=("</para></proceduralStep>\n")	
                            if new_dmc_created == True :
                                final_line=("</para>\n")
                        if subsublevel_created == True:
                            MODULE.write("<!--closing subsublevel_created == True: -->")
                            final_line += "</proceduralStep>\n</proceduralStep>\n"
                            subsublevel_created=False

                        if subsubsublevel_created == True	:
                            MODULE.write("<!--closing sublevel_created == True: -->")
                            final_line += "</proceduralStep>\n</proceduralStep>\n</proceduralStep>\n"
                            subsubsublevel_created=False
                        MODULE.write(final_line)
                        closed_level += 1						
                        MODULE.write("</proceduralStep></mainProcedure><closeRqmts><reqCondGroup><noConds/></reqCondGroup></closeRqmts></procedure></content></dmodule>")
                        print("completed data module %s" %name)
                    MODULE.close
                    

    except Exception as e:
        log_print("Failed while writing data module {}".format(name))
        log_print(traceback.format_exc(), True)
        errors = True

    try :
    ##########################################################################################################
        #Context checker
        ##########################################################################################
        #dmc_files = [f for f in listdir(path_name) if isfile(join(path_name, f)) and "DMC-HON" in f and (f[-4:] == ".XML" or f[-4:] == ".xml")]
        dmc_files = list(path_name.glob('DMC-HON*.xml'))
        print("Checking for context errors")
        for dmc_file in dmc_files :
            text = dmc_file.read_text(encoding='utf-8')
            text = re.sub(re.compile("<!--(?!Arbortext).*?-->", re.DOTALL), "", text)
            #text = re.sub(r'<mainProcedure>\n?<proceduralStep>\n?<para>([^<]+)</para>', r'<mainProcedure><proceduralStep><title>\1</title>', text)
            text=re.sub("</?underline>", "", text)
            text=re.sub("&lt; /?subscript>", "", text) ##Isn't this fixed in entity replace section?
            ##Sub out superscript as well?
            
            split_dmc=text.splitlines()	
            step_count=0
            ##Can probably do this step without line-by-line
            with dmc_file.open("w+", encoding='utf-8') as DMC :	
                for i in range(len(split_dmc)) :
                    ##These two if statements can be RE
                    if "<dmCode " in split_dmc[i][0:10]  and int(option) == 1: 
                        name=dmc_file.name.split("-")
                        split_dmc[i]="<dmCode assyCode=\""+name[5]+"\" disassyCode=\""+name[6][0:2]+"\" disassyCodeVariant=\"A\" infoCode=\""+name[7][0:3]+"\" infoCodeVariant=\""+name[7][3:]+ \
                         "\"\nitemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/>\n"	
                    if "<dmTitle><techName>" in split_dmc[i] :
                        infocode=dmc_file.name.split("-")[7][0:3]
                        ##Make a dictionary out of this
                        if int(option) == 1:
                            if infocode == "100" :
                                techname="DESCRIPTION"
                            elif infocode == "018"	:
                                techname="INTRODUCTION"
                            elif infocode == "400"	:
                                techname="TESTING AND FAULT ISOLATION"
                            elif infocode == "051":
                                techname="SCHEMATIC AND WIRING DIAGRAMS"
                            elif infocode == "500"	:
                                techname="DISASSEMBLY"
                            elif infocode == "200":
                                techname="CLEANING"
                            elif infocode == "300"	:
                                techname="CHECK"
                            elif infocode == "600"	:
                                techname="REPAIR"
                            elif infocode == "700"	:
                                techname="ASSEMBLY"
                            elif infocode == "711":
                                techname="FITS AND CLEARANCES"
                            elif infocode == "900":
                                techname="SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES"
                            elif infocode == "941":	
                                techname="ILLUSTRATED PARTS LIST"
                            elif infocode == "800":	
                                techname="STORAGE (INCLUDING TRANSPORTATION)"	
                            else :
                                techname=""
                            split_dmc[i] =re.sub("<techName>(.*?)</techName>", "<techName>"+techname+"</techName>",split_dmc[i] )

                    ######Checking steps #####
                    if "<proceduralStep>" in split_dmc[i]:
                        opening=re.findall("<proceduralStep>",split_dmc[i])
                        step_count=step_count+len(opening)
                    if "</proceduralStep>" in split_dmc[i] and "</mainProcedure>" not in split_dmc[i]:
                        closing=re.findall("</proceduralStep>",split_dmc[i])
                        step_count=step_count-len(closing)
                    if "</mainProcedure>" in split_dmc[i]:	
                        closing=re.findall("</proceduralStep>",split_dmc[i])
                        step_count=step_count-len(closing)
                        ##Use absolute value of step count 
                        if step_count == -1 :
                            split_dmc[i]=split_dmc[i].replace("</proceduralStep>","", 1)
                        elif step_count == 1:
                            if "</para>" in split_dmc[i] :
                                split_dmc[i]=split_dmc[i][0:7]+"</proceduralStep>"+split_dmc[i][7:]
                            else :
                                split_dmc[i]="</proceduralStep>"+split_dmc[i]
                        elif step_count == -2	:
                            split_dmc[i]=split_dmc[i].replace("</proceduralStep>","", 2)

                    if split_dmc[i]!="" and split_dmc[i]!=" ":
                        DMC.write(split_dmc[i]+"\n")	 
        print("Part 1 of context checking complete")
        print("Part 2 of context checking commencing")	

        #dmc_files = [f for f in listdir(path_name) if isfile(join(path_name, f)) and "DMC-HON" in f and "00PA" not in f and "00WA" not in f and (f[-4:] == ".XML" or f[-4:] == ".xml")]
        for dmc_file in dmc_files :
            if "00PA" in dmc_file.name or "00WA" in dmc_file.name:
                continue
            
            text = dmc_file.read_text(encoding='utf-8')
            
            text=text.replace("\n"," ")
            text=re.sub("\s{2,}", " ", text)
            text=text.replace("> <","><")
            text=text.replace("<SECOND LEVEL>","<para>")
            text=text.replace("</SECOND LEVEL>","</para>")
            text=text.replace("<subscript>","")
            text=text.replace("</subscript>","")
            text=text.replace("<superscript>","")
            text=text.replace("</superscript>","")
            text=text.replace("<!-- no figure or table at previous line -->","")
            text=text.replace("</para></para>" , "</para>")
            text=re.sub("</para>{2,}", "</para>", text) 
            text=text.replace("<listItem></para>" , "<listItem>")
            text=text.replace("</listItem></para>" , "</listItem>")
            text=text.replace("</para><para></listItem> " , "</para></listItem>")
            text=text.replace("</para><para></proceduralStep>" , "</para></proceduralStep>")
            text=text.replace("</para><randomList>" , "</para><para><randomList>")
            text=re.sub("</para> <!--(.*?)--> </para>", r"</para> <!--\1-->", text)
            text=re.sub("</note></para>", "</note><para>", text)
            text=text.replace("</note></para><figure>","</note><figure>") 
            text=text.replace("</note><para><figure>","</note><figure>") 
            text=text.replace("</note><para><para>","</note><para>")
            text=text.replace("</note><para></proceduralStep>","</note></proceduralStep>")
            text=re.sub("</note><para><note>", "</note><note>", text)
            text=text.replace("</note> <randomList>" , "</note><para><randomList>")
            text=text.replace("</note><randomList>" , "</note><para><randomList>")
            text=text.replace("<entry></para><note>" , "<entry><note>")
            text=text.replace("</note><para></entry>" , "</note></entry>")
            text=re.sub("</table></para>", "</table> ", text)
            text=text.replace("</table></para><table>","</table><table>")
            text=text.replace("</table><para><figure>","</table><figure>")
            text=re.sub("<row><para>", "<row><entry><para> ", text)		
            text=re.sub("</figure></para>", "</figure>", text)
            text=text.replace("<para></para>","")
            text=text.replace("<para><table>","</para><table>")
            text=re.sub("<para><note>", "</para><note>", text)		
            text=text.replace("</proceduralStep> </para> <proceduralStep>" , "</proceduralStep><proceduralStep>")
            text=re.sub("([A-Z])&([A-Z])",r"\1&amp;\2", text)		
            text=re.sub("</figure><para><para>", "</figure><para>", text)
            text=re.sub("</figure><para><note>", "</figure><note>", text)
            text=re.sub("</figure><para>\s+<note>", "</figure><note>", text)
            text=re.sub("</figure><para> <figure>", "</figure><figure>", text)
            text=re.sub("</figure>\s+</para></proceduralStep>", "</figure></proceduralStep>", text)
            text=re.sub("</figure><randomList>", "</figure><para><randomList>", text)
            text=text.replace("</figure> <randomList>" , "</figure><para><randomList>") 
            text=text.replace("</randomList><proceduralStep>" , "</randomList></para><proceduralStep>") 
            text=text.replace("<para> </proceduralStep>" , "</proceduralStep>")
            text=text.replace("!\"#$%&'" , "!\"#$%'")
            text=text.replace("<para><para>","<para>")		
            text=text.replace("<para></para>","")
            text=text.replace("</note><para><para></entry>" , "</note><para></para></entry>")
            text=text.replace("<proceduralStep></para><table>" , "<proceduralStep><table>")
            text=text.replace("</para><?xml version" , "<?xml version")
            text=text.replace("</randomList><note>" , "</randomList></para><note>")
            text=text.replace("<notePara></para><para>" , "<notePara>")
            
            #print("Completed find replaces")
            with dmc_file.open("w+", encoding='utf-8') as DMC :				
                #print("Started: "+dmc_file)

                para_section=re.findall("<para>(.+?)</proceduralStep>", text)
                for a in range(len(para_section)) :				
                    #print(para_section[a])
                    last_para_closed=para_section[a].rfind("</para>")
                    last_para_opened=para_section[a].rfind("<para>")
                    if last_para_opened>last_para_closed :						
                        para_section_new=para_section[a][last_para_opened:]+"</para>"
                        text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)		
                    elif last_para_opened<last_para_closed :
                        #print(para_section[a][last_para_opened:])
                        num_opened=para_section[a].count("<para>")
                        num_opened += 1
                        num_closed=para_section[a].count("</para>")
                        if num_opened!=num_closed :						
                            #Errors normally happen around tables and figures
                            if "<table>" in para_section[a] :
                                open_table=para_section[a].find("<table>")	
                                last_para_opened=para_section[a][:open_table].rfind("<para>")
                                if "<" not in para_section[a][last_para_opened+6:open_table] and len(para_section[a][last_para_opened+6:open_table])>5 :
                                    para_section_new=para_section[a][last_para_opened+6:open_table]+"</para>"
                                    text=text.replace(para_section[a][last_para_opened+6:open_table], para_section_new, 1)
                                    para_section[a]=para_section[a].replace(para_section[a][last_para_opened+6:open_table], para_section_new, 1)
                                    num_closed=para_section[a].count("</para>")
                                    num_opened=para_section[a].count("<para>")
                                    num_opened += 1
                            if "</table>" in para_section[a] and num_opened!=num_closed :
                                close_table=para_section[a].find("</table>")
                                last_para_closed=para_section[a][close_table:].find("</para>")
                                last_para_opened=para_section[a][close_table:].find("<para>")
                                if "<para>" in para_section[a][close_table:close_table+20] :
                                    next_tag=para_section[a][close_table+14:].find("<")
                                    next_tag=close_table+14+next_tag+6
                                    if "</para" not in para_section[a][close_table+14:next_tag] and "<figur" in para_section[a][next_tag-8:next_tag]:
                                        para_section_new=para_section[a][close_table+14:next_tag-6]+"</para>"
                                        text=text.replace(para_section[a][close_table+14:next_tag-6], para_section_new , 1)									
                                        para_section[a]=para_section[a].replace(para_section[a][close_table+14:next_tag-6], para_section_new, 1)
                                        num_closed=para_section[a].count("</para>")
                                        num_opened=para_section[a].count("<para>")
                                        num_opened += 1									
                            if "</figure>" in para_section[a] and num_opened!=num_closed:
                                close_figure=para_section[a].rfind("</figure>")															
                                if "</para>" in para_section[a][close_figure+9:] and "<para>" not in  para_section[a][close_figure+9:]:
                                    #This  next line limites the scope of the search but also fucks up the numbering 
                                    last_para_closed=para_section[a][close_figure+9:].rfind("</para>")
                                    last_para_closed=close_figure+9+last_para_closed
                                    #print("/para> found")
                                    #print(para_section[a][close_figure+9:last_para_closed])	
                                    para_section_new="<para>"+para_section[a][close_figure+9:last_para_closed]
                                    text=text.replace(para_section[a][close_figure+9:last_para_closed], para_section_new, 1)
                                    para_section[a]=para_section[a].replace(para_section[a][close_figure+9:last_para_closed], para_section_new, 1)
                                    num_closed=para_section[a].count("</para>")
                                    num_opened=para_section[a].count("<para>")
                                    num_opened += 1
                            if "</note>" in para_section[a] and num_opened!=num_closed:	
                                close_note=para_section[a].find("</note>")								
                                last_para_closed=para_section[a][close_note:].find("</para>")
                                last_para_opened=para_section[a][close_note:].find("<para>")
                                if last_para_opened == -1 and last_para_closed!=-1 :				
                                    para_section_new="<para>"+para_section[a][close_note+7:]
                                    text=text.replace(para_section[a][close_note+7:], para_section_new, 1)
                                    para_section[a]=para_section[a].replace(para_section[a][close_note+7:], para_section_new, 1)
                                    num_closed=para_section[a].count("</para>")
                                    num_opened=para_section[a].count("<para>")
                                    num_opened += 1
                
                para_section=re.findall("</table>(.+?)<figure>", text)
                for a in range(len(para_section)) :	
                    if "<para>" in para_section[a] and "</para>" not in para_section[a] and "<table>" not in  para_section[a] :					
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)
                        
                para_section=re.findall("</figure>(.+?)<figure>", text)
                for a in range(len(para_section)) :	
                    if "<" not in para_section[a] :
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)
                        
                para_section=re.findall("</figure>(.+?)<randomList>", text)
                for a in range(len(para_section)) :	
                    #print(para_section[a])
                    if "<para>" not in para_section[a] and "<" not in para_section[a]:
                        para_section_new="<para>"+para_section[a]
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)
                    if "<para>" not in para_section[a] and "</figure>" in  para_section[a] :
                        last_fig_closed=para_section[a].rfind("</figure>")
                        last_fig_closed=last_fig_closed+9
                        if "<" not in para_section[a][last_fig_closed:]:
                            para_section_new="<para>"+para_section[a][last_fig_closed:]
                            text=text.replace(para_section[a][last_fig_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_fig_closed:], para_section_new, 1)
                        elif "</note>" in para_section[a][last_fig_closed:] :
                            last_note_closed=para_section[a].rfind("</note>")
                            last_note_closed=last_note_closed+7
                            para_section_new="<para>"+para_section[a][last_note_closed:]
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "</figure>" in  para_section[a] :
                        last_fig_closed=para_section[a].rfind("</figure>")
                        last_fig_closed=last_fig_closed+9					
                        if "<para>" not in para_section[a][last_fig_closed:] and "<" not in para_section[a][last_fig_closed:]:
                            para_section_new="<para>"+para_section[a][last_fig_closed:]
                            text=text.replace(para_section[a][last_fig_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_fig_closed:], para_section_new, 1)

                para_section=re.findall("</figure>(.+?)<table>", text)
                for a in range(len(para_section)) :	
                    if "<" not in para_section[a] :
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)				
                    last_fig_closed=para_section[a].rfind("</figure>")
                    if last_fig_closed!=-1 :
                        last_fig_closed=last_fig_closed+10
                        if "<" not in para_section[a][last_fig_closed:] and len(para_section[a][last_fig_closed:])>4 :
                            para_section_new="<para>"+para_section[a][last_fig_closed:]+"</para>"
                            text=text.replace(para_section[a][last_fig_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_fig_closed:], para_section_new, 1)

                para_section=re.findall("<para>(.+?)<note>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:]:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:	
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)
                        
                para_section=re.findall("<para>(.+?)<table>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:]:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:	
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)
                        
                para_section=re.findall("<para>(.+?)<figure>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:] and len(para_section[a][last_para_opened:])>3:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)

                para_section=re.findall("<para>(.+?)<proceduralStep>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:] and len(para_section[a][last_para_opened:])>3:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)		

                para_section=re.findall("<para>(.+?)<para>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:] and len(para_section[a][last_para_opened:])>3:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)				

                para_section=re.findall("<para>(.+?)</proceduralStep>", text)
                for a in range(len(para_section)) :					
                    if "<para>" in para_section[a] :
                        last_para_opened=para_section[a].rfind("<para>")
                        last_para_opened += 6
                        if "<" not in para_section[a][last_para_opened:] and len(para_section[a][last_para_opened:])>3:
                            para_section_new=para_section[a][last_para_opened:]+"</para>"
                            text=text.replace(para_section[a][last_para_opened:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_para_opened:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)				

                para_section=re.findall("</figure>(.+?)</para>", text)
                for a in range(len(para_section)) :					
                    if "</figure>" in para_section[a] :
                        last_fig_closed=para_section[a].rfind("</figure>")
                        last_fig_closed += 9
                        if "<" not in para_section[a][last_fig_closed:] and len(para_section[a][last_fig_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_fig_closed:]
                            text=text.replace(para_section[a][last_fig_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_fig_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)	

                para_section=re.findall("</figure>(.+?)</proceduralStep>", text)
                for a in range(len(para_section)) :					
                    if "</figure>" in para_section[a] :
                        last_fig_closed=para_section[a].rfind("</figure>")
                        last_fig_closed += 9
                        if "<" not in para_section[a][last_fig_closed:] and len(para_section[a][last_fig_closed:])>3 :
                            para_section_new="<para>"+para_section[a][last_fig_closed:]+"</para>"
                            text=text.replace(para_section[a][last_fig_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_fig_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)

                para_section = re.findall("</randomList>(.+?)</?proceduralStep>", text)
                for a in range(len(para_section)) :					
                    if "</randomList>" in para_section[a] :
                        last_list_closed=para_section[a].rfind("</randomList>")
                        last_list_closed += 13
                        if "<" not in para_section[a][last_list_closed:] and len(para_section[a][last_list_closed:])>3:
                            para_section_new=para_section[a][last_list_closed:]+"</para>"
                            text=text.replace(para_section[a][last_list_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_list_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)		

                para_section=re.findall("</randomList>(.+?)<table>", text)
                for a in range(len(para_section)) :					
                    if "</randomList>" in para_section[a] :
                        last_list_closed=para_section[a].rfind("</randomList>")
                        last_list_closed += 13
                        if "<" not in para_section[a][last_list_closed:] and len(para_section[a][last_list_closed:])>3:
                            para_section_new=para_section[a][last_list_closed:]+"</para>"
                            text=text.replace(para_section[a][last_list_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_list_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new=para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)			

                para_section=re.findall("</note>(.+?)</proceduralStep>", text)
                for a in range(len(para_section)) :					
                    if "</note>" in para_section[a] :
                        last_note_closed=para_section[a].rfind("</note>")
                        last_note_closed += 7
                        if "<" not in para_section[a][last_note_closed:] and len(para_section[a][last_note_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_note_closed:]+"</para>"
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)	

                para_section=re.findall("</note>(.+?)<note>", text)
                for a in range(len(para_section)) :					
                    if "</note>" in para_section[a] :
                        last_note_closed=para_section[a].rfind("</note>")
                        last_note_closed += 7
                        if "<" not in para_section[a][last_note_closed:] and len(para_section[a][last_note_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_note_closed:]+"</para>"
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)		

                para_section=re.findall("</note>(.+?)<randomList>", text)
                for a in range(len(para_section)) :					
                    if "</note>" in para_section[a] :
                        last_note_closed=para_section[a].rfind("</note>")
                        last_note_closed += 7
                        if "<" not in para_section[a][last_note_closed:] and len(para_section[a][last_note_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_note_closed:]
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)

                para_section=re.findall("</note>(.+?)</para>", text)
                for a in range(len(para_section)) :					
                    if "</note>" in para_section[a] :
                        last_note_closed=para_section[a].rfind("</note>")
                        last_note_closed += 7
                        if "<" not in para_section[a][last_note_closed:] and len(para_section[a][last_note_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_note_closed:]
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)	

                para_section=re.findall("</note>(.+?)<table>", text)
                for a in range(len(para_section)) :					
                    if "</note>" in para_section[a] :
                        last_note_closed=para_section[a].rfind("</note>")
                        last_note_closed += 7
                        if "<" not in para_section[a][last_note_closed:] and len(para_section[a][last_note_closed:])>3:
                            para_section_new="<para>"+para_section[a][last_note_closed:]+"</para>"
                            text=text.replace(para_section[a][last_note_closed:], para_section_new, 1)
                            para_section[a]=para_section[a].replace(para_section[a][last_note_closed:], para_section_new, 1)
                    if "<" not in para_section[a] and len(para_section[a])>3:
                        para_section_new="<para>"+para_section[a]+"</para>"
                        text=text.replace(para_section[a], para_section_new, 1)
                        para_section[a]=para_section[a].replace(para_section[a], para_section_new, 1)

                DMC.write(text)		
        #####After all the other changes have be made make 1 more find replace check to ensure no new errors were introduced
        ##Can be part of the previous for-loop
        for dmc_file in dmc_files :
            text = dmc_file.read_text(encoding="utf-8")
            
            with dmc_file.open("w+", encoding='utf-8') as DMC :				
                text=text.replace("\n"," ")
                text=re.sub("\s{2,}", " ", text)
                text=text.replace(">\s*<","><")
                text = re.sub("(?:<para>)+","<para>", text)
                text = re.sub("(?:</para>)+","</para>", text)
                text= re.sub("</?SECOND LEVEL>","", text)
                text=text.replace("<title><para>","<title>")
                text=text.replace("</para></title>","</title>")
                text=re.sub("</para>{2,}", "</para>", text) 
                text=re.sub("<(/?)listItem></para>" , r"<\1listItem>", text)
                text=text.replace("<para<para>>" , "<para>")
                text=text.replace("</para><para></listItem> " , "</para></listItem>")
                text=text.replace("</note></para>","</note>") 
                text=text.replace("<entry></para>" , "<entry>")
                text = re.sub("(?:<para>)+<(/?)(table|figure|note|notePara|entry|listItem|proceduralStep)>", r"<\1\2>", text)
                text = re.sub("<(table|figure|note|notePara)>(?:</?para>)+", r"<\1>", text)
                text = re.sub("<row><para>", "<row>", text)
                text = text.replace("</proceduralStep></para>" , "</proceduralStep>")
                text = re.sub("(?<!<para>)<randomList>", "<para><randomList>", text)
                text = re.sub("</randomList>(?!</para>)", "</randomList></para>", text)
                text = text.replace("!\"#$%&'" , "!\"#$%'")
                text = re.sub("&(?!\S+;)", '&amp;', text)
                text = text.replace("</para><?xml version" , "<?xml version")
                text = re.sub("<para><(/?)proceduralStep>", r"<\1proceduralStep>", text)
                text = text.replace("<para></para>","")
                text = re.sub(r"(?:<para>)+<(/?)entry>" , r"<\1entry>", text)
                text = re.sub(r'</note></para>', r'</note>', text)
                def close_tag(match):
                    if match.group(3) == "/{}".format(match.group(1)):
                        return match.group(0)
                    else:
                        return "<{0}>{1}</{0}><{2}>".format(match.group(1), match.group(2), match.group(3))
                text = re.sub(re.compile(r'<(para)>(.*?)<(/?(?:para|proceduralStep|table|entry|listItem|row|figure|graphic|note))>', re.DOTALL), close_tag, text) 
                #text=text.replace("><",">\n<")
            
                DMC.write(text)	
        print("Context verification complete")				
    except Exception as e:
        log_print("Context check failed")
        log_print(traceback.format_exc(), True)
        errors = True

        #########################################################    IPL BUILDER #################################################################################
    ipl_files = [f for f in listdir(path_name) if isfile(join(path_name, f)) and "941" in f]
    if len(ipl_files)>0 :
        try :

            alphabet= list(string.ascii_uppercase)
            #path_name = os.path.dirname(os.path.realpath(__file__))
            Page_num1 = re.compile("^Page")
            New_section1= re.compile("^<figure><title>")
            New_section2= re.compile("^IPL Figure \d+\w?\.")
            vendor_format = re.compile("^(.*?)\(V\d{5}\)")
            CSD_format = re.compile("^(.*?)\(CSD: (.*?) V\d{5}\)")
            CSD_format2 = re.compile("^(.*?)\(CSD: (.*?)-\d{4,}\)")
            OPT_format1 = re.compile("^(.*?)\(OPT PN:(.*?) V\d{5}\)")
            OPT_format2 = re.compile("^(.*?)\(OPT PN:(.*?)\)")
            OPT_format3= re.compile("^(.*?)\(OPT (.*?)\)")
            PRE_SB_format1 = re.compile("^(.*?)\(PRE SB(.*?)\)")
            PRE_SB_format2 = re.compile("^(.*?)\(PRE SPB(.*?)\)")
            POST_SB_format1 = re.compile("^(.*?)\(POST SB(.*?)\)")
            POST_SB_format2 = re.compile("^(.*?)\(POST SPB(.*?)\)")
            Ord_format = re.compile("^(.*?)\(ORDER PN(.*?)\)")
            REPLD_format1 = re.compile("^(.*?)\(REPLACED BY(.*?)\)")
            REPLD_format2 = re.compile("^(.*?)\(REPL BY(.*?)\)")
            REPLs_format = re.compile("^(.*?)\(REPLACES ITEM(.*?)\)")
            UPA_format = re.compile("^(.*?) \d+ ")
            EFF_format1 = re.compile("^(.*?) [A-Z] ")
            EFF_format2 = re.compile("^(.*?) ([A-Z],)+[A-Z]")
            EFF_format3 = re.compile("^(.*?) [A-Z]\n")
            EFF_format4 = re.compile("^(.*?) [A-Z]-[A-Z] ")
            Rds_format0= re.compile(r"^([A-UW-Z]\d+,?)+")
            Rds_format1= re.compile(r"^(.*?) ([A-Z]\d+,)+[A-Z]\d+")
            Rds_format2= re.compile(r"^(.*?) [A-Z]\d{1,3} ")
            Rds_format3= re.compile(r"^(.*?) \([A-Z]\d+\)")
            Rds_format4= re.compile(r"^(.*?) \(([A-Z](\d+),)+[A-Z]\d+}\)")
            Rds_format5= re.compile(r"^[A-Z]\d+ ")
            dimension1=re.compile("^(.*?)\(\d\.\d UF (.*?)\)")
            dimension2=re.compile("^(.*?)\(\d+ OHMS(.*?)W\)")
            dimension3=re.compile("^(.*?)\(\d\.\d+ IN. THK\)")

            First_row= "\"Figure Number\",\"ATA\",\"CAGE\",\"Title\",\"Sheets\" "
            ##column names for the ipl#####
            data_name_row = """"Illustrated Items","Item No","Part Number (< 15 chrs)","CAGE","Indent","Keyword","Additional Description ","Dimensions","Attached Part","ESDS","RDs","Over-length PN","HPN","HPN CAGE","Optional PN","Option CAGE","Replaced by item","Replaces item","Superceded by item ","Supercedes item","Pre SB","Post SB","Use with Item","See FIG. For NHA","See FIG. For Details","See FIG. For Removal","See FIG. For BKDN","Miscellaneous Notes","EFF Code","UPA",\n"""
            counter=0
            ###Data for the book ###
            date_value="17 Oct 2016"
            header_value=re.compile("^TCN-2020 Ignition Exciter")

            try:
                text = (path_name / "ILLUS_941_pt.txt").read_text(encoding='utf-8')
                #Do processing on whole IPL here
                text=re.sub("H­", "H-", text)
                text=re.sub("\(PRE \nSB", "(PRE SB", text)
                last_section = "0"
                for IPL_Fig in re.finditer(re.compile(r'<figure>.*?(?=<figure>|<end_of_file>)', re.DOTALL), text):
                    ipl_text = IPL_Fig.group(0)
                    #ipl_text = re.sub('<figure><title>', '', ipl_text, 1)
                    fig_num = re.search(r'<fignum>([^<]+)</fignum>', ipl_text)
                    if fig_num is not None:
                        fig_num = fig_num.group(1) 
                    elif last_section == "0":
                        fig_num = "1"
                    elif last_section[-1].isdigit():
                        fig_num = "{}A".format(last_section)
                    else:
                        fig_num = "{}{}".format(last_section[0:-1], chr(ord(last_section[-1] + 1)))
                    print("New IPL Figure Found: {}".format(fig_num))
                    last_section = fig_num
                    ipl_section_name = "IPL SECTION {}.txt".format(fig_num)
                    (path_name / ipl_section_name).write_text(ipl_text, encoding='utf-8')
                #list of files

                dmc_list = sorted(path_name.glob('IPL SEC*.txt'), key=lambda fname : int(re.search('\d+', fname.name).group(0)))
                #counter=0
                print("Formatting text")
                for dmc_file in dmc_list :
                    # f = open(dmc_file,  encoding='utf-8' )
                    # text = f.read()		
                    # f.close()
                    text = dmc_file.read_text(encoding='utf-8')
                    text=re.sub(ata_code, "", text)		
                    text=re.sub("-\nItem Not Illustrated ", "", text)	
                    text=re.sub("- ITEM NOT ILLUSTRATED", "", text)	
                    text=re.sub("-ITEMNOT ILLUSTRATED ", "", text)	
                    text=re.sub("-ITEMNOTILLUSTRATED ", "", text)	
                    text=re.sub("	", "  ", text)
                    text=re.sub("\)  \n\(", ") (", text)
                    text=re.sub("\) \n\(", ") (", text)
                    text=re.sub("\n\(", " (", text)
                    text=re.sub("\) -", ")\n-", text)
                    text=re.sub("-\n", "-", text)
                    text=re.sub("Y­", "Y-", text)
                    text=re.sub("A­", "A-", text)
                    text=re.sub("Â­", "-", text)
                    text=re.sub(date_value, "", text)
                    text=re.sub(date_value.replace(" ",""), "", text)
                    text=re.sub(ata_code, "", text)
                    text=re.sub("Blank Page", "", text)
                    text=re.sub("UP799634", "", text)
                    text=re.sub("­", "-", text)
                    text=re.sub("- ", "-", text)
                    text=re.sub("•", ".", text)
                    text=re.sub("\(PRE \nSB", "(PRE SB", text)
                    text=re.sub("\(SEEFIG\.", "(SEE FIG. ", text)
                    text=re.sub("\(SEE1", "(SEE FIG. 1 ", text)
                    text=re.sub("\(SEE2", "(SEE FIG. 2 ", text)
                    text=re.sub("FORNHA\) ", "FOR NHA) ", text)
                    text=re.sub("FORDETAILS\)", " FOR DETAILS) ", text)
                    text=re.sub("USEDONASSY", "USED ON ASSY", text)
                    text=re.sub("\n\n", "\n", text)
                    text=re.sub("--", "-", text)
                    text=re.sub("-	-", "-", text)
                    #counter += 1
                    split_dmc=text.splitlines()	
                    name = re.sub('IPL SECTION ', "Edited data", dmc_file.with_suffix('').name)
                    p_name = (path_name / name).with_suffix(".txt")
                    with p_name.open("w+", encoding='utf-8') as DMC:
                        for i in range(len(split_dmc)) :
                            #Remove unneeded data
                            split_dmc[i]=re.sub("\s+"," ", split_dmc[i])
                            split_dmc[i]=re.sub("• ",".", split_dmc[i])
                            split_dmc[i]=re.sub("\. ",".", split_dmc[i])
                            split_dmc[i]=split_dmc[i].replace("COMPONENT MAINTENANCE MANUAL", "")	
                            split_dmc[i]=split_dmc[i].replace("COMPONENTMAINTENANCEMANUAL ", "")	
                            split_dmc[i]=split_dmc[i].replace("EFFECTIVITY ", "")	
                            split_dmc[i]=split_dmc[i].replace("© Honeywell International Inc. Do not copy without express permission of Honeywell. ", "")
                            split_dmc[i]=re.sub(header_value, "", split_dmc[i])
                            split_dmc[i]=split_dmc[i].replace(". Honeywell International Inc. Do not copy without express permission of Honeywell. ", "")
                            split_dmc[i]=split_dmc[i].replace("Copying,use or disclosure of information on this page is subject to proprietary restrictions. ", "")	
                            split_dmc[i]=split_dmc[i].replace("© Honeywell International Inc. Do not copy without express permission of Honeywell.", "")
                            split_dmc[i]=split_dmc[i].replace(", ", ",")
                            split_dmc[i]=split_dmc[i].replace("--", "-")
                            split_dmc[i]=split_dmc[i].replace("..***.***", "")
                            split_dmc[i]=split_dmc[i].replace("---*---", "")
                            split_dmc[i]=split_dmc[i].replace("2041222 ", "")
                            split_dmc[i]=re.sub("\.{4,}", " ", split_dmc[i])

                            #Fix space issues 
                            split_dmc[i]=re.sub("CLAMP(\d)", "CLAMP \1", split_dmc[i])

                            #Remove page number
                            if Page_num1.match(split_dmc[i]):
                                split_dmc[i]=""
                            #Remove effectivity 
                            if "EFFECTIVITY ALL" in  split_dmc[i]:
                                split_dmc[i]=""
                            #Remove date
                            if date_value in split_dmc[i]:
                                split_dmc[i]=""	
                            #Merge - with item number
                            if split_dmc[i][0:2] == "- " :
                                split_dmc[i]=split_dmc[i].replace("- ", "-", 1)
                            #Remove R for revised
                            if split_dmc[i][0:2] == "R " :
                                split_dmc[i]=split_dmc[i].replace("R ", "", 1)
                            if "IPL Figure" in split_dmc[i] and i<10 :
                                dmc_space=split_dmc[i].split(" ") 
                                fig_num=dmc_space[2]						
                                dot_point=fig_num.find(".")
                                if dot_point>=1 :
                                    fig_num=fig_num[:dot_point]
                                fig_num=fig_num.replace(".", "")
                                fig_num=fig_num.replace("(Sheet", "")
                            if i+1 <len(split_dmc) :
                                if "Units" in split_dmc[i][0:5] and fig_num in  split_dmc[i+1][0:3]:
                                    split_dmc[i+1]=split_dmc[i+1].replace(fig_num , "", 1)
                                if split_dmc[i+1][0:1] == "(" :
                                    split_dmc[i+1]=split_dmc[i+1].replace(")  " , ")\n", 1)
                                    split_dmc[i+1]=split_dmc[i+1].replace(") " , ")\n", 1)
                                    split_dmc[i]= split_dmc[i]+split_dmc[i+1]
                                    split_dmc[i+1]=""

                            #Can't be moved before the if units statement to remove the extra figure number
                            if i > 2 :
                                if "Units" in split_dmc[i-1][0:5] and fig_num in  split_dmc[i][0:3]:
                                    if ("-"+fig_num) not in split_dmc[i] :
                                        split_dmc[i]=split_dmc[i].replace(fig_num , "", 1)			
                                elif "Item  Part" in split_dmc[i-1][0:11] and fig_num in  split_dmc[i][0:3]:
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                                elif "Item Part" in split_dmc[i-1][0:11] and fig_num in  split_dmc[i][0:3]:
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                                elif "FIG.ITEM" in split_dmc[i-1] and fig_num in  split_dmc[i][0:3] :
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                                elif "ITEM PART" in split_dmc[i-1] and fig_num in split_dmc[i][0:3] :
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                                elif "ITEM PARTNUMBER" in split_dmc[i-1] and fig_num in  split_dmc[i][0:3] :
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                                elif "FIG & ITEM" in split_dmc[i-1] and fig_num in  split_dmc[i][0:3] :
                                    split_dmc[i]=split_dmc[i].replace(fig_num, "", 1)	
                            if split_dmc[i]!="" and split_dmc[i]!=" " and split_dmc[i]!="\n":	
                                DMC.write(split_dmc[i]+" \n")

                    ####################################################
                    ###########Remove additional info
                    ##################################################
                    text = p_name.read_text(encoding='utf-8')
                    text=re.sub("\)\n\n", ")\n", text)
                    text=re.sub("\)\n\(", ") (", text)
                    text=re.sub("-\n", "-", text)
                    text=re.sub("  ", " ", text)
                    text=re.sub("  ", " ", text)
                    text=re.sub("\n\(", " (", text)
                    text=re.sub("Â", "", text)
                    text = re.sub(re.compile(r"^EFFECT.*?ASSY\s*\n(\d+\w?\n?)?", re.DOTALL|re.MULTILINE), "", text) #Remove IPL Header
                    text = text.replace("-ITEM NOT ILLUSTRATED", "") #Remove footer
                    text = re.sub(re.compile("^(?:ALL|R) ", re.MULTILINE), "", text)
                    split_dmc=text.splitlines()
                    with p_name.open("w+", encoding='utf-8') as DMC :
                        for i in range(len(split_dmc)) :		
                            if split_dmc[i] == "Units " :
                                split_dmc[i]="  "			
                            #Check to see if 2 items ended up on the same row 
                            num_entries=re.findall("\.[A-Z](.*?) ",  split_dmc[i])	
                            len_num_entries=len(num_entries)
                            if "TTACHING" in num_entries or "IAMETER" in num_entries  :
                                len_num_entries=len_num_entries-1
                            if len_num_entries >1 :
                                ipl_values=split_dmc[i].split(" ")
                                for a in range(len(ipl_values)) :					
                                    if num_entries[1] in ipl_values[a] :
                                        split_dmc[i]=split_dmc[i].replace(ipl_values[a-2],"\n"+ipl_values[a-2])

                            #Remove page number
                            if Page_num1.match(split_dmc[i]):
                                split_dmc[i]=""
                                
                            if i+2 <len(split_dmc) and "Units  " in split_dmc[i]:
                                split_dmc[i]=split_dmc[i].replace("Units  ", "")
                                split_dmc[i+1]=split_dmc[i+1].replace("Fig. Airline Eff Per ", "")
                                split_dmc[i+2]=split_dmc[i+2].replace("Item Part Number Stock No. 1234567 Nomenclature Code Assy ", "")				
                            if len(split_dmc[i])>2 : 
                                if split_dmc[i][0] == " " :
                                    split_dmc[i]=split_dmc[i][1:]

                            if split_dmc[i]!="" and split_dmc[i]!=" " and split_dmc[i]!="\n":	
                                DMC.write(split_dmc[i]+" \n")

                    text = p_name.read_text(encoding="utf-8")
                    text=re.sub("\n(\s?\n)+", "\n", text)
                    text=re.sub("\)\.", "\) \.", text)
                    text=text.replace("-*- ", " ")
                    text=text.replace("-*", " ")
                    with p_name.open("w+", encoding='utf-8') as DMC :
                        DMC.write(text)
                        
                    text = p_name.read_text(encoding="utf-8")
                    split_dmc=text.splitlines()
                    ################################
                    ##Treatment of txt to csv
                    #################################
                    #name="Unused data"+str(counter)
                    with p_name.open("w+", encoding='utf-8') as DMC :	
                        #name="Data_values"+str(counter)
                        #if counter >1 :
                        #	name1="Unused data"+str(counter-1)
                        with p_name.with_suffix(".csv").open("w+", encoding='utf-8') as data :				
                            data.write(First_row+"\n")
                            fig_data = re.search("<figure><title>([^<]+)</title><sheets>([^<]+)</sheets><fignum>([^<]+)</fignum></figure>", text)
                            if fig_data is None:
                                Second_row = '{},{},{},,,'.format(p_name.stem.split(' ')[-1], ata_code, cage_code)
                            else:	
                                Second_row = '{}, {}, {}, {}, {},'.format(fig_data.group(3), ata_code, cage_code, fig_data.group(1), fig_data.group(2))
                            data.write(Second_row+"\n")
                            data.write(data_name_row)
                            for i in range(len(split_dmc)) :																	
                                data_row=[","]*30
                                data_row[29]="\"1\",\n"	

                                ipl_values=split_dmc[i].split(" ")						
                                #If the first group has any digits
                                if any(char.isdigit() for char in ipl_values[0]) == True and Rds_format0.match(ipl_values[0]) == None and Rds_format5.match(ipl_values[0]) == None :
                                    ipl_values[0]=ipl_values[0].replace("Â", "")							
                                    if "-" in ipl_values[0] :
                                        data_row[0]="\"-\","
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(ipl_values[0], " ", 1)
                                        ipl_values[0]=ipl_values[0].replace("-", "", 1)
                                        data_row[1]="\""+ipl_values[0]+"\","	
                                    else :

                                        data_row[1]="\""+ipl_values[0]+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(ipl_values[0], " ", 1)						
                                    if len(ipl_values)>3 :
                                        data_row[2]="\""+ipl_values[1]+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(ipl_values[1], " ", 1)
                                        indent_num=0
                                        indent_num=ipl_values[2].count(".")		
                                        #Removed used text`
                                        split_dmc[i]=split_dmc[i].replace(ipl_values[2], " ", 1)
                                        ipl_values[2]=ipl_values[2].replace(".", "")
                                        if len(ipl_values)>=4 :
                                            if ipl_values[2] == "CIRCUIT" and ipl_values[3] == "CARD" :
                                                ipl_values[2]="CIRCUIT CARD"
                                                split_dmc[i]=split_dmc[i].replace(ipl_values[3], " ", 1)
                                        #Checks to see if name has a space 
                                        if any(char.isdigit() for char in ipl_values[3]) == False and len(ipl_values[3])>5 and "REPL" not in ipl_values[3] and ".ATTACHING" not in ipl_values[3] and "(ORDER" not in ipl_values[3] and "(ESDS" not in ipl_values[3]:							
                                            ipl_values[2]=ipl_values[2]+" "+ipl_values[3]
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(ipl_values[3], " ", 1)						
                                        data_row[5]="\""+ipl_values[2]+"\","	
                                        data_row[4]="\""+str(indent_num)+"\","	

                                    #Must use regular expressions for all the other sections
                                    #REPLACE USED sections with nothing to narrow down options 
                                    split_dmc[i]=re.sub("\s+"," ", split_dmc[i])
                                    #Find vendor code
                                    if vendor_format.match(split_dmc[i]) :
                                        vendor_codes= re.search("\(V\d\d\d\d\d\)", split_dmc[i])
                                        vendor_code=vendor_codes.group(0).replace("(V", "")
                                        vendor_code=vendor_code.replace(")", "")
                                        data_row[3]="\""+vendor_code+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(vendor_codes.group(0), "", 1)
                                    #Find 	CSD:
                                    if CSD_format.match(split_dmc[i]) or  CSD_format2.match(split_dmc[i]):
                                        csd_codes= re.search("\(CSD: (.*?)\)", split_dmc[i])
                                        csd_code=csd_codes.group(0).replace("(", "")
                                        csd_code=csd_code.replace(")", "")
                                        csd_code=csd_code.split(" ")
                                        if len(csd_code) == 3 :
                                            data_row[12]="\""+csd_code[1]+"\","	
                                            csd_code[2]=csd_code[2].replace("V", "", 1)
                                            data_row[13]="\""+csd_code[2]+"\","	
                                        if len(csd_code) == 2:
                                            csd_code=csd_code[1].split("-")
                                            data_row[12]="\""+csd_code[0]+"\","	
                                            csd_code[1]=csd_code[1].replace("V", "", 1)
                                            data_row[13]="\""+csd_code[1]+"\","									
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(csd_codes.group(0), "", 1)
                                    #Find EDS
                                    if "(ESDS)" in split_dmc[i] :
                                        data_row[9]="\"ESDS\","	
                                        split_dmc[i]=split_dmc[i].replace("(ESDS)", "", 1)

                                    #Find oPT pN
                                    if OPT_format1.match(split_dmc[i]) or OPT_format2.match(split_dmc[i]) or OPT_format3.match(split_dmc[i]):
                                        if OPT_format1.match(split_dmc[i]):
                                            OPT_codes= re.search("\(OPT PN:(.*?)\)", split_dmc[i])
                                            OPT_code=OPT_codes.group(0).replace("(", "")
                                            OPT_code=OPT_code.replace(")", "")
                                            OPT_code=OPT_code.split(" ")
                                            OPT_code[1]=OPT_code[1].replace("PN:", "", 1)
                                            data_row[14]="\""+OPT_code[1]+"\","	
                                            OPT_code[1]=OPT_code[1].replace("V", "", 1)
                                            data_row[15]="\""+OPT_code[2]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(OPT_codes.group(0), "", 1)
                                        if OPT_format2.match(split_dmc[i]):
                                            OPT_codes= re.search("\(OPT PN:(.*?)\)", split_dmc[i])
                                            OPT_code=OPT_codes.group(0).replace("(", "")
                                            OPT_code=OPT_code.replace(")", "")
                                            OPT_code=OPT_code.split(" ")
                                            OPT_code[1]=OPT_code[1].replace("PN:", "", 1)
                                            data_row[14]="\""+OPT_code[1]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(OPT_codes.group(0), "", 1)	
                                        if OPT_format3.match(split_dmc[i]):
                                            OPT_codes= re.search("\(OPT(.*?)\)", split_dmc[i])
                                            OPT_code=OPT_codes.group(0).replace("(", "")
                                            OPT_code=OPT_code.replace(")", "")
                                            OPT_code=OPT_code.split(" ")
                                            if "PN:" in OPT_code:
                                                OPT_code[1]=OPT_code[1].replace("PN:", "", 1)
                                                data_row[14]="\""+OPT_code[1]+"\","	
                                                #Removed used text
                                                split_dmc[i]=split_dmc[i].replace(OPT_codes.group(0), "", 1)
                                    #Find Replaced by 
                                    if REPLD_format1.match(split_dmc[i]) or REPLD_format2.match(split_dmc[i]):
                                        if REPLD_format1.match(split_dmc[i]):
                                            REPLD_codes= re.search("\(REPLACED BY(.*?)\)", split_dmc[i])
                                            REPLD_code=REPLD_codes.group(0)
                                            REPLD_code=REPLD_code.split(" ")
                                            REPLD_code[3]=REPLD_code[3].replace(")", "")
                                            data_row[16]="\""+REPLD_code[3]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(REPLD_codes.group(0), "", 1)
                                        if REPLD_format2.match(split_dmc[i]):
                                            REPLD_codes= re.search("\(REPL BY(.*?)\)", split_dmc[i])
                                            REPLD_code=REPLD_codes.group(0)
                                            if "EFF CODE)" in REPLD_code:
                                                data_row[27]="\""+REPLD_code+"\","	

                                            else :
                                                REPLD_code=REPLD_code.split(" ")
                                                REPLD_code[3]=REPLD_code[3].replace(")", "")
                                                data_row[16]="\""+REPLD_code[3]+"\","	
                                                #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(REPLD_codes.group(0), "", 1)	

                                    #Find Replaces 
                                    if REPLs_format.match(split_dmc[i]) :
                                        REPLS_codes= re.search("\(REPLACES ITEM(.*?)\)", split_dmc[i])
                                        REPLS_code=REPLS_codes.group(0)
                                        REPLS_code=REPLS_code.split(" ")
                                        REPLS_code[2]=REPLS_code[2].replace(")", "")
                                        data_row[17]="\""+REPLS_code[2]+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(REPLS_codes.group(0), "", 1)
                                    #Find see fig 
                                    if "(SEE FIG" in split_dmc[i] or "(FOR DETAILS SEE FIG" in split_dmc[i]:
                                        if "DETAILS)" in split_dmc[i] :
                                            Detail_codes= re.search("\(SEE FIG(.*?)FOR DETAILS\)", split_dmc[i])
                                            Detail_code=Detail_codes.group(0)		
                                            Detail_code=Detail_code.split(" ")
                                            if Detail_code[2] == "FOR" :
                                                Detail_code[2]=Detail_code[1].replace("FIG.", "")
                                            data_row[24]="\""+Detail_code[2]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(Detail_codes.group(0), "", 1)	
                                        if "(FOR DETAILS SEE FIG" in split_dmc[i]:
                                            Detail_codes= re.search("\(FOR DETAILS SEE FIG(.*?)\)", split_dmc[i])
                                            Detail_code=Detail_codes.group(0)		
                                            Detail_code=Detail_code.split(" ")
                                            data_row[24]="\""+Detail_code[4]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(Detail_codes.group(0), "", 1)	
                                        if "FOR BKDN)" in split_dmc[i] :
                                            Detail_codes= re.search("\(SEE FIG(.*?)FOR BKDN\)", split_dmc[i])
                                            Detail_code=Detail_codes.group(0)		
                                            Detail_code=Detail_code.split(" ")
                                            if Detail_code[2] == "FOR" :
                                                Detail_code[2]=Detail_code[1].replace("FIG.", "")
                                            data_row[26]="\""+Detail_code[2]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(Detail_codes.group(0), "", 1)	
                                        if "FOR FURTHER BKDN)" in split_dmc[i] :
                                            Detail_codes= re.search("\(SEE FIG(.*?)FOR FURTHER BKDN\)", split_dmc[i])
                                            Detail_code=Detail_codes.group(0)		
                                            Detail_code=Detail_code.split(" ")
                                            if Detail_code[2] == "FOR" :
                                                Detail_code[2]=Detail_code[1].replace("FIG.", "")
                                            data_row[26]="\""+Detail_code[2]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(Detail_codes.group(0), "", 1)	
                                        if "FOR NHA)"  in split_dmc[i] :
                                            Detail_codes= re.search("\(SEE FIG(.*?)FOR NHA\)", split_dmc[i])
                                            Detail_code=Detail_codes.group(0)		
                                            Detail_code=Detail_code.split(" ")
                                            if Detail_code[2] == "FOR" :
                                                Detail_code[2]=Detail_code[1].replace("FIG.", "")
                                            data_row[23]="\""+Detail_code[2]+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(Detail_codes.group(0), "", 1)	

                                    #Find opder pn 
                                    if Ord_format.match(split_dmc[i]) :
                                        ord_codes= re.search("\(ORDER PN(.*?)\)", split_dmc[i])
                                        ord_code=ord_codes.group(0)
                                        data_row[27]="\""+ord_code+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(ord_codes.group(0), "", 1)
                                    #Find dimensions option 1
                                    if "CRES " in split_dmc[i] :
                                        if "FLH CRES " in split_dmc[i] :
                                            flh_codes= re.search("FLH CRES \d-\d\dX\d-\d", split_dmc[i])
                                            flh_code=flh_codes.group(0)	
                                            data_row[7]="\""+flh_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(flh_codes.group(0), "", 1)		
                                        if "PNH CRES " in split_dmc[i] :
                                            pnh_codes= re.search("PNH CRES \d-\d+X\d-\d+", split_dmc[i])
                                            pnh_code=pnh_codes.group(0)	
                                            data_row[7]="\""+pnh_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(pnh_codes.group(0), "", 1)	
                                        if "CSKH CRES" in split_dmc[i]  :
                                            pnh_codes= re.search("CSKH CRES \d+-\d+X\d+-\d+", split_dmc[i])
                                            pnh_code=pnh_codes.group(0)	
                                            data_row[7]="\""+pnh_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(pnh_codes.group(0), "", 1)	
                                        if "CRES " in split_dmc[i] and "ID" in split_dmc[i] :
                                            pnh_codes= re.search("CRES \d+\.\d+ ID", split_dmc[i])
                                            pnh_code=pnh_codes.group(0)	
                                            data_row[7]="\""+pnh_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(pnh_codes.group(0), "", 1)									
                                        if "CRES " in split_dmc[i] :
                                            pnh_codes= re.search("CRES \d+-\d+X\d+-\d+", split_dmc[i])
                                            pnh_code=pnh_codes.group(0)	
                                            data_row[7]="\""+pnh_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(pnh_codes.group(0), "", 1)							
                                    #Find dimension option 2 
                                    if dimension1.match(split_dmc[i]) :
                                        dim_codes= re.search("\(\d\.\d UF(.*?)V\)", split_dmc[i])
                                        dim_code=dim_codes.group(0)	
                                        if "\n" in data_row[7] :
                                            data_row[7]=data_row[7].replace ("\n",dim_code+"\n")
                                        else :	
                                            data_row[7]="\""+dim_code+"\","		
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(dim_codes.group(0), "", 1)
                                    if dimension2.match(split_dmc[i]) :
                                        dim_codes= re.search("\(\d+ OHMS(.*?)W\)", split_dmc[i])
                                        dim_code=dim_codes.group(0)	
                                        if "\n" in data_row[7] :
                                            data_row[7]=data_row[7].replace ("\n",dim_code+"\n")
                                        else :	
                                            data_row[7]="\""+dim_code+"\","		
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(dim_codes.group(0), "", 1)
                                    #THK measurement 
                                    if dimension3.match(split_dmc[i]) :
                                        dim_codes= re.search("\(\d\.\d+ IN. THK\)", split_dmc[i])
                                        dim_code=dim_codes.group(0)	

                                        data_row[7]="\""+dim_code+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(dim_codes.group(0), "", 1)

                                    #fIND LEFTOVER nomenclature
                                    if "CUP PT" in 	split_dmc[i]:
                                        cup_codes= re.search("CUP PT STL \d-\d+X\d-\d+", split_dmc[i])	
                                        cup_code=cup_codes.group(0)	
                                        data_row[5]=data_row[5][0:-2]+" "+cup_code+"\","	
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(cup_codes.group(0), "", 1)	
                                    #Find pre sb 
                                    if PRE_SB_format1.match(split_dmc[i]) or PRE_SB_format2.match(split_dmc[i]) :
                                        if PRE_SB_format1.match(split_dmc[i]):
                                            PRE_codes= re.search("\(PRE SB(.*?)\)", split_dmc[i])
                                            PRE_code=PRE_codes.group(0)
                                            PRE_code=PRE_code.replace("(PRE SB", "")
                                            PRE_code=PRE_code.replace(")", "")
                                            data_row[20]="\""+PRE_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(PRE_codes.group(0), "", 1)	
                                        if PRE_SB_format2.match(split_dmc[i]) :
                                            PRE_codes= re.search("\(PRE SPB(.*?)\)", split_dmc[i])
                                            PRE_code=PRE_codes.group(0)
                                            PRE_code=PRE_code.replace("(PRE SPB", "")
                                            PRE_code=PRE_code.replace(")", "")
                                            data_row[20]="\""+PRE_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(PRE_codes.group(0), "", 1)	
                                    #Find POST SB 
                                    if POST_SB_format1.match(split_dmc[i]) or POST_SB_format2.match(split_dmc[i]) :
                                        if POST_SB_format1.match(split_dmc[i]):
                                            post_codes= re.search("\(POST SB(.*?)\)", split_dmc[i])
                                            post_code=post_codes.group(0)
                                            post_code=post_code.replace("(POST SB", "")
                                            post_code=post_code.replace(")", "")
                                            data_row[21]="\""+post_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(post_codes.group(0), "", 1)	
                                        if POST_SB_format2.match(split_dmc[i]) :
                                            post_codes= re.search("\(POST SPB(.*?)\)", split_dmc[i])
                                            post_code=post_codes.group(0)
                                            post_code=post_code.replace("(POST SPB", "")
                                            post_code=post_code.replace(")", "")
                                            data_row[21]="\""+post_code+"\","
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(post_codes.group(0), "", 1)						
                                    #Find use with items 
                                    if "(USE WITH ITEM" in split_dmc[i] and ")" in split_dmc[i]: 
                                        post_codes= re.search("\(USE WITH ITEM(.*?)\)", split_dmc[i])
                                        post_code=post_codes.group(0)
                                        post_code=post_code.replace("(USE WITH ITEM", "")
                                        post_code=post_code.replace(")", "")
                                        data_row[22]="\""+post_code+"\","
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace(post_codes.group(0), "", 1)	

                                    #Find rds 
                                    if Rds_format1.match(split_dmc[i]) or Rds_format2.match(split_dmc[i]) or Rds_format5.match(split_dmc[i]):
                                        if Rds_format1.match(split_dmc[i]):
                                            rds_codes= re.search(" ([A-Z]\d+,)+[A-Z]\d+", split_dmc[i])
                                            rds_code=rds_codes.group(0)
                                            data_row[10]="\""+rds_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(rds_codes.group(0), "", 1)	
                                        if Rds_format2.match(split_dmc[i]) :
                                            rds_codes= re.search(" [A-Z]\d{1,3} ", split_dmc[i])
                                            rds_code=rds_codes.group(0)
                                            data_row[10]="\""+rds_code+"\","
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(rds_codes.group(0), "", 1)	
                                        if Rds_format5.match(split_dmc[i]) :
                                            rds_codes= re.search("[A-Z]\d+ ", split_dmc[i])
                                            rds_code=rds_codes.group(0)
                                            data_row[10]="\""+rds_code+"\","
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(rds_codes.group(0), "", 1)
                                    #Find rds in brackets 
                                    if Rds_format3.match(split_dmc[i]) or Rds_format4.match(split_dmc[i]) :
                                        if Rds_format3.match(split_dmc[i]) :
                                            rds_codes= re.search("([A-Z]\d+)", split_dmc[i])
                                            rds_code=rds_codes.group(0)
                                            rds_code=rds_code.replace("(", "")
                                            rds_code=rds_code.replace(")", "")
                                            data_row[10]="\""+rds_code+"\","
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(rds_codes.group(0), "", 1)							
                                        if Rds_format4.match(split_dmc[i]):
                                            rds_codes= re.search(" \(([A-Z]\d+,)+[A-Z]\d+\)", split_dmc[i])
                                            rds_code=rds_codes.group(0)
                                            rds_code=rds_code.replace("(", "")
                                            rds_code=rds_code.replace(")", "")
                                            data_row[10]="\""+rds_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(rds_codes.group(0), "", 1)	

                                    #Fix errors causes by upa being stuck on comma
                                    split_dmc[i]=re.sub(",(\d) ", r", \1 ", split_dmc[i]) 
                                    #Find upa 
                                    if UPA_format.match(split_dmc[i]) or "RF " in  split_dmc[i] or "AR " in  split_dmc[i]:
                                        UPA_codes= re.search(" \d+ ", split_dmc[i])
                                        if UPA_codes == None  and "RF" in  split_dmc[i] :
                                            data_row[29]="\"RF\",\n"	
                                            split_dmc[i]=split_dmc[i].replace("RF ", "", 1)	
                                        elif UPA_codes == None  and "AR " in  split_dmc[i] :
                                            data_row[29]="\"AR\",\n"	
                                            split_dmc[i]=split_dmc[i].replace("AR ", "", 1)	
                                        else :
                                            UPA_code=UPA_codes.group(0)
                                            UPA_code=UPA_code.replace(" ", "")
                                            data_row[29]="\""+UPA_code+"\",\n"	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(UPA_codes.group(0), " ", 1)	
                                    #Find Eff Codes 
                                    if EFF_format1.match(split_dmc[i]) or EFF_format2.match(split_dmc[i]) or EFF_format3.match(split_dmc[i]) or  EFF_format4.match(split_dmc[i]):
                                        if EFF_format1.match(split_dmc[i]):
                                            EFF_codes= re.search(" [A-Z] ", split_dmc[i])
                                            EFF_code=EFF_codes.group(0)
                                            data_row[28]="\""+EFF_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), "", 1)	
                                        if EFF_format2.match(split_dmc[i]) :
                                            EFF_codes= re.search(" ([A-Z],)+[A-Z]", split_dmc[i])
                                            EFF_code=EFF_codes.group(0)
                                            data_row[28]="\""+EFF_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), "", 1)	
                                        if EFF_format3.match(split_dmc[i]) :
                                            EFF_codes= re.search(" [A-Z]\n", split_dmc[i])
                                            EFF_code=EFF_codes.group(0)
                                            EFF_code=EFF_code[0:-2]
                                            data_row[28]="\""+EFF_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), "", 1)	
                                        if EFF_format4.match(split_dmc[i]) :
                                            EFF_codes= re.search(" [A-Z]-[A-Z] ", split_dmc[i])
                                            EFF_code=EFF_codes.group(0)
                                            data_row[28]="\""+EFF_code+"\","	
                                            #Removed used text
                                            split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), " ", 1)	
                                    #Attached parts 
                                    if "..ATTACHING PARTS" in  split_dmc[i]:
                                        data_row[8]="\"Y\","
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace("..ATTACHING PARTS", "", 1)
                                    elif "(ATTACHING PARTS)" in  split_dmc[i]:
                                        data_row[8]="\"Y\","
                                        #Removed used text
                                        split_dmc[i]=split_dmc[i].replace("(ATTACHING PARTS)", "", 1)	

                                    #Missed extra nomenclature
                                    if "FRONT" in  split_dmc[i] or "REAR" in  split_dmc[i] or  "BLOCK" in  split_dmc[i] :
                                        if "FRONT" in  split_dmc[i] :
                                            data_row[6]="\"FRONT\","	
                                            split_dmc[i]=split_dmc[i].replace("FRONT", "", 1)
                                        if "REAR" in  split_dmc[i] :
                                            data_row[6]="\"REAR\","		
                                            split_dmc[i]=split_dmc[i].replace("REAR", "", 1)
                                        if "BLOCK" in  split_dmc[i] :
                                            data_row[6]="\"BLOCK\","		
                                            split_dmc[i]=split_dmc[i].replace("BLOCK", "", 1)	
                                    #Nonprocurable 
                                    if "(NONPROCURABLE)" in  split_dmc[i] :
                                        data_row[27]="\"(NONPROCURABLE)\n\","
                                        split_dmc[i]=split_dmc[i].replace("(NONPROCURABLE)", " ", 1)
                                    #Order NHA	
                                    if "(ORDER NHA)" in  split_dmc[i] :
                                        if "\n" in data_row[27] :
                                            data_row[27]=data_row[27].replace("\n","\n(ORDER NHA)\n", 1)
                                        else:
                                            data_row[27]="\"(ORDER NHA)\","
                                        split_dmc[i]=split_dmc[i].replace("(ORDER NHA)", "", 1)	
                                    # #Place leftover text in msc
                                    split_dmc[i]=re.sub("\s+"," ", split_dmc[i])
                                    split_dmc[i]=re.sub("\(\)"," ", split_dmc[i])
                                    if split_dmc[i]!="" and split_dmc[i]!=" " :
                                        if "\n" in data_row[27] :
                                            data_row[27]=data_row[27].replace("\n","\n"+split_dmc[i]+"\n",1)
                                        else:
                                            data_row[27]="\""+split_dmc[i]+"\","
                                        #Removed used text
                                        split_dmc[i]=""	

                                    #############Check next line ###############################
                                    #For items that are split over 2 lines
                                    if i+1 <len(split_dmc):
                                        if any(char.isdigit() for char in split_dmc[i+1][0:5]) == False :
                                            ipl_values_next=split_dmc[i+1].split(" ")

                                            if "CSKH" not in ipl_values_next[0] and "CRES" not in ipl_values_next[0] and  "PNH" not in ipl_values_next[0] and  "FLH" not in ipl_values_next[0]:
                                                #Removed used text
                                                split_dmc[i+1]=split_dmc[i+1].replace(ipl_values_next[0], "", 1)	
                                                if len(ipl_values_next) >=2 :									

                                                    #Missed words that should be in extra nomenclature
                                                    if "GRAY" in ipl_values_next[1] or "BLACK" in ipl_values_next[1]:
                                                        ipl_values_next[0]=ipl_values_next[0]+" "+ipl_values_next[1]
                                                        split_dmc[i+1]=split_dmc[i+1].replace(ipl_values_next[1], "", 1)			
                                                data_row[6]="\""+str(ipl_values_next[0])+"\","															
                                            if vendor_format.match(split_dmc[i+1]) :
                                                vendor_codes= re.search("\(V\d\d\d\d\d\)", split_dmc[i+1])
                                                vendor_code=vendor_codes.group(0).replace("(V", "")
                                                vendor_code=vendor_code.replace(")", "")
                                                data_row[3]="\""+vendor_code+"\","	
                                                #Removed used text
                                                split_dmc[i+1]=split_dmc[i+1].replace(vendor_codes.group(0), "", 1)

                                            #Find 	CSD:

                                            if CSD_format.match(split_dmc[i+1]) or  CSD_format2.match(split_dmc[i+1]):
                                                csd_codes= re.search("\(CSD: (.*?)\)", split_dmc[i+1])
                                                csd_code=csd_codes.group(0).replace("(", "")
                                                csd_code=csd_code.replace(")", "")
                                                csd_code=csd_code.split(" ")
                                                if len(csd_code) == 3 :
                                                    data_row[12]="\""+csd_code[1]+"\","	
                                                    csd_code[2]=csd_code[2].replace("V", "", 1)
                                                    data_row[13]="\""+csd_code[2]+"\","	
                                                if len(csd_code) == 2:
                                                    csd_code=csd_code[1].split("-")
                                                    data_row[12]="\""+csd_code[0]+"\","	
                                                    csd_code[1]=csd_code[1].replace("V", "", 1)
                                                    data_row[13]="\""+csd_code[1]+"\","	
                                                #Removed used text
                                                split_dmc[i]=split_dmc[i].replace(csd_codes.group(0), " ", 1)
                                            #Find oPT pN
                                            if OPT_format1.match(split_dmc[i+1]) or OPT_format2.match(split_dmc[i+1]):
                                                if OPT_format1.match(split_dmc[i+1]):
                                                    OPT_codes= re.search("\(OPT PN:(.*?)\)", split_dmc[i+1])
                                                    OPT_code=OPT_codes.group(0).replace("(", "")
                                                    OPT_code=OPT_code.replace(")", "")
                                                    OPT_code=OPT_code.split(" ")
                                                    OPT_code[1]=OPT_code[1].replace("PN:", "", 1)
                                                    data_row[14]="\""+OPT_code[1]+"\","	
                                                    OPT_code[1]=OPT_code[1].replace("V", "", 1)
                                                    data_row[15]="\""+OPT_code[2]+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(OPT_codes.group(0), "", 1)
                                                if OPT_format2.match(split_dmc[i+1]):
                                                    OPT_codes= re.search("\(OPT PN:(.*?)\)", split_dmc[i+1])
                                                    OPT_code=OPT_codes.group(0).replace("(", "")
                                                    OPT_code=OPT_code.replace(")", "")
                                                    OPT_code=OPT_code.split(" ")
                                                    OPT_code[1]=OPT_code[1].replace("PN:", "", 1)
                                                    data_row[14]="\""+OPT_code[1]+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(OPT_codes.group(0), " ", 1)	
                                            #Find Replaced by 
                                            if REPLD_format1.match(split_dmc[i+1]) or REPLD_format2.match(split_dmc[i+1]):
                                                if REPLD_format1.match(split_dmc[i+1]):
                                                    REPLD_codes= re.search("\(REPLACED BY(.*?)\)", split_dmc[i+1])
                                                    REPLD_code=REPLD_codes.group(0)
                                                    REPLD_code=REPLD_code.split(" ")
                                                    REPLD_code[3]=REPLD_code[3].replace(")", "")
                                                    data_row[16]="\""+REPLD_code[3]+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(REPLD_codes.group(0), "", 1)
                                                if REPLD_format2.match(split_dmc[i+1]):
                                                    REPLD_codes= re.search("\(REPL BY(.*?)\)", split_dmc[i+1])
                                                    REPLD_code=REPLD_codes.group(0)
                                                    if "EFF CODE)" in REPLD_code:
                                                        data_row[27]="\""+REPLD_code+"\","													
                                                    else :
                                                        REPLD_code=REPLD_code.split(" ")
                                                        REPLD_code[3]=REPLD_code[3].replace(")", " ")
                                                        data_row[16]="\""+REPLD_code[3]+"\","	
                                                        #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(REPLD_codes.group(0), "", 1)	
                                            #Find Replaces 
                                            if REPLs_format.match(split_dmc[i+1]) :
                                                REPLS_codes= re.search("\(REPLACES ITEM(.*?)\)", split_dmc[i+1])
                                                REPLS_code=REPLS_codes.group(0)
                                                REPLS_code=REPLS_code.split(" ")
                                                REPLS_code[2]=REPLS_code[2].replace(")", "")
                                                data_row[17]="\""+REPLS_code[2]+"\","	
                                                #Removed used text
                                                split_dmc[i+1]=split_dmc[i+1].replace(REPLS_codes.group(0), "", 1)			
                                            #Find opder pn 
                                            if Ord_format.match(split_dmc[i+1]) :
                                                ord_codes= re.search("\(ORDER PN(.*?)\)", split_dmc[i+1])
                                                ord_code=ord_codes.group(0)
                                                data_row[27]="\""+ord_code+"\","	
                                                #Removed used text
                                                split_dmc[i+1]=split_dmc[i+1].replace(ord_codes.group(0), "", 1)		
                                            #Find dimensions 
                                            if "CRES " in split_dmc[i+1] :
                                                if "FLH CRES " in split_dmc[i+1] :
                                                    flh_codes= re.search("FLH CRES \d-\d\dX\d-\d", split_dmc[i+1])
                                                    flh_code=flh_codes.group(0)	
                                                    data_row[7]="\""+flh_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(flh_codes.group(0), "", 1)		
                                                if "PNH CRES " in split_dmc[i+1] :
                                                    pnh_codes= re.search("PNH CRES \d-\d+X\d-\d+", split_dmc[i+1])
                                                    pnh_code=pnh_codes.group(0)	
                                                    data_row[7]="\""+pnh_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(pnh_codes.group(0), "", 1)	
                                                if "CSKH CRES" in split_dmc[i+1] :
                                                    pnh_codes= re.search("CSKH CRES \d+-\d+X\d+-\d+", split_dmc[i+1])
                                                    pnh_code=pnh_codes.group(0)	
                                                    data_row[7]="\""+pnh_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(pnh_codes.group(0), "", 1)	
                                                if "CRES " in split_dmc[i+1] and "ID" in split_dmc[i+1] :
                                                    pnh_codes= re.search("CRES \d+\.\d+ ID", split_dmc[i+1])
                                                    pnh_code=pnh_codes.group(0)	
                                                    data_row[7]="\""+pnh_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i+1]=split_dmc[i+1].replace(pnh_codes.group(0), "", 1)									
                                                if "CRES " in split_dmc[i+1] :
                                                    pnh_codes= re.search("CRES \d+-\d+X\d+-\d+", split_dmc[i+1])
                                                    if pnh_codes!= None:
                                                        pnh_code=pnh_codes.group(0)	
                                                        data_row[7]="\""+pnh_code+"\","	
                                                        #Removed used text
                                                        split_dmc[i+1]=split_dmc[i+1].replace(pnh_codes.group(0), "", 1)			

                                            #Find Eff Codes 
                                            if EFF_format1.match(split_dmc[i]) or EFF_format2.match(split_dmc[i]) or EFF_format3.match(split_dmc[i]):
                                                if EFF_format1.match(split_dmc[i]):
                                                    EFF_codes= re.search(" [A-Z] ", split_dmc[i])
                                                    EFF_code=EFF_codes.group(0)
                                                    data_row[28]="\""+EFF_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), "", 1)	
                                                if EFF_format2.match(split_dmc[i]) :
                                                    EFF_codes= re.search(" ([A-Z],)+[A-Z]", split_dmc[i])
                                                    EFF_code=EFF_codes.group(0)
                                                    data_row[28]="\""+EFF_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), "", 1)	
                                                if EFF_format3.match(split_dmc[i]) :
                                                    EFF_codes= re.search(" [A-Z]\n", split_dmc[i])
                                                    EFF_code=EFF_codes.group(0)
                                                    EFF_code=EFF_code[0:-2]
                                                    data_row[28]="\""+EFF_code+"\","	
                                                    #Removed used text
                                                    split_dmc[i]=split_dmc[i].replace(EFF_codes.group(0), " ", 1)	
                                                # #Place leftover text in msc
                                                split_dmc[i+1]=re.sub("\s+"," ", split_dmc[i+1])
                                                split_dmc[i+1]=re.sub("\(\)"," ", split_dmc[i+1])
                                                if split_dmc[i+1]!="" and split_dmc[i+1]!=" " :
                                                    if "\n" in data_row[27] :
                                                        data_row[27]=data_row[27].replace("\n","\n"+split_dmc[i+1]+"\n",1)
                                                    else:
                                                        data_row[27]="\""+split_dmc[i+1]+"\","
                                                    #Removed used text
                                                    split_dmc[i+1]=""			
                                        #Find rds 
                                        # if Rds_format1.match(split_dmc[i+1]) or Rds_format2.match(split_dmc[i+1]) or Rds_format0.match(split_dmc[i+1])or Rds_format5.match(split_dmc[i+1]) :								
                                        #     group1= split_dmc[i+1].split(" ")
                                        #     if any(char.isalpha()  for char in group1[0]) == True :
                                        #         if Rds_format0.match(split_dmc[i+1]):
                                        #             rds_codes= re.search(r"([A-Z]\d+,)+[A-Z]\d+ ", split_dmc[i+1])
                                        #             rds_code=rds_codes.group(0)
                                        #             data_row[10]="\""+rds_code+"\","	
                                        #             #Removed used text
                                        #             split_dmc[i+1]=split_dmc[i+1].replace(rds_codes.group(0), "", 1)	
                                        #         if Rds_format1.match(split_dmc[i+1]):
                                        #             rds_codes= re.search(r" ([A-Z]\d,)+[A-Z]\d", split_dmc[i+1])
                                        #             rds_code=rds_codes.group(0)
                                        #             data_row[10]="\""+rds_code+"\","	
                                        #             #Removed used text
                                        #             split_dmc[i+1]=split_dmc[i+1].replace(rds_codes.group(0), "", 1)	
                                        #         if Rds_format2.match(split_dmc[i+1]) :
                                        #             rds_codes= re.search(r" [A-Z]\d{1,3} ", split_dmc[i+1])
                                        #             rds_code=rds_codes.group(0)
                                        #             data_row[10]="\""+rds_code+"\","
                                        #             #Removed used text
                                        #             split_dmc[i+1]=split_dmc[i+1].replace(rds_codes.group(0), "", 1)				
                                        #         if Rds_format5.match(split_dmc[i+1]) :
                                        #             rds_codes= re.search(r"[A-Z]\d+ ", split_dmc[i+1])
                                        #             rds_code=rds_codes.group(0)
                                        #             data_row[10]="\""+rds_code+"\","
                                        #             #Removed used text
                                        #             split_dmc[i+1]=split_dmc[i+1].replace(rds_codes.group(0), "", 1)
                                        rds = Rds_format0.match(split_dmc[i+1])
                                        if rds is not None:
                                            rds_code = rds.group(0)
                                            split_dmc[i+1]=split_dmc[i+1].replace(rds_code, "", 1)

                                    for c in range(len(data_row)):
                                        data_row[c]=data_row[c].replace("±", "&plusmn;")
                                        data_row[c]=data_row[c].replace("VALVESUBASSEMBLY", "VALVE SUBASSEMBLY")
                                        data_row[c]=data_row[c].replace("VALVEASSY", "VALVE ASSY")
                                        data_row[c]=data_row[c].replace("SERVOSUBASSEMBLY", "SERVO SUBASSEMBLY")
                                        data_row[c]=data_row[c].replace("SWITCHSUBASSEMBLY", "SWITCH SUBASSEMBLY")
                                        data_row[c]=data_row[c].replace("ACTUATORSUBASSEMBLY", "ACTUATOR SUBASSEMBLY")
                                        data.write(data_row[c])
                                DMC.write(split_dmc[i]+"\n")

                print("Data files complete. Proceed to Data module creation")		

            except Exception as e:
                log_print(traceback.format_exc(), True)
                errors = True
            
            if cc is None:	#We only want to get this input with non-Launchpad runs, since Launchpad users can't check the files
                get_input("Please verify excel sheet(s) before continuing. \nTo continue press Enter ")

            #TO DO: Add logic to parse through the excel sheets and remove bad entries
            #TO DO: Update IPL Creator Code

            print("Generating 941 files")
            ###########################################  Part 2   ############################################################
            disassy = 0 

            def add_brackets(item):
                if len(item) == 0:
                    return ""

                if item[0] != '(' or item[-1] != ')':
                    item = '(' + item + ')'

                return item.replace('\n', ' ')


            duplicate_items = []

            def check_match(match):
                if match is not None:
                    return(match.group(1))
                else:
                    return("")

            def GenerateReferTos(reftype, fig, figvar):	
                nonlocal ata_code
                refer_string = """\n<referTo refType="rft%s"><catalogSeqNumberRef assyCode="%s"
            figureNumber="%s" %sitem="001" subSubSystemCode="%s" subSystemCode="%s"
            systemCode="%s"></catalogSeqNumberRef></referTo>""" % (reftype, ata_code[6:], "0" * (2 - len(fig)) + fig, "figureNumberVariant=\"%s\" " % figvar if figvar != "" else "", ata_code[4], ata_code[3], ata_code[0:2])
                return refer_string

            logText = ""

            ###To find non ascii characers search [^\x00-\x7F]+

            #Get the path for this script
            dmc_list = sorted(path_name.glob('Edited*.csv'), key=lambda fname : int(re.search('\d+', fname.name).group(0)))
            
            for file in dmc_list:
                try:
                    figtext = ""		
                    with file.open("rt", encoding='utf-8') as f:
                        reader = csv.reader(f)
                        print(file)
                        for line_num, line in enumerate(reader):
                            
                            try:
                                if(len(line) <= 2):
                                    continue
                                else:
                                    #line_num = int(i / 2) + 1
                                    if line_num == 1:
                                        fignbr = re.split(r"\.",line[0])[0]
                                        figvar = "figureNumberVariant=\"%s\" " % fignbr[-1] if fignbr[-1].isalpha() else ""
                                        if figvar != "":
                                            fignbr = fignbr[0:-1]
                                        fignbr = "0" * (2 - len(fignbr)) + fignbr
                                        fig_title = line[3]
                                        fig_sheets = int(line[4])
                                        ata = ata_code
                                        #cage_code = re.split(r"\.",line[2])[0]
                                        syscode = ata[0:2]
                                        subsys = ata[3]
                                        subsubsys = ata[4]
                                        assy = ata[6:]
                                        disassy += 1
                                        module_name = 'DMC-HON%s-EAA-%s-%s%s-%s-%sA-941A-C.xml' % (cage_code, syscode, subsys, subsubsys, assy, "0" * (2 - len(str(disassy))) + str(disassy))
                                        # while isfile(join(path_name, module_name)):
                                            # disassy += 1
                                            # module_name = 'DMC-HON%s-EAA-%s-%s%s-%s-%sA-941A-C.xml' % (cage_code, syscode, subsys, subsubsys, assy, "0" * (2 - len(str(disassy))) + str(disassy))
                                        #Header data
                                        ###Header should include entits notation 
                                        figtext += """<?xml version="1.0" encoding="UTF-8"?>
<!--Arbortext, Inc., 1988-2014, v.4002-->
<!DOCTYPE dmodule [
<!NOTATION cgm SYSTEM "cgm">
]>
<?Pub Inc?>
<dmodule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/ipd.xsd">
<?MENTORPATH ?>
<identAndStatusSection>
<dmAddress>
<dmIdent>
<dmCode assyCode="%s" disassyCode="%s%s" disassyCodeVariant="A" infoCode="941" infoCodeVariant="A" itemLocationCode="C" modelIdentCode="HON%s" subSubSystemCode="%s" subSystemCode="%s" systemCode="%s" systemDiffCode="EAA"/>
<language countryIsoCode="US" languageIsoCode="sx"/>
<issueInfo inWork="00" issueNumber="001"/></dmIdent>
<dmAddressItems>
<issueDate day="30" month="06" year="2019"/>
<dmTitle><techName></techName>
<infoName></infoName>
</dmTitle>
</dmAddressItems></dmAddress>
<dmStatus issueType="new">
<security securityClassification="01"/>
<responsiblePartnerCompany enterpriseCode="%s">
</responsiblePartnerCompany>
<originator enterpriseCode="%s"></originator>
<applic>
<displayText>
<simplePara>ALL</simplePara>
</displayText>
</applic>
<brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00"
disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A"
itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0"
subSystemCode="0" systemCode="00" systemDiffCode="AAA"/></dmRefIdent>
</dmRef></brexDmRef>
<qualityAssurance>
<unverified/></qualityAssurance>
</dmStatus>
</identAndStatusSection>
<content>
<illustratedPartsCatalog>
<figure>
<title>%s</title>
%s
</figure>""" % (assy, "0" if disassy < 10 else "", disassy, cage_code, subsubsys, subsys, syscode, cage_code, cage_code, fig_title, '<graphic infoEntityIdent="Original"></graphic>' * fig_sheets)
                                    elif line_num >= 4:
                                        revbar = not_illustrated = item = itemvar = part_number = indent = part_keyword = short_name = attach = refs = eff = quantity = ""
                                        gpd = []
                                        refs = []
                                        mfr = cage_code
                                        for n,l in enumerate(line):
                                            n += 1
                                            try:
                                                if l == "":
                                                    continue

                                                if n == 1:
                                                    not_illustrated = "\n<notIllustrated></notIllustrated>"
                                                    continue
                                                elif n == 2:
                                                    item = re.split(r"\.",l)[0]
                                                    itemvar = item[-1] if item[-1].isalpha() else ""
                                                    if itemvar != "":
                                                        item = item[0:-1]
                                                    item = "0" * (3 - len(item)) + item
                                                    continue
                                                elif n == 3:
                                                    part_number = l
                                                    continue
                                                elif n == 4:
                                                    mfr = l
                                                    continue
                                                elif n == 5:
                                                    indent = int(re.split(r"\.",l)[0]) + 1
                                                    continue
                                                elif n == 6:
                                                    part_keyword = l
                                                    continue
                                                elif n == 7:
                                                    short_name = l
                                                    continue
                                                elif n == 8:
                                                    dimensions = add_brackets(l)
                                                    continue
                                                elif n == 9:
                                                    attach = "\n<attachStoreShipPart attachStoreShipPartCode=\"1\"/>"
                                                    continue
                                                elif n == 10:
                                                    gpd.append(["esds", "(ESDS)"])
                                                    continue
                                                elif n == 11:
                                                    rds = re.split(',', l)
                                                    for rd in rds:
                                                        gpd.append(["rd", rd])
                                                    continue
                                                elif n == 12:
                                                    opn = re.split('\n', l)
                                                    for o in opn:
                                                        gpd.append(["opn", add_brackets("OVERLENGTH PN %s" % o)])
                                                    continue
                                                elif n == 13:
                                                    hpn = re.split('\n', l)
                                                    hpn_cage = re.split('\n', line[n])
                                                    for p,c in zip(hpn, hpn_cage):
                                                        gpd.append(["csdmfr", add_brackets("CSD: %s V%s" % (p,c))])
                                                        gpd.append(["csd", add_brackets("%s " % p)])
                                                    continue
                                                elif n == 14:
                                                    # gpd.append(["hpn", add_brackets("%s V%s" % (hpn,l))])
                                                    continue
                                                elif n == 15:
                                                    opt_pn = re.split('\n', l)
                                                    opt_cage = re.split('\n', line[n])
                                                    for p,c in zip(opt_pn, opt_cage):
                                                        gpd.append(["optpn", add_brackets("OPT PN %s V%s" % (p,c))])
                                                    continue
                                                elif n == 16:
                                                    # optpn = re.split('\n', l)
                                                    # for o in optpn:
                                                        # gpd.append(["optpn", add_brackets("%s V%s" % (opt_pn, o))])
                                                    continue
                                                elif n == 17:
                                                    rp = re.split('\n', l)
                                                    for r in rp:
                                                        gpd.append(["rp", add_brackets("REPLACED BY ITEM %s" % r)])
                                                    continue
                                                elif n == 18:
                                                    rps = re.split('\n', l)
                                                    for r in rps:
                                                        r=re.split(r"\.",r)[0] 
                                                        gpd.append(["rps", add_brackets("REPLACES ITEM %s" % r)])
                                                        continue
                                                elif n == 19:
                                                    sd = re.split('\n', l)
                                                    for s in sd:
                                                        s=re.split(r"\.",s)[0] 
                                                        gpd.append(["sd", add_brackets("SUPERCEDED BY ITEM %s" % s)])
                                                    continue
                                                elif n == 20:
                                                    sdes = re.split('\n', l)
                                                    for s in sdes:
                                                        gpd.append(["sdes", add_brackets("SUPERCEDES ITEM %s" % s)])
                                                    continue
                                                elif n == 21:
                                                    sbs = re.split('\n', l)
                                                    for s in sbs:
                                                        gpd.append(["sbs", add_brackets("PRE SB %s" % s)])
                                                    continue
                                                elif n == 22:
                                                    sbs = re.split('\n', l)
                                                    for s in sbs:
                                                        gpd.append(["sbs", add_brackets("POST SB %s" % s)])
                                                    continue
                                                elif n == 23:
                                                    uwi = re.split('\n', l)
                                                    for u in uwi:
                                                        gpd.append(["uwi", add_brackets("USE WITH ITEM %s" % u)])
                                                    continue
                                                elif n == 24:
                                                    nha = re.split('\n', l)
                                                    for ref in nha:
                                                        if ref[-1].isalpha():
                                                            var = ref[-1]
                                                            ref = ref[0:-1]
                                                        else:
                                                            var = ""
                                                        ref=re.split(r"\.",ref)[0]		
                                                        refs.append(GenerateReferTos("01", ref, var))
                                                    continue
                                                elif n == 25:
                                                    details = re.split('\n', l)
                                                    for ref in details:
                                                        if ref[-1].isalpha():
                                                            var = ref[-1]
                                                            ref = ref[0:-1]
                                                        else:
                                                            var = ""
                                                        ref=re.split(r"\.",ref)[0]	
                                                        refs.append(GenerateReferTos("02", ref, var))
                                                    continue
                                                elif n == 26:
                                                    removal = re.split('\n', l)
                                                    for ref in removal:
                                                        if ref[-1].isalpha():
                                                            var = ref[-1]
                                                            ref = ref[0:-1]
                                                        else:
                                                            var = ""
                                                        ref=re.split(r"\.",ref)[0]		
                                                        refs.append(GenerateReferTos("06", ref, var))
                                                    continue
                                                elif n == 27:
                                                    bkdn = re.split('\n', l)
                                                    for ref in bkdn:
                                                        if ref[-1].isalpha():
                                                            var = ref[-1]
                                                            ref = ref[0:-1]
                                                        else:
                                                            var = ""
                                                        ref=re.split(r"\.",ref)[0]		
                                                        refs.append(GenerateReferTos("10", ref, var))
                                                    continue
                                                elif n == 28:
                                                    msc = re.split('\n', l)
                                                    for m in msc:
                                                        gpd.append(["msc", add_brackets(m)]) 
                                                    continue
                                                elif n == 29:
                                                    eff = "\n<applicabilitySegment><usableOnCodeEquip>%s</usableOnCodeEquip></applicabilitySegment>" % l
                                                    continue
                                                elif n == 30:
                                                    quantity = l
                                                    continue
                                            except Exception as e:
                                                log_print(traceback.format_exc(), True)
                                                errors = True
                                                continue

                                        refer_tos = ""
                                        for ref in refs:
                                            refer_tos += ref

                                        generic_part_data = ""
                                        if len(gpd) > 0:
                                            generic_part_data = "\n<genericPartDataGroup>"
                                            for data in gpd:
                                                generic_part_data += "\n<genericPartData genericPartDataName=\"%s\"><genericPartDataValue>%s</genericPartDataValue></genericPartData>" % (data[0], data[1])
                                            generic_part_data += "\n</genericPartDataGroup>"

                                        desc = "%s-%s" % (part_keyword, short_name)

                                        #Generate and add a new catalogSeqNumber to the IPL file
                                        ipl_item = """\n<catalogSeqNumber assyCode="%s" figureNumber="%s"
                %sindenture="%s" item="%s"
                subSubSystemCode="%s" subSystemCode="%s" systemCode="%s">
                <itemSeqNumber itemSeqNumberValue="00%s">
                <quantityPerNextHigherAssy>%s</quantityPerNextHigherAssy>
                <partRef manufacturerCodeValue="%s" partNumberValue="%s"></partRef>
                <partSegment>
                <itemIdentData><descrForPart>%s</descrForPart>
                <partKeyword>%s</partKeyword>
                <shortName>%s</shortName>
                </itemIdentData></partSegment>
                <partLocationSegment>%s%s%s</partLocationSegment>%s%s
                </itemSeqNumber></catalogSeqNumber>""" % (assy, fignbr, figvar, indent, item, subsubsys, subsys, syscode, itemvar, quantity, mfr, part_number, desc, part_keyword, short_name, attach, not_illustrated, refer_tos, eff, generic_part_data)	
                                        ipl_item = re.sub(r"<partLocationSegment></partLocationSegment>\n", '', ipl_item)						
                                        figtext += '\n' + ipl_item
                            except Exception as e:
                                log_print(traceback.format_exc(), True)
                                errors = True
                                continue
                except:
                    log_print(traceback.format_exc(), True)
                    errors = True

                figtext += "\n</illustratedPartsCatalog>\n</content>\n</dmodule>"

                try:
                    (path_name / module_name).write_text(figtext, encoding="utf-8")
                except Exception as e:
                    log_print("Error while writing to file: %s" % module_name)
                    log_print(traceback.format_exc(), True)
                    errors = True					
        except Exception as e:
            log_print("Failed while writing IPL")
            log_print(traceback.format_exc(), True)
            errors = True

    try :	
        #################################################
        #PMC creation section
        ###############################################
        dmc_files = list(path_name.glob("DMC-HON*.xml"))
        dmc_list = [d.name for d in dmc_files]
        #print(dmc_list)
        dict_infocodes_cmm = {
            "INTRO" : ["018"],
            "DESCR" : ["100"],
            "TESTI" : ["400"],
            "SCHEM" : ["051"],
            "REPAI" : ["600"],
            "DISAS" : ["500"],
            "ASSEM" : ["700"],
            "STORA" : ["800"],
            "INSPE" : ["300"],
            "CHECK" : ["300"],
            "CLEAN" : ["200"],
            "FITS " : ["711"],
            "FITS&" : ["711"],
            "SPECI" : ["900"],
            "ILLUS" : ["941", "018"]
        }
        def write_dmrefs_to_pmc(PMC, entries):
            PMC.write(line + "\n")
            for entry in entries:	
                if "not applicable" in entry["title"].lower():
                    PMC.write("""<pmEntry>\n<dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="000" infoCodeVariant="A"
    itemLocationCode="C" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00"
    systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n</pmEntry>\n""")
                    return
                else:
                    PMC.write("<pmEntry><pmEntryTitle>" + entry["title"] + "</pmEntryTitle>\n")
                    
                required_entries = entry["count"]											
                dmcref=""
                counter = 0
                
                first_entry = True #for 941
                try:
                    dict_infocodes_cmm[entry["name"]]
                except KeyError:
                    PMC.write("</pmEntry>\n")
                    return

                for dmc in list(dmc_list):
                    name_parts = dmc.split("-")
                    dmref = "<dmRef><dmRefIdent><dmCode assyCode=\""+name_parts[5]+"\" disassyCode=\""+name_parts[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name_parts[7][0:3]+"\" infoCodeVariant=\""+name_parts[7][3:]+ \
                    "\"\nitemLocationCode=\"C\" modelIdentCode=\""+name_parts[1]+"\" subSubSystemCode=\"" +name_parts[4][1:]+"\" subSystemCode=\""+name_parts[4][0:1]+"\" systemCode=\""+name_parts[3]+"\"\n systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n"
                    if name_parts[7][0:3] in dict_infocodes_cmm[entry["name"]] and counter < required_entries:
                        if entry["name"] == "INTRO" and (name_parts[7][-1] in alphabet[19:] or "02" in name_parts[6]):
                            continue
                        counter += 1
                        if "941A" not in dmc:
                            dmcref += dmref
                        else:
                            #Read the file so we can check if it's a variant
                            text_941 = (path_name / dmc).read_text(encoding='utf-8')
                            try:
                                csn = re.search('<catalogSeqNumber[^>]+>', text_941).group(0)
                                hasvar = "figureNumberVariant" in csn
                            except:
                                dmcref += dmref
                        
                            dmcref += "{}{}{}".format("</pmEntry>" if not first_entry and not hasvar else "", "<pmEntry>" if not hasvar else "", dmref) 
                            if first_entry:
                                first_entry = False
                        dmc_list.remove(dmc)
                if entry["title"] == "Detailed Parts List":
                    dmcref += "</pmEntry>"
                dmcref += "</pmEntry>"
                PMC.write(dmcref+"\n")
            dmcref=""
            for dmc in list(dmc_list):
                name_parts = dmc.split("-")
                if name_parts[7][0:3] in dict_infocodes_cmm[entry["name"]]:	
                    if entry["name"] == "INTRO" and (name_parts[7][-1] in alphabet[19:] or "02" in name_parts[6]):
                        continue
                    dmcref += "<dmRef><dmRefIdent><dmCode assyCode=\""+name_parts[5]+"\" disassyCode=\""+name_parts[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name_parts[7][0:3]+"\" infoCodeVariant=\""+name_parts[7][3:]+ \
                    "\"\nitemLocationCode=\"C\" modelIdentCode=\""+name_parts[1]+"\" subSubSystemCode=\"" +name_parts[4][1:]+"\" subSystemCode=\""+name_parts[4][0:1]+"\" systemCode=\""+name_parts[3]+"\"\n systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n"	
                    dmc_list.remove(dmc)
            PMC.write(dmcref+"\n")
        #Add second level to pmc as well as how many dmc need to be added to each section 
        PMCS = list(path_name.glob("PMC*.xml"))
        PMC = PMCS[0].open(encoding="utf-8")
        PMC_text = PMC.read()		
        split_PMC=PMC_text.splitlines()	
        new_pmc=PMCS[0]
        (path_name / "sl_entries.txt").write_text(str(sl_entries))
        with new_pmc.open("w+",  encoding="utf-8") as PMC :			
            # loops through pmc shell
            print("DMCs are being added to PMC")
            if int(option) == 1:
                for line in split_PMC:	
                    for k in sl_entries:
                        if ">" + k['name'] in line and "SERVICE BULLETIN LIST" not in line: #SERVICING and SERVICE BULLETIN both start with "servi". Kind of gross, need to find a better way to sort this.
                            if "SPECIAL PROCEDURES" in line: #Ditto for Special Procedures and Special Tools, Fixtures, Equipment
                                write_dmrefs_to_pmc(PMC, [entry for entry in sl_entries if entry['name'] == "SPROC"])
                            else:
                                write_dmrefs_to_pmc(PMC, [entry for entry in sl_entries if entry['name'] == k['name']])
                            break
                    else:
                        if line.strip() != "":
                            PMC.write(line+"\n")
                PMC.close()
                print("PMC changes complete")	
            elif int(option) == 2 or int(option) == 3:
                dmc_list = [d.name for d in dmc_files]
                for line in split_PMC:	
                    if "<pmEntry pmEntryType=\"pmt58\"><pmEntryTitle>" in line :
                        PMC.write(line+"\n")

                        for dmc in dmc_list :
                            dmc=dmc.split("__")
                            dmc0=dmc[0].replace("_", " ")\
                                .replace("INSPECTION CHECK", "INSPECTION/CHECK").replace("TORQUE TEMPERATURE", "TORQUE/TEMPERATURE")\
                                .replace("REMOVAL REINSTALLATION", "REMOVAL/REINSTALLATION")

                            if dmc0 in line:
                                dmc[1] = dmc[1][1:] if dmc[1][0] == "_" else dmc[1]
                                name_parts=(dmc[1]).split("-")

                                dmcref="<dmRef><dmRefIdent><dmCode assyCode=\""+name_parts[5]+"\" disassyCode=\""+name_parts[6][:-1]+"\" disassyCodeVariant=\"A\" infoCode=\""+name_parts[7][0:3]+"\" infoCodeVariant=\""+name_parts[7][3:]+ \
                                    "\"\nitemLocationCode=\"C\" modelIdentCode=\""+name_parts[1]+"\" subSubSystemCode=\"" +name_parts[4][1:]+"\" subSystemCode=\""+name_parts[4][0:1]+"\" systemCode=\""+name_parts[3]+"\"\n systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n"	

                                PMC.write(dmcref+"\n")
                    elif line.strip() != "":
                        PMC.write(line + "\n")								
                print("PMC changes complete")
                #Rename files for MM option
                for file in dmc_files:
                    dmc = file.name.split("__")				
                    if len(dmc) > 1:
                        file.replace(file.with_name(dmc[1].lstrip('_')))
                        #Remove names with an extra underscore

    except Exception as e:
        log_print("Failed while writing PMC")
        log_print(traceback.format_exc(), True)
        errors = True

    ###############################################################################################
    ##########CAUTION REP BUILDER
    ##############################################################################################

    caut_counter=0
    caut_counter_atl=0
    caution_ref= """<cautionRef cautionIdentNumber="$$$$" id="$$$$">$***$</cautionRef>\n"""
    warning_ref= """<warningRef warningIdentNumber="$$$$" id="$$$$">$***$</warningRef>\n"""
    
    dmc_caut_rep_beging= """<?xml version="1.0" encoding="UTF-8"?>
    <!--Arbortext, Inc., 1988-2014, v.4002-->
    <!DOCTYPE dmodule [
    <!NOTATION tif SYSTEM "tiff">
    <!ENTITY % ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
    %ISOEntities; ]>
    <?Pub Inc?>
    <dmodule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/comrep.xsd">
    <identAndStatusSection>
    <dmAddress>
    <dmIdent>
    <dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="012" infoCodeVariant="B" itemLocationCode="D" modelIdentCode="HON99193" subSubSystemCode="0" subSystemCode="0" systemCode="72" systemDiffCode="EAA"/>
    <language countryIsoCode="US" languageIsoCode="en"/>
    <issueInfo inWork="00" issueNumber="001"/></dmIdent>
    <dmAddressItems>
    <issueDate day="05" month="12" year="2018"/>
    <dmTitle><techName>General</techName><infoName>General warnings and cautions and related safety data</infoName></dmTitle>
    </dmAddressItems></dmAddress>
    <dmStatus issueType="new">
    <security securityClassification="01"/>
    <responsiblePartnerCompany enterpriseCode="99193"></responsiblePartnerCompany>
    <originator enterpriseCode="99193"></originator>
    <applic>
    <displayText>
    <simplePara>ALL</simplePara>
    </displayText>
    </applic>
    <brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0" subSystemCode="0" systemCode="00"
    systemDiffCode="AAA"/></dmRefIdent></dmRef></brexDmRef>
    <qualityAssurance>
    <unverified/></qualityAssurance></dmStatus>
    </identAndStatusSection>
    <content>
    <commonRepository>
    <cautionRepository> 
    </cautionRepository></commonRepository></content></dmodule>
    """

    dmc_warn_rep_beging= """<?xml version="1.0" encoding="UTF-8"?>
    <!--Arbortext, Inc., 1988-2014, v.4002-->
    <!DOCTYPE dmodule [
    <!NOTATION tif SYSTEM "tiff">
    <!ENTITY % ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
    %ISOEntities; ]>
    <?Pub Inc?>
    <dmodule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/comrep.xsd">
    <identAndStatusSection>
    <dmAddress>
    <dmIdent>
    <dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="012" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HON99193" subSubSystemCode="0" subSystemCode="0" systemCode="72" systemDiffCode="EAA"/>
    <language countryIsoCode="US" languageIsoCode="en"/>
    <issueInfo inWork="00" issueNumber="001"/></dmIdent>
    <dmAddressItems>
    <issueDate day="05" month="12" year="2018"/>
    <dmTitle><techName>General</techName><infoName>General warnings and cautions and related safety data</infoName></dmTitle>
    </dmAddressItems></dmAddress>
    <dmStatus issueType="new">
    <security securityClassification="01"/>
    <responsiblePartnerCompany enterpriseCode="99193"></responsiblePartnerCompany>
    <originator enterpriseCode="99193"></originator>
    <applic>
    <displayText>
    <simplePara>ALL</simplePara>
    </displayText>
    </applic>
    <brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="AA" infoCode="022" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="S1000DBIKE" subSubSystemCode="0" subSystemCode="0" systemCode="00"
    systemDiffCode="AAA"/></dmRefIdent></dmRef></brexDmRef>
    <qualityAssurance>
    <unverified/></qualityAssurance></dmStatus>
    </identAndStatusSection>
    <content>
    <commonRepository>
    <warningRepository>
    </warningRepository></commonRepository></content></dmodule>"""
    
    dmc_files = [f for f in list(path_name.glob("DMC*.xml")) if "941" not in f.name and "00PA" not in f.name and "00WA" not in f.name]

    # for file in dmc_files:
        # text = file.read_text(encoding='utf-8')
        # text = re.sub('<(procedure|preliminaryRqmts)>', r'\n<\1>', text)
        # file.write_text(text, encoding='utf-8')

    caut_rep_name = dmc_files[0].name[0:25]+"-00A-012B-D.xml"
    warn_rep_name = dmc_files[0].name[0:25]+"-00A-012A-D.xml"
    name=(caut_rep_name).split("-")
    caut_rep_dmref = "<dmRef><dmRefIdent><dmCode assyCode=\""+name[5]+"\" disassyCode=\"01\" disassyCodeVariant=\"A\" infoCode=\"012\" infoCodeVariant=\"B\" itemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n"
    warn_rep_dmref = "<dmRef><dmRefIdent><dmCode assyCode=\""+name[5]+"\" disassyCode=\"01\" disassyCodeVariant=\"A\" infoCode=\"012\" infoCodeVariant=\"A\" itemLocationCode=\"C\" modelIdentCode=\""+name[1]+"\" subSubSystemCode=\"" +name[4][1:]+"\" subSystemCode=\""+name[4][0:1]+"\" systemCode=\""+name[3]+"\" systemDiffCode=\"EAA\"/></dmRefIdent></dmRef>\n"
    
    try:
        caut_repo_text = {}
        warn_repo_text = {}
        def sub_warn_caut(match):
            nonlocal local_warn_caut
            nonlocal caut_repo_text
            nonlocal warn_repo_text
            caut_ref = ""
            warn_ref = ""
            for wc in re.findall(r"<note>\n?<notePara>(WARNING|CAUTION)\s?:\s*(.*?)</notePara>\n?</note>", match.group(0)):
                if wc[0] == "WARNING":
                    repo = warn_repo_text
                    id_prefix = "warn-"
                else:
                    repo = caut_repo_text
                    id_prefix = "caut-"
                
                #Check if warning/caution exists in master repo already. If so, assign existing id. If not, assign new id and add it. 
                for k,v in repo.items():
                    if wc[1] == v:
                        id = k
                        break
                else:
                    id = id_prefix + add_leading_zero(len(repo) + 1 , 4)
                    repo[id] = wc[1]
                
                #If warning/caution doesn't already exist in local header, add it
                if not id in local_warn_caut: 
                    local_warn_caut.append(id)
                    
                if id_prefix == "caut-":
                    caut_ref += "{} ".format(id)
                else:
                    warn_ref += "{} ".format(id)
                
            caut_ref = caut_ref.strip()
            warn_ref = warn_ref.strip()
            
            step = match.group(1)
            if caut_ref != "":
                if "cautionRefs=" in step:
                    step = re.sub(r'cautionRefs="([^"]+)"', r'cautionRefs="\1 {}"'.format(caut_ref), step)
                else:
                    step += ' cautionRefs="{}"'.format(caut_ref)
                    
            if warn_ref != "":
                if "warningRefs=" in step:
                    step = re.sub(r'warningRefs="([^"]+)"', r'warningRefs="\1 {}"'.format(warn_ref), step)
                else:
                    step += ' warningRefs="{}"'.format(warn_ref)

            return '<{}>'.format(step)
        
        #Gather warnings/cautions from files. Turn into references, populate warningsAndCautionsRef
        for file in dmc_files:
            text = file.read_text(encoding='utf-8')
            
            local_warn_caut = []
            text = re.sub(r'((<note><notePara>(?:WARNING|CAUTION).*?</note>)((?:</proceduralStep>)+|))+', r'\3\2', text)

            text = re.sub(re.compile(r'<(proceduralStep[^>]*)>[^\n]+\n<note>\n?<notePara>(?:WARNING|CAUTION)\s?:\s*(.*?)</notePara></note>(?!\n*<note>\n?<notePara>(?:WARNING|CAUTION))\n*', re.DOTALL), sub_warn_caut, text)
            text = re.sub(re.compile(r'<note>\n?<notePara>(?:WARNING|CAUTION).*?</note>\n*<(proceduralStep[^>]*|)>', re.DOTALL), sub_warn_caut, text)

            if len(local_warn_caut) == 0:
                continue
                
            warningsAndCautionsRef = "<warningsAndCautionsRef>\n"
            for k in [x for x in local_warn_caut if "warn" in x]:
                new_ref = re.sub('\${4}', k, warning_ref)
                new_ref = re.sub('\$\*\*\*\$', warn_rep_dmref, new_ref)
                warningsAndCautionsRef += new_ref
    
            for k in [x for x in local_warn_caut if "caut" in x]:
                new_ref = re.sub('\${4}', k, caution_ref)
                new_ref = re.sub('\$\*\*\*\$', caut_rep_dmref, new_ref)
                warningsAndCautionsRef += new_ref

            warningsAndCautionsRef += "</warningsAndCautionsRef>\n"
            text = re.sub(r'<procedure>', '{}<procedure>'.format(warningsAndCautionsRef), text)
            file.write_text(text, encoding='utf-8')

        #Build repository
        warn_repo_content = ""
        for k,v in warn_repo_text.items():
            warn_repo_content += "<warningSpec><warningIdent warningIdentNumber=\"{0}\" id=\"{0}\"/><warningAndCautionPara>{1}</warningAndCautionPara></warningSpec>\n".format(k, v)
            
        (path_name / warn_rep_name).write_text(re.sub('<warningRepository>', '<warningRepository>\n{}'.format(warn_repo_content), dmc_warn_rep_beging), encoding='utf-8')
        
        caut_repo_content = ""
        for k,v in caut_repo_text.items():
            caut_repo_content += "<cautionSpec><cautionIdent cautionIdentNumber=\"{0}\" id=\"{0}\"/><warningAndCautionPara>{1}</warningAndCautionPara></cautionSpec>\n".format(k, v)
            
        (path_name / caut_rep_name).write_text(re.sub('<cautionRepository>', '<cautionRepository>\n{}'.format(caut_repo_content), dmc_caut_rep_beging), encoding='utf-8')
    except Exception as e:
        log_print("Failed while writing warnings/cautions repositories")
        log_print(traceback.format_exc(), True)
        errors = True

    ####Add generic modules for CMMs, should add options for other book types
    if int(option) == 1:
        print("Adding generic modules")
        #Copy files from folder listed bellow to current folder
        cmm_generic = Path(os.path.abspath(os.path.dirname(__file__))) / "Generic Modules/CMM"
        Generics = list(cmm_generic.glob("*.xml"))
        for generic in Generics:		
            shutil.copy2(str(generic), str(path_name / generic.name))

    ###############Recheck context after removing cautions and warnings ##################
    try:	
        for dmc_file in dmc_files :
            text = dmc_file.read_text(encoding='utf-8')	

            text=text.replace("\n"," ")
            text=re.sub("\s{2,}", " ", text)
            text=re.sub("<!-- (.*?)-->", "", text)		
            text=text.replace("</?SECOND LEVEL>","")
            text=text.replace("<figure><title><para>","<figure><title>")
            text=text.replace("</para></title><graphic","</title><graphic")		
            text=re.sub("(</para>)+", "</para>", text) 
            text=text.replace("<listItem></para>" , "<listItem>")
            text=text.replace("</listItem></para>" , "</listItem>")
            text=text.replace("<para<para>>" , "<para>")
            text=text.replace("</para><para></listItem> " , "</para></listItem>")
            text=text.replace("</para><para></proceduralStep>" , "</para></proceduralStep>")
            text=text.replace("</para><randomList>" , "</para><para><randomList>")
            text=re.sub("</para> <!--(.*?)--> </para>", r"</para> <!--\1-->", text)
            text=re.sub("</note></para>", "</note><para>", text)
            text=text.replace("</note></para><figure>","</note><figure>") 
            text=text.replace("</note><para><figure>","</note><figure>") 
            text=text.replace("</note><para><para>","</note><para>")
            text=re.sub("</note><para><note>", "</note><note>", text)
            text=text.replace("</note> <randomList>" , "</note><para><randomList>")
            text=text.replace("</note><randomList>" , "</note><para><randomList>")
            text=text.replace("<entry></para><note>" , "<entry><note>")
            text=text.replace("</note><para></entry>" , "</note></entry>")
            text=re.sub("</table></para>", "</table> ", text)
            text=text.replace("</table></para><table>","</table><table>")
            text=text.replace("</table><para><figure>","</table><figure>")
            text=re.sub("<row><para>", "<row><entry><para> ", text)		
            text=re.sub("</figure></para>", "</figure>", text)
            text=text.replace("<para></para>","")
            text=text.replace("<para><table>","</para><table>")
            text=re.sub("<para><note>", "</para><note>", text)		
            text=text.replace("</proceduralStep> </para> <proceduralStep>" , "</proceduralStep><proceduralStep>")
            text=re.sub("([A-Z])&([A-Z])",r"\1&amp;\2", text)		
            text=re.sub("</figure><para><para>", "</figure><para>", text)
            text=re.sub("</figure><para><note>", "</figure><note>", text)
            text=re.sub("</figure><para>\s+<note>", "</figure><note>", text)
            text=re.sub("</figure><para><figure>", "</figure><figure>", text)
            text=re.sub("</figure>\s+</para></proceduralStep>", "</figure></proceduralStep>", text)
            text=re.sub("</figure><randomList>", "</figure><para><randomList>", text)			
            text=text.replace("</figure> <randomList>" , "</figure><para><randomList>") 
            text=text.replace("</randomList><proceduralStep>" , "</randomList></para><proceduralStep>") 
            text=text.replace("<para> </proceduralStep>" , "</proceduralStep>")
            text=text.replace("!\"#$%&'" , "!\"#$%'")
            text=text.replace("<para><para>","<para>")		
            text=text.replace("<para></para>","")
            text=text.replace("</note><para><para></entry>" , "</note><para></para></entry>")
            text = re.sub(r"(?:<para>)+<(/?)proceduralStep>", r"<\1proceduralStep>", text)
            text=text.replace("</para><?xml version" , "<?xml version")
            text=text.replace("<notePara></para><para>" , "<notePara>")
            text=text.replace("</para><para></proceduralStep" , "</para></proceduralStep")
            text=text.replace("</figure></para></proceduralStep" , "</figure></proceduralStep")
            text=text.replace("</para></para><figure>" , "</para><figure>")
            text=text.replace("</notePara><!--Caution added" , "</notePara></note><!--Caution added")
            text=text.replace("</notePara><!--Warning" , "</notePara></note><!--Warning")
            text=text.replace("</para><para></proceduralStep" , "</para></proceduralStep")
            text = re.sub('</table><row>.*?</row>', '</table>', text)
            text = re.sub('</table></para>', '</table>', text)
            #Deals with cautions/warnings in tables
            text = re.sub(r'<note><notePara>(CAUTION|WARNING):', r'<para>\1:', text)
            text = re.sub(r'(<entry><para>[^<]+)</notePara></para></note>', r'\1</para>', text)
            
            text = re.sub(r">\s*<", ">\n<", text)
            text = re.sub(r"\n?<end_of_file>", "", text)
            text = re.sub(r"<\s*>", "", text)
            dmc_file.write_text(text, encoding='utf-8')
        print("Context verification complete")				
    except Exception as e:
        log_print("Final context check failed")
        log_print(traceback.format_exc(), True)
        errors = True

    if not debug_mode:
        cleanup_files(path_name) 

    log_print("Conversion completed")
    exit_handler(0 if not errors else 1)

if __name__ == "__main__":
    DigitalSunshine(None, Path('.'), None)