# import atexit
# import glob
# import importlib
import math
# import ntpath
# import os
import re
import sys
import traceback
from datetime import date
from pathlib import Path
import sqlite3
DB_PATH = "C:/Users/asmith/Documents/GitHub/Launchpad/launchpad/Finals/data_conversion_finals.db"
try:
    from launchpad.functions import sqlite_select, sqlite_update, log_print
except ImportError:
    print("Could not find Launchpad")
    def sqlite_connect(DB_PATH):
        try:
            connection = sqlite3.connect(DB_PATH)
            cursor = connection.cursor()
        except sqlite3.Error as error:
            print(f"Error while connecting to sqlite: {error}")
            return None, None
        else:
            # print("Successfully connected to Database")
            return connection, cursor

    def sqlite_select(query, db=None):
        connection, cursor = sqlite_connect() if db is None else sqlite_connect(db)
        return_value = []
        if connection is not None and cursor is not None:
            try:
                cursor.execute(query)
            except sqlite3.Error as error:
                print(error)
            else:
                return_value = cursor.fetchall()
            finally:
                cursor.close()
                connection.close()

        return return_value

    def sqlite_update(query, values=()):
        connection, cursor = sqlite_connect()
        success = False
        if connection is not None and cursor is not None:
            try:
                if len(values):
                    cursor.execute(query, values)
                else:
                    cursor.execute(query)
            except sqlite3.Error as error:
                print(error)
            else:
                try:
                    connection.commit()
                except sqlite3.Error as error:
                    print(error)
                else:
                    success = True
            finally:
                cursor.close()
                connection.close()
        return success

try:
    from launchpad import APP
except ImportError:
    pass



pattern_infoname = re.compile(r'<infoName>(.*?)</infoName>', re.DOTALL)
pattern_techname = re.compile(r'<techName>(.*?)</techName>', re.DOTALL)
pattern_title = re.compile(r'<title>(.*?)</title>', re.DOTALL)
pattern_para = re.compile(r'<para>(.*?)</para>', re.DOTALL)
pattern_content = re.compile(r"<content>(.*?)</content>", re.DOTALL)
pattern_brex = re.compile(r"<brexDmRef>(.*?)</brexDmRef>", re.DOTALL)
pattern_quality = re.compile(r"<qualityAssurance>(.*?)</qualityAssurance>", re.DOTALL)
pattern_ATA = re.compile(r'<externalPubCode pubCodingScheme="CMP">(.*?)</externalPubCode>', re.DOTALL)
pattern_CAGE = re.compile(r'pmIssuer="(.*?)"', re.DOTALL)
pattern_condcrossref = re.compile(r"<condCrossRefTableRef>(.*?)</condCrossRefTableRef>", re.DOTALL)
pattern_relimrq = re.compile(r'<preliminaryRqmts>(.*?)</preliminaryRqmts>', re.DOTALL)
pattern_closerq = re.compile(r'<closeRqmts>(.*?)</closeRqmts>', re.DOTALL)
pattern_prodattlist = re.compile(r'<productAttributeList>(.*?)</productAttributeList>', re.DOTALL)
pattern_lep = re.compile(r'pmEntryType="pmt56">(.*?)</pmEntry>', re.DOTALL)
pattern_toolspec = re.compile(r'</itemIdentData>\s*<techData>')
pattern_toolspec1 = re.compile(r'</itemIdentData>\s*</toolSpec>')
pattern_toolspec2 = re.compile(r'</procurementData>\s*</toolSpec>')
pattern_condgroup = re.compile(r'<reqCondGroup>\s*</reqCondGroup>')
pattern_reqsupeq = re.compile(r'<reqSupportEquips>\s*</reqSupportEquips>')
pattern_reqsupplies = re.compile(r'<reqSupplies>\s*</reqSupplies>')
pattern_reqspares = re.compile(r'<reqSpares>\s*</reqSpares>')
pattern_reqsafety = re.compile(r'<reqSafety>\s*</reqSafety>')
pattern_supeqgp = re.compile(r'<supportEquipDescrGroup>\s*</supportEquipDescrGroup>')
pattern_supdesgp = re.compile(r'<supplyDescrGroup>\s*</supplyDescrGroup>')
pattern_supeq = re.compile(r'<supportEquipDescr>\s*</supportEquipDescr>')
pattern_supdes = re.compile(r'<supplyDescr>\s*</supplyDescr>')
pattern_wnc = re.compile(r'<warningsAndCautionsRef>\s*</warningsAndCautionsRef>')
pattern_cominfo = re.compile(r'<commonInfo>\s*</commonInfo>')
pattern_pmentry = re.compile(r'<pmEntry>\s*</pmEntry>')
pattern_prodatt = re.compile(r'<productAttribute(.*?)</productAttribute>', re.DOTALL)
pattern_logo = re.compile(r'<logo>(.*?)</logo>', re.DOTALL)
pattern_procstep = re.compile(r'<proceduralStep>\s*</proceduralStep>')
pattern_pmt57 = re.compile(r'<pmEntry pmEntryType="pmt57">\s*</pmEntry>')
pattern_emptypmentry = re.compile(r'<pmEntry>\s*</pmEntry>')
pattern_gpdg = re.compile(r'<genericPartDataGroup>\s*</genericPartDataGroup>')
pattern_gpd = re.compile(r'<genericPartData>\s*</genericPartData>')
pattern_gpdv = re.compile(r'<genericPartDataValue>\s*</genericPartDataValue>')
pattern_issuedate = re.compile(r'<issueDate .*?/>', re.DOTALL)
pattern_dmcode = re.compile(r'<dmCode(.*?)/>', re.DOTALL)

manual_types = {
    "CMM": "EAA",
    "EIPC": "EAC",
    "EM": "EAD",
    "LMM": "EAG",
    "HMM": "EAG",
    "MM": "EAF",
    "OHM": "EAJ",
    "IRM": "EAI",
    "SPM": "EAN",
    "SDIM": "EAM",
    "AMM": "EAB",
    "IM": "EAH",
    "IMM": "EAH",
    "OH": "EAK",
    "ORIM": "EAL"
}

site_prefixes = {
    "Ottawa": "0",
    "Phoenix": "1",
    "India": "2",
}

try:
    pm_prefix = site_prefixes[APP.config['SITE']]
except:
    pm_prefix = "0"

def add_zeroes(number, dig):
    n = abs(number)
    return f'{"-" if number < 0 else ""}' + '0' * (dig - digits(n)) + str(n)

def digits(n):
    if n == 0:
        return 1
    return int(math.log10(n))+1

def check_match(match, grp=1):
    if match is not None:
        return(match.group(grp))
    else:
        return("")

def infoCode_sysDiff(icv, sd):
    if icv != "Z":
        icv = chr(ord(icv)+1)
    else:
        icv = "A"
        sd += 1
    return icv, sd

def sysDiff(sd, sdv):
    if sd != 99:
        sd += 1
    else:
        sd = 0
        sdv = chr(ord(sdv)+1)
    return sd, sdv

def get_col(i):
    i = max(i - 1, 0)
    col = chr((i % 26) + 65)
    if i >= 26:
        col += chr((((i - 26) // 26) % 26) + 65)
        if i >= 702:
            col += chr((((i - (702 - 26 * (i // 702))) // 27 // 26) % 26) + 65)
    return col[::-1]

def incr(s, amount):
    r_str = list(map(lambda x: ord(x)-65, reversed(s)))
    a = 1 if amount > 0 else -1
    for _ in range(abs(amount)):
        if len(r_str) == 0:
            return 'A'
        i = 0
        while True:
            r_str[i] += a
            if r_str[i] not in range(0,26):
                if a == 1:
                    r_str[i] = 0
                else:
                    r_str[i] = 25
                if i == len(r_str) - 1:
                    if a == 1:
                        r_str.append(0)
                    else:
                        r_str = r_str[:-1]
                    break
                i += 1
            else:
                break
    return ''.join(map(lambda x: chr(x+65), reversed(r_str)))

def checkingDMCodes(working_dir):
    print("\nVerifying File Names and dmCodes...")
    files = sorted(working_dir.glob('DMC*.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        text = re.sub('"></dmCode>', '"/>', text)
        dmcode = re.sub('\n', ' ', check_match(pattern_dmcode.search(text)))
        linereplace = re.sub('"\n', '" ', text)
        file.write_text(linereplace, encoding="utf-8")
        filename = file.name
        filename = re.sub('DMC-', '', filename)
        components = re.split('-', filename)
        comp_dict = {
            "model": components[0],
            "diff": components[1],
            "sys": components[2],
            "subsys": components[3][0],
            "subsub": components[3][1],
            "assy": components[4],
            "disassy": components[5][0:2],
            "disvar" : components[5][2],
            "info" : components[6][0:3],
            "infovar" : components[6][3],
            "loc" : components[7].split('_')[0][0]
            }
        dmcodematch = "assyCode=\"%s\" disassyCode=\"%s\" disassyCodeVariant=\"%s\" infoCode=\"%s\" infoCodeVariant=\"%s\" itemLocationCode=\"%s\" modelIdentCode=\"%s\" subSubSystemCode=\"%s\" subSystemCode=\"%s\" systemCode=\"%s\" systemDiffCode=\"%s\"" % (comp_dict["assy"], comp_dict["disassy"], comp_dict["disvar"], comp_dict["info"], comp_dict["infovar"], comp_dict["loc"], comp_dict["model"], comp_dict["subsub"], comp_dict["subsys"], comp_dict["sys"], comp_dict["diff"])
        if dmcodematch.lower() in dmcode.lower():
            continue
        else:
            text = file.read_text(encoding="utf-8")
            dmcodereplace = re.sub(dmcode, ' ' + dmcodematch, text)
            file.write_text(dmcodereplace, encoding="utf-8")

def valPMC(working_dir):
    print("\nValidating Errors...")
    files = sorted(working_dir.glob('PMC*.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        pmcLogo = re.sub('logo="Honeywell Logo.eps"', '', text)
        LEP = re.sub(pattern_lep, 'pmEntryType="pmt56"><pmEntryTitle>LIST OF EFFECTIVE PAGES</pmEntryTitle><externalPubRef authorityDocument="LEP"><externalPubRefIdent></externalPubRefIdent></externalPubRef></pmEntry>', pmcLogo)
        pmentry = re.sub(pattern_pmentry, '', LEP)
        logo = re.sub(pattern_logo, '', pmentry)
        pmt = re.sub(pattern_pmt57, '', logo)
        emptypmentry = re.sub(pattern_emptypmentry, '', pmt)
        file.write_text(emptypmentry, encoding="utf-8")

def val00W(working_dir):
    files = sorted(working_dir.glob('*-00W*.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        useforparts = re.sub('useForPartsList="yes"', '', text)
        file.write_text(useforparts, encoding="utf-8")

def valAll(working_dir):
    for file in working_dir.glob('*.XML'):
        text = file.read_text(encoding="utf-8")
        caret = re.sub('\<\?Pub Caret -(.*?)\?\>', '', text)
        langCode = re.sub('languageIsoCode="en"', 'languageIsoCode="sx"', caret)
        procstep = re.sub(pattern_procstep, '', langCode)
        gpdv = re.sub(pattern_gpdv, '', procstep)
        gpd = re.sub(pattern_gpd, '', gpdv)
        gpdg = re.sub(pattern_gpdg, '', gpd)
        pmcLogo = re.sub('https://myaerospace.honeywell.com/wps/portal/', 'https://aerospace.honeywell.com/en/learn/about-us/about-myaerospace', gpdg)
        pmcLogo = re.sub('www.myaerospace.com', 'https://aerospace.honeywell.com', pmcLogo)
        pmcLogo = re.sub('.tif" NDATA tif>', '.cgm" NDATA cgm>', pmcLogo)
        if "PMC" in file.name:
            issueDate = check_match(pattern_issuedate.search(pmcLogo), grp=0)
        file.write_text(pmcLogo, encoding="utf-8")
    if issueDate:
        for file in working_dir.glob('*-941*.XML'):
            text = file.read_text(encoding="utf-8")
            fixissuedate = re.sub(pattern_issuedate, issueDate, text)
            file.write_text(fixissuedate, encoding="utf-8")

def val00N(working_dir):
    for file in working_dir.glob('*-00N*.XML'):
        text = file.read_text(encoding="utf-8")
        toolspec = re.sub(pattern_toolspec, '</itemIdentData><procurementData></procurementData><techData>', text)
        toolspec = re.sub(pattern_toolspec1, '</itemIdentData>\n<procurementData></procurementData><techData></techData><toolAlts><tool>\n<itemDescr></itemDescr></tool></toolAlts></toolSpec>', toolspec)
        toolspec = re.sub(pattern_toolspec2, '</procurementData><techData></techData><toolAlts><tool><itemDescr></itemDescr></tool></toolAlts></toolSpec>', toolspec)
        file.write_text(toolspec, encoding="utf-8")

def valCondGroup(working_dir):
    for file in working_dir.glob('*.XML'):
        text = file.read_text(encoding="utf-8")
        supeq = re.sub(pattern_supeq, '', text)
        supdes = re.sub(pattern_supdes, '', supeq)
        supeqgp = re.sub(pattern_supeqgp, '', supdes)
        supdesgp = re.sub(pattern_supdesgp, '', supeqgp)
        condgroup = re.sub(pattern_condgroup, '<reqCondGroup><reqCondNoRef><reqCond></reqCond></reqCondNoRef></reqCondGroup>', supdesgp)
        reqsupeq = re.sub(pattern_reqsupeq, '<reqSupportEquips><noSupportEquips/></reqSupportEquips>', condgroup)
        reqsupplies = re.sub(pattern_reqsupplies, '<reqSupplies><noSupplies/></reqSupplies>', reqsupeq)
        ReqSpares = re.sub(pattern_reqspares, '<reqSpares><noSpares/></reqSpares>', reqsupplies)
        ReqSafety = re.sub(pattern_reqsafety, '<reqSafety><noSafety/></reqSafety>', ReqSpares)
        cominfo = re.sub(pattern_cominfo, '', ReqSafety)
        wnc = re.sub(pattern_wnc, '', cominfo)
        file.write_text(wnc, encoding="utf-8")

def cleanup(working_dir):
    for f in working_dir.glob('*.xml'):
        new_filename = f.name.replace("_001-00_sx-US","")
        new_filename = new_filename.replace("_001-00_en-US","")
        new_filename = new_filename.replace("xml","XML")
        f.rename(f.with_name(new_filename))

def removeRemarks(working_dir):
    pattern_rfu = re.compile(r"<remarks>.*?</remarks>", re.DOTALL)
    for file in working_dir.glob("*.xml"):
        text = file.read_text(encoding='utf-8')
        text = re.sub(pattern_rfu, "", text)
        file.write_text(text, encoding="utf-8")

def addIssue(working_dir):
    for file in working_dir.glob("DMC*.xml"):
        text = file.read_text(encoding='utf-8')
        text = re.sub('issueNumber="[^<]+"', 'issueNumber="001"', text)
        file.write_text(text, encoding="utf-8")

def PMCfileName(working_dir, pmcname):
    for file in working_dir.glob("PMC*.xml"):
        file.rename(file.with_name(pmcname))

def DM_Rename(working_dir, new_name, filename):
    pattern_dmref = re.compile('<dmRef([^>]*)>(.*?)</dmRef>', re.DOTALL)

    class MultiFile(Exception):
        def __init__(self,*args,**kwargs):
            Exception.__init__(self,*args,**kwargs)
    class NoFile(Exception):
        def __init__(self,*args,**kwargs):
            Exception.__init__(self,*args,**kwargs)
    class NotFound(Exception):
        def __init__(self,*args,**kwargs):
            Exception.__init__(self,*args,**kwargs)
    #Function to print to log and screen at the same time. Make the second argument 'True' if you want to print only to the log and not the console
    def log_print(printMessage, printToLogOnly = False):
        if(not printToLogOnly):
            print(printMessage)
        global logText
        logText += '\n' + str(printMessage)
    #Function that runs at the end of the script. You should call this function at any time you want the script to end.
    def exit_handler():
        # if logText != "":
        #     try:
        #         print("\n>>>Would you like to generate a log file? (y/n)")
        #         #This loop will wait for you to press the Y or N keys, then run some code and break the loop.
        #         while True:
        #             key = ord(getch())
        #             if(key == 121):
        #                 #I'd recommend changing the log name based on the script that's outputting it
        #                 (working_dir / 'rename_dms_log.txt').write_text(logText.strip('\n'))
        #                 break
        #             elif(key == 110):
        #                 break
        #     except:
        #         traceback.print_exc()
        #         print("\n>>>Press any key to exit")
        #         key = ord(getch())
        # else:
        #     print("\n>>>Press any key to exit")
        #     #This loop will wait for you to press the Y or N keys, then run some code and break the loop.
        #     key = ord(getch())
        (working_dir / 'rename_dms_log.txt').write_text(logText.strip('\n'))
        sys.exit(0)
    def get_components(f):
        try:
            f = re.sub('DMC-', '', f)
            components = re.split('-', f)
            comp_dict = {
                    "model": components[0],
                    "diff": components[1],
                    "sys": components[2],
                    "subsys": components[3][0],
                    "subsub": components[3][1],
                    "assy": components[4],
                    "disassy": components[5][0:2],
                    "disvar" : components[5][2],
                    "info" : components[6][0:3],
                    "infovar" : components[6][3],
                    "loc" : components[7].split('_')[0][0]
                }
        except:
            log_print("Invalid filename format!")
            exit_handler()
        else:
            return comp_dict
    def get_filename_from_xref(dmref):
        try:
            vars = re.split(' |\n', dmref)
            vars = [var.split('\"')[1] for var in vars if(len(var.split('\"')) >= 2)]
            dmc = "%s-%s-%s-%s%s-%s-%s%s-%s%s-%s" % (vars[6], vars[10], vars[9], vars[8], vars[7], vars[0], vars[1], vars[2], vars[3], vars[4], vars[5])
            return dmc
        except IndexError:
            return ""
        except Exception as e:
            print(dmref)
            log_print("Error while parsing dmRef:")
            log_print(traceback.format_exc())
            return None
    def get_xref_from_filename(name):
        comp_dict = get_components(new_name)
        return "<dmRef><dmRefIdent><dmCode assyCode=\"%s\" disassyCode=\"%s\" disassyCodeVariant=\"%s\" infoCode=\"%s\" infoCodeVariant=\"%s\" itemLocationCode=\"%s\" modelIdentCode=\"%s\" subSubSystemCode=\"%s\" subSystemCode=\"%s\" systemCode=\"%s\" systemDiffCode=\"%s\"/></dmRefIdent></dmRef>" \
        % (comp_dict["assy"], comp_dict["disassy"], comp_dict["disvar"], comp_dict["info"], comp_dict["infovar"], comp_dict["loc"], comp_dict["model"], comp_dict["subsub"], comp_dict["subsys"], comp_dict["sys"], comp_dict["diff"])
    def replace_xref(match):
        if get_filename_from_xref(match.group(2)) in filename.name:
            return re.sub('<dmRef>', '<dmRef{}>'.format(match.group(1)), new_xref)
        else:
            return match.group(0)
    
    #String where we log all our log_print() messages so we can later write them to log file if desired.
    logText = ""
    new_xref = get_xref_from_filename(new_name)
    try: #Replace PMC Reference
        #print("\nReplacing PMC Reference...", end="\r")
        #Get a list of all DMCs in the directory
        pmc = sorted(working_dir.glob('PMC*.XML'))
        #If there happens to be no valid files in the directory
        if(len(pmc) == 0):
            raise NoFile
        else:
            pmc = pmc[0]
            text = pmc.read_text(encoding="utf-8")
            new_text = re.sub(pattern_dmref, replace_xref, text)
            if text != new_text:
                pmc.write_text(new_text, encoding="utf-8")
            else:
                raise NotFound
    except PermissionError:
        print("   Renaming File... Error: Permission Denied! Ensure file is not open.")
    except NoFile:
        print("   Replacing PMC Reference... Error: No PMC Found!")
    except NotFound:
        if any(x in filename.name for x in {"00L", "00W", "00N", "012", "00K", "00P", "018E"}):
            pass
        else:
            print("   Replacing PMC Reference... Warning: No Reference Found In PMC for %s" % filename.name)
    except:
        print("   Replacing DMC References... Error:")
        print(traceback.format_exc())
    try: #Replace DMC References
        #Process each file in turn
        for file in working_dir.glob('DMC*.XML'):
            #Read content into a string
            text = file.read_text(encoding="utf-8")
            new_text = re.sub(pattern_dmref, replace_xref, text)
            #Reopen file for writing
            if text != new_text:
                file.write_text(new_text, encoding="utf-8")
    except PermissionError:
            print("   Renaming File... Error: Permission Denied! Ensure {} is not open.".format(file))
    except NoFile:
        print("   Replacing DMC References... Error: No Data Modules Found!")
    except:
        print("   Replacing DMC References... Error:")
        print(traceback.format_exc())
    try: #Get the actual file to be renamed
        #print("\nFinding File To Rename... ", end="\r")
        file = list(working_dir.glob(f'*{filename.name}*'))
        if len(file) == 0:
            raise NoFile
        elif len(file) > 1:
            raise MultiFile
    except NoFile:
        print("   Finding File To Rename... Error: No File Found!")
        exit_handler()
    except MultiFile:
        print("   Finding File To Rename... Error: More Than 1 File Found!")
        exit_handler()
    except:
        print("   Finding File To Rename... Error!")
        exit_handler()
    else: #We've gotten the file, so change the DM Code and Filename
        file = file[0]
        try:
            #print("\nReplacing DM Code... ", end="\r")
            text = file.read_text(encoding="utf-8")
            text = re.sub(pattern_dmcode, re.search(pattern_dmcode, new_xref).group(0), text, 1)
            file.write_text(text, encoding="utf-8")
        except PermissionError:
            print(f"   Replacing DM Code {filename.name}... Error: Permission Denied! Ensure file is not open.")
            exit_handler()
        except:
            print(f"   Replacing DM Code {filename.name}... Error:")
            print(traceback.format_exc())
        try:
            #print("\nRenaming File... ", end="\r")
            if new_name[-4:].upper() != ".XML":
                new_name += ".XML"
            file.rename(file.with_name(new_name))
        except PermissionError:
            print(f"   Renaming File {filename.name}... Error: Permission Denied! Ensure file is not open.")
        except FileExistsError:
            print(f"   Renaming File {filename.name}... Error: File already exists!")
        except Exception as e:
            print(f"   Renaming File {filename.name}... Error: {e}")

#RANDOM FIXES
def other(working_dir, Modelic, CAGECode, PubNumber):
    #Update Quality Assurance Tag
    files = sorted(working_dir.glob('*.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        qualityassurance = re.sub(pattern_quality, '<qualityAssurance><firstVerification verificationType="tabtop"/></qualityAssurance>', text)
        brex = re.sub(pattern_brex, '<brexDmRef><dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00"\ndisassyCodeVariant="A" infoCode="022" infoCodeVariant="A"\nitemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0"\nsubSystemCode="0" systemCode="00" systemDiffCode="A"/></dmRefIdent></dmRef></brexDmRef>', qualityassurance)
        pmcode = re.sub('<pmCode modelIdentCode="(.+?)" pmIssuer="(.+?)" pmNumber="(.+?)"', f'<pmCode modelIdentCode="HON{Modelic}" pmIssuer="{CAGECode}" pmNumber="{PubNumber}"', brex)
        otherform = re.sub('"></dmCode>', '"/>', pmcode)
        otherform = re.sub(r'infoName\s*>', 'infoName>', otherform)
        otherform = re.sub('<title> ', '<title>', otherform)
        otherform = re.sub(' </title> ', '</title>', otherform)
        if "00W" in file.name:
            otherform = re.sub(pattern_condcrossref, '', otherform)
        file.write_text(otherform, encoding="utf-8")

#RENAME FUNCTION FOR ALL BOOKS BUT EIPCS
def renamingCMM(working_dir, Modelic, sysDiffCode, ATANumber, booktype):
    introrange = ['B','C','D','E','F','G','H','I','J','L','T','U','V','W','X','Y']
    introrange2 = ['A','K','M','N','O','P','Q','R','S']
    #VARIABLES USED FOR INCREMENTING DURING FILE RENAMING

    IT1 = "B"
    IT2 = 0
    T1 = "A"
    T2 = 0
    VCL1 = "B"
    VCL2 = 0
    TSG11 = "A"
    TSG12 = 0
    TSG41 = "A"
    TSG42 = 0
    TSG411 = "A"
    TSG421 = 0
    D1 = "A"
    D2 = 0
    SWG1 = 0
    SWG4 = 0
    SWG41 = 0
    DSG11 = "A"
    DSG12 = 0
    DSG41 = "A"
    DSG42 = 0
    DSG411 = "A"
    DSG421 = 0
    DS1 = "A"
    DS2 = 0
    SD1 = "A"
    SD2 = 0
    WD1 = "A"
    WD2 = 0
    SM1 = "A"
    SM2 = 0
    CL1 = "A"
    CL2 = 0
    CLG11 = "A"
    CLG12 = 0
    CLG41 = "A"
    CLG42 = 0
    CLG411 = "A"
    CLG421 = 0
    ICG11 = "A"
    ICG12 = 0
    ICG41 = "A"
    ICG42 = 0
    ICG411 = "A"
    ICG421 = 0
    IC1 = "A"
    IC2 = 0
    RPG11 = "A"
    RPG12 = 0
    RPG41 = "A"
    RPG42 = 0
    RPG411 = "A"
    RPG421 = 0
    RP1 = "A"
    RP2 = 0
    ASG11 = "A"
    ASG12 = 0
    ASG41 = "A"
    ASG42 = 0
    ASG411 = "A"
    ASG421 = 0
    AS1 = "A"
    AS2 = 0
    FC1 = "A"
    FC2 = 0
    ST1 = "A"
    ST2 = 0
    STR1 = "A"
    STR3 = 0
    STRG1 = 0
    STRG4 = 0
    STRG41 = 0
    SP1 = "A"
    RM1 = "A"
    RM2 = 0
    RMG11 = "A"
    RMG12 = 0
    RMG41 = "A"
    RMG42 = 0
    RMG411 = "A"
    RMG421 = 0
    AT1 = "A"
    AT2 = 0
    IST1 = "A"
    IST3 = 0
    ISTG11 = "A"
    ISTG12 = 0
    ISTG41 = "A"
    ISTG42 = 0
    ISTG411 = "A"
    ISTG431 = 0
    SVG1 = "A"
    SVG3 = 0
    SVGG1 = 0
    SVGG4 = 0
    SVGG41 = 0
    RW1 = "A"
    RW3 = 0
    MSCL1 = "A"
    MSCL3 = 0
    HM1 = "A"
    HM3 = 0
    IPL1 = 1
    RPO = "A"
    JSTSGD1 = "A"
    JSTSGD2 = 0
    JSTSG1 = "A"
    JSTSG2 = 0
    JSSWDD1 = "A"
    JSSWDD2 = 0
    JSSWD1 = "A"
    JSSWD2 = 0
    JSSWD11 = "A"
    JSSWD21 = 0
    JSDSD1 = "A"
    JSDSD2 = 0
    JSDS1 = "A"
    JSDS2 = 0
    JSCLD1 = "A"
    JSCLD2 = 0
    JSCL1 = "A"
    JSCL2 = 0
    JSICD1 = "A"
    JSICD2 = 0
    JSIC1 = "A"
    JSIC2 = 0
    JSRPD1 = "A"
    JSRPD2 = 0
    JSRP1 = "A"
    JSRP2 = 0
    JSASD1 = "A"
    JSASD2 = 0
    JSAS1 = "A"
    JSAS2 = 0
    JSRMD1 = "A"
    JSRMD2 = 0
    JSRM1 = "A"
    JSRM2 = 0
    JSITD1 = "A"
    JSITD2 = 0
    JSIT1 = "A"
    JSIT2 = 0
    #RENAMING FILES DEPENDING ON INFONAME, TECHNAME, TITLE AND PARA - ONE SECTION AT A TIME
    files = sorted(working_dir.glob('DMC*.XML'))
    print("\nFinalizing Files... \n")
    for file in files:
        text = file.read_text(encoding="utf-8")
        infoname = re.sub('\n', ' ', check_match(pattern_infoname.search(text)))
        techname = re.sub('\n', ' ', check_match(pattern_techname.search(text)))
        title = re.sub('\n', ' ', check_match(pattern_title.search(text)))
        para = re.sub('\n', ' ', check_match(pattern_para.search(text)))
        #filenamecount = file.name
        # if infoname == "" or techname == "" or title == "" or para == "":
        #     pass
        new_name = None
        #FRONT MATTER
        if (("Honeywell &ndash; Confidential".lower() in title.lower()) or ("Honeywell &ndash; Confidential".lower() in infoname.lower()) or ("Honeywell - Confidential".lower() in title.lower()) or ("Honeywell - Confidential".lower() in infoname.lower())) and  ("COPYRIGHT BY HONEYWELL INTERNATIONAL INC.".lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-023A-D" % sysDiffCode
        elif (("Honeywell &ndash; Confidential".lower() in title.lower()) or ("Honeywell &ndash; Confidential".lower() in infoname.lower()) or ("Honeywell - Confidential".lower() in title.lower()) or ("Honeywell - Confidential".lower() in infoname.lower())) and  ("COPYRIGHT BY HONEYWELL LIMITED.".lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-01A-023A-D" % sysDiffCode
        elif ("Honeywell Materials License Agreement".lower() in infoname.lower()) or ("Honeywell Materials License Agreement".lower() in techname.lower()) or ("Honeywell Materials License Agreement".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-010A-D" % sysDiffCode
        elif ("Safety Advisory".lower() in infoname.lower()) or ("Safety Advisory".lower() in techname.lower()) or ("Safety Advisory".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-012A-D" % sysDiffCode
        elif ("Warrant/Liability".lower() in infoname.lower()) or ("Warrant/Liability".lower() in techname.lower()) or ("Warrant/Liability".lower() in title.lower()) or ("Warranty/Liability".lower() in infoname.lower()) or ("Warranty/Liability".lower() in techname.lower()) or ("Warranty/Liability".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-012B-D" % sysDiffCode
        elif ("Copyright - Notice".lower() in infoname.lower()) or ("Copyright - Notice".lower() in techname.lower()) or ("Copyright - Notice".lower() in title.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-021A-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("Transmittal Information".lower() in infoname.lower()) or ("Transmittal Information".lower() in techname.lower()) or ("Transmittal Information".lower() in title.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-003A-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("Record of Revisions".lower() in infoname.lower()) or ("Record of Revisions".lower() in techname.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-003B-D" % sysDiffCode
        elif ("Record of Temporary Revisions".lower() in infoname.lower()) or ("Record of Temporary Revisions".lower() in techname.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-003C-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("SERVICE BULLETIN LIST".lower() in infoname.lower()) or ("SERVICE BULLETIN LIST".lower() in techname.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-008A-D" % (Modelic, sysDiffCode, ATANumber)
        #INTRODUCTION
        elif ("Introduction".lower() in infoname.lower()) or ("Introduction".lower() in techname.lower()):
            if ("This publication gives maintenance instructions".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018A-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Observance of Manual Instructions".lower() in title.lower()) :
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018A-D" % sysDiffCode
            elif (title.lower() == "Symbols".lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018B-D" % sysDiffCode
            elif ("Units of Measure".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018C-D" % sysDiffCode
            elif ("Torque Values".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018C-D" % sysDiffCode
            elif ("Page Number Block Explanation".lower() in title.lower()) :
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018D-D" % sysDiffCode
            elif ("Chapter/Section/Subject Explanation".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018D-D" % sysDiffCode
            elif ("Illustration".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018E-D" % sysDiffCode
            elif ("Application of Maintenance".lower() in title.lower()) or ("Application of Jet Engine Maintenance".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018F-D" % sysDiffCode
            elif ("Standard Practices Manual".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018G-D" % sysDiffCode
            elif ("Electrostatic Discharge".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018H-D" % sysDiffCode
            elif ("Honeywell Aerospace Online Technical Publications".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018I-D" % sysDiffCode
            elif ("Honeywell Aerospace Contact Team".lower() in title.lower()) or ("Global Customer Care Center".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018J-D" % sysDiffCode
            elif ("Honeywell/Vendor Publications".lower() in title.lower()) and (("The publication title".lower() in para.lower()) or ("Related Honeywell publications".lower() in para.lower()) or ("Honeywell publications related".lower() in para.lower())):
                new_name = "DMC-HON%s-%s-%s-00A-018K-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Honeywell/Vendor Publications".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018K-D" % sysDiffCode
            elif ("Other Publications".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018L-D" % sysDiffCode
            elif ("The component maintenance levels".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018M-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("The abbreviations are used in agreement".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018N-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Verification Data".lower() in title.lower()) and ("Honeywell".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018O-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Verification Data".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018O-D" % sysDiffCode
            elif ("Software Data".lower() in title.lower()) and ("The".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018P-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Software Data".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018P-D" % sysDiffCode
            elif ("Modification/Configuration History".lower() in title.lower()) and ("Refer".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018Q-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Modification/Configuration History".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018Q-D" % sysDiffCode
            elif ("Change History for Parts List".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018R-D" % sysDiffCode
            elif ("Change History for Parts List".lower() in title.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018R-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Applicable Service Information Documents".lower() in title.lower()) and ("Refer".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018S-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Applicable Service Information Documents".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018S-D" % sysDiffCode
            elif ("Gearbox repaired as necessary.".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-01A-018A-D" % (Modelic, sysDiffCode, ATANumber)
            #IRM SPECIFIC INTRO SECTIONS
            elif ("Publication Use".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018B-D" % sysDiffCode
            elif ("Standard Definitions".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018E-D" % sysDiffCode
            elif ("FPI".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018F-D" % sysDiffCode
            elif ("MPI".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018G-D" % sysDiffCode
            elif ("Bearing Check".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018H-D" % sysDiffCode
            elif ("Marking of Critical High Temperature Alloys".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018I-D" % sysDiffCode
            elif ("General Check".lower() in title.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-910A-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("ROTATING COMPONENTS".lower() in infoname.lower()) or ("ROTATING COMPONENTS".lower() in techname.lower()):
                    new_name = "DMC-HON%s-%s-%s-01A-018J-D" % (Modelic, sysDiffCode, ATANumber)
            else:
                if IT1 in introrange2:
                    IT1 = chr(ord(IT1)+1)
                    continue
                new_name = ("DMC-HON%s-%s-%s-%sA-018%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IT2, 2), IT1))
                if IT1 in introrange:
                    IT1 = chr(ord(IT1)+1)
                else:
                    IT1 = "A"
                    IT2 += 1
        #IPL
        elif ("ILLUSTRATED PARTS LIST".lower() in infoname.lower()) or ("ILLUSTRATED PARTS LIST".lower() in techname.lower()) or ("Introduction".lower() in infoname.lower()):
            if ("General".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018T-D" % sysDiffCode
            elif ("General".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018T-D" % sysDiffCode
            elif ("Job Setup Data".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018U-D" % sysDiffCode
            elif ("Job Setup Data".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018U-D" % sysDiffCode
            elif ("Vendor Code List".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018V-D" % sysDiffCode
            elif ("Vendor Code List".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018V-D" % sysDiffCode
            elif ("Equipment Designator Index".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018W-D" % sysDiffCode
            elif ("Equipment Designator Index".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018W-D" % sysDiffCode
            elif ("Numerical Index".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018X-D" % sysDiffCode
            elif ("Numerical Index".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018X-D" % sysDiffCode
            elif ("Detailed Parts List".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-018Y-D" % sysDiffCode
            elif ("Detailed Parts List".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018Y-D" % sysDiffCode
            elif ("The vendor codes and part numbers that are shown in the DPL".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-019A-D" % (Modelic, sysDiffCode, ATANumber)
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-019%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(VCL2, 2), VCL1))
                VCL1, VCL2 = infoCode_sysDiff(VCL1, VCL2)
        elif ("Vendor Code List".lower() in infoname.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-019A-D" % (Modelic, sysDiffCode, ATANumber)
        #DESCRIPTION AND OPERATION
        elif ("Description and Operation".lower() in infoname.lower()) or ("Technical data".lower() in infoname.lower()) or ("Description and Operation".lower() in techname.lower()) or ("Description".lower() in techname.lower()) or ("Description".lower() in infoname.lower()) or ("System Description".lower() in infoname.lower()) or ("Technical Data".lower() in infoname.lower()):
            new_name = ("DMC-HON%s-%s-%s-%sA-040%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(D2, 2), D1))
            D1, D2 = infoCode_sysDiff(D1, D2)
        #OPERATION
        elif (infoname.lower() == "Operation".lower()):
            new_name = ("DMC-HON%s-%s-%s-%sA-100%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(D2, 2), D1))
            D1, D2 = infoCode_sysDiff(D1, D2)   
        #TESTING AND FAULT ISOLATION
        elif ("TESTING AND FAULT ISOLATION".lower() in infoname.lower()) or ("TESTING AND FAULT ISOLATION".lower() in techname.lower()) or ("TESTING AND TROUBLE SHOOTING ".lower() in infoname.lower()) or ("FAULT ISOLATION".lower() in infoname.lower()) or ("TESTING".lower() in infoname.lower()) or ("AIRWORTHINESS LIMITATIONS".lower() in infoname.lower()) or ("TROUBLE SHOOTING".lower() in infoname.lower()) or ("TROUBLESHOOTING".lower() in infoname.lower()) or ("TESTING AND TROUBLESHOOTING".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use the test procedures in this section to test and isolate faults.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-400A-D" % (sysDiffCode, add_zeroes(TSG12, 2), TSG11))
                TSG12, TSG11 = sysDiff(TSG12, TSG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-400B-D" % (sysDiffCode, add_zeroes(JSTSGD2, 2), JSTSGD1))
                JSTSGD2, JSTSGD1 = sysDiff(JSTSGD2, JSTSGD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-400C-D" % (sysDiffCode, add_zeroes(JSTSG2, 2), JSTSG1))
                JSTSG2, JSTSG1 = sysDiff(JSTSG2, JSTSG1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-400D-D" % (sysDiffCode, add_zeroes(TSG42, 2), TSG41))
                TSG42, TSG41 = sysDiff(TSG42, TSG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-400F-D" % (sysDiffCode, add_zeroes(TSG421, 2), TSG411))
                TSG421, TSG411 = sysDiff(TSG421, TSG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-400E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-420%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(T2, 2), T1))
                T1, T2 = infoCode_sysDiff(T1, T2)
        #SCHEMATIC AND WIRING DIAGRAM
        elif ("SCHEMATIC AND WIRING DIAGRAMS".lower() in infoname.lower()) or ("SCHEMATIC AND WIRING DIAGRAMS".lower() in techname.lower()) or ("SCHEMATICS AND WIRING DIAGRAMS".lower() in infoname.lower())  or ("WIRING DATA".lower() in infoname.lower()) or ("SCHEMATICS AND WIRING DIAGRAMS".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower())and ("This section gives schematic and wiring diagrams for the LRU.".lower() in para.lower()):
                if SWG1 != 99:
                    new_name = ("DMC-HONAERO-%s-00-00-00-%sA-050A-D" % (sysDiffCode, add_zeroes(SWG1, 2)))
                    SWG1 += 1
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                if SWG4 != 99:
                    new_name = ("DMC-HONAERO-%s-00-00-00-%sA-050D-D" % (sysDiffCode, add_zeroes(SWG4, 2)))
                    SWG4 += 1
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-050B-D" % (sysDiffCode, add_zeroes(JSSWDD2, 2), JSSWDD1))
                JSSWDD2, JSSWDD1 = sysDiff(JSSWDD2, JSSWDD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-050C-D" % (sysDiffCode, add_zeroes(JSSWD21, 2), JSSWD11))
                JSSWD21, JSSWD11 = sysDiff(JSSWD21, JSSWD11)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                if SWG41 != 99:
                    new_name = ("DMC-HONAERO-%s-00-00-00-%sA-050F-D" % (sysDiffCode, add_zeroes(SWG41, 2)))
                    SWG41 += 1
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-050E-D" % sysDiffCode
            elif ("Schematic Diagrams".lower() in title.lower()) or ("Interconnect Diagram".lower() in title.lower()):
                new_name = ("DMC-HON%s-%s-%s-%sA-051%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(SD2, 2), SD1))
                SD1, SD2 = infoCode_sysDiff(SD1, SD2)
            elif ("Wiring Diagram".lower() in title.lower()) or ("Wire Lists".lower() in title.lower()):
                new_name = ("DMC-HON%s-%s-%s-%sA-054%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(WD2, 2), WD1))
                WD1, WD2 = infoCode_sysDiff(WD1, WD2)
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-050%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(SM2, 2), SM1))
                SM1, SM2 = infoCode_sysDiff(SM1, SM2)
        #DISASSEMBLY
        elif ("Disassembly".lower() in infoname.lower()) or ("Disassembly".lower() in techname.lower()) or  ("Disconnect, remove and disassemble procedures".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these procedures to remove parts from the LRU".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-500A-D" % (sysDiffCode, add_zeroes(DSG12, 2), DSG11))
                DSG12, DSG11 = sysDiff(DSG12, DSG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-500B-D" % (sysDiffCode, add_zeroes(JSDSD2, 2), JSDSD1))
                JSDSD2, JSDSD1 = sysDiff(JSDSD2, JSDSD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-500C-D" % (sysDiffCode, add_zeroes(JSDS2, 2), JSDS1))
                JSDS2, JSDS1 = sysDiff(JSDS2, JSDS1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-500D-D" % (sysDiffCode, add_zeroes(DSG42, 2), DSG41))
                DSG42, DSG41 = sysDiff(DSG42, DSG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-500F-D" % (sysDiffCode, add_zeroes(DSG421, 2), DSG411))
                DSG421, DSG411 = sysDiff(DSG421, DSG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-500E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-500%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(DS2, 2), DS1))
                DS1, DS2 = infoCode_sysDiff(DS1, DS2)
                
        #CLEANING
        elif ("CLEANING".lower() in infoname.lower()) or ("CLEANING".lower() in techname.lower()) or ("CLEANING/PAINTING".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower())and ("Use these procedures to remove dust, dirt, and unwanted oil and grease".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-250A-D" % (sysDiffCode, add_zeroes(CLG12, 2), CLG11))
                CLG12, CLG11 = sysDiff(CLG12, CLG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-250B-D" % (sysDiffCode, add_zeroes(JSCLD2, 2), JSCLD1))
                JSCLD2, JSCLD1 = sysDiff(JSCLD2, JSCLD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-250C-D" % (sysDiffCode, add_zeroes(JSCL2, 2), JSCL1))
                JSCL2, JSCL1 = sysDiff(JSCL2, JSCL1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-250D-D" % (sysDiffCode, add_zeroes(CLG42, 2), CLG41))
                CLG42, CLG41 = sysDiff(CLG42, CLG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-250F-D" % (sysDiffCode, add_zeroes(CLG421, 2), CLG411))
                CLG421, CLG411 = sysDiff(CLG421, CLG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-250E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-250%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(CL2, 2), CL1))
                CL1, CL2 = infoCode_sysDiff(CL1, CL2)

        #INSPECTION/CHECK
        elif ("INSPECTION/CHECK".lower() in infoname.lower()) or ("INSPECTION/CHECK".lower() in techname.lower()) or ("CHECK".lower() in infoname.lower()) or ("OPERATIONAL CHECKOUT".lower() in infoname.lower()) or ("CHECK".lower() in techname.lower()) or ("INSPECTION".lower() in techname.lower()) or ("INSPECTION".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these procedures to find damage or worn parts and parts that show signs of near failure".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-300A-D" % (sysDiffCode, add_zeroes(ICG12, 2), ICG11))
                ICG12, ICG11 = sysDiff(ICG12, ICG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-300B-D" % (sysDiffCode, add_zeroes(JSICD2, 2), JSICD1))
                JSICD2, JSICD1 = sysDiff(JSICD2, JSICD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-300C-D" % (sysDiffCode, add_zeroes(JSIC2, 2), JSIC1))
                JSIC2, JSIC1 = sysDiff(JSIC2, JSIC1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-300D-D" % (sysDiffCode, add_zeroes(ICG42, 2), ICG41))
                ICG42, ICG41 = sysDiff(ICG42, ICG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not Applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-300F-D" % (sysDiffCode, add_zeroes(ICG421, 2), ICG411))
                ICG421, ICG411 = sysDiff(ICG421, ICG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-300E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-300%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IC2, 2), IC1))
                IC1, IC2 = infoCode_sysDiff(IC1, IC2)
                
        #REPAIR
        elif ("REPAIR".lower() in infoname.lower()) or ("REPAIR".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these procedures for the LRU to replace defective parts".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-600A-D" % (sysDiffCode, add_zeroes(RPG12, 2), RPG11))
                RPG12, RPG11 = sysDiff(RPG12, RPG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-600B-D" % (sysDiffCode, add_zeroes(JSRPD2, 2), JSRPD1))
                JSRPD2, JSRPD1 = sysDiff(JSRPD2, JSRPD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-600C-D" % (sysDiffCode, add_zeroes(JSRP2, 2), JSRP1))
                JSRP2, JSRP1 = sysDiff(JSRP2, JSRP1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-600D-D" % (sysDiffCode, add_zeroes(RPG42, 2), RPG41))
                RPG42, RPG41 = sysDiff(RPG42, RPG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-600F-D" % (sysDiffCode, add_zeroes(RPG421, 2), RPG411))
                RPG421, RPG411 = sysDiff(RPG421, RPG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-600E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-600%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(RP2, 2), RP1))
                RP1, RP2 = infoCode_sysDiff(RP1, RP2)
                
        # ASSEMBLY
        elif (infoname.lower() == "ASSEMBLY".lower()) or (techname.lower() == "ASSEMBLY".lower()) or (infoname.lower() == "ASSEMBLY (WITH STORAGE)".lower()) or (techname.lower() == "ASSEMBLY (WITH STORAGE)".lower()) or (infoname.lower() == "Assemble, install and connect procedures".lower()) or (infoname.lower() == "ASSEMBLY 001".lower()) or (infoname.lower() == "ASSEMBLY 002".lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these procedures to assemble the LRU.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-700A-D" % (sysDiffCode, add_zeroes(ASG12, 2), ASG11))
                ASG12, ASG11 = sysDiff(ASG12, ASG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-700B-D" % (sysDiffCode, add_zeroes(JSASD2, 2), JSASD1))
                JSASD2, JSASD1 = sysDiff(JSASD2, JSASD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-700C-D" % (sysDiffCode, add_zeroes(JSAS2, 2), JSAS1))
                JSAS2, JSAS1 = sysDiff(JSAS2, JSAS1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-700D-D" % (sysDiffCode, add_zeroes(ASG42, 2), ASG41))
                ASG42, ASG41 = sysDiff(ASG42, ASG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not Applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-700F-D" % (sysDiffCode, add_zeroes(ASG421, 2), ASG411))
                ASG421, ASG411 = sysDiff(ASG421, ASG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-700E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-700%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(AS2, 2), AS1))
                AS1, AS2 = infoCode_sysDiff(AS1, AS2)
                
        #FITS AND CLEARANCES
        elif ("FITS AND CLEARANCES".lower() in infoname.lower()) or ("FITS AND CLEARANCES".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("This section gives the fits and clearances used when the LRU".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711A-D" % sysDiffCode
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711D-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711F-D" % sysDiffCode
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-711E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-711%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(FC2, 2), FC1))
                FC1, FC2 = infoCode_sysDiff(FC1, FC2)
                
        #SPECIAL TOOLS, FIXTURES, EQUIPMENT, AND CONSUMABLES
        elif ("SPECIAL TOOLS, FIXTURES".lower() in infoname.lower()) or ("SPECIAL TOOLS AND FIXTURES".lower() in infoname.lower()) or ("SPECIAL TOOLS, FIXTURES".lower() in techname.lower()) or ("SPECIAL TOOLS FIXTURES EQUIPMENT AND CONSUMABLES".lower() in infoname.lower()) or ("SPECIAL TOOLS FIXTURES EQUIPMENT AND CONSUMABLES".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("This section gives the special tools, fixtures, equipment, and consumable materials that you can use for LRU maintenance.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900A-D" % sysDiffCode
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900D-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900F-D" % sysDiffCode
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-900E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-900%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(ST2, 2), ST1))
                ST1, ST2 = infoCode_sysDiff(ST1, ST2)
                
        #SPECIAL PROCEDURES
        elif ("SPECIAL PROCEDURES".lower() in infoname.lower()) or ("SPECIAL PROCEDURES".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these special procedures to do additional maintenance that is not covered in any".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900A-D" % sysDiffCode
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900D-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900F-D" % sysDiffCode
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-01A-900E-D" % sysDiffCode
            else:
                if SP1 != "Z":
                    new_name = ("DMC-HON%s-%s-%s-01A-900%s-D" % (Modelic, sysDiffCode, ATANumber, SP1))
                    SP1 = chr(ord(SP1)+1)
        #REMOVAL
        elif ("REMOVAL".lower() in infoname.lower()) or ("REMOVAL".lower() in techname.lower()) or ("REMOVAL/INSTALLATION".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower())and ("Use these procedures for removal of a module, portion of a module, or component from a fully assembled off-the-wing engine.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-520A-D" % (sysDiffCode, add_zeroes(RMG12, 2), RMG11))
                RMG12, RMG11 = sysDiff(RMG12, RMG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-520B-D" % (sysDiffCode, add_zeroes(JSRMD2, 2), JSRMD1))
                JSRMD2, JSRMD1 = sysDiff(JSRMD2, JSRMD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-520C-D" % (sysDiffCode, add_zeroes(JSRM2, 2), JSRM1))
                JSRM2, JSRM1 = sysDiff(JSRM2, JSRM1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-520D-D" % (sysDiffCode, add_zeroes(RMG42, 2), RMG41))
                RMG42, RMG41 = sysDiff(RMG42, RMG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-520F-D" % (sysDiffCode, add_zeroes(RMG421, 2), RMG411))
                RMG421, RMG411 = sysDiff(RMG421, RMG411)
            elif ("Not Applicable".lower() in title.lower()):
                    new_name = "DMC-HONAERO-%s-00-00-00-00A-520E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-520%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(RM2, 2), RM1))
                RM1, RM2 = infoCode_sysDiff(RM1, RM2)   
        #ADJUSTMENT/TEST
        elif ("ADJUSTMENT/TEST".lower() in infoname.lower()) or ("ADJUSTMENT/TEST".lower() in techname.lower()) or ("TEST".lower() in infoname.lower()) or ("examination".lower() in infoname.lower()):
            new_name = ("DMC-HON%s-%s-%s-%sA-320%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(AT2, 2), AT1))
            AT1, AT2 = infoCode_sysDiff(AT1, AT2)
        #INSTALLATION
        elif ("INSTALLATION".lower() in infoname.lower()) or ("INSTALLATION".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower())and ("Use these procedures to install a module, portion of a module, or component on an off-the-wing engine.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-720A-D" % (sysDiffCode, add_zeroes(ISTG12, 2), ISTG11))
                ISTG12, ISTG11 = sysDiff(ISTG12, ISTG11)
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-720B-D" % (sysDiffCode, add_zeroes(JSITD2, 2), JSITD1))
                JSITD2, JSITD1 = sysDiff(JSITD2, JSITD1)
            elif (title.lower() == "Job Setup".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-720C-D" % (sysDiffCode, add_zeroes(JSIT2, 2), JSIT1))
                JSIT2, JSIT1 = sysDiff(JSIT2, JSIT1)
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-720D-D" % (sysDiffCode, add_zeroes(ISTG42, 2), ISTG41))
                ISTG42, ISTG41 = sysDiff(ISTG42, ISTG41)
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%s%s-720F-D" % (sysDiffCode, add_zeroes(ISTG431, 2), ISTG411))
                ISTG431, ISTG411 = sysDiff(ISTG431, ISTG411)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-720E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-720%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IST3, 2), IST1))
                IST1, IST3 = infoCode_sysDiff(IST1, IST3)
        #SERVICING
        elif ("SERVICING".lower() in infoname.lower()) or ("SERVICING".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower())  and ("Use these procedures to do the oil servicing.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-200A-D" % (sysDiffCode, add_zeroes(SVGG1, 2)))
                SVGG1 += 1
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-200B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-200C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-200D-D" % (sysDiffCode, add_zeroes(SVGG4, 2)))
                SVGG4 += 1
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-200F-D" % (sysDiffCode, add_zeroes(SVGG41, 2)))
                SVGG41 += 1
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-200E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-200%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(SVG3, 2), SVG1))
                SVG1, SVG3 = infoCode_sysDiff(SVG1, SVG3)
                
        #STORAGE (INCLUDING TRANSPORTATION)
        elif ("STORAGE (INCLUDING TRANSPORTATION)".lower() in infoname.lower()) or ("Package".lower() in infoname.lower()) or ("Preservation".lower() in infoname.lower()) or ("STORAGE (INCLUDING TRANSPORTATION)".lower() in techname.lower()) or ("STORAGE".lower() in infoname.lower()) or  ("HANDLING".lower() in infoname.lower()) or ("SHIPPING".lower() in infoname.lower()) or ("PACKING AND SHIPPING".lower() in infoname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use these procedures to prepare the LRU for storage or transportation.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-800A-D" % (sysDiffCode, add_zeroes(STRG1, 2)))
                STRG1 += 1
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-800B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-800C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-800D-D" % (sysDiffCode, add_zeroes(STRG4, 2)))
                STRG4 += 1
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = ("DMC-HONAERO-%s-00-00-00-%sA-800F-D" % (sysDiffCode, add_zeroes(STRG41, 2)))
                STRG41 += 1
            elif ("Package".lower() in title.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-830A-D" % (Modelic, sysDiffCode, ATANumber)
            elif (title.lower() == "Storage".lower()):
                new_name = "DMC-HON%s-%s-%s-00A-850A-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Transportation".lower() in title.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-860A-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-800E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-800%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(STR3, 2), STR1))
                STR1, STR3 = infoCode_sysDiff(STR1, STR3)
        #REWORK
        elif ("REWORK".lower() in infoname.lower()) or ("REWORK".lower() in techname.lower()):
            if ("Reason for the Job".lower() in title.lower()) and ("Use the instructions in this section to modify the unit as needed".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664A-D" % sysDiffCode
            elif (title.lower() == "Job Setup Data".lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664B-D" % sysDiffCode
            elif (title.lower() == "Job Setup".lower())  and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664C-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Remove all tools, equipment, used parts, and materials from the work area.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664D-D" % sysDiffCode
            elif ("Job Close-up".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664F-D" % sysDiffCode
            elif ("Not Applicable".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-664E-D" % sysDiffCode
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-664%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(RW3, 2), RW1))
                RW1, RW3 = infoCode_sysDiff(RW1, RW3)
        #MISCELLANEOUS
        elif ("STANDARD PRACTICES".lower() in techname.lower()) or ("STANDARD PRACTICES".lower() in infoname.lower()) or ("APPENDIX".lower() in techname.lower()) or ("APPENDIX".lower() in infoname.lower()) or ("PERFORMANCE SPECIFICATIONS".lower() in infoname.lower()) or ("MISCELLANEOUS".lower() in infoname.lower()) or ("TRAY ALIGNMENT PROCEDURES".lower() in infoname.lower()) or ("REQUIREMENTS".lower() in infoname.lower()) :
            new_name = ("DMC-HON%s-%s-%s-%sA-910%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(MSCL3, 2), MSCL1))
            MSCL1, MSCL3 = infoCode_sysDiff(MSCL1, MSCL3)
        #HEAVY MAINTENANCE OR MAINTENANCE PRACTICES
        elif ("MAINTENANCE PRACTICES".lower() in infoname.lower()) or ("MAINTENANCE PRACTICES".lower() in techname.lower()) or ("HEAVY MAINTENANCE".lower() in infoname.lower()) or ("HEAVY MAINTENANCE".lower() in techname.lower()):
            new_name = ("DMC-HON%s-%s-%s-%sA-913%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(HM3, 2), HM1))
            HM1, HM3 = infoCode_sysDiff(HM1, HM3)
        #REPOSITORIES
        elif (infoname.lower() == "Warning repository".lower()) or (techname.lower() == "Warning repository".lower()) or (infoname.lower() == "Warnings CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012A-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Caution repository".lower()) or (techname.lower() == "Caution repository".lower()) or (infoname.lower() == "Cautions CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012B-D" % (booktype, ATANumber)
        elif (infoname.lower() == "General warnings and cautions and related safety data".lower()) or (techname.lower() == "General warnings and cautions and related safety data".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012%s-D" % (booktype, ATANumber, RPO)
            RPO = ''.join(chr(ord(letter)+1) for letter in RPO)
        elif (infoname.lower() == "Support equipment common information repository".lower()) or (techname.lower() == "Support equipment common information repository".lower()) or (infoname.lower() == "Support Equipment CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00NA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Organizations common information repository".lower()) or (techname.lower() == "Organizations common information repository".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00KA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Supplies - List of products common information repository".lower()) or (techname.lower() == "Supplies - List of products common information repository".lower()) or (infoname.lower() == "Supplies CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00LA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Applicability Cross-reference Table (ACT)".lower()) or (techname.lower() == "Applicability Cross-reference Table (ACT)".lower()):
            new_name = "DMC-HON%s-%s-%s-00A-00WA-D" % (Modelic, sysDiffCode, ATANumber)
        elif (infoname.lower() == "Product Cross-reference Table (PCT)".lower()) or (techname.lower() == "Product Cross-reference Table (PCT)".lower()):
            new_name = "DMC-HON%s-%s-%s-00A-00PA-D" % (Modelic, sysDiffCode, ATANumber)
        #IPL
        elif (infoname.lower() == "IPL".lower()) or (techname.lower() == "IPL".lower()):
            new_name = ("DMC-HON%s-%s-%s-%sA-941A-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IPL1, 2)))
            if IPL1 != 99:
                IPL1 += 1
 
        if new_name is not None:
            DM_Rename(working_dir, new_name, file)

# RE-RENAMING 018E DEPENDING ON DMREFS INSIDE MODULE
def illustrationINTRO(working_dir, Modelic, sysDiffCode, ATANumber):
    files = sorted(working_dir.glob('DMC-HONAERO-*-00-00-00-00A-018E-D.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        para = re.sub('\n', ' ', check_match(pattern_para.search(text)))
        if para == "":
            continue

        #ALL APPLICABLE AUTHORITY NAME
        if ('Some of the exploded view illustrations shown in the <dmRef authorityName="ILLUSTRATED PARTS LIST"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef authorityName="DISASSEMBLY"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef authorityName="CLEANING"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef authorityName="INSPECTION/CHECK"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef authorityName="REPAIR"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef authorityName="ASSEMBLY"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef authorityName="FITS AND CLEARANCES"><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-018E-D" % sysDiffCode
        #ALL APPLICABLE
        elif ('Some of the exploded view illustrations shown in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-018E-D" % sysDiffCode
        #IPL, DISASSY AND ASSY NOT APPLICABLE
        elif ('Some of the exploded view illustrations shown in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="01" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-02A-018E-D" % sysDiffCode
        #FITS AND CLEARANCES NOT APPLICABLE
        elif ('Some of the exploded view illustrations shown in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-03A-018E-D" % sysDiffCode
        #IPL, DISASSY, ASSY, FITS AND CLEARANCES NOT APPLICABLE
        elif ('Some of the exploded view illustrations shown in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="01" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="A" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-04A-018E-D" % sysDiffCode
        #ALL NOT APPLICABLE
        elif ('Some of the exploded view illustrations shown in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="01" disassyCodeVariant="A" infoCode="018" infoCodeVariant="T" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> section are also referenced in the <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="500" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="250" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="300" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="600" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="700" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef>, and/or <dmRef><dmRefIdent><dmCode assyCode="00" disassyCode="00" disassyCodeVariant="A" infoCode="711" infoCodeVariant="E" itemLocationCode="D" modelIdentCode="HONAERO" subSubSystemCode="0" subSystemCode="0" systemCode="00" systemDiffCode="EAA"/></dmRefIdent></dmRef> sections of this manual'.lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-05A-018E-D" % sysDiffCode
        else:
            new_name = "DMC-HON%s-%s-%s-01A-018E-D" % (Modelic, sysDiffCode, ATANumber)
        
        DM_Rename(working_dir, new_name, file)

# RENAMING EIPCS
def renamingEIPC(working_dir, Modelic, sysDiffCode, ATANumber, booktype):
    IT1 = "B"
    IT2 = 0
    IPL1 = 1
    DSC = "A"
    RPO = "A"

    print("\nFinalizing EIPC Files... \n")
    for file in working_dir.glob('DMC*.XML'):
        text = file.read_text(encoding="utf-8")
        namefile = file.name
        dic = namefile.split("-")
        infoname = re.sub('\n', ' ', check_match(pattern_infoname.search(text)))
        techname = re.sub('\n', ' ', check_match(pattern_techname.search(text)))
        title = re.sub('\n', ' ', check_match(pattern_title.search(text)))
        para = re.sub('\n', ' ', check_match(pattern_para.search(text)))
        new_name = None
        #FRONT MATTER
        if (("Honeywell &ndash; Confidential".lower() in title.lower()) or ("Honeywell &ndash; Confidential".lower() in infoname.lower()) or ("Honeywell – Confidential".lower() in infoname.lower()) or ("Honeywell - Confidential".lower() in title.lower()) or ("Honeywell - Confidential".lower() in infoname.lower())) and  ("COPYRIGHT BY HONEYWELL INTERNATIONAL INC.".lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-023A-D" % sysDiffCode
        elif (("Honeywell &ndash; Confidential".lower() in title.lower()) or ("Honeywell &ndash; Confidential".lower() in infoname.lower()) or ("Honeywell - Confidential".lower() in title.lower()) or ("Honeywell - Confidential".lower() in infoname.lower())) and  ("COPYRIGHT BY HONEYWELL LIMITED.".lower() in para.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-01A-023A-D" % sysDiffCode
        elif ("Honeywell Materials License Agreement".lower() in infoname.lower()) or ("Honeywell Materials License Agreement".lower() in techname.lower()) or ("Honeywell Materials License Agreement".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-010A-D" % sysDiffCode
        elif ("Safety Advisory".lower() in infoname.lower()) or ("Safety Advisory".lower() in techname.lower()) or ("Safety Advisory".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-012A-D" % sysDiffCode
        elif ("Warrant/Liability".lower() in infoname.lower()) or ("Warrant/Liability".lower() in techname.lower()) or ("Warrant/Liability".lower() in title.lower()) or ("Warranty/Liability".lower() in infoname.lower()) or ("Warranty/Liability".lower() in techname.lower()) or ("Warranty/Liability".lower() in title.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-012B-D" % sysDiffCode
        elif ("Copyright - Notice".lower() in infoname.lower()) or ("Copyright - Notice".lower() in techname.lower()) or ("Copyright - Notice".lower() in title.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-021A-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("Transmittal Information".lower() in infoname.lower()) or ("Transmittal Information".lower() in techname.lower()) or ("Transmittal Information".lower() in title.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-003A-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("Record of Revisions".lower() in infoname.lower()) or ("Record of Revisions".lower() in techname.lower()):
            new_name = "DMC-HONAERO-%s-00-00-00-00A-003B-D" % sysDiffCode
        elif ("Record of Temporary Revisions".lower() in infoname.lower()) or ("Record of Temporary Revisions".lower() in techname.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-003C-D" % (Modelic, sysDiffCode, ATANumber)
        elif ("SERVICE BULLETIN LIST".lower() in infoname.lower()) or ("SERVICE BULLETIN LIST".lower() in techname.lower()):
            new_name = "DMC-HON%s-%s-%s-00A-008A-D" % (Modelic, sysDiffCode, ATANumber)
        #INTRODUCTION
        elif ("Introduction".lower() in infoname.lower()) or ("Introduction".lower() in techname.lower()) or ("ILLUSTRATED PARTS LIST".lower() in infoname.lower()) :
            if ("This publication gives maintenance instructions".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018A-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Observance of Manual Instructions".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018A-D" % sysDiffCode
            elif (title.lower() == "Symbols".lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018B-D" % sysDiffCode
            elif ("Units of Measure".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018C-D" % sysDiffCode
            elif ("Page Number Block Explanation".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018D-D" % sysDiffCode
            elif ("Illustration".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018E-D" % sysDiffCode
            elif ("Application of Maintenance".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018F-D" % sysDiffCode
            elif ("Standard Practices Manual".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018G-D" % sysDiffCode
            elif ("Electrostatic Discharge".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018H-D" % sysDiffCode
            elif ("Honeywell Aerospace Online Technical Publications".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018I-D" % sysDiffCode
            elif ("Honeywell Aerospace Contact Team".lower() in title.lower()) or ("Global Customer Care Center".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018J-D" % sysDiffCode
            elif ("Honeywell/Vendor Publications".lower() in title.lower()) and ("The publication title".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018K-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Honeywell/Vendor Publications".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018K-D" % sysDiffCode
            elif ("Other Publications".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018L-D" % sysDiffCode
            elif ("The component maintenance levels".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018M-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("The abbreviations are used in agreement".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018N-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Verification Data".lower() in title.lower()) and ("Honeywell".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018O-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Verification Data".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018O-D" % sysDiffCode
            elif ("Software Data".lower() in title.lower()) and ("The".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018P-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Software Data".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018P-D" % sysDiffCode
            elif ("Modification/Configuration History".lower() in title.lower()) and ("Refer".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018Q-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Modification/Configuration History".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018Q-D" % sysDiffCode
            elif ("Change History for Parts List".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018R-D" % sysDiffCode
            elif ("Change History for Parts List".lower() in title.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018R-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Applicable Service Information Documents".lower() in title.lower()) and ("Refer".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-018S-D" % (Modelic, sysDiffCode, ATANumber)
            elif ("Applicable Service Information Documents".lower() in title.lower()) and ("Not applicable".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018S-D" % sysDiffCode
            elif ("This publication gives the parts for the equipment shown on the Title page.".lower() in para.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018T-D" % sysDiffCode
            elif ("Job Setup Data".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018U-D" % sysDiffCode
            elif ("Vendor Code List".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018V-D" % sysDiffCode
            elif ("Equipment Designator Index".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018W-D" % sysDiffCode
            elif ("Numerical Index".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018X-D" % sysDiffCode
            elif ("Detailed Parts List".lower() in title.lower()):
                new_name = "DMC-HONAERO-%s-00-00-00-00A-018Y-D" % sysDiffCode
            elif ("Vendor codes, preceded by the capital letter V,".lower() in para.lower()):
                new_name = "DMC-HON%s-%s-%s-00A-019A-D" % (Modelic, sysDiffCode, ATANumber)
            else:
                new_name = ("DMC-HON%s-%s-%s-%sA-018%s-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IT2, 2), IT1))
                IT1, IT2  = infoCode_sysDiff(IT1, IT2)
        #REPOSITORIES
        elif (infoname.lower() == "Warning repository".lower()) or (techname.lower() == "Warning repository".lower()) or (infoname.lower() == "Warnings CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012A-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Caution repository".lower()) or (techname.lower() == "Caution repository".lower()) or (infoname.lower() == "Cautions CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012B-D" % (booktype, ATANumber)
        elif (infoname.lower() == "General warnings and cautions and related safety data".lower()) or (techname.lower() == "General warnings and cautions and related safety data".lower()):
            new_name = "DMC-HON%s-A-%s-00A-012%s-D" % (booktype, ATANumber, RPO)
            RPO = chr(ord(RPO)+1)
        elif (infoname.lower() == "Support equipment common information repository".lower()) or (techname.lower() == "Support equipment common information repository".lower()) or (infoname.lower() == "Support Equipment CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00NA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Organizations common information repository".lower()) or (techname.lower() == "Organizations common information repository".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00KA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Supplies - List of products common information repository".lower()) or (techname.lower() == "Supplies - List of products common information repository".lower()) or (infoname.lower() == "Supplies CIR".lower()):
            new_name = "DMC-HON%s-A-%s-00A-00LA-D" % (booktype, ATANumber)
        elif (infoname.lower() == "Applicability Cross-reference Table (ACT)".lower()) or (techname.lower() == "Applicability Cross-reference Table (ACT)".lower()):
            new_name = "DMC-HON%s-%s-%s-00A-00WA-D" % (Modelic, sysDiffCode, ATANumber)
        elif (infoname.lower() == "Product Cross-reference Table (PCT)".lower()) or (techname.lower() == "Product Cross-reference Table (PCT)".lower()):
            new_name = "DMC-HON%s-%s-%s-00A-00PA-D" % (Modelic, sysDiffCode, ATANumber)
        elif (infoname.lower() == "IPL".lower()) or ("ENGINE".lower()) in infoname.lower():
            new_name = ("DMC-HON%s-%s-%s-%s%s-941A-D" % (Modelic, sysDiffCode, ATANumber, add_zeroes(IPL1, 2), DSC))
            IPL1, DSC = sysDiff(IPL1, DSC)

        if new_name is not None:
            DM_Rename(working_dir, new_name, file)

def genericModules(working_dir):
    #UPDATE GENERIC DATA MODULES - COMMENTED OUT UNTIL MODULES ARE FULLY UPDATED
    # #HONEYWELL CONFIDENTIAL
    # print("\n\nUpdating Generic Data Modules...\n")
    # files = sorted(Path('//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion/513005 - Generic Data Modules/1. Proprietary Information').glob('DMC*.XML'))
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # confidential = re.sub('/n', ' ', check_match(pattern_content.search(text)))
    # files = sorted(Path('.').glob('DMC*023A-D.XML'))
    # if(len(files) == 0):
        # print("No Honeywell Confidential File Found.\n")
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # template = re.sub(pattern_content, "<content>%s</content>" % confidential, text)
        # changes = True
        # if (changes):
            # file.write_text(template, encoding="utf-8")
            # print("   Honeywell Confidential Updated!\n")
    # #LICENSE AGREEMENT
    # files = sorted(Path('//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion/513005 - Generic Data Modules/1. Proprietary Information').glob('(License Agreement)*.XML'))
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # licenseAgreement = re.sub('/n', ' ', check_match(pattern_content.search(text)))
    # files = sorted(Path('.').glob('DMC*010A-D.XML'))
    # if(len(files) == 0):
        # print("No License Agreement File Found.\n")
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # template = re.sub(pattern_content, "<content>%s</content>" % licenseAgreement, text)
        # changes = True
        # if (changes):
            # file.write_text(template, encoding="utf-8")
            # print("   License Agreement Updated!\n")
    # #SAFETY ADVISORY
    # files = sorted(Path('//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion/513005 - Generic Data Modules/1. Proprietary Information').glob('(Safety Advisory)*.XML'))
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # safetyadvisory = re.sub('/n', ' ', check_match(pattern_content.search(text)))
    # files = sorted(Path('.').glob('DMC-HONAERO-*-00-00-00-00A-012A-D.XML'))
    # if(len(files) == 0):
        # print("No Safety Advisory File Found.\n")
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # template = re.sub(pattern_content, "<content>%s</content>" % safetyadvisory, text)
        # changes = True
        # if (changes):
            # file.write_text(template, encoding="utf-8")
            # print("   Safety Advisory Updated!\n")
    # #WARRANTY/LIABILITY
    # files = sorted(Path('//172.16.15.22/Data/WORK/Honeywell/513 - Honeywell Other Sites/513005 - Conversion/513005 - Generic Data Modules/1. Proprietary Information').glob('(Warranty & Liability)*.XML'))
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # warrliab = re.sub('/n', ' ', check_match(pattern_content.search(text)))
    # files = sorted(Path('.').glob('DMC-HONAERO-*-00-00-00-00A-012B-D.XML'))
    # if(len(files) == 0):
        # print("No Warranty & Liability File Found.\n")
    # for file in files:
        # text = file.read_text(encoding="utf-8")
        # template = re.sub(pattern_content, "<content>%s</content>" % warrliab, text)
        # changes = True
        # if (changes):
            # file.write_text(template, encoding="utf-8")
            # print("   Warranty & Liability Updated!\n")
    files = sorted(working_dir.glob('*.XML'))
    for file in files:
        text = file.read_text(encoding="utf-8")
        otherform = re.sub('\(\n<dmRef', '(<dmRef', text)
        file.write_text(otherform, encoding="utf-8")

# CHANGE PROCEDURAL TO DESCRIPTIVE
def Procedural_To_Descript(text, filename, log_path):
    if "00L" in filename or "00N" in filename:
        return text

    if 'infoCode="00L"' in text or 'infoCode="00N"' in text:
        log_print("\n   WARNING: %s has references to tools/consumables repository. Could not be changed to a descriptive module." % filename, log_path)
    else:
        procdes = re.sub('/proced.xsd', '/descript.xsd', text)
        descrproc = re.sub('mainProcedure>', 'description>', procdes)
        descrproc = re.sub('<proceduralStep', '<levelledPara', descrproc)
        descrproc = re.sub('/proceduralStep>', '/levelledPara>', descrproc)
        descrproc = re.sub('</?procedure>', '', descrproc)
        relimrq = re.sub(pattern_relimrq, '', descrproc)
        text = re.sub(pattern_closerq, '', relimrq)

    return text

# CHANGE DESCRIPTIVE TO PROCEDURAL
def Descript_To_Procedural(text):
    procdes = re.sub('/descript.xsd', '/proced.xsd', text)
    descrproc = re.sub('<description(.*?)>', '<description>', procdes)
    descrproc = re.sub('<description>', '<procedure><preliminaryRqmts><reqCondGroup><noConds/></reqCondGroup>\n<reqSupportEquips><noSupportEquips/></reqSupportEquips>\n<reqSupplies><noSupplies/></reqSupplies>\n<reqSpares><noSpares/></reqSpares>\n<reqSafety><noSafety/></reqSafety>\n</preliminaryRqmts><mainProcedure>', descrproc)
    descrproc = re.sub('</description>', '</mainProcedure><closeRqmts>\n<reqCondGroup>\n<noConds/></reqCondGroup>\n</closeRqmts></procedure>', descrproc)
    descrproc = re.sub('<levelledPara', '<proceduralStep', descrproc)
    descrproc = re.sub('/levelledPara>', '/proceduralStep>', descrproc)
    descrproc = re.sub('<mainProcedure>\n?<para>', '<mainProcedure><proceduralStep><para>', descrproc)
    descrproc = re.sub('<mainProcedure>\n?<para>', '<mainProcedure><proceduralStep><para>', descrproc)
    descrproc = re.sub('</para>\n?</mainProcedure>', '</para></proceduralStep></mainProcedure>', descrproc)
    text = re.sub('<closeRqmts>\n?<reqCondGroup>\n?<noConds/>\n?</reqCondGroup>\n?</closeRqmts>\n?</mainProcedure>', '</mainProcedure>\n<closeRqmts>\n<reqCondGroup><noConds/></reqCondGroup>\n</closeRqmts>', descrproc)
    return text

# Renaming all itemLocationCodes to C caused duplicate filename issues, so the quickfix is to change everything to D during the finals script and have this function to go back in and fix everything to be C_sx-US
def BandAidFix(working_dir):
    for f in working_dir.glob('*.XML'):
        text = f.read_text(encoding="utf-8")
        descrproc = re.sub('<closeRqmts>\n?<reqCondGroup>\n?<noConds/>\n?</reqCondGroup>\n?</closeRqmts>\n?</mainProcedure>', '</mainProcedure>\n<closeRqmts>\n<reqCondGroup><noConds/></reqCondGroup>\n</closeRqmts>', text)
        ilcode = re.sub('itemLocationCode="D"', 'itemLocationCode="C"', descrproc)
        f.write_text(ilcode, encoding="utf-8")
        f.rename(f.with_name(re.sub(r"-D(?:_sx-US)?.XML", "-C_sx-US.XML", f.name)))

def main(working_dir, job_number=None, manual=None, modellic=None, cage=None, ata_number=None, data_type=None):
    jobnumber = job_number or input ("Please enter the job number: ")
    test = jobnumber == "x"

    sysDiffCode = manual_types.get(manual, "EAA")
    
    if not test:
        #GET ATA AND CONFIRM WITH USER
        try:
            file = list(working_dir.glob('PMC*.XML'))[0]
        except IndexError:
            raise FileNotFoundError("No PMC File Found.")
        else:
            text = file.read_text(encoding="utf-8")

        # pattern_ATA = re.compile(r'<externalPubCode pubCodingScheme="CMP">(.*?)</externalPubCode>', re.DOTALL)
        ATANumber = ata_number or check_match(pattern_ATA.search(text))
        Modelic = modellic
        CAGECode = cage or check_match(pattern_CAGE.search(text))
        db_job = sqlite_select(f"SELECT pm_number FROM 'Delivery Info' WHERE job='{job_number}'", fetchall=False)
        if not db_job or db_job[0] is None:
            try:
                pm_number = int(sqlite_select(f"SELECT pm_number FROM 'Delivery Info' WHERE modellic='{Modelic}' AND cage='{CAGECode}' ORDER BY pm_number DESC;", fetchall=False)[0]) + 1
            except TypeError:
                pm_number = 1
            except IndexError:
                pm_number = 1
            if db_job:
                sqlite_update(f"UPDATE 'Delivery Info' SET type=?, cage=?, pm_number=?, delivery_date=? WHERE job=?;", (manual, CAGECode, pm_number, date.today(), job_number))
            else:
                sqlite_update(f"INSERT INTO 'Delivery Info' (job, type, delivery_date, modellic, cage, pm_number) VALUES (?, ?, ?, ?, ?, ?);", (job_number, manual, date.today(), Modelic, CAGECode, pm_number))
        else:
            pm_number = db_job[0]
        PubNumber = f"{pm_prefix}{'0' * (4 - digits(pm_number))}{pm_number}"
        Modelic = Modelic.replace('HON', "")
        pmcname = f"PMC-HON{Modelic}-{CAGECode}-{PubNumber}-01.XML"

        booktype = data_type
        # if Modelic in {131, "131", "RE100", "AS907", "CFE738", "GTCP331", "GTCP36", "GTCP85", "HGT1700", "RE220", "TFE731", "TPE331", "TSCP700"}:
        #     booktype = "ENGAPU"
        # else:
        #     booktype = "AVIONICS"

    else:
        Modelic = "XXXX"
        booktype = "XXXX"
        CAGECode = "XXXXX"
        sysDiffCode = "XXX"
        PubNumber = "XXXXX"
        ATANumber = "XX-XX-XX"

    checkingDMCodes(working_dir)
    valAll(working_dir)
    valPMC(working_dir)
    val00W(working_dir)
    val00N(working_dir)
    valCondGroup(working_dir)
    cleanup(working_dir)
    PMCfileName(working_dir, pmcname)
    removeRemarks(working_dir)
    addIssue(working_dir)
    other(working_dir, Modelic, CAGECode, PubNumber)
    if (manual == "EIPC"):
        renamingEIPC(working_dir, Modelic, sysDiffCode, ATANumber, booktype)
    else:
        renamingCMM(working_dir, Modelic, sysDiffCode, ATANumber, booktype)
    illustrationINTRO(working_dir, Modelic, sysDiffCode, ATANumber)
    genericModules(working_dir)

    for f in working_dir.glob("DMC*.XML"):
        text = f.read_text(encoding='utf-8')
        info_code = check_match(re.search('infoCode="([0-9]+)"', text))
        if not info_code:
            continue

        if info_code[0] == "0":
            text = Procedural_To_Descript(text, f.name, str(working_dir / 'report.log'))
        else:
            text = Descript_To_Procedural(text)

        f.write_text(text, encoding="utf-8")

    BandAidFix(working_dir)

if __name__ == "__main__":
    main(Path('.'))
    input("\nFinal Process Complete! Press ENTER to Exit.")