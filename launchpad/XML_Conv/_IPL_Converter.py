import re
import traceback
from functools import partial

# String where we log all our log_print() messages so we can later write them to log file if desired.
pattern_dpl = re.compile(
    r"<pmEntry>\n?<pmEntryTitle>\s?Detailed Parts List</pmEntryTitle>\n<pmEntry>(.*?)</pmEntry>(?=\n</content>)",
    re.S)
pattern_fig = re.compile(
    r"(<figure .*?fignbr=\"([^\"]+)\".*?key=\"([^\"]+)\"[^>]*>(.*?</figure>.*?</figure>))",
    re.S)
pattern_itemdata = re.compile(r"<itemdata([^>]+)>(.*?)</itemdata>", re.S)
pattern_itemnbr = re.compile(r"itemnbr=\"([^\"]+)\"")
pattern_attach = re.compile(r"attach=\"(\d)\"")
pattern_illusind = re.compile(r"illusind=\"(\d)\"")
pattern_indent = re.compile(r"indent=\"(\d)\"")
pattern_delitem = re.compile(r"delitem=\"(\d)\"")
pattern_tags = re.compile(r"<(?!(?:ipl)?nom)(\w+)[^>]*>(.*?)</\1>", re.S)
pattern_ref = re.compile(r"[^\d<]*(\d+\w?)(?:[^\d<]*(\d+\w?))?")
pattern_mfr = re.compile(r"<mfr>([^<]+)</mfr>(?!\n?</\w{3}mfr)")
pattern_spl = re.compile(r'spl="(\w{5})"')
pattern_graphic = re.compile(r"<figure(.*?)</figure>", re.S)
pattern_title = re.compile(r"<title>(.+?)</title>", re.S)
pattern_sheet = re.compile(r"<graphic([^<]+)</graphic>")
pattern_gnbr = re.compile(r"infoEntityIdent=\"([^\"]+)\"")
pattern_imgarea = re.compile(r"imgarea=\"([^\"]*)\"")
pattern_chapnbr = re.compile(r'chapnbr="(\d{2})"')
pattern_sectnbr = re.compile(r'sectnbr="(\d{2})"')
pattern_subjnbr = re.compile(r'subjnbr="(\d{2})"')
pattern_revdate = re.compile(r'revdate="([^"]*)"')
pattern_tsn = re.compile(r'tsn="([^"]*)"')
pattern_reffig = re.compile(r"FIG(?:URE)?\s?(\w+)")
pattern_refitem = re.compile(r"ITEM\s?(\w+)")


def log_print_partial(logText, message, printToLogOnly=False, cc=None):
    if cc is not None:
        cc.log_print(message, printToLogOnly)
    else:
        if(not printToLogOnly):
            print(message)
        logText.append(str(message))


def increment_variant(match):
    return '{}{}'.format(
        match.group(1),
        chr(ord(match.group(2)) +
            (2 if ord(match.group(2)) >= ord('P') else 1)))


def check_match(match, grp=1):
    if match is not None:
        return(match.group(grp))
    else:
        return("")

# This could be a generic function in a separate module?


def GetDmref(name):
    components = re.split('-', name)

    comp_dict = {
        "model": components[1],
        "diff": components[2],
        "sys": components[3],
        "subsys": components[4][0],
        "subsub": components[4][1],
        "assy": components[5],
        "disassy": components[6][0:2],
        "disvar": components[6][2],
        "info": components[7][0:3],
        "infovar": components[7][3],
        "loc": components[8].split('_')[0][0]
    }

    return """<dmRef><dmRefIdent>
    <dmCode assyCode="%s" disassyCode="%s" disassyCodeVariant="%s"
    infoCode="%s" infoCodeVariant="%s" itemLocationCode="%s"
    modelIdentCode="%s" subSubSystemCode="%s" subSystemCode="%s"
    systemCode="%s" systemDiffCode="%s"/></dmRefIdent></dmRef>""" %\
        (comp_dict["assy"], comp_dict["disassy"], comp_dict["disvar"],
         comp_dict["info"], comp_dict["infovar"], comp_dict["loc"],
         comp_dict["model"], comp_dict["subsub"], comp_dict["subsys"],
         comp_dict["sys"], comp_dict["diff"])


def DoTheThing(source, dir, book_info, cc):
    logText = []

    skip_figure_items = {}
    # Path('processed_source.xml').write_text(source, encoding='utf-8')
    module_list = {}

    log_print = partial(log_print_partial, logText, cc=cc)

    def GenerateReferTos(ref, tag):
        # If 'ATA' is in the reference, or FIG isn't, referTo's won't support it.
        if "<refint" in ref:
            ref = "SEE IPL FIGURE {} FOR {}".format(
                re.search(r'refid="([^"]+)"', ref).group(1)[1:],
                "NHA" if tag == "fnha" else "DETAILS")
        if "ATA" in ref or "FIG" not in ref or "FIELD MAINT" in ref:
            if "SEE" not in ref:
                ref = re.sub(r"\(", r"(SEE ", ref, 1)

            if tag == "fds" and "FOR DETAILS" not in ref:
                ref = re.sub(r"\)", r" FOR DETAILS)", ref, 1)
            elif tag == "fnha" and "FOR NHA" not in ref:
                ref = re.sub(r"\)", r" FOR NHA)", ref, 1)
            gpd_list.append(ref)
            gpd_tags.append("see")
            return ""

        # Get the figure and figure variant, if applicable
        ref_figure = check_match(pattern_reffig.search(ref))
        if ref_figure == "":
            gpd_list.append(ref)
            gpd_tags.append("see")
            return ""

        if ref_figure[-1].isalpha():
            ref_figvar = ref_figure[-1]
            ref_figure = ref_figure[0:-1]
        else:
            ref_figvar = ""

        # Get the item and item variant, if applicable
        if "ITEM" in ref:
            ref_item = check_match(pattern_refitem.search(ref))
            if ref_item != "":
                if ref_item[-1].isalpha():
                    ref_itemvar = ref_item[-1]
                    if ref_figure in skip_figure_items:
                        if ref_item[0:-1] in skip_figure_items[ref_figure]:
                            if ord(ref_itemvar) >= ord('I'):
                                ref_itemvar = chr(ord(ref_itemvar) + 1)
                            if ord(ref_itemvar) >= ord('O'):
                                ref_itemvar = chr(ord(ref_itemvar) + 1)
                    ref_item = ref_item[0:-1]
                else:
                    ref_itemvar = ""
            else:
                gpd_list.append(ref)
                gpd_tags.append("see")
                return ""
        else:
            ref_item = "001"
            ref_itemvar = ""

        # Get the refer type
        if "NHA" in ref or tag == "fnha":
            ref_type = "rft01"
        elif "DETAILS" in ref or tag == "fds":
            ref_type = "rft02"
        elif "BKDN" in ref:
            ref_type = "rft10"
        elif "REMOVAL" in ref:
            ref_type = "rft06"
        elif "OPT MFG PN" in ref:
            ref_type = "rft03"
        elif "FIELD MAINT" in ref:
            ref_type = "rft51"
        elif "FOR INSTALLATION" in ref:
            ref_type = "rft52"
        elif "PLMB INST" in ref:
            ref_type = "rft53"
        elif "FURTHER BKDN" in ref:
            ref_type = "rft54"
        else:
            gpd_list.append(ref)
            gpd_tags.append("see")
            return ""

        refer_string = """\n<referTo refType="%s"><catalogSeqNumberRef assyCode="%s"
    figureNumber="%s%s" %sitem="%s%s" %ssubSubSystemCode="%s" subSystemCode="%s"
    systemCode="%s"></catalogSeqNumberRef></referTo>""" % \
            (ref_type, assy, "0" * (2 - len(ref_figure)), ref_figure,
             'figureNumberVariant="%s" ' % ref_figvar if ref_figvar != "" else "",
             "0" * (3 - len(ref_item)), ref_item,
             'itemVariant="%s" ' % ref_itemvar if ref_itemvar != "" else "",
             subsubsys, subsys, sys)
        return refer_string

    path_name = dir

    pmc = sorted(path_name.glob("PMC*.xml"))

    if len(pmc) != 1:
        log_print(
            "IPL Conversion Failed: Please ensure exactly one 'PMC*.xml' file is present in the directory")
        return

    pmc = pmc[0]
    pm_text = ""
    firstEntry = True

    ids = {}

    try:  # Generate 941
        text = source
        ipl_text = check_match(re.search(re.compile(
            r'<dplist>(.*?)</dplist>', re.S), text))
        if ipl_text == "":
            log_print("\n	No IPL Found!")
            return None, logText
        # Path("source.txt").write_text(source, encoding="utf-8")
        print("\n	Generating 941 files...", end='\r')
        ipl_text = re.sub(r'<\?Pub[^>]+>', '', ipl_text)
        ipl_text = re.sub('<rev(?:st|end)>', '', ipl_text)
        if book_info:
            cage = book_info['cage']
            assy = book_info['ata'][-2:]
            sys = book_info['ata'][0:2]
            subsys = book_info['ata'][3]
            subsubsys = book_info['ata'][4]
            revdate = book_info['revdate']
            issueNum = book_info['issue_no']
        else:
            cage = check_match(pattern_spl.search(text)).strip()
            
            assy = check_match(pattern_subjnbr.search(text))
            
            sys = check_match(pattern_chapnbr.search(text))
            sectnbr = check_match(pattern_sectnbr.search(text))
            if sectnbr != "":
                subsys = sectnbr[0]
                subsubsys = sectnbr[-1]
            else:
                subsys = subsubsys = ""
        
            revdate = check_match(pattern_revdate.search(text))
            issueNum = check_match(pattern_tsn.search(text))

        if revdate != "":
            revdate = [revdate[0:4], revdate[4:6], revdate[6:]]
        else:
            revdate = ["0000", "00", "00"]
        
        issueNum = (3 - len(str(issueNum))) * "0" + str(issueNum)
        pm_text = "<pmEntry><pmEntryTitle>Detailed Parts List</pmEntryTitle>\n<pmEntry>"

        listOfFigures = pattern_fig.findall(ipl_text)
        disassyCode = 0
        for k, fig in enumerate(listOfFigures):
            listOfItemData = pattern_itemdata.findall(fig[0])
            figtext = ""

            # Data for each graphic, including key, title and the ICN and page size for each sheet
            fignbr = fig[1]
            graphic = pattern_graphic.search(fig[3]).group(1)
            key = fig[2]
            # key = pattern_key.search(graphic).group(1)
            # key = "ipl-fig-%s%s" % ("0" * (3 - len(fignbr)), fignbr)
            title = pattern_title.search(graphic).group(1)
            figure_text = "<figure id=\"%s\">\n<title>%s</title>\n" % (
                key, title)
            sheets = pattern_sheet.findall(graphic)

            # Generate the graphic ICN, and add foldout dimensions if required
            for sheet in sheets:
                gnbr = pattern_gnbr.search(sheet).group(1)
                foldout = True if check_match(
                    pattern_imgarea.search(sheet)).lower() == "hl" else False
                figure_text += "<graphic infoEntityIdent=\"%s\"%s></graphic>\n" % (
                    gnbr, " reproductionHeight=\"209.55 mm\" reproductionWidth=\"355.6 mm\"" if foldout else "")
            figure_text += "</figure>"

            # Header data
            disassyCode += 1
            if disassyCode == 100:
                disassyCode = 1

            disassyCodeVariant = chr(ord('A') + ((k + 1) // 100))
            figtext += """<?xml version="1.0" encoding="UTF-8"?>
<!--Arbortext, Inc., 1988-2014, v.4002-->
<!DOCTYPE dmodule [
<!ENTITY %% ISOEntities PUBLIC "ISO 8879-1986//ENTITIES ISO Character Entities 20030531//EN//XML" "http://www.s1000d.org/S1000D_2-3/ent/xml/ISOEntities">
%%ISOEntities;
<!NOTATION cgm SYSTEM "cgm">
<!NOTATION tif SYSTEM "tif">
]>
<?Pub Inc?>
<dmodule xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:noNamespaceSchemaLocation="http://www.s1000d.org/S1000D_4-1/xml_schema_flat/ipd.xsd">
<?MENTORPATH ?>
<identAndStatusSection>
<dmAddress>
<dmIdent>
<dmCode assyCode="%s" disassyCode="%s%s" disassyCodeVariant="%s"
infoCode="941" infoCodeVariant="A" itemLocationCode="C"
modelIdentCode="HON%s" subSubSystemCode="%s" subSystemCode="%s"
systemCode="%s" systemDiffCode="EAA"/>
<language countryIsoCode="US" languageIsoCode="sx"/>
<issueInfo inWork="00" issueNumber="%s"/></dmIdent>
<dmAddressItems>
<issueDate day="%s" month="%s" year="%s"/>
<dmTitle><techName>IPL</techName>
<infoName>Detailed Parts List</infoName>
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
<illustratedPartsCatalog>""" % (assy, "0" if disassyCode < 10 else "", disassyCode, disassyCodeVariant, cage, subsubsys, subsys, sys, issueNum, revdate[2], revdate[1], revdate[0], cage, cage)
            figtext += figure_text
            ids["%s%s%s" % ("0" if disassyCode < 10 else "",
                            disassyCode, disassyCodeVariant)] = key
            module_name = 'DMC-HON%s-EAA-%s-%s%s-%s-%s%s%s-941A-C_sx-US.XML' % (
                cage, sys, subsys, subsubsys, assy, "0"
                if disassyCode < 10 else "", disassyCode, disassyCodeVariant)
            
            dmref = GetDmref(module_name)
            
            module_list[key] = dmref
            isVariant = True if fignbr[-1].isalpha() else False
            itemvar_skip = 0
            skip_item = None
            for i in listOfItemData:
                illustrated = " - " if check_match(
                    pattern_illusind.search(i[0])) == "0" else "   "
                attach = check_match(pattern_attach.search(i[0]))
                item = check_match(pattern_itemnbr.search(i[0])).strip()
                indenture = check_match(pattern_indent.search(i[0]))
                indenture = '' if indenture == "" else int(indenture) * '.'
                # tags: dd, kwd, adt, upa, pnr, effcode, csdmfr, optmfr, esds, sbs, rp, rps
                tags = pattern_tags.findall(i[1])
                use_list = []
                shortName = ""
                refto = []
                gpd_tags = []
                gpd_list = []
                geoloc = []
                quantity = ""

                for tag in tags:
                    if tag[0] == "kwd":
                        partKeyword = tag[1].replace('\n', ' ')
                        partKeyword = partKeyword.strip()
                    elif tag[0] == "pnr":
                        partNumberValue = tag[1]
                    elif tag[0] == "adt":
                        shortName = tag[1].replace('\n', ' ')
                    elif tag[0] == "effcode":
                        use_list.append(tag[1])
                    elif tag[0] == "upa":
                        quantity = tag[1]
                    elif tag[0] == "dd":
                        gpd_list.append(tag[1])
                        gpd_tags.append("dd")
                    elif tag[0] == "csdmfr" or tag[0] == "optmfr":
                        mfrtags = pattern_tags.findall(tag[1])
                        for mtag in mfrtags:
                            if mtag[0] == "csd":
                                mf1 = "CSD: %s" % mtag[1]
                                gpd_list.append(mtag[1])
                                gpd_tags.append(mtag[0])
                            elif mtag[0] == "opt":
                                mf1 = "OPT MFR: %s" % mtag[1]
                                gpd_list.append(mtag[1])
                                gpd_tags.append(mtag[0])
                            else:
                                mf2 = " V%s" % mtag[1]
                        mf = mf1 + mf2
                        gpd_list.append(mf)
                        gpd_tags.append(tag[0])
                    elif tag[0] == "esds":
                        gpd_list.append(tag[1])
                        gpd_tags.append(tag[0])
                    elif tag[0] == "rp":
                        gpd_list.append("REPLACED BY ITEM: %s" % tag[1])
                        gpd_tags.append("replacedBy")
                    elif tag[0] == "rps":
                        gpd_list.append("REPLACES ITEM: %s" % tag[1])
                        gpd_tags.append("replaces")
                    elif tag[0] == "sbs":
                        sbstags = pattern_tags.findall(tag[1])
                        for stag in sbstags:
                            if stag[0] == "chgnbr":
                                chgnbr = stag[1]
                            elif stag[0] == "chgtyp":
                                chgtyp = stag[1]
                            elif stag[0] == "chgcond":
                                chgcond = stag[1]
                        sb = "(%s %s %s)" % (chgcond, chgtyp, chgnbr)
                        gpd_list.append(sb)
                        gpd_tags.append("serviceBulletin")
                    elif tag[0] == "fnha" or tag[0] == "fds":
                        refto.append([tag[1].replace('.', ''), tag[0]])
                    elif tag[0] == "eqdes":
                        rdi_tags = pattern_tags.findall(tag[1])
                        rd = geo = ""
                        for rtag in rdi_tags:
                            if rtag[0] == "rd" or rtag[0] == "rdi":
                                rd = rtag[1]
                            elif rtag[0] == "geoloc":
                                geo = rtag[1]
                        geoloc.append((rd, geo))
                    elif tag[0] == "sd":
                        gpd_list.append("SUPERSEDED BY ITEM: %s" % tag[1])
                        gpd_tags.append("supersededByItem")
                    elif tag[0] == "sdes":
                        gpd_list.append("SUPERSEDES ITEM: %s" % tag[1])
                        gpd_tags.append("supersedesItem")
                    elif tag[0] == "uoi":
                        gpd_list.append("USED ON ITEM: %s" % tag[1])
                        gpd_tags.append("usedOnItem")
                    elif tag[0] == "uwi":
                        gpd_list.append("USED WITH ITEM: %s" % tag[1])
                        gpd_tags.append("usedWithItem")
                    elif tag[0] == "uwp":
                        gpd_list.append("USED WITH PN: %s" % tag[1])
                        gpd_tags.append("usedWithPN")
                    elif tag[0] == "opn":
                        gpd_list.append("OVERLENGTH PN: %s" % tag[1])
                        gpd_tags.append(tag[0])
                    elif tag[0] != "csd" and tag[0] != "opt" and tag[0] != "eqdes" and tag[0] != "mfr":
                        if "SEE" in tag[1]:
                            refto.append([tag[1].replace('.', ''), tag[0]])
                        else:
                            gpd_list.append(tag[1])
                            gpd_tags.append(tag[0])

                mfr = check_match(pattern_mfr.search(i[1]))

                deleted = check_match(pattern_delitem.search(
                    i[0])) == "1" or partKeyword == "DELETED"
                if deleted:
                    if partKeyword != "DELETED":
                        partKeyword = "DELETED"
                    shortName = ""
                    mfr = ""
                    quantity = "0"

                if len(use_list) > 0:
                    if len(use_list) == 1:
                        use = use_list[0]
                    else:
                        use = ""
                        for c, u in enumerate(use_list):
                            use += u
                            if c == len(use_list) - 1:
                                break
                            use += ','
                else:
                    use = " "

                i_refs = ""
                for ref in refto:
                    i_refs += GenerateReferTos(ref[0], ref[1])

                if len(geoloc) > 0:
                    i_refs += '\n<referTo>'
                    for g in geoloc:
                        i_refs += '<functionalItemRef functionalItemNumber="{}" installationIdent="{}"/>'.format(
                            g[0], g[1])
                    i_refs += '\n</referTo>'

                if len(gpd_list) > 0:
                    i_gpd = "\n<genericPartDataGroup>"
                    for t, d in enumerate(gpd_list):
                        i_gpd += "\n<genericPartData genericPartDataName=\"%s\"><genericPartDataValue>%s</genericPartDataValue></genericPartData>" % (
                            gpd_tags[t], re.sub(r'(ITEM:?\s?\d{1,3})([I-Z])', increment_variant, d))
                    i_gpd += "\n</genericPartDataGroup>"
                else:
                    i_gpd = ""

                # All the values for each item to be converted
                i_delete = "changeType=\"delete\" " if deleted and partNumberValue != "" else ""
                i_fignbr = fignbr if fignbr[-1].isnumeric() else fignbr[0:-1]
                i_fignbrzero = "0" * (2 - len(i_fignbr))
                i_figvar = "figureNumberVariant=\"%s\" " % fignbr[-1] if fignbr[-1].isalpha(
                ) else ""
                i_itemzero = "0" * \
                    (3 - len(item)
                     ) if item[-1].isnumeric() else "0" * (4 - len(item))
                i_item = item if item[-1].isnumeric() else item[0:-1]
                i_itemvar = item[-1] if item[-1].isalpha() else ""

                if i_itemvar == "I":
                    skip_item = i_item
                    itemvar_skip = 1
                    if fignbr not in skip_figure_items:
                        skip_figure_items[fignbr] = [skip_item]
                    else:
                        skip_figure_items[fignbr].append(skip_item)

                if (itemvar_skip == 1 and i_itemvar == "N") or (itemvar_skip == 0 and i_itemvar == "O"):
                    itemvar_skip += 1

                if skip_item == i_item:
                    i_itemvar = chr(ord(i_itemvar) + itemvar_skip)
                else:
                    itemvar_skip = 0
                i_mfr = mfr if mfr != "" else cage
                i_attach = "\n<attachStoreShipPart attachStoreShipPartCode=\"1\"/>" if attach == "1" else ""
                i_illust = "\n<notIllustrated></notIllustrated>" if illustrated == " - " else ""
                i_use = "\n<applicabilitySegment><usableOnCodeEquip>%s</usableOnCodeEquip></applicabilitySegment>" % use if use != " " else ""
                i_desc = "%s-%s" % (partKeyword, shortName)
                i_kwd = partKeyword
                i_adt = shortName

                # Generate and add a new catalogSeqNumber to the IPL file
                ipl_item = """\n<catalogSeqNumber assyCode="%s" figureNumber="%s%s"
%s indenture="%s" item="%s%s"
subSubSystemCode="%s" subSystemCode="%s" systemCode="%s">
<itemSeqNumber %sitemSeqNumberValue="00%s">
<quantityPerNextHigherAssy>%s</quantityPerNextHigherAssy>
<partRef manufacturerCodeValue="%s" partNumberValue="%s"></partRef>
<partSegment>
<itemIdentData><descrForPart>%s</descrForPart>
<partKeyword>%s</partKeyword>
<shortName>%s</shortName>
</itemIdentData></partSegment>
<partLocationSegment>%s%s%s</partLocationSegment>%s%s
</itemSeqNumber></catalogSeqNumber>""" % (assy, i_fignbrzero, i_fignbr, i_figvar, len(indenture) + 1, i_itemzero, i_item, subsubsys, subsys, sys, i_delete, i_itemvar, quantity, i_mfr, partNumberValue, i_desc, i_kwd, i_adt, i_attach, i_illust, i_refs, i_use, i_gpd)
                ipl_item = re.sub(
                    r"<partLocationSegment></partLocationSegment>\n", '',
                    ipl_item)
                figtext += '\n' + ipl_item
            pm_text += "%s%s" % ("\n</pmEntry>\n<pmEntry>" if not firstEntry
                                 and not isVariant else "", dmref)
            if firstEntry:
                firstEntry = False
            # Close off tags and write the file
            figtext += "\n</illustratedPartsCatalog>\n</content>\n</dmodule>"
            (path_name / module_name).write_text(figtext, encoding="utf-8")
    except Exception:
        log_print("	Generating 941 files... Error!")
        # print(i)
        log_print(traceback.format_exc(), True)
    else:
        log_print("	Generating 941 files... Done!")
    finally:
        pm_text += "\n</pmEntry>\n</pmEntry>\n</pmEntry>\n"

    try:  # Print PMC (Need to generate new one instead of replace in old one)
        print("\n	Printing To PMC...", end='\r')
        text = (path_name / pmc.name).read_text(encoding="utf-8")
        text = re.sub(pattern_dpl, pm_text.strip('\n'), text)
        (path_name / pmc.name).write_text(text, encoding="utf-8")
    except Exception:
        log_print("	Printing To PMC... Error!")
        log_print(traceback.format_exc(), True)
    else:
        log_print("	Printing To PMC... Done!")
    return module_list, logText


if __name__ == '__main__':
    DoTheThing()
