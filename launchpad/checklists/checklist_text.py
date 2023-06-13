# All the texts on the checklists

#################################################
# Text for Data Conversion Checklist
#################################################

dc_1 = 'Incorrect Order/Nesting'
dc_2 = 'IPL (No NI/EDI)'
dc_3 = 'Missing/Incorrect Text'
dc_4 = 'Spelling Errors/Duplicate text'
dc_5 = 'Missing Space/Punctuation'
dc_6 = 'Template Update'
dc_7 = 'Warning/Caution Errors'
dc_8 = 'Incorrect/Missing Graphics'
dc_9 = 'Format Errors'
dc_10 = 'References'
dc_blocks = {1: {'Minor': dc_1}, 2: {'Major': dc_2}, 3: {'Major': dc_3},
             4: {'Minor': dc_4}, 5: {'Minor': dc_5}, 6: {'Minor': dc_6},
             7: {'Major': dc_7}, 8: {'Major': dc_8}, 9: {'Minor': dc_9},
             10: {'Major': dc_10}}
di_1 = 'Minor'
di_2 = 'Major'
di_3 = 'Major'
di_4 = 'Minor'
di_5 = 'Minor'
di_6 = 'Minor'
di_7 = 'Major'
di_8 = 'Major'
di_9 = 'Minor'
di_10 = 'Major'           
dc = [dc_1, dc_2, dc_3, dc_4, dc_5, dc_6, dc_7, dc_8, dc_9, dc_10]
di_list = [di_1, di_2, di_3, di_4, di_5, di_6, di_7, di_8, di_9, di_10]
dc_length = sum(len(v) for v in dc_blocks.values())

code_1 = 1
code_2 = 2
code_3 = 3
code_4 = 4
code_5 = 5
code_6 = 6
code_7 = 7
code_8 = 8
code_9 = 9
code_10 = 10

############################################
# Text for the Writer Checklist
#############################################

writer_A = {1: 'All revised or reissued pages are accounted for in the highlights letter.',
            2: 'Description of changes are accurate and are correctly documented.',
            3: 'Title of the Highlights clearly identifies the applicable CMM, component name and part number, and aircraft.'}
writer_B = {1: 'Illustrations are complete and legible.',
            2: 'Moisture Sensitive and ESDS symbols used where applicable.',
            3: 'Artwork is correctly located.',
            4: 'Requested changes have been completed.'}
writer_C = {1: 'Warnings, Cautions and Notes are correct.',
            2: 'Applicable safety precautions and procedures are included (e.g. lithium batteries)'}
writer_D = {1: 'All source data incorporated per change request.',
            2: 'Revision information is identified with change bars and correct revision number is identified on the RR page.',
            3: 'Text and drawing callouts do not contain typos, improper punctuation and/or poor grammar.',
            4: 'Procedures are clear, understandable and in logical steps.',
            5: 'Acronyms and abbreviations are defined at first occurrence of the manual. In some cases only non ASME Y14. 38 acronyms  are required.  Check the Introduction section for the applicable requirements.',
            6: 'Abbreviations and nomenclatures used in text are consistent with those used in IPL/IPC.',
            7: 'Units of metric measure conversion are completed as applicable.',
            8: 'Header and Footer are correct on all pages of the manual',
            9: 'Correct page numbering format is used.',
            10: 'Check that page numbers are in sequence.',
            11: 'If applicable, correct styles were used.',
            12: 'If foldouts are in the manual make sure Header and Footer (page no.) are in their proper place.  Does the caption read correctly?',
            13: 'No widows or orphans are present in manual.',
            14: 'Title page identifies the equipment by name and part number, including the customer part number if applicable.',
            15: 'Title page has the latest copyright clause.',
            16: 'The Service Bulletin List is complete with Revisions and Applicability updated.',
            17: 'On List of Effective Pages (LOEP) all page numbers, blank pages and dates on the match the actual pages of the publication and vice-versa.',
            18: 'Verify the TOC.',
            19: 'Disassembly, Repair, and Assembly instructions are specific and detailed.',
            20: 'Active voice and simplified English are used in the Disassembly, Repair, and Assembly sections.',
            21: 'Special Tools, Fixture and Equipment Table data is properly applied (as per specifications).',
            22: 'All lists/tables are complete and have correct titles.',
            23: 'Tables/Figures numbering is correct and properly sequenced.',
            24: 'Multi-page figures/schematics are in proper order.',
            25: 'Item numbers agree with related figure and text references.',
            26: 'All cross-references are correct.',
            27: 'References to other sections are in upper case.',
            28: 'Nomenclature and references are consistent.',
            29: 'Pre and Post Service Bulletin (SB) references are provided as required.',
            30: 'Part numbers are consistent throughout text.',
            31: 'A spell check has been performed.',
            32: 'File names conform to the standard file naming conventions and/or customer requirements.'}
writer_E = {1: 'Correct Vendor Codes and addresses provided.',
            2: 'Reference Designation Index is in proper Alpha/Numeric order.',
            3: 'If applicable, ensure the Numerical Index is formatted, sorted and agrees with the GAP.',
            4: 'Figure title agrees with the first item in IP.',
            5: 'Referenced figure number agrees with related parts breakdow.',
            6: 'Item numbering in GAPL and illustrations are consistent and in the proper disassembly order.',
            7: 'Parts breakdown agrees with source dat.',
            8: 'GAPL is properly indented to show relationship to NH.',
            9: 'Attaching part format correct.',
            10: 'For all service bulletins incorporated, make sure that the information is identified as pre-SB or post-SB'}
writer_F = {1: 'Validate SGML.',
            2: 'Verify that all graphic entities are mapped to a referential Graphics folder.'}
writer_G = {1: 'Workflow/JIRA Ticket updated and Abak updated',
            2: 'ROC Completed'}

writer_blocks = {'A': {'Highlights': writer_A},
                 'B': {'Illustrations': writer_B},
                 'C': {'Warnings and Cautions': writer_C},
                 'D': {'Text': writer_D},
                 'E': {'IPC/IPL': writer_E},
                 'F': {'SGML': writer_F},
                 'G': {'QA Requirements': writer_G}}
writer = [writer_A, writer_B, writer_C, writer_D, writer_E, writer_F, writer_G]
writer_length = sum(len(v) for v in writer)

#################################################
# Text for the Illustration Checklist
#################################################

illustration_A = {1: 'Confirm template size (CMM, CMP)',
                  2: 'Ensure illustration conforms to the current specification.',
                  3: 'Perform final quality check of illustrations (i.e. missed callouts, line weights, font size etc.).',
                  4: 'Process Honeywell Graphic Job Request data for each illustration.'}

illustration_blocks = {'A': {'Illustration': illustration_A}}
illustration = [illustration_A]
illustration_length = sum(len(v) for v in illustration)

############################################
# Text for the Editor Checklist
############################################

editor_A = {1: 'File names conform to the standard file naming conventions and/or customer requirements.'}
editor_B = {1: 'All revised or reissued pages are accounted for in the highlights letter.',
            2: 'Descriptions of changes are accurate (for reissues, refer to a copy of the last revision/initial release of the manual to verify).'}
editor_C = {1: 'The required data is included on the title page (added part numbers, dash numbers, model numbers, etc.).',
            2: 'Honeywell trademark information is verified.',
            3: 'Honeywell address is correct.',
            4: 'Copyright year matches release date.'}
editor_D = {1: 'Spell check is completed on all files.',
            2: 'Acronyms are identified at the first occurrence in the manual; only one definition is used for each acronym.',
            3: 'In some cases only non ASME Y14.38 acronyms are required.  Check the Introduction section for the applicable requirements.',
            4: 'The first word in a bulleted list is initial capped; periods are used if items form a sentence.',
            5: 'Paragraphs are not orphaned/widowed (e.g., 1. has a 2., (a) has a (b), etc.).',
            6: 'Abbreviations and nomenclatures used in text are consistent with those used in IPL/IPC.',
            7: 'Simplified English is used for new or added text.',
            8: 'All warnings and cautions are lined up vertically with and precede the text to which they apply.',
            9: 'All notes immediately follow the text and/or subheading to which they apply.',
            10: 'Pages/paragraphs are in consecutive alpha/numeric order.',
            11: 'Revised information is identified with rev bars and are properly placed.',
            12: 'Proper font, format, and layout; on word omissions, and appropriate sentence structure/length.',
            13: 'Check that only the first page number of a foldout sheet appears in the HL page.',
            14: 'Do not use phrase "greater than" or "less than" use symbol > or <.',
            15: 'Symbols +, ±. >, etc. are adjacent to the following number (i.e. no space) when numbers are alone. When modifying an adjacent number, there is a space (e.g.10 ± 5)',
            16: 'There is a space between a number and the following defining letter (e.g. 6 V, 15 W), and between the defining letter and its descriptor (e.g. 120 mV dc)',
            17: 'The word volts and watts is replaced by the letter V and W in both text and tables.',
            18: 'References to measurements in text use numerical characters and abbreviations (e.g. changed at 1 sec. intervals).',
            19: 'Figures and tables are referenced as follows: See Figure 1...., Refer to Table 1....',
            20: 'Client’s requirements have been completed in accordance with the Change Request.',
            21: 'All technical/format/content changes requested have been correctly carried out.'}
editor_E = {1: 'All figures and tables are numbered.',
            2: 'Figure and table numbers are sequential.',
            3: 'Callouts appear before the figure or table; figures and tables appear immediately after the callout.',
            4: 'Paragraph references are verified.',
            5: 'Autoreferences are used for figures, tables, and paragraph references.',
            6: 'Units of metric conversion are correct.'}
editor_F = {1: 'Item number is located at the top of each page.',
            2: 'ITEM NOT ILLUSTRATED appears on all GAPL pages.',
            3: 'The GAPL starts on an odd page after each figure illustration.',
            4: 'Illustrations are complete and referenced figure number agrees with related IPL breakdown.',
            5: 'The nomenclature of the Figure title matches item 1 in the GAPL'}
editor_G = {1: 'Section, figure, and table titles are verified.',
            2: 'Automated TOC is regenerated after making changes to the manual.',
            3: 'Paragraph, and page numbers are correct.'}
editor_H = {1: 'List is complete-all pages are accounted for.',
            2: 'Foldouts are correctly identified.',
            3: 'Revision status is correctly identified.',
            4: 'LEP has accurate dates of changed pages and box indicating changed, added, or deleted pages.'}
editor_I = {1: 'Illustrations are complete and legible.',
            2: 'Change indicator is correctly used to identify changes in artwork.',
            3: 'Artwork is properly located in relation to text.',
            4: 'Illustrations comply with end user requirements.'}
editor_J = {1: 'Workflow/JIRA ticket updated and Abak updated'}

editor_blocks = {'A': {'File Names': editor_A},
                 'B': {'Highlight Letter': editor_B},
                 'C': {'Title Page': editor_C},
                 'D': {'Text': editor_D},
                 'E': {'References': editor_E},
                 'F': {'IPL': editor_F},
                 'G': {'Table of Contents': editor_G},
                 'H': {'List of Effective Pages': editor_H},
                 'I': {'Illustrations': editor_I},
                 'J': {'QA Requirements': editor_J}}
editor = [editor_A, editor_B, editor_C, editor_D, editor_E, editor_F, editor_G,
          editor_H, editor_I, editor_J]
editor_length = sum(len(v) for v in editor)

############################################
# Text for the QA Checklist
############################################

# Note: checklist template did not have a line F
qa_note = 'NOTE: If there are no corrections, proceed to QA2. If there are corrections, send to writer for rework before QA2.'
qa_A = {1: 'Correct original date/Change No. and date of change.',
        2: 'Proper copyright date(s).'}
qa_B = {1: 'List is complete - all pages are accounted for.',
        2: 'Revision status is correctly identified.',
        3: 'LEP has accurate dates of changed pages and box indicating changed, added, or deleted pages.'}
qa_C = {1: 'Nomenclature, terminology and style are correct and consistent.',
        2: 'Correct indentations: paragraphs, sub-paragraphs, etc.',
        3: 'Correct numbering sequence for paragraphs, figures, parts, sections.',
        4: 'Spelling/punctuation (scan for errors in spelling, punctuation, use of upper/lower case, cross-references).',
        5: 'Warnings, Cautions, Notes and symbols formatted correctly.',
        6: 'Headers and footers are formatted correctly and have the correct part number/date specified.',
        7: 'IPL changes have been reflected in the IPL drawings, Alphanumeric Index, Equipment Designator Index, Assembly Disassembly, and any other areas that give IPL item numbers.',
        8: 'No characters were replaced by symbols or dropped during PDF creation and all special symbols are correct.'}
qa_D = {1: 'Illustrations are complete and legible.',
        2: 'Change bars or revision indicators are used to identify changes in art.',
        3: 'Artwork is properly located in relation to text.',
        4: 'Illustrations comply with end user requirements.'}
qa_E = {1: 'All revised or reissued pages are accounted for.',
        2: 'Descriptions of changes are correctly documented.'}
qa_G = {1: 'Editor’s markup has been incorporated.',
        2: 'Has all of the paperwork (certificates, ROC, checklists) been completed?'}
qa_H = {1: 'QA markup has been incorporated.',
        2: 'Revision dates are correct.',
        3: 'Check Highlights, List of Effective Pages (LEP), Table of Contents (TOC) and revision indicators.',
        4: 'Correct use of left/right/blank pages.',
        5: 'IPL changes have been reflected in the IPL drawings, Alphanumeric Index, Equipment Designator Index, Assembly Disassembly, and any other areas that give IPL item numbers.',
        6: 'PDF file has been checked for completeness, structure, bookmarks and proper format for section heads.',
        7: 'PDF file has been optimized.'}
qa_I = {1: 'QA2 has been signed off.',
        2: 'All of the client’s requirements have been completed in accordance with statement of work (SOW).',
        3: 'All required items ready for delivery (i.e. PDF, printed copy, associated data, etc.).',
        4: 'Job delivered.'}

qa_blocks_1 = {'A': {'Title and Front Matter Pages': qa_A},
               'B': {'List of Effective Pages (LEP)': qa_B},
               'C': {'Text (Spot Checks)': qa_C},
               'D': {'Illustrations': qa_D},
               'E': {'Highlights Page': qa_E},
               'G': {'Miscellaneous': qa_G}}
qa_blocks_2 = {'H': {'QA2': qa_H}}
qa_blocks_3 = {'I': {'Delivery for Review': qa_I}}
qa_blocks = {**qa_blocks_1, **qa_blocks_2, **qa_blocks_3}
qa = [qa_A, qa_B, qa_C, qa_D, qa_E, qa_G, qa_H, qa_I]
qa_length = sum(len(v) for v in qa)

##################################################
# Text for the Final Delivery Checklist
###################################################

dl_A = {1: 'Correct folder structure created.',
        2: 'All final working files available for delivery (SGML, XML, ISO, etc.).',
        3: 'Prepare package for PDMS archiving and deliver to program administrator.'}
dl_B = {1: 'Record of Temporary Revisions page updated with created TR.',
        2: 'PRINT file with TR incorporated created and named correctly.',
        3: 'VIEW file with TR incorporated created and named correctly.',
        4: 'TR incorporated into the latest revision of the manual',
        5: 'TR number unique for this manual.'}
dl_C = {1: 'Record of Revisions updated to reflect the revision number and date.',
        2: 'PRINT file created and named correctly.',
        3: 'VIEW file created and named correctly.',
        4: 'Completely blank pages removed from the VIEW file.'}
dl_D = {1: 'Final deliverables reviewed for completeness and accuracy.',
        2: 'Honeywell address on title page is correct.',
        3: 'Date on deliverables is correct.'}
dl_E = {1: 'Checklists filled out correctly',
        2: 'Abak updated with latest status and dates'}
dl_F = {1: 'Highlights page has referenced correct page, paragraph, step, table and figure numbers.',
        2: 'Descriptions of changes on Highlights page are correctly documented.',
        3: 'Title Page has correct revision number.',
        4: 'Title Page has correct original issue and revision dates.',
        5: 'List of Effective pages accurately reflects page numbers and revision dates.',
        6: 'Table of Contents has been check against content of publication and is accurate.',
        7: 'Bookmarks are present for all sections, including any TRs that may have been added.'}
dl_G = {1: 'Publication has the correct D number.',
        2: 'Publication has the correct ATA number.',
        3: 'CAGE code accuracately affects the originating site.',
        4: 'All graphics are present in publication.'}
dl_H = {1: 'Notify Illustration team that the job is being delivered final and graphics can be archived.',
        2: 'Notify Publication Coordinator and Project Manager that the files are ready for delivery.'}

dl_blocks = {'A': {'File Names and Folder Structure': dl_A},
             'B': {'Temporary Revisions': dl_B},
             'C': {'Manual Revisions': dl_C},
             'D': {'Final Review': dl_D},
             'E': {'Workflow Requirements': dl_E},
             'F': {'Front Matter': dl_F},
             'G': {'Miscellaneous': dl_G},
             'H': {'Notifications': dl_H}}
dl = [dl_A, dl_B, dl_C, dl_D, dl_E, dl_F, dl_G, dl_H]
dl_length = sum(len(v) for v in dl)

##########################################
# Text for the DPMO Checklist
###########################################

dpmo_A = {1: 'A highlight is missing, incorrect, or incomplete.',
          2: 'A rev bar is missing or incorrectly placed.',
          3: 'An asterisk in the LEP is missing or incorrectly placed.'}
dpmo_B = {1: 'A reference or cross-reference is missing or incorrect.'}
dpmo_C = {1: 'An illustration is technically incorrect or incorrectly formatted.',
          2: 'An illustration is missing or incorrectly placed.',
          3: 'A wrong illustration is used.',
          4: 'Text is missing or incorrect.',
          5: 'Text is misused, misspelled, or incorrectly formatted.',
          6: 'Punctuation is missing or misused.'}
dpmo_D = {1: 'An illustration is technically incorrect or incorrectly formatted.',
          2: 'An illustration is missing or incorrectly placed.',
          3: 'A wrong illustration is used.'}
dpmo_E = {1: 'A unit of measure or metric equivalent is missing, incorrect, or incorrectly formatted.'}
dpmo_F = {1: 'A part nomenclature is missing or is incorrect.'}
dpmo_G = {1: 'A part number is missing, incorrect, or incorrectly formatted.'}
dpmo_H = {1: 'Source data is not incorporated or not incorporated correctly per the change request or customer-supplied change driver(s).'}
dpmo_I = {1: 'A table is missing or incorrectly placed.',
          2: 'A wrong table is used.',
          3: 'A table is incorrectly formatted.'}
dpmo_J = {1: 'A wrong template or template revision is used.',
          2: 'Boilerplate text is not updated per Standards Team instructions.',
          3: 'Boilerplate text is modified without Standards Team approval.'}
dpmo_K = {1: 'Text is technically incorrect, missing, or is incomplete.',
          2: 'Text is misused or misspelled.',
          3: 'Punctuation is missing or misused.'}
dpmo_L = {1: 'A TR was not collated correctly.'}
dpmo_M = {1: 'A warning or caution is missing, incorrectly placed, or incorrectly formatted.',
          2: 'An incorrect warning or caution is used.'}
dpmo_N = {1: 'A technical error that is not listed above',
          2: ' A format error that is not listed above'}
dpmo_O = {1: 'The Approval Record is missing a required approval/stamp.',
          2: 'The initial copyright year or current copyright year is incorrect.',
          3: 'The Export Control Code on the Title page does not match the Technology Export Classification of the end item part number in AeroPDM.',
          4: 'A required final file is missing or is the wrong file.',
          5: 'A required final file is incorrectly named.',
          6: 'A "TBD" or a "?" is found in the VIEW final file.',
          7: 'The initial date or revision date in the Title page footer does not match the dates in the Revision History Table.',
          8: 'The QA Checklist is incomplete or is missing a signature or date.',
          9: 'There is an asterisk (*) in the LEP for one of the front matter sections that should not contain an asterisk.'}
dpmo_P = {1: 'Attribute values are not properly linked or completed.',
          2: 'Links are not correctly applied.'}

dpmo_blocks = {'A': {'Change Identification': dpmo_A},
               'B': {'Cross-Reference': dpmo_B},
               'C': {'Illustrated Parts List / Detailed Parts List / Engines': dpmo_C},
               'D': {'Illustration / Figure': dpmo_D},
               'E': {'Unit of Measure': dpmo_E},
               'F': {'Part Nomenclature': dpmo_F},
               'G': {'Part Number': dpmo_G},
               'H': {'Source Data': dpmo_H},
               'I': {'Table': dpmo_I},
               'J': {'Template': dpmo_J},
               'K': {'Text': dpmo_K},
               'L': {'TR Collation': dpmo_L},
               'M': {'Warnings / Cautions': dpmo_M},
               'N': {'Other': dpmo_N},
               'O': {'Final Quality Check': dpmo_O},
               'P': {'Software / Code': dpmo_P}}
dpmo = [dpmo_A, dpmo_B, dpmo_C, dpmo_D, dpmo_E, dpmo_F,
        dpmo_G, dpmo_H, dpmo_I, dpmo_J, dpmo_K, dpmo_L, dpmo_M, dpmo_N,
        dpmo_O, dpmo_P]
dpmo_length = sum(len(v) for v in dpmo)

# List of Subjects for which the Number of Errors isn't used in the DPMO score
dpmo_exclusion = [2, 9, 19, 24, 25, 30, 38, 39, 40, 41]

##########################################
# Text for the Translation Checklist
###########################################

trans_english = {1:'Kept same filenaming as on the server?',
           2:'In Trados, used the correct memory?',
           3:'Make sure that unnecessary segments were not saved in memory (stand-alone numbers/letters,etc.)?',
           4:'Verify that all numbers contained in the French text correspond to the numbers in the English text.',
           5:'Translated callouts along with the text?',
           6:'All text has been translated?',
           7:'Spellcheck/grammar check has been done using Antidote?',
           8:'QA Checker in TRADOS (F8) performed and each error message addressed?',
           9:'File saved in the right folder on the server? (A_Translation Completed)',
           10:'Gave the file back to Team Lead after completion (if applicable)?',
           11:'The JIRA ticket has been updated.',
           12:'The time sheet has been updated.'}

trans_french = {1:'Ai-je gardé les mêmes noms de fichiers que ceux du serveur?',
           2:'Dans TRADOS, ai-je utilisé la bonne mémoire?',
           3:'Me suis-je assuré qu’il n’y a aucun segment inutile dans la mémoire? (chiffres seuls, lettres seules,etc.)',
           4:'S’assurer que les chiffres dans le texte français correspondent avec les chiffres dans le texte anglais.',
           5:'Ai-je traduit les « callouts » à mesure que je traduis le texte?',
           6:'Tout le texte a-t-il été traduit?',
           7:'La vérification orthographique/grammaticale a-t-elle été effectuée à l’aide d’Antidote?',
           8:'Ai-je effectué la vérification de qualité en TRADOS (F8) et vérifié chaque message d’erreur?',
           9:'Ai-je enregistré le fichier dans le bon répertoire du serveur (A_Translation Completed)?',
           10:'Une fois terminé, ai-je remis le dossier à mon chef de section (si c’est applicable)?',
           11:'J’ai mis à jour le formulaire de circulation/JIRA.',
           12:'J’ai mis à jour ma feuille de temps.'}

