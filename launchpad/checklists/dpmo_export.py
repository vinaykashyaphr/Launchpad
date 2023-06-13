import numpy as np
from datetime import timedelta, datetime
import calendar
import json
from flask import flash
import math
import plotly.graph_objects as go
import plotly
from plotly.subplots import make_subplots
from operator import itemgetter
import pandas as pd

# Helper functions


def daterange(start, end):
    date_list = [start + timedelta(days=x) for x in range(0, ((end-start).days)+1)]
    return date_list


def round_up(n, decimals=0):
    multiplier = 10 ** decimals
    return math.ceil(n * multiplier) / multiplier


def addrows_single(single_list):
    row = "<tr>"
    for elem in single_list:
        row += "<td>"+str(elem)+"</td>"
    row += "</tr>"
    return row


def addrows_multi(multi_list):
    row = ""
    for single in multi_list:
        row += "<tr>"
        for elem in single:
            row += "<td>"+str(elem)+"</td>"
        row += "</tr>"
    return row


def dpmo_table_creation(results, start_date, end_date,
                        year_input, month_input, status):

    # Table 1: Main DPMO table

    if status == 'Monthly Metrics':
        year_input = int(year_input)
        month_input = int(month_input)
        month_start = datetime(year_input, month_input, 1)
        month_end_day = calendar.monthrange(year_input, month_input)[1]
        month_end = datetime(year_input, month_input, month_end_day)
        table6_dates = daterange(month_start, month_end)
        for x in table6_dates:
            x = str(x.date())
    swap_start = start_date
    swap_end = end_date
    start_date = swap_end
    end_date = swap_start
    count_var = 0
    dup_jn = []
    dup_jn_er = []
    date_range = []
    er_level_list = []
    major_errors_pub = {'TR': 0, 'SIL': 0, 'SB': 0, 'CMM': 0, 'CMP': 0,
                        'EM': 0, 'EIPC': 0, 'MM': 0, 'IM': 0, 'SPB': 0}
    minor_errors_pub = {'TR': 0, 'SIL': 0, 'SB': 0, 'CMM': 0, 'CMP': 0,
                        'EM': 0, 'EIPC': 0, 'MM': 0, 'IM': 0, 'SPB': 0}
    major_total = 0
    minor_total = 0
    error_list_total = [0]*30
    ppm_total = []

    job_row_list = []
    total_pages = 0
    total_fpy_inter_1 = 0
    total_fpy_inter_2 = 0
    total_fpy_calc = 0
    total_dup_calc = 0
    job_site_total = [0]*12
    find_site_total = [0]*12
    ppm_site_total = [0]*12
    tr_errors = [0]*30
    sil_errors = [0]*30
    sb_errors = [0]*30
    cmm_errors = [0]*30
    cmp_errors = [0]*30
    em_errors = [0]*30
    eipc_errors = [0]*30
    mm_errors = [0]*30
    im_errors = [0]*30
    spb_errors = [0]*30
    new_error_list = [[0]*30]*10

    table3_pub_total = [0]*10
    total_pub_unique = [0] * 10
    type_list = ['TR', 'SIL', 'SB', 'CMM', 'CMP', 'EM', 'EIPC', 'MM', 'IM', 'SPB']
    site_list = ['500', '513', '517', '518', '519', '521', '522', '526', '528', '529', '530', '534']
    total_row_pub_type = [0]*10
    unique_pages_pub = [0]*10

    for log in results:
        job = log.jobs
        current_jt = job[0].type_of_publication
        current_jn = job[0].job_no

        # Remove all jobs that don't have the correct type or site information
        if str(current_jt) in type_list:
            if str((current_jn)[0:3]) in site_list:
                job = log.jobs
                dup_jn += [current_jn]
                jn_er = str(current_jn) + 'ER' + str(log.er)
                dup_jn_er += [jn_er]
                checklist_data = json.loads(log.data)
                stored_data = list(checklist_data.values())
                date_range += [stored_data[0]]
                er_level_list += [int(log.er)]  # ER level- JIRA import
                total_pages += int(stored_data[1])
    er_dict = ({0: 0})
    if er_level_list != []:
        if max(er_level_list) > 0:
            er_dict.update({i+1: 0 for i in range(max(er_level_list))})

    dup_jn_er_dict = {i: dup_jn_er.count(i) for i in dup_jn_er}

    table4_dates = {i: [0]*10 for i in date_range}

    for log in results:
        job = log.jobs
        current_jn = job[0].job_no
        current_jt = job[0].type_of_publication

        # Remove all jobs that don't have the correct type or site information
        if str(current_jt) in type_list:
            if str((current_jn)[0:3]) in site_list:
                site = str(current_jn)[0:3]
                checklist_data = json.loads(log.data)
                stored_data = list(checklist_data.values())
                jn_er = str(current_jn) + 'ER' + str(log.er)
                dates = stored_data[0]
                checked = log.created_by
                er = int(log.er)
                tp = stored_data[1]
                count_er = int(er_dict.get(er))
                count_er += 1
                er_dict.update({er: count_er})

                # Not all errors in the standard DPMO checklists are needed
                error_list = [stored_data[3].get('Number of errors'),
                                stored_data[4].get('Number of errors'),
                                stored_data[5].get('Number of errors'),
                                stored_data[6].get('Number of errors'),
                                stored_data[7].get('Number of errors'),
                                stored_data[8].get('Number of errors'),
                                stored_data[9].get('Number of errors'),
                                stored_data[10].get('Number of errors'),
                                stored_data[11].get('Number of errors'),
                                stored_data[12].get('Number of errors'),
                                stored_data[13].get('Number of errors'),
                                stored_data[14].get('Number of errors'),
                                stored_data[15].get('Number of errors'),
                                stored_data[16].get('Number of errors'),
                                stored_data[17].get('Number of errors'),
                                stored_data[18].get('Number of errors'),
                                stored_data[19].get('Number of errors'),
                                stored_data[20].get('Number of errors'),
                                stored_data[21].get('Number of errors'),
                                stored_data[22].get('Number of errors'),
                                stored_data[23].get('Number of errors'),
                                stored_data[24].get('Number of errors'),
                                stored_data[25].get('Number of errors'),
                                stored_data[26].get('Number of errors'),
                                stored_data[27].get('Number of errors'),
                                stored_data[28].get('Number of errors'),
                                stored_data[30].get('Number of errors'),
                                stored_data[31].get('Number of errors'),
                                stored_data[32].get('Number of errors'),
                                stored_data[33].get('Number of errors')]

                def fn(list1, list2):
                    new_list = []
                    for x, y in zip(list1, list2):
                        new_list += [int(x)+int(y)]
                    return new_list

                for pubtype, errors_1, step1 in zip(type_list, new_error_list, list(range(len(type_list)))):
                    if str(current_jt) == pubtype:
                        new_list = fn(errors_1, error_list)
                        new_error_list[step1] = new_list

                for step, total, indiv in zip(range(len(error_list_total)), error_list_total, error_list):
                    error_list_total[step] += int(error_list[step])

                minor_error_count = int(error_list[2]) + int(error_list[9]) +\
                    int(error_list[19]) + int(error_list[24]) +\
                    int(error_list[25]) + int(error_list[29])

                total_errors = 0
                for x in error_list:
                    total_errors += int(x)
                major_error_count = total_errors - minor_error_count

                major_errors_inter = major_errors_pub.get(current_jt)
                major_errors_pub.update({current_jt:
                                        (major_errors_inter +
                                            major_error_count)})
                major_total += int(major_error_count)

                minor_errors_inter = minor_errors_pub.get(current_jt)
                minor_errors_pub.update({current_jt:
                                        (minor_errors_inter +
                                            minor_error_count)})
                minor_total += int(minor_error_count)

                # Table 4 calculation
                if dup_jn_er_dict.get(jn_er) is not False:
                    for pub_type, step in zip(type_list, range(len(type_list))):
                        if current_jt == pub_type:
                            unique_pages_pub[step] += int(tp)
                            dup_jn_er_dict.update({jn_er: False})

                if int(stored_data[1]) == 0:
                    ppm_calc = 0
                else:
                    ppm_calc = int((major_error_count/int(stored_data[1])) * 1000000)
                ppm_total += [ppm_calc]

                count = count_var
                count_var += 1
                if total_errors == 0:
                    fpy_inter_1 = 1
                else:
                    fpy_inter_1 = 0

                dup = dup_jn_er.count(jn_er)
                if dup == 1:
                    fpy_inter_2 = 1
                else:
                    fpy_inter_2 = 0
                if (fpy_inter_1+fpy_inter_2) == 2:
                    fpy_calc = 1
                else:
                    fpy_calc = 0
                type_count = [0]*10
                type_error_list = [tr_errors, sil_errors, sb_errors, cmm_errors, cmp_errors, em_errors, eipc_errors,
                                   mm_errors, im_errors, spb_errors]

                pub_type_total = [0]*10
                pub_type_unique = [0]*10
                for x, y, z in zip(range(len(type_list)), type_list, type_error_list):
                    if current_jt == y:
                        pub_type_total[x] += 1
                        table3_pub_total[x] += 1
                        if fpy_calc == 1:
                            type_count[x] += 1
                            total_row_pub_type[x] += 1
                            pub_type_unique[x] += 1
                            total_pub_unique[x] += 1
                        for step, error in zip(range(len(z)), error_list_total):
                            z[step] += error_list_total[step]
                        type_errors = table4_dates.get(dates)
                        type_errors[x] += total_errors
                        table4_dates.update({dates: type_errors})

                total_fpy_inter_1 += fpy_inter_1
                total_fpy_inter_2 += fpy_inter_2
                total_fpy_calc += fpy_calc
                total_dup_calc += dup

                jobs_site = [0]*12
                find_site = [0]*12
                ppm_site = [0]*12

                for x, y in zip(range(len(jobs_site)), site_list):
                    if site == y:
                        jobs_site[x] = 1
                        find_site[x] = total_errors
                        ppm_site[x] = ppm_calc
                        job_site_total[x] += 1
                        find_site_total[x] += total_errors
                        ppm_site_total[x] += ppm_calc

                job_row = [dates, checked, er, current_jn, current_jt, '', tp] + error_list +\
                        [major_error_count, minor_error_count, ppm_calc, total_errors, count, fpy_inter_1, dup, fpy_inter_2,
                        fpy_calc] + type_count + [jn_er] + jobs_site + find_site + ppm_site
                job_row_list.append(job_row)

    # Adding the 'Totals' row
    if count_var == 0:
        ppm_avg_total = 0
    else:
        ppm_avg_total = (sum(ppm_total))/(count_var)
    total_errors_row = int(major_total) + int(minor_total)

    # calculating total row for Job Number:
    my_dict = {i: dup_jn.count(i) for i in dup_jn}
    jn = len(my_dict.values())

    # calculating total row for JobNumberER:
    my_dict2 = {i: dup_jn_er.count(i) for i in dup_jn_er}
    jobno_er = len(my_dict2.values())

    total_row = ['Total', '', '', jn, '', '', total_pages] + error_list_total +\
                [major_total, minor_total, ppm_avg_total, total_errors_row, '',
                 total_fpy_inter_1, total_dup_calc, total_fpy_inter_2, total_fpy_calc] +\
                total_pub_unique + [jobno_er] + job_site_total + find_site_total + ppm_site_total

    # Table: Heartbeat metrics
    if jobno_er == 0:
        first_pass_yield = 'DIV BY 0'
    else:
        first_pass_yield = (total_fpy_calc/jobno_er)*100
    # first pass yield = total fpy calc / total jn_er
    throughput = jobno_er
    # throughput = total jn_er (unique?)
    total_findings = major_total + minor_total
    # total findings = (all) total major errors + (all) total minor errors
    major_findings = major_total
    # major findings = (all) total major errors
    minor_findings = minor_total
    # minor findings = (all) total minor errors
    average_pmm_level = ppm_avg_total
    # average pmm level = total ppm level (from table, average already done)
    total_pages_checked = total_pages
    # total pages checked = total pages (all)

    # Table 1 creation

    table1_type_inter = type_list
    table1_row_inter = []
    for x, y in zip(table1_type_inter, new_error_list):
        table1_row_inter += [['']*6+[x]+y]

    t1h1="<h4>Table 1: HPS QA Review Checklist</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th colspan='7'>HPS QA Review Checklist</th><th colspan='3'>Change Identification</th><th>Cross Ref</th><th colspan='6'>Illustrated Parts List / Detailed Parts List / Engines</th>" +\
         "<th colspan='3'>Illustrations / figures</th><th>Unit of Measure</th><th>Part Number</th><th>Source Data</th><th colspan='3'>Table</th><th colspan='3'>Template</th>"+\
         "<th colspan='3'>Text</th><th colspan='2'>Warnings / Cautions</th><th colspan='2'>Other</th></tr></thead>"
    t1h2="<thead><tr><th colspan='5'></th><th colspan='2'>Severity</th><th>Technical</th><th>Technical</th><th>Format</th><th>Technical</th><th>Technical</th><th>Technical</th>"+\
         "<th>Technical</th><th>Technical</th><th>Technical</th><th>Format</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Technical</th>"+\
         "<th>Technical</th><th>Technical</th><th>Format</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Format</th><th>Format</th><th>Technical</th><th>Technical</th><th>Technical</th><th>Format</th></tr></thead>"
    t1h3="<thead><tr><th colspan='5'></th><th>Code</th><th>CID-1</th><th>CID-1</th><th>CID-2</th><th>CRF-1</th><th>DPL-3</th><th>DPL-3</th><th>DPL-3</th><th>DPL-3</th><th>DPL-3</th><th>DPL-3</th>"+\
         "<th>Fig 1</th><th>Fig 1</th><th>Fig 2</th><th>MEA-1</th><th>NOM-1</th><th>PN-1</th><th>SRC-1</th><th>TBL-1</th><th>TBL-1</th><th>TBL-2</th><th>TEM-1</th><th>TEM-1</th><th>TEM-1</th><th>TXT-1</th>"+\
         "<th>TXT-2</th><th>TXT-2</th><th>WC-1</th><th>WC-1</th><th>OTH-1</th><th>OTH-2</th>"+\
         "<th colspan='21'></th><th colspan='12'>Jobs by Site</th><th colspan='12'>Quality Findings by Site</th><th colspan='12'>PPM Level by Site</th></tr></thead>"
    t1h4="<thead><tr><th>Date</th><th>Checked By</th><th>ER level</th><th>Job Number</th><th>Job Type</th><th>Changed Pages</th><th>Total Pages</th>"+\
         "<th>A highlight is missing, incorrect, or incomplete</th><th>A rev bar is missing or incorrectly placed</th><th>An asterisk in the LEP is missing or incorrectly placed.</th>" +\
         "<th>A reference or cross-reference is missing or incorrect</th><th>An illustration is technically incorrect or incorrectly formatted</th>"+\
         "<th>An illustration is missing or incorrectly placed</th><th>A wrong illustration is used</th><th>Text is missing or incorrect</th>"+\
         "<th>Text is misused, misspelled, or incorrectly formatted</th><th>Punctuation is missing or misused</th><th>An illustration is technically incorrect or incorrectly formatted</th><th>An illustration is missing or incorrectly placed</th>"+\
         "<th>A wrong illustrations is used</th><th>A unit of measure or metric equivalent is missing, incorrect, or incorrectly formatted</th><th>A part nomenclature is missing</th><th>A part number is missing, incorrect, or incorrectly formatted</th>"+\
         "<th>Source data is not incorporated or not incorporated correctly per the change request or customer-supplied change driver(s)</th><th>A table is missing or incorrectly placed</th><th>A wrong table is used</th><th>A table is incorrectly formatted</th>"+\
         "<th>A wrong template or template revision is used</th><th>Boilerplate text is not updated per Standards Team instructions</th><th>Boilerplate text is modified without Standards Team approval</th><th>Text is technically incorrect, missing, or is incomplete</th>"+\
         "<th>Text is misused or misspelled</th><th>Punctuation is missing or misused</th><th>A warning or caution is missing, incorrectly placed, or incorrectly formatted</th><th>A warning or caution is missing, incorrectly placed, or incorrectly formatted</th>"+\
         "<th>A technical error not listed</th><th>A format error not listed above</th>"+\
         "<th>Major Errors</th><th>Minor Errors</th><th>PPM Level</th><th>Total</th><th>Count</th><th>FPY Intermediate Calculation</th><th>(Duplicates) 1=FPY Pass, 1 &lt FPY Fail</th><th>FPY Intermediate Calculation</th><th>FPY Calculation</th>"+\
         "<th>TR</th><th>SIL</th><th>SB</th><th>CMM</th><th>CMP</th><th>EM</th><th>EIPC</th><th>MM</th><th>IM</th><th>SPB</th><th></th>"+\
         "<th>500</th><th>513</th><th>517</th><th>518</th><th>519</th><th>521</th><th>522</th><th>526</th><th>528</th><th>529</th><th>530</th><th>534</th>"+\
         "<th>500</th><th>513</th><th>517</th><th>518</th><th>519</th><th>521</th><th>522</th><th>526</th><th>528</th><th>529</th><th>530</th><th>534</th>"+\
         "<th>500</th><th>513</th><th>517</th><th>518</th><th>519</th><th>521</th><th>522</th><th>526</th><th>528</th><th>529</th><th>530</th><th>534</th></tr></thead>"
    t1r1 = "<tbody>" + addrows_multi(job_row_list) + addrows_single(total_row) +addrows_multi(table1_row_inter)+ "</tbody></table>"
    table1 = t1h1+t1h2+t1h3+t1h4+t1r1

    tuple0 = ('HPS QA Review Checklist','','','','','','','Change Identification','','','Cross Ref','Illustrated Parts List / Detailed Parts List / Engines','','','','','',
         'Illustrations / figures','','','Unit of Measure','Part Number','Source Data','Table','','','Template','','',
         'Text','', '', 'Warnings / Cautions','','Other')+('','')*29
    tuple1 = ('', '', '', '', '', '','Severity','Technical','Technical','Format','Technical','Technical','Technical',
        'Technical','Technical','Technical','Format','Technical','Technical','Technical','Technical','Technical','Technical','Technical',
        'Technical','Technical','Format','Technical','Technical','Technical','Technical','Format','Format','Technical','Technical','Technical','Format')+('','')*28
    tuple2 = ('', '', '', '', '', '','Code','CID-1','CID-1','CID-2','CRF-1','DPL-3','DPL-3','DPL-3','DPL-3','DPL-3','DPL-3',
        'Fig 1','Fig 1','Fig 2','MEA-1','NOM-1','PN-1','SRC-1','TBL-1','TBL-1','TBL-2','TEM-1','TEM-1','TEM-1','TXT-1',
        'TXT-2','TXT-2','WC-1','WC-1','OTH-1','OTH-2') + ('','')*10 + ('Jobs by Site', '')+('', '')*5+('Quality Findings by Site', '') + ('','')*5 + ('PPM Level by Site', '')+ ('','')*5
    tuple3= ('Date','Checked By','ER level','Job Number','Job Type','Changed Pages','Total Pages',
        'A highlight is missing, incorrect, or incomplete','A rev bar is missing or incorrectly placed','An asterisk in the LEP is missing or incorrectly placed',
        'A reference or cross-reference is missing or incorrect','An illustration is technically incorrect or incorrectly formatted',
        'An illustration is missing or incorrectly placed','A wrong illustration is used','Text is missing or incorrect',
        'Text is misused, misspelled, or incorrectly formatted','Punctuation is missing or misused','An illustration is technically incorrect or incorrectly formatted','An illustration is missing or incorrectly placed',
        'A wrong illustrations is used','A unit of measure or metric equivalent is missing, incorrect, or incorrectly formatted','A part nomenclature is missing','A part number is missing, incorrect, or incorrectly formatted',
        'Source data is not incorporated or not incorporated correctly per the change request or customer-supplied change driver(s)','A table is missing or incorrectly placed','A wrong table is used','A table is incorrectly formatted',
        'A wrong template or template revision is used','Boilerplate text is not updated per Standards Team instructions','Boilerplate text is modified without Standards Team approval','Text is technically incorrect, missing, or is incomplete',
        'Text is misused or misspelled','Punctuation is missing or misused','A warning or caution is missing, incorrectly placed, or incorrectly formatted','A warning or caution is missing, incorrectly placed, or incorrectly formatted',
        'A technical error not listed','A format error not listed above',
        'Major Errors','Minor Errors','PPM Level','Total','Count','FPY Intermediate Calculation','(Duplicates) 1=FPY Pass, 1 &lt FPY Fail','FPY Intermediate Calculation','FPY Calculation',
        'TR','SIL','SB','CMM','CMP','EM','EIPC','MM','IM','SPB','',
        '500','513','517','518','519','521','522','526','528','529','530','534',
        '500','513','517','518','519','521','522','526','528','529','530','534',
        '500','513','517','518','519','521','522','526','528','529','530','534')
    
    columns_l = []
    for x in range(len(tuple0)):
        columns_l += [str(x)]
    df_t1 = [tuple0]
    df_table1 = pd.DataFrame(df_t1, columns=columns_l)
    df_table1 = df_table1.append(pd.Series((list(tuple1)), index=df_table1.columns), ignore_index=True)
    df_table1 = df_table1.append(pd.Series((list(tuple2)), index=df_table1.columns), ignore_index=True)
    df_table1 = df_table1.append(pd.Series((list(tuple3)), index=df_table1.columns), ignore_index=True)

    for x in job_row_list:
        df_table1 = df_table1.append(pd.Series(x, index=df_table1.columns), ignore_index=True)

    df_table1 = df_table1.append(pd.Series(total_row, index=df_table1.columns), ignore_index=True)

    tuple_df_t1_2 = ('', '')*17+('','','')

    columns_l = []
    for x in range(len(tuple_df_t1_2)):
        columns_l += [str(x)]

    df_t1_2 = [tuple_df_t1_2]
    df_table1_2 = pd.DataFrame(df_t1_2, columns=columns_l)
    for x in table1_row_inter:
        df_table1_2 = df_table1_2.append(pd.Series(x, index=df_table1_2.columns), ignore_index=True)

    # Table 2 creation

    t2rows = []
    t2col1 = list(er_dict.keys())
    t2col2 = list(er_dict.values())
    for x, y in zip(t2col1, t2col2):
        t2rows.append([x, y])

    t2h1 = "<h4>Table 2: Number of Jobs per ER Level</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>ER Level</th><th>Number of Jobs</th></tr></thead>"
    t2r1 = "<tbody>" + addrows_multi(t2rows) + "</tbody></table>"
    table2 = t2h1+t2r1

    df_t2 = [('ER Level', 'Number of Jobs')]
    df_table2 = pd.DataFrame(df_t2, columns=['0', '1'])
    for x in t2rows:
        df_table2 = df_table2.append(pd.Series(x, index=df_table2.columns), ignore_index=True)

    # Table 3 creation

    table3_major_sum = sum(list(major_errors_pub.values()))
    table3_minor_sum = sum(list(minor_errors_pub.values()))
    t3rows = []
    fpy_list = []

    for passed, total in zip(table3_pub_total, total_pub_unique):
        if int(passed) == 0:
            value = 'DIV BY 0'
        else:
            value = (int(total))/(int(passed))
        fpy_list += [value]
    for a,b,c,d,e,f,g in zip(type_list, table3_pub_total, total_pub_unique, fpy_list, unique_pages_pub, major_errors_pub.values(), minor_errors_pub.values()):
        if d == 'DIV BY 0':
            t3rows.append([a,b,c,d,e,f,g])
        else:
            t3rows.append([a,b,c,str(d*100)+'%',e,f,g])                           

    t3h1 = "<h4>Table 3: Publication Type Information</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>Publication Type</th><th>Total</th><th>Pass</th><th>FPY</th><th>Total Pages</th><th>Major Errors</th><th>Minor Errors</th></tr></thead>"
    t3r1 = "<tbody>"+addrows_multi(t3rows)+addrows_single(['Total Major', table3_major_sum])+addrows_single(['Total Minor', table3_minor_sum])+"</tbody></table>"
    table3=t3h1+t3r1

    df_t3 = [('Publication Type', 'Total', 'Pass', 'FPY', 'Total Pages', 'Major Errors', 'Minor Errors')]
    df_table3 = pd.DataFrame(df_t3, columns=['0', '1', '2', '3', '4', '5', '6'])
    for x in t3rows:
        df_table3 = df_table3.append(pd.Series(x, index=df_table3.columns), ignore_index=True)
    df_table3 = df_table3.append(pd.Series(['Total Major', table3_major_sum, 'Total Minor', table3_minor_sum, '', '', ''], index=df_table3.columns), ignore_index=True)

    # Table 4 creation

    date_range_list = list(table4_dates.keys())
    date_errors = list(table4_dates.values())
    t4rows = []
    
    if start_date == None or end_date == None:
        if status == 'Date Range':
            flash('Table 4 will only display dates with existing checklists if before and after dates are not specified.')

            for dates in table4_dates.keys():
                t4_row = [dates, sum(list(table4_dates.get(dates)))]
                for x in list(table4_dates.get(dates)):
                    t4_row += [x]
                t4rows += [t4_row]
    else:
        if status == 'Monthly Metrics':
            date_range_t4 = table6_dates
        else:
            date_range_t4 = daterange(start_date, end_date)

        for dates in date_range_t4:
            dates = str(dates.date())
            if table4_dates.get(dates) == None:
                t4_row = [dates] + [0]*11
            else:
                t4_row = [dates, sum(list(table4_dates.get(dates)))]
                for x in list(table4_dates.get(dates)):
                    t4_row += [x]
            t4rows += [t4_row]

    t4h1 = "<h4>Table 4: Defects per Day</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>Date Range (Y-M-D)</th><th>Defects per Day</th><th>TR</th><th>SIL</th><th>SB</th><th>CMM</th><th>CMP</th><th>EM</th><th>EIPC</th><th>MM</th><th>IM</th><th>SPB</th></tr></thead>"
    t4r1 = "<tbody>"+addrows_multi(t4rows)+"</tbody></table>"
    table4 = t4h1+t4r1
    tuple_t4 = ('Date Range (Y-M-D)','Defects per Day','TR','SIL','SB','CMM','CMP','EM','EIPC','MM','IM','SPB')
    columns_l = []
    for x in range(len(tuple_t4)):
        columns_l += [str(x)]

    df_t4 = [tuple_t4]
    df_table4 = pd.DataFrame(df_t4, columns=columns_l)
    for x in t4rows:
        df_table4 = df_table4.append(pd.Series(x, index=df_table4.columns), ignore_index=True)
    
    df_space_inter = [('', '')]
    df_space = pd.DataFrame(df_space_inter, columns=['0', '1'])


    if status == 'Monthly Metrics':

        # TABLE 5: Metrics: Quality Findings

        # Qaulity Findings = description of error
        # Total = (all) total for that error
        # Cumulative = total errors so far (including current error)
        # % = current cumulative/total as a percentage
        # Error % = total for that error/ throughput 
        # Total (at the bottom) = sum(Total column)

        table5_findings = ['A highlight is missing, incorrect, or incomplete', 'A rev bar is missing or incorrectly placed', 'An asterisk in the LEP is missing or incorrectly placed.',
                        'A reference or cross-reference is missing or incorrect', 'An illustration is technically incorrect or incorrectly formatted (DPL-3)',
                        'An illustration is missing or incorrectly placed (DPL-3)', 'A wrong illustration is used', 'Text is missing or incorrect',
                        'Text is misused, misspelled, or incorrectly formatted', 'Punctuation is missing or misused (DPL-3)', 'An illustration is technically incorrect or incorrectly formatted (Fig 1)',
                        'An illustration is missing or incorrectly placed (Fig 2)', 'A wrong illustrations is used', 'A unit of measure or metric equivalent is missing, incorrect, or incorrectly formatted',
                        'A part nomenclature is missing', 'A part number is missing, incorrect, or incorrectly formatted', 'Source data is not incorporated or not incorporated correctly per the change request or customer-supplied change driver(s)',
                        'A table is missing or incorrectly placed', 'A wrong table is used', 'A table is incorrectly formatted', 'A wrong template or template revision is used',
                        'Boilerplate text is not updated per Standards Team instructions', 'Boilerplate text is modified without Standards Team approval',
                        'Text is technically incorrect, missing, or is incomplete', 'Text is misused or misspelled', 'Punctuation is missing or misused (TXT-2)',
                        'A warning or caution is missing, incorrectly placed, or incorrectly formatted', 'A technical error not listed', 'A format error not listed above']
        
        table5_total = error_list_total
        total = sum(table5_total)
        table5_inter = []
        for x, y in zip(table5_findings, table5_total):
            table5_inter.append([x, y])
        table5_total = sorted(table5_inter, key=itemgetter(1))
        table5_find_sorted = []
        table5_total_sorted = []
        for x in table5_total:
            table5_find_sorted += [x[0]]
            table5_total_sorted += [x[1]]
        table5_total_sorted.reverse()
        table5_find_sorted.reverse()

        table5_cumulative = np.cumsum(table5_total_sorted)
        table5_percent = [0]*30
        table5_error_percent = [0]*30

        for step in range(len(table5_total_sorted)):
            if total == 0:
                table5_percent[step] = 'DIV BY 0'
            else:
                table5_percent[step] = (table5_cumulative[step]/total)*100
            if throughput == 0:
                table5_error_percent[step] = 'DIV BY 0'
            else:
                table5_error_percent[step] = (table5_total_sorted[step]/throughput)*100
        
        t5rows = []

        for find, t5total, cumulative, percent, error in zip(table5_find_sorted, table5_total_sorted, table5_cumulative, table5_percent, table5_error_percent):
            if percent == 'DIV BY 0':
                percent_output = percent
            else:
                percent_output = str(round(percent))+'%'
            if error == 'DIV BY 0':
                error_output = error
            else:
                error_output = str(round(error))+'%'
            t5rows.append([find, t5total, cumulative, percent_output, error_output])
        t5h1 = "<h4>Table 6: Quality Findings</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>Quality Findings</th><th>Total</th><th>Cumulative</th><th>%</th><th>Error %</th></tr></thead>"
        t5r1 = "<tbody>"+addrows_multi(t5rows)+addrows_single(['Total', total])+"</tbody></table>"
        table5 = t5h1+t5r1

        df_t5 = [('Quality Findings','Total','Cumulative','%','Error %')]
        df_table5 = pd.DataFrame(df_t5, columns=['0','1','2','3','4'])
        for x in t5rows:
            df_table5 = df_table5.append(pd.Series(x, index=df_table5.columns), ignore_index=True)
        df_table5 = df_table5.append(pd.Series(['Total', total, '', '', ''], index=df_table5.columns), ignore_index=True)

        fig_pareto = make_subplots(specs=[[{"secondary_y": True}]])

        fig_pareto.add_trace(
            go.Bar(x=table5_find_sorted, y=table5_total_sorted, name="Total"),
            secondary_y=False)

        fig_pareto.add_trace(
            go.Scatter(x= table5_find_sorted, y=table5_percent, name="%"),
            secondary_y=True)

        fig_pareto.update_layout(title_text="Pareto of Quality Findings")

        fig_pareto.update_yaxes(title_text="Total", secondary_y=False)
        fig_pareto.update_yaxes(title_text="%", secondary_y=True)
        fig_pareto = plotly.offline.plot(fig_pareto, output_type='div')

        # TABLE 6: Metrics: Defects per Day

        year_input = int(year_input)
        month_input=int(month_input)
        month_start = datetime(year_input, month_input, 1)
        month_end_day = calendar.monthrange(year_input, month_input)[1]
        month_end = datetime(year_input, month_input, month_end_day)
        table6_dates = daterange(month_start, month_end)
            
        defects = []
        
        for x in table6_dates:
            x = str(x.date())
            if table4_dates.get(x) == None:
                defects += [0]
            else:
                defects += [sum(list(table4_dates.get(x)))]
        
        average_single = round_up(np.average(defects), decimals=2)
        defects_inter = np.array(defects)
        ll1 = round_up((average_single)-(1*np.std(defects_inter)), decimals=2)
        ll2 = round_up((average_single)-(2*np.std(defects_inter)), decimals=2)
        ll3 = round_up((average_single)-(3*np.std(defects_inter)), decimals=2)
        ul1 = round_up((average_single)+(1*np.std(defects_inter)), decimals=2)
        ul2 = round_up((average_single)+(2*np.std(defects_inter)), decimals=2)
        ul3 = round_up((average_single)+(3*np.std(defects_inter)), decimals=2)
        table6_average = average_single

        t6rows = []
        for a, b in zip(table6_dates, defects):
            t6rows.append([str(a.date()), b, table6_average, ll1, ll2, ll3, ul1, ul2, ul3])

        t6h1 = "<h4>Table 7: Quality Review Findings</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>Date</th><th>Defects</th><th>Average</th><th>LL1</th><th>LL2</th><th>LL3</th><th>UL1</th><th>UL2</th><th>UL3</th></tr></thead>"
        t6r1 = "<tbody>"+addrows_multi(t6rows)+"</tbody></table>"
        table6 = t6h1+t6r1

        df_t6 = [('Date','Defects','Average','LL1','LL2','LL3','UL1','UL2','UL3')]
        df_table6 = pd.DataFrame(df_t6, columns=['0','1','2','3','4','5','6','7','8'])
        for x in t6rows:
            df_table6 = df_table6.append(pd.Series(x, index=df_table6.columns), ignore_index=True)

        average_fig = [average_single]*len(table6_dates)
        ll1_fig = [ll1]*len(table6_dates)
        ll2_fig = [ll2]*len(table6_dates)
        ll3_fig = [ll3]*len(table6_dates)
        ul1_fig = [ul1]*len(table6_dates)
        ul2_fig = [ul2]*len(table6_dates)
        ul3_fig = [ul3]*len(table6_dates)

        fig_runchart = go.Figure()
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=defects, mode='lines+markers', name='Defects'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=average_fig, mode='lines+markers', name='Average'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ll1_fig, mode='lines', name='LL1'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ll2_fig, mode='lines', name='LL2'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ll3_fig, mode='lines', name='LL3'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ul1_fig, mode='lines', name='UL1'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ul2_fig, mode='lines', name='UL2'))
        fig_runchart.add_trace(go.Scatter(x=table6_dates, y=ul3_fig, mode='lines', name='UL3'))
        fig_runchart.update_layout(title_text="Run Chart Qaulity Review Findings")
        fig_runchart.update_xaxes(title_text="Dates")
        fig_runchart = plotly.offline.plot(fig_runchart, output_type='div')

        # Table 7 creation

        t7rows = []
        for a, b, c, d in zip(site_list, job_site_total, find_site_total, ppm_site_total):
            t7rows.append([a,b,c,d])

        t7h1 = "<h4>Table 8: Site Information</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'><thead><tr><th>Site</th><th>Jobs per Site</th><th>Findings by Site</th><th>AVG PPM Level by Site</th></tr></thead>"
        t7r1 = "<tbody>"+addrows_multi(t7rows)+"</tbody></table>"
        table7 = t7h1+t7r1

        df_t7 = [('Site', 'Jobs per Site', 'Findings by Site', 'AVG PPM Level by Site')]
        df_table7 = pd.DataFrame(df_t7, columns=['0', '1', '2', '3'])
        for x in t7rows:
            df_table7 = df_table7.append(pd.Series(x, index=df_table7.columns), ignore_index=True)

        labels = site_list
        values = job_site_total
        fig_site_inter = go.Figure(data=[go.Pie(labels=labels, values=values)])
        fig_site_inter.update_layout(title_text="Jobs per Site")
        fig_site = plotly.offline.plot(fig_site_inter, output_type='div')

        # Table 8 creation - Heartbeat metrics

        t8_col1 = ['First Pass Yield', 'Throughput', 'Total Findings', 'Major Findings', 'Minor Findings',
                    'Average PPM Level', 'Total Pages Checked']
        if first_pass_yield == 'DIV BY 0':
            fpy = 'DIV BY 0'
        else:
            fpy = str(round(first_pass_yield))+'%'
        t8_col2 = [fpy, throughput, total_findings, major_findings, minor_findings,
                    round(average_pmm_level), total_pages_checked]
        t8rows = []
        for x, y in zip(t8_col1, t8_col2):
            t8rows.append([x,y])
        t8h1= "<h2>Monthly Metrics</h2><br><h4>Table 5: Monthly Metrics</h4><table style='max-height:600px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'>"
        t8r1="<tbody>"+addrows_multi(t8rows)+"</tbody></table>"
        table8= t8h1+t8r1

        df_t8 = [('Metric', 'Value')]
        df_table8 = pd.DataFrame(df_t8, columns=['0', '1'])
        for x in t8rows:
            df_table8 = df_table8.append(pd.Series(x, index=df_table8.columns), ignore_index=True)

        df_table1 = pd.concat([df_table1, df_space, df_table1_2, df_space, df_table2, df_space, df_table3, df_space, df_table4,
                                df_space, df_table8, df_space, df_table5, df_space, df_table6, df_space, df_table7], sort=False)

        return [table1, table2, table3, table4, table5, table6, table7, table8, fig_site, fig_pareto, fig_runchart,
                df_table1]
    else:
        # Only return the first 4 tables for the Date Range
        df_table1 = pd.concat([df_table1, df_space, df_table1_2, df_space, df_table2, df_space, df_table3, df_space, df_table4], sort=False)
        return [table1, table2, table3, table4, df_table1]