from launchpad.checklists.checklist_text import (writer_A, writer_B, writer_C,
                                                 writer_D, writer_E, writer_F,
                                                 writer_G,
                                                 illustration_A, editor_A,
                                                 editor_B,
                                                 editor_C, editor_D, editor_E,
                                                 editor_F,
                                                 editor_G, editor_H, editor_I,
                                                 editor_J,
                                                 qa_A, qa_B, qa_C, qa_D, qa_E,
                                                 qa_G, qa_H, qa_I,
                                                 dl_A, dl_B, dl_C, dl_D, dl_E,
                                                 dl_F, dl_G, dl_H,
                                                 dpmo_A, dpmo_B, dpmo_C,
                                                 dpmo_D, dpmo_E, dpmo_F,
                                                 dpmo_G, dpmo_H, dpmo_I,
                                                 dpmo_J, dpmo_K,
                                                 dpmo_L, dpmo_M, dpmo_N,
                                                 dpmo_O, dpmo_P,
                                                 dc_1, dc_2, dc_3, dc_4, dc_5,
                                                 dc_6, dc_7,
                                                 dc_8, dc_9, dc_10,
                                                 trans_english, trans_french)

# Creates the Table Views for Checklist_manager

def TableViews(checklist_type, row_content_list):
    # Table header section
    max_revision = len(row_content_list)
    headers = []
    jn = "<thead><tr><th></th><th></th><th>Job Number: </th>"
    rev="<thead><tr><th></th><th></th><th>Revision: </th>"
    er_level = "<thead><tr><th></th><th></th><th>ER Level: </th>"
    cl_type ="<thead><tr><th></th><th></th><th>Checklist Type: </th>"
    date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
    created_by ="<thead><tr><th></th><th></th><th>Created By: </th>"
    complete = "<thead><tr><th></th><th></th><th>Status: </th>"
    last_edit_by ="<thead><tr><th></th><th></th><th>Last Edited By: </th>"
    last_edit_date = "<thead><tr><th></th><th></th><th>Last Edited Date: </th>"
    for i in range(max_revision):
        complete += "<th colspan='2'>" + str(row_content_list[i][8]) + "</th>"
        jn+="<th colspan='2'>" + str(row_content_list[i][0]) + "</th>"
        rev+="<th colspan='2'>" + str(row_content_list[i][1]) + "</th>"
        er_level+= "<th colspan='2'>" + str(row_content_list[i][2]) + "</th>"
        cl_type+="<th colspan='2'>" + str(row_content_list[i][3]) + "</th>"
        date_created+="<th colspan='2'>" + str(row_content_list[i][4]) + "</th>"
        created_by+="<th colspan='2'>" + str(row_content_list[i][5]) + "</th>"
        last_edit_by +="<th colspan='2'>" + str(row_content_list[i][6]) + "</th>"
        last_edit_date += "<th colspan='2'>" + str(row_content_list[i][7]) + "</th>"
    jn += "</tr></thead>"
    rev += "</tr></thead>"
    er_level += "</tr></thead>"
    cl_type += "</tr></thead>"
    date_created += "</tr></thead>"
    created_by += "</tr></thead>"
    complete += "</tr></thead>"
    last_edit_by += "</tr></thead>"
    last_edit_date += "</tr></thead>"

    if checklist_type == 'Data Conversion':
        tableh = "<thead><tr><th>Defect Intensity</th><th>Code</th><th>Description</th>"
        pages = "<thead><tr><th></th><th></th><th>Pages Reviewed: </th>"
        major = "<thead><tr><th></th><th></th><th>Total Major Errors: </th>"
        minor = "<thead><tr><th></th><th></th><th>Total Minor Errors: </th>"
        ref_major = "<thead><tr><th></th><th></th><th>Item 10 References as a Major PPM (<7000): </th>"
        ref_minor = "<thead><tr><th></th><th></th><th>Item 10 References as a Minor PPM (<7000): </th>"
        for i in range(max_revision):
            tableh += "<th colspan='2'> Number of Errors </th>"
            pages += "<th colspan='2'>" + str(row_content_list[i][9]) + "</th>"
            major += "<th colspan='2'>" + str(row_content_list[i][10]) + "</th>"
            minor += "<th colspan='2'>" + str(row_content_list[i][11]) + "</th>"
            ref_major += "<th colspan='2'>" + str(row_content_list[i][12]) + "</th>"
            ref_minor += "<th colspan='2'>" + str(row_content_list[i][13]) + "</th>"
        tableh += "</tr></thead>"
        pages += "</tr></thead>"
        major += "</tr></thead>"
        minor += "</tr></thead>"
        ref_major += "</tr></thead>"
        ref_minor += "</tr></thead>"

    if checklist_type == 'Writer' or checklist_type == 'Illustration':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        for i in range(max_revision):
            if str(row_content_list[i][3]) == '':
                strings = 'Comments'
            else:
                if str(row_content_list[i][3]) == '0':
                    strings = 'Pre-Delivery Comments'
                else:
                    strings = 'Engineering Review Comments #'+str(row_content_list[i][3])
            tableh += "<th colspan='2'>"+strings+"</th>"
        if checklist_type == 'Writer':
            author = "<thead><tr><th></th><th></th><th>Writer: </th>"
            date = "<thead><tr><th></th><th></th><th>Date: </th>"
            extra = "<thead><tr><th></th><th></th><th>Number of Changed Pages: </th>"

            for i in range(max_revision):
                author += "<th colspan='2'>" +\
                        str(row_content_list[i][10]) + "</th>"
                date += "<th colspan='2'>" +\
                        str(row_content_list[i][11]) + "</th>"
                extra += "<th colspan='2'>" +\
                        str(row_content_list[i][9]) + "</th>"

        if checklist_type == 'Illustration':
            author = "<thead><tr><th></th><th></th><th>Illustrator: </th>"
            date = "<thead><tr><th></th><th></th><th>Date: </th>"
            extra = "<thead><tr><th></th><th></th><th>Comments: </th>"
            for i in range(max_revision):
                author += "<th colspan='2'>" +\
                        str(row_content_list[i][9]) + "</th>"
                date += "<th colspan='2'>" +\
                        str(row_content_list[i][10]) + "</th>"
                extra += "<th colspan='2'>" +\
                        str(row_content_list[i][11]) + "</th>"

        author += "</tr></thead>"
        date += "</tr></thead>"
        extra += "</tr></thead>"
        tableh += "</tr></thead>"

    if checklist_type == 'Editor':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        author = "<thead><tr><th></th><th></th><th>Editor: </th>"
        date = "<thead><tr><th></th><th></th><th>Date: </th>"
        for i in range(max_revision):
            if str(row_content_list[i][3]) == '':
                strings = 'Comments'
            else:
                if str(row_content_list[i][3]) == '0':
                    strings = 'Pre-Delivery Comments'
                else:
                    strings = 'Engineering Review Comments #'+str(row_content_list[i][3])
            tableh += "<th colspan='2'>"+strings+"</th>"
            author += "<th colspan='2'>" +\
                      str(row_content_list[i][9]) + "</th>"
            date += "<th colspan='2'>" +\
                    str(row_content_list[i][10]) + "</th>"
        author += "</tr></thead>"
        date += "</tr></thead>"
        tableh += "</tr></thead>"

    if checklist_type == 'QA':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        for i in range(max_revision):
            if str(row_content_list[i][3]) == '':
                strings = 'Comments'
            else:
                if str(row_content_list[i][3]) == '0':
                    strings = 'Pre-Delivery Comments'
                else:
                    strings = 'Engineering Review Comments #'+str(row_content_list[i][3])
            tableh += "<th colspan='2'>"+strings+"</th>"
        qa1 = "<thead><tr><th></th><th></th><th>QA (1): </th>"
        date1 = "<thead><tr><th></th><th></th><th>Date (1): </th>"
        qa2 = "<thead><tr><th></th><th></th><th>QA (2): </th>"
        date2 = "<thead><tr><th></th><th></th><th>Date (2): </th>"
        qa3 = "<thead><tr><th></th><th></th><th>QA (3): </th>"
        date3 = "<thead><tr><th></th><th></th><th>Date (3): </th>"
        for i in range(max_revision):
            qa1 += "<th colspan='2'>" + str(row_content_list[i][9]) + "</th>"
            date1 += "<th colspan='2'>" + str(row_content_list[i][10]) + "</th>"
            qa2 += "<th colspan='2'>" + str(row_content_list[i][11]) + "</th>"
            date2 += "<th colspan='2'>" + str(row_content_list[i][12]) + "</th>"
            qa3 += "<th colspan='2'>" + str(row_content_list[i][13]) + "</th>"
            date3 += "<th colspan='2'>" + str(row_content_list[i][14]) + "</th>"
        qa1 += "</tr></thead>"
        date1 += "</tr></thead>"
        qa2 += "</tr></thead>"
        date2 += "</tr></thead>"
        qa3 += "</tr></thead>"
        date3 += "</tr></thead>"
        tableh += "</tr></thead>"

    if checklist_type == 'Final Delivery':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        author = "<thead><tr><th></th><th></th><th>Name: </th>"
        date = "<thead><tr><th></th><th></th><th>Date: </th>"
        for i in range(max_revision):
            tableh += "<th colspan='2'> Completed </th>"
            author += "<th colspan='2'>" +\
                      str(row_content_list[i][9]) + "</th>"
            date += "<th colspan='2'>" +\
                    str(row_content_list[i][10]) + "</th>"
        author += "</tr></thead>"
        date += "</tr></thead>"

    if checklist_type == 'DPMO':
        jn = "<thead><tr><th></th><th>Job Number: </th>"
        rev="<thead><tr><th></th><th>Revision: </th>"
        er_level = "<thead><tr><th></th><th>ER Level: </th>"
        cl_type ="<thead><tr><th></th><th>Checklist Type: </th>"
        date_created = "<thead><tr><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        created_by ="<thead><tr><th></th><th>Created By: </th>"
        complete = "<thead><tr><th></th><th>Status: </th>"
        last_edit_by ="<thead><tr><th></th><th>Last Edited By: </th>"
        last_edit_date = "<thead><tr><th></th><th>Last Edited Date: </th>"
        for i in range(max_revision):
            complete += "<th colspan='2'>" + str(row_content_list[i][8]) + "</th>"
            jn+="<th colspan='2'>" + str(row_content_list[i][0]) + "</th>"
            rev+="<th colspan='2'>" + str(row_content_list[i][1]) + "</th>"
            er_level+= "<th colspan='2'>" + str(row_content_list[i][2]) + "</th>"
            cl_type+="<th colspan='2'>" + str(row_content_list[i][3]) + "</th>"
            date_created+="<th colspan='2'>" + str(row_content_list[i][4]) + "</th>"
            created_by+="<th colspan='2'>" + str(row_content_list[i][5]) + "</th>"
            last_edit_by +="<th colspan='2'>" + str(row_content_list[i][6]) + "</th>"
            last_edit_date += "<th colspan='2'>" + str(row_content_list[i][7]) + "</th>"
        jn += "</tr></thead>"
        rev += "</tr></thead>"
        er_level += "</tr></thead>"
        cl_type += "</tr></thead>"
        date_created += "</tr></thead>"
        created_by += "</tr></thead>"
        complete += "</tr></thead>"
        last_edit_by += "</tr></thead>"
        last_edit_date += "</tr></thead>"

        tableh = "<thead><tr><th></th><th>Subject</th>"
        pages = "<thead><tr><th></th><th>Total Pages: </th>"
        date = "<thead><tr><th></th><th>Date: </th>"
        score = "<thead><tr><th></th><th>DPMO Score: </th>"
        for i in range(max_revision):
            tableh += "<th colspan='2'>Number of Errors</th>"
            pages += "<th colspan='2'>" + str(row_content_list[i][10]) + "</th>"
            date += "<th colspan='2'>" + str(row_content_list[i][9]) + "</th>"
            score += "<th colspan='2'>" + str(row_content_list[i][11]) + "</th>"
        pages += "</tr></thead>"
        score += "</tr></thead>"
        tableh += "</tr></thead>"
        date += "</tr></thead>"

    if checklist_type == 'Translation':
        jn = "<thead><tr><th>Job Number: </th>"
        rev="<thead><tr><th>Revision: </th>"
        er_level = "<thead><tr><th>ER Level: </th>"
        cl_type ="<thead><tr><th>Checklist Type: </th>"
        date_created = "<thead><tr><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        created_by ="<thead><tr><th>Created By: </th>"
        complete = "<thead><tr><th>Status: </th>"
        last_edit_by ="<thead><tr><th>Last Edited By: </th>"
        last_edit_date = "<thead><tr><th>Last Edited Date: </th>"
        for i in range(max_revision):
            complete += "<th colspan='2'>" + str(row_content_list[i][8]) + "</th>"
            jn+="<th colspan='2'>" + str(row_content_list[i][0]) + "</th>"
            rev+="<th colspan='2'>" + str(row_content_list[i][1]) + "</th>"
            er_level+= "<th colspan='2'>" + str(row_content_list[i][2]) + "</th>"
            cl_type+="<th colspan='2'>" + str(row_content_list[i][3]) + "</th>"
            date_created+="<th colspan='2'>" + str(row_content_list[i][4]) + "</th>"
            created_by+="<th colspan='2'>" + str(row_content_list[i][5]) + "</th>"
            last_edit_by +="<th colspan='2'>" + str(row_content_list[i][6]) + "</th>"
            last_edit_date += "<th colspan='2'>" + str(row_content_list[i][7]) + "</th>"
        jn += "</tr></thead>"
        rev += "</tr></thead>"
        er_level += "</tr></thead>"
        cl_type += "</tr></thead>"
        date_created += "</tr></thead>"
        created_by += "</tr></thead>"
        complete += "</tr></thead>"
        last_edit_by += "</tr></thead>"
        last_edit_date += "</tr></thead>"

        tableh = "<thead><tr><th>Subject</th>"
        translator = "<thead><tr><th>Translator: </th>"
        date1 = "<thead><tr><th>Date: </th>"
        date2 = "<thead><tr><th>(Signature) Date: </th>"
        memory_english = "<thead><tr><th>Memory used: </th>"
        memory_french = "<thead><tr><th>Mémoire utilisée: </th>"
        client = "<thead><tr><th>Client: </th>"
        for i in range(max_revision):
            tableh += "<th colspan='2'>Verified</th>"
            date1 += "<th colspan='2'>" +\
                      str(row_content_list[i][9]) + "</th>"
            client += "<th colspan='2'>" +\
                      str(row_content_list[i][10]) + "</th>"
            translator += "<th colspan='2'>" +\
                      str(row_content_list[i][11]) + "</th>"
            date2 += "<th colspan='2'>" +\
                      str(row_content_list[i][12]) + "</th>"
            memory_english += "<th colspan='2'>" +\
                      str(row_content_list[i][13]) + "</th>"
            memory_french += "<th colspan='2'>" +\
                      str(row_content_list[i][14]) + "</th>"
        translator += "</tr></thead>"
        date1 += "</tr></thead>"
        date2 += "</tr></thead>"
        client += "</tr></thead>"
        memory_english += "</tr></thead>"
        memory_french += "</tr></thead>"
        tableh += "</tr></thead>"


    all_headers = "<html><table style='max-height:1000px;' class='table table-responsive table-hover table-bordered table-striped overflow-auto'>"

    if checklist_type == 'Data Conversion':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created + complete +\
                        last_edit_by +last_edit_date +  pages + major + minor + ref_major + ref_minor +tableh
        addrows_var = 13
    if checklist_type == 'Writer' or checklist_type == 'Illustration':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created + complete +\
                        last_edit_by + last_edit_date +\
                        author + date + extra + tableh
        addrows_var = 11
    if checklist_type == 'Editor'or checklist_type == 'Final Delivery':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created +  complete +\
                        last_edit_by + last_edit_date +\
                       author + date + tableh
        addrows_var = 10
    if checklist_type == 'QA':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created +  complete +\
                        last_edit_by + last_edit_date + qa1 + date1 + \
                       qa2 + date2 + qa3 + date3 + tableh
        addrows_var = 14
    if checklist_type == 'DPMO':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created  + complete +\
                        last_edit_by + last_edit_date +\
                       date + pages + score + tableh
        addrows_var = 11

    if checklist_type == 'Translation':
        all_headers += jn + rev + er_level + cl_type + created_by + date_created  + complete +\
                        last_edit_by + last_edit_date +\
                       date1 + client + translator + date2 + memory_english + memory_french + tableh
        addrows_var = 14

    # Table body section
    def addrow(rows):
        row = ""
        if max_revision != 0:
            for i in range(max_revision):
                row += "<td colspan='2'>" + \
                       str(row_content_list[i][rows+addrows_var]) + "</td>"
        return row
    tableb = "<tbody>"
    if checklist_type == 'Data Conversion':
        tableb += "<tr><td> Minor </td><td> 1 </td><td>" + dc_1 + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td> Major </td><td> 2 </td><td>" + dc_2 + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td> Major </td><td> 3 </td><td>" + dc_3 + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 4 </td><td>" + dc_4 + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 5 </td><td>" + dc_5 + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 6 </td><td>" + dc_6 + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td> Major </td><td> 7 </td><td>" + dc_7 + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td> Major </td><td> 8 </td><td>" + dc_8 + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 9 </td><td>" + dc_9 + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td> Major </td><td> 10 </td><td>" + dc_10 + "</td>" + addrow(10) + "</tr>"

    if checklist_type == 'Writer':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Highlights </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_A.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Illustrations </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_B.get(1) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_B.get(2) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_B.get(3) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_B.get(4) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Warnings and Cautions </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_C.get(1) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_C.get(2) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Text </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_D.get(1) + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_D.get(2) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_D.get(3) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_D.get(4) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + writer_D.get(5) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + writer_D.get(6) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + writer_D.get(7) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + writer_D.get(8) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + writer_D.get(9) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + writer_D.get(10) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td></td><td> 11 </td><td>" + writer_D.get(11) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td> 12</td><td>" + writer_D.get(12) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td></td><td> 13 </td><td>" + writer_D.get(13) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td></td><td> 14 </td><td>" + writer_D.get(14) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td> 15 </td><td>" + writer_D.get(15) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td></td><td> 16 </td><td>" + writer_D.get(16) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td></td><td> 17 </td><td>" + writer_D.get(17) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td> 18 </td><td>" + writer_D.get(18) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td> 19 </td><td>" + writer_D.get(19) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td></td><td> 20 </td><td>" + writer_D.get(20) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td> 21 </td><td>" + writer_D.get(21) + "</td>" + addrow(30) + "</tr>"
        tableb += "<tr><td></td><td> 22 </td><td>" + writer_D.get(22) + "</td>" + addrow(31) + "</tr>"
        tableb += "<tr><td></td><td> 23 </td><td>" + writer_D.get(23) + "</td>" + addrow(32) + "</tr>"
        tableb += "<tr><td></td><td> 24 </td><td>" + writer_D.get(24) + "</td>" + addrow(33) + "</tr>"
        tableb += "<tr><td></td><td> 25 </td><td>" + writer_D.get(25) + "</td>" + addrow(34) + "</tr>"
        tableb += "<tr><td></td><td> 26 </td><td>" + writer_D.get(26) + "</td>" + addrow(35) + "</tr>"
        tableb += "<tr><td></td><td> 27 </td><td>" + writer_D.get(27) + "</td>" + addrow(36) + "</tr>"
        tableb += "<tr><td></td><td> 28 </td><td>" + writer_D.get(28) + "</td>" + addrow(37) + "</tr>"
        tableb += "<tr><td></td><td> 29 </td><td>" + writer_D.get(29) + "</td>" + addrow(38) + "</tr>"
        tableb += "<tr><td></td><td> 30 </td><td>" + writer_D.get(30) + "</td>" + addrow(39) + "</tr>"
        tableb += "<tr><td></td><td> 31 </td><td>" + writer_D.get(31) + "</td>" + addrow(40) + "</tr>"
        tableb += "<tr><td></td><td> 32 </td><td>" + writer_D.get(32) + "</td>" + addrow(41) + "</tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> IPC/IPL </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_E.get(1) + "</td>" + addrow(42) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_E.get(2) + "</td>" + addrow(43) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_E.get(3) + "</td>" + addrow(44) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_E.get(4) + "</td>" + addrow(45) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + writer_E.get(5) + "</td>" + addrow(46) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + writer_E.get(6) + "</td>" + addrow(47) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + writer_E.get(7) + "</td>" + addrow(48) + "</tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + writer_E.get(8) + "</td>" + addrow(49) + "</tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + writer_E.get(9) + "</td>" + addrow(50) + "</tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + writer_E.get(10) + "</td>" + addrow(51) + "</tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> SGML</b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_F.get(1) + "</td>" + addrow(52) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_F.get(2) + "</td>" + addrow(53) + "</tr>"
        tableb += "<tr><td><b> G</b><td></td></td><td><b> QA Requirements </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_G.get(1) + "</td>" + addrow(54) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_G.get(2) + "</td>" + addrow(55) + "</tr>"

    if checklist_type == 'Illustration':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Illustration </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + illustration_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + illustration_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + illustration_A.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + illustration_A.get(4) + "</td>" + addrow(4) + "</tr>"

    if checklist_type == 'Editor':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> File Names </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Highlight Letter </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_B.get(1) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_B.get(2) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Title Page </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_C.get(1) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_C.get(2) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_C.get(3) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_C.get(4) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Text </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_D.get(1) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_D.get(2) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_D.get(3)  + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_D.get(4) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_D.get(5) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + editor_D.get(6) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + editor_D.get(7) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + editor_D.get(8) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + editor_D.get(9) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + editor_D.get(10) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td></td><td> 11 </td><td>" + editor_D.get(11) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td></td><td> 12 </td><td>" + editor_D.get(12) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td></td><td> 13 </td><td>" + editor_D.get(13) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td> 14 </td><td>" + editor_D.get(14) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td></td><td> 15 </td><td>" + editor_D.get(15) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td></td><td> 16 </td><td>" + editor_D.get(16) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td> 17 </td><td>" + editor_D.get(17) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td></td><td> 18 </td><td>" + editor_D.get(18) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td></td><td> 19 </td><td>" + editor_D.get(19) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td> 20 </td><td>" + editor_D.get(20) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td> 21 </td><td>" + editor_D.get(21) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> References </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_E.get(1) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_E.get(2) + "</td>" + addrow(30) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_E.get(3) + "</td>" + addrow(31) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_E.get(4) + "</td>" + addrow(32) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_E.get(5) + "</td>" + addrow(33) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + editor_E.get(6) + "</td>" + addrow(34) + "</tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> IPL </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_F.get(1) + "</td>" + addrow(35) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_F.get(2) + "</td>" + addrow(36) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_F.get(3) + "</td>" + addrow(37) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_F.get(4) + "</td>" + addrow(38) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_F.get(5) + "</td>" + addrow(39) + "</tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Table of Contents </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_G.get(1) + "</td>" + addrow(40) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_G.get(2) + "</td>" + addrow(41) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_G.get(3) + "</td>" + addrow(42) + "</tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> List of Effective Pages </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_H.get(1) + "</td>" + addrow(43) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_H.get(2) + "</td>" + addrow(44) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_H.get(3) + "</td>" + addrow(45) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_H.get(4) + "</td>" + addrow(46) + "</tr>"
        tableb += "<tr><td><b> I </b><td></td></td><td><b> Illustrations </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_I.get(1) + "</td>" + addrow(47) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_I.get(2) + "</td>" + addrow(48) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_I.get(3) + "</td>" + addrow(49) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_I.get(4) + "</td>" + addrow(50) + "</tr>"
        tableb += "<tr><td><b> J </b><td></td></td><td><b> QA Requirements </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_J.get(1) + "</td>" + addrow(51) + "</tr>"

    if checklist_type == 'QA':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Title and Front Matter Pages </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> List of Effective Pages (LEP) </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_B.get(1) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_B.get(2) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_B.get(3) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Text (Spot Checks) </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_C.get(1) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_C.get(2) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_C.get(3) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_C.get(4) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + qa_C.get(5)  + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + qa_C.get(6) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + qa_C.get(7) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + qa_C.get(8) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Illustrations </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_D.get(1) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_D.get(2) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_D.get(3) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_D.get(4) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> Highlights Page </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_E.get(1) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_E.get(2) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Miscellaneous </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_G.get(1) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_G.get(2) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> QA2 </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_H.get(1) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_H.get(2) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_H.get(3) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_H.get(4) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + qa_H.get(5) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + qa_H.get(6) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + qa_H.get(7) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td><b> I </b><td></td></td><td><b> Delivery for Review </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_I.get(1) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_I.get(2) + "</td>" + addrow(30) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_I.get(3) + "</td>" + addrow(31) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_I.get(4) + "</td>" + addrow(32) + "</tr>"

    if checklist_type == 'Final Delivery':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> File Names and Folder Structure </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_A.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Temporary Revisions </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_B.get(1) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_B.get(2) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_B.get(3) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_B.get(4) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + dl_B.get(5) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Manual Revisions </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_C.get(1) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_C.get(2)  + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_C.get(3) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_C.get(4) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Final Review </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_D.get(1) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_D.get(2) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_D.get(3) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> Workflow Requirements </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_E.get(1) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_E.get(2) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> Front Matter </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_F.get(1) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_F.get(2) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_F.get(3) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_F.get(4) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + dl_F.get(5) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + dl_F.get(6) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + dl_F.get(7) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Miscellaneous </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_G.get(1) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_G.get(2) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_G.get(3) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_G.get(4) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> Notifications </b></td></tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_H.get(1) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_H.get(2) + "</td>" + addrow(30) + "</tr>"

    if checklist_type == 'DPMO':
        tableb += "<tr><td></td><td><b> Change Identification </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_A.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td></td><td><b> Cross-Reference </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_B.get(1) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td><b>Illustrated Parts List / Detailed Parts List / Engines </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(1) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(2) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(3) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(4) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(5) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_C.get(6)  + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td><b> Illustration / Figure </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(1) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(2) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(3) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td></td><td><b> Unit of Measure </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_E.get(1) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td><b> Part Nomenclature </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_F.get(1) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td></td><td><b> Part Number </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_G.get(1) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td><b> Source Data </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_H.get(1) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td></td><td><b> Table </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_I.get(1) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_I.get(2) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_I.get(3) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td><b> Template </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(1) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(2) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(3) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td><b> Text </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_K.get(1) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_K.get(2) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_K.get(3) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td><b> TR Collation </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_L.get(1) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td><b> Warnings / Cautions </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_M.get(1) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_M.get(2) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td><b> Other </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_N.get(1) + "</td>" + addrow(30) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_N.get(2) + "</td>" + addrow(31) + "</tr>"
        tableb += "<tr><td></td><td><b> Final Quality Check </b></td></tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(1) + "</td>" + addrow(32) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(2) + "</td>" + addrow(33) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(3) + "</td>" + addrow(34) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(4) + "</td>" + addrow(35) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(5) + "</td>" + addrow(36) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(6) + "</td>" + addrow(37) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(7) + "</td>" + addrow(38) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_O.get(8) + "</td>" + addrow(39) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_O.get(9) + "</td>" + addrow(40) + "</tr>"
        tableb += "<tr><td></td><td><b> Software / Code </b></td></tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_P.get(1) + "</td>" + addrow(41) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_P.get(2) + "</td>" + addrow(42) + "</tr>"


    if checklist_type == 'Translation':
        tableb += "<tr><td>" + trans_english.get(1) + "<br><br>" + trans_french.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(2) + "<br><br>" + trans_french.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(3) + "<br><br>" + trans_french.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(4) + "<br><br>" + trans_french.get(4) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(5) + "<br><br>" + trans_french.get(5) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(6) + "<br><br>" + trans_french.get(6) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(7) + "<br><br>" + trans_french.get(7) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(8) + "<br><br>" + trans_french.get(8) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(9) + "<br><br>" + trans_french.get(9) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(10) + "<br><br>" + trans_french.get(10) + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(11) + "<br><br>" + trans_french.get(11) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td>" + trans_english.get(12) + "<br><br>" + trans_french.get(12) + "</td>" + addrow(12) + "</tr>"
    
    tableb += "</tbody></table>"
    table = all_headers + tableb + "</html>"
    return table