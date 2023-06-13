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

# Creates the index tables for all the checklists


def TableCreation(checklist_type, max_revision, row_content_list, job_no):
    # Table header section
    headers = []
    if checklist_type == 'Data Conversion':
        tableh = "<thead><tr><th>Defect Intensity</th><th>Code</th><th>Description</th>"
        updatelink = 'data_conversion_update'
        deletelink = 'data_conversion_delete'
        export_excel_link = 'data_conversion_export_excel'
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):

            er = str(row_content_list[i][3])
            strings = 'Error Count'
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            er_row += "<th colspan='3'>" + er + "</th>"
            headers += [strings]
        pages = "<thead><tr><th></th><th></th><th>Pages Reviewed: </th>"
        complete = "<thead><tr><th></th><th></th><th>Status: </th>"

        major = "<thead><tr><th></th><th></th><th>Total Major Errors: </th>"
        minor = "<thead><tr><th></th><th></th><th>Total Minor Errors: </th>"
        ref_major = "<thead><tr><th></th><th></th><th>Item 10 References as a Major PPM (<7000): </th>"
        ref_minor = "<thead><tr><th></th><th></th><th>Item 10 References as a Minor PPM (<7000): </th>"
        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'

            complete += "<th colspan='3'>" + status + "</th>"
            pages += "<th colspan='3'>" + str(row_content_list[i][4]) + "</th>"
            major += "<th colspan='3'>" + str(row_content_list[i][5]) + "</th>"
            minor += "<th colspan='3'>" + str(row_content_list[i][6]) + "</th>"
            ref_major += "<th colspan='3'>" + str(row_content_list[i][7]) + "</th>"
            ref_minor += "<th colspan='3'>" + str(row_content_list[i][8]) + "</th>"
        pages += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"
        complete += "</tr></thead>"
        major += "</tr></thead>"
        minor += "</tr></thead>"
        ref_major += "</tr></thead>"
        ref_minor += "</tr></thead>"
        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"

    if checklist_type == 'Writer' or checklist_type == 'Illustration':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):
            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            if er == '':
                strings = 'Comments'
                headers += [strings]
            else:
                if er == '0':
                    strings = 'Pre-Delivery Comments'
                    headers += [strings]
                else:
                    strings = 'Engineering Review Comments #' + str(er)
                    headers += [strings]
        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th></th><th>Status:</th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"

        if checklist_type == 'Writer':
            updatelink = 'writer_update'
            deletelink = 'writer_delete'
            export_excel_link = 'writer_export_excel'
            author = "<thead><tr><th></th><th></th><th>Writer: </th>"
            date = "<thead><tr><th></th><th></th><th>Date: </th>"
            extra = "<thead><tr><th></th><th></th><th>Number of Changed Pages: </th>"

        if checklist_type == 'Illustration':
            updatelink = 'illustration_update'
            deletelink = 'illustration_delete'
            export_excel_link = 'illustration_export_excel'
            author = "<thead><tr><th></th><th></th><th>Illustrator: </th>"
            date = "<thead><tr><th></th><th></th><th>Date: </th>"
            extra = "<thead><tr><th></th><th></th><th>Comments: </th>"

        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            complete += "<th colspan='3'>" +\
                      status + "</th>"
            author += "<th colspan='3'>" +\
                      str(row_content_list[i][4]) + "</th>"
            date += "<th colspan='3'>" +\
                    str(row_content_list[i][5]) + "</th>"
            extra += "<th colspan='3'>" +\
                     str(row_content_list[i][6]) + "</th>"
        author += "</tr></thead>"
        complete += "</tr></thead>"
        date += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"
        extra += "</tr></thead>"

    if checklist_type == 'Editor':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):
            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            if er == '':
                strings = 'Comments'
                headers += [strings]
            else:
                if er == '0':
                    strings = 'Pre-Delivery Comments'
                    headers += [strings]
                else:
                    strings = 'Engineering Review Comments #' + str(er)
                    headers += [strings]
        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th></th><th>Status:</th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        updatelink = 'editor_update'
        deletelink = 'editor_delete'
        export_excel_link = 'editor_export_excel'
        author = "<thead><tr><th></th><th></th><th>Editor: </th>"
        date = "<thead><tr><th></th><th></th><th>Date: </th>"
        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            author += "<th colspan='3'>" +\
                      str(row_content_list[i][4]) + "</th>"
            complete += "<th colspan='3'>" +\
                      status + "</th>"
            date += "<th colspan='3'>" +\
                    str(row_content_list[i][5]) + "</th>"
        author += "</tr></thead>"
        date += "</tr></thead>"
        complete += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"

    if checklist_type == 'Translation':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):
            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            strings = 'Verified'
            headers += [strings]

        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th></th><th>Status:</th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        updatelink = 'translation_update'
        deletelink = 'translation_delete'
        export_excel_link = 'translation_export_pdf'
        translator = "<thead><tr><th></th><th></th><th>Translator: </th>"
        date1 = "<thead><tr><th></th><th></th><th>Date: </th>"
        date2 = "<thead><tr><th></th><th></th><th>(Signature) Date: </th>"
        memory_english = "<thead><tr><th></th><th></th><th>Memory used: </th>"
        memory_french = "<thead><tr><th></th><th></th><th>Mémoire utilisée: </th>"
        client = "<thead><tr><th></th><th></th><th>Client: </th>"

        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            complete += "<th colspan='3'>" +\
                      status + "</th>"
            date1 += "<th colspan='3'>" +\
                      str(row_content_list[i][4]) + "</th>"
            client += "<th colspan='3'>" +\
                      str(row_content_list[i][5]) + "</th>"
            translator += "<th colspan='3'>" +\
                      str(row_content_list[i][6]) + "</th>"
            date2 += "<th colspan='3'>" +\
                      str(row_content_list[i][7]) + "</th>"
            memory_english += "<th colspan='3'>" +\
                      str(row_content_list[i][8]) + "</th>"
            memory_french += "<th colspan='3'>" +\
                      str(row_content_list[i][9]) + "</th>"
        translator += "</tr></thead>"
        date1 += "</tr></thead>"
        date2 += "</tr></thead>"
        client += "</tr></thead>"
        memory_english += "</tr></thead>"
        memory_french += "</tr></thead>"
        complete += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"

    if checklist_type == 'QA':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):

            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            if er == '':
                strings = 'Comments'
                headers += [strings]
            else:
                if er == '0':
                    strings = 'Pre-Delivery Comments'
                    headers += [strings]
                else:
                    strings = 'Engineering Review Comments #' + str(er)
                    headers += [strings]
        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th></th><th>Status: </th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        updatelink = 'qa_update'
        deletelink = 'qa_delete'
        export_excel_link = 'qa_export_excel'
        qa1 = "<thead><tr><th></th><th></th><th>QA (1): </th>"
        date1 = "<thead><tr><th></th><th></th><th>Date (1): </th>"
        qa2 = "<thead><tr><th></th><th></th><th>QA (2): </th>"
        date2 = "<thead><tr><th></th><th></th><th>Date (2): </th>"
        qa3 = "<thead><tr><th></th><th></th><th>QA (3): </th>"
        date3 = "<thead><tr><th></th><th></th><th>Date (3): </th>"
        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            complete += "<th colspan='3'>" + status + "</th>"
            qa1 += "<th colspan='3'>" + str(row_content_list[i][4]) + "</th>"
            date1 += "<th colspan='3'>" + str(row_content_list[i][5]) + "</th>"
            qa2 += "<th colspan='3'>" + str(row_content_list[i][6]) + "</th>"
            date2 += "<th colspan='3'>" + str(row_content_list[i][7]) + "</th>"
            qa3 += "<th colspan='3'>" + str(row_content_list[i][8]) + "</th>"
            date3 += "<th colspan='3'>" + str(row_content_list[i][9]) + "</th>"
        qa1 += "</tr></thead>"
        date1 += "</tr></thead>"
        complete += "</tr></thead>"
        qa2 += "</tr></thead>"
        date2 += "</tr></thead>"
        qa3 += "</tr></thead>"
        date3 += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"

    if checklist_type == 'Final Delivery':
        tableh = "<thead><tr><th></th><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):
            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            strings = 'Completed'
            headers += [strings]
        icons = "<thead><tr><th></th><th></th><th></th>"
        created_by = "<thead><tr><th></th><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th></th><th>Status: </th>"
        date_created = "<thead><tr><th></th><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        updatelink = 'final_delivery_update'
        deletelink = 'final_delivery_delete'
        export_excel_link = 'final_delivery_export_excel'
        author = "<thead><tr><th></th><th></th><th>Name: </th>"
        date = "<thead><tr><th></th><th></th><th>Date: </th>"
        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            complete += "<th colspan='3'>" +\
                      status + "</th>"
            author += "<th colspan='3'>" +\
                      str(row_content_list[i][4]) + "</th>"
            date += "<th colspan='3'>" +\
                    str(row_content_list[i][5]) + "</th>"
        author += "</tr></thead>"
        date += "</tr></thead>"
        complete += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"

    if checklist_type == 'DPMO':
        tableh = "<thead><tr><th></th><th>Subject</th>"
        rev_row = "<thead><tr><th></th><th>Revision: </th>"
        er_row = "<thead><tr><th></th><th>Engineering Review Level: </th>"
        for i in range(max_revision):
            er = str(row_content_list[i][3])
            er_row += "<th colspan='3'>" + er + "</th>"
            rev_row += "<th colspan='3'>" + str(i+1) + "</th>"
            strings = 'Number of Errors'
            headers += [strings]

        icons = "<thead><tr><th></th><th></th>"
        created_by = "<thead><tr><th></th><th>Created By:</th>"
        complete = "<thead><tr><th></th><th>Status:</th>"
        date_created = "<thead><tr><th></th><th>Date Created: <br> (Y-M-D H:M:S)</th>"
        updatelink = 'dpmo_update'
        deletelink = 'dpmo_delete'
        export_excel_link = 'dpmo_export_excel'
        pages = "<thead><tr><th></th><th>Total Pages: </th>"
        date = "<thead><tr><th></th><th>Date: </th>"
        score = "<thead><tr><th></th><th>DPMO Score: </th>"
        for i in range(max_revision):
            if str(row_content_list[i][0]) == "True":
                status = 'Complete'
            else:
                status = 'Incomplete'
            complete += "<th colspan='3'>" + status + "</th>"
            pages += "<th colspan='3'>" + str(row_content_list[i][5]) + "</th>"
            date += "<th colspan='3'>" + str(row_content_list[i][4]) + "</th>"
            score += "<th colspan='3'>" + str(row_content_list[i][6]) + "</th>"
        pages += "</tr></thead>"
        score += "</tr></thead>"
        complete += "</tr></thead>"
        date += "</tr></thead>"
        er_row += "</tr></thead>"
        rev_row += "</tr></thead>"
    all_headers = "<html><table class='bottomBorder'>"

    for i in range(max_revision):
        icons += "<td><a class='material-icons' style='font-size:24px;color:black;text-decoration:None' id=" + \
                  updatelink + " href=\"" + updatelink + "/" + job_no+"/" + \
                  str(i+1)+"\">create</a></td>"
        icons += "<td><a class='material-icons' style='font-size:24px;color:black;text-decoration:None' id=" + \
                  export_excel_link + " href=\"" + export_excel_link + "/" + job_no+ "/" + \
                  str(i+1)+"\">arrow_downward</a></td>"
        icons += "<th><a class='material-icons' style='font-size:24px;color:black;text-decoration:None' id=" + \
                 deletelink + " href=\"" + deletelink + "/" + job_no + \
                 "/" + str(i+1) + "/"+checklist_type + \
                 "\" onclick='return confirmDelete();'>delete_forever</a></th>"
        created_by += "<th colspan='3'>" +\
                      str(row_content_list[i][1]) + "</th>"
        date_created += "<th colspan='3'>" +\
                        str(row_content_list[i][2]) + "</th>"
        tableh += "<th colspan='3'>" + headers[i] + "</th>"
    icons += "</tr></thead>"
    created_by += "</tr></thead>"
    date_created += "</tr></thead>"
    tableh += "</tr></thead>"

    if checklist_type == 'Data Conversion':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + pages + \
                       major + minor + ref_major + ref_minor + tableh
        addrows_var = 8
    if checklist_type == 'Writer' or checklist_type == 'Illustration':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + \
                       author + date + extra + tableh
        addrows_var = 6
    if checklist_type == 'Editor'or checklist_type == 'Final Delivery':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + \
                       author + date + tableh
        addrows_var = 5
    if checklist_type == 'QA':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + qa1 + date1 + \
                       qa2 + date2 + qa3 + date3 + tableh
        addrows_var = 9
    if checklist_type == 'DPMO':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + \
                       date + pages + score + tableh
        addrows_var = 6
    if checklist_type == 'Translation':
        all_headers += icons + er_row + rev_row + complete + created_by + date_created + \
                       date1 + client + translator + date2 + memory_english + memory_french + tableh
        addrows_var = 9

    # Table body section

    def addrow(rows):
        row = ""
        if max_revision != 0:
            for i in range(max_revision):
                row += "<td colspan='3'>" + \
                       str(row_content_list[i][rows+addrows_var]) + "</td>"
        return row

    def addth():
        row = ""
        if max_revision != 0:
            for i in range(max_revision):
                row += "<td colspan='3'></td>"
        return row
    tableb = "<tbody>"
    if checklist_type == 'Data Conversion':
        tableb += "<tr><td> Minor </td><td> 1 </td><td>" + dc_1 + "</td><td>" + addrow(1) + "</tr>"
        tableb += "<tr><td> Major </td><td> 2 </td><td>" + dc_2 + "</td><td>" + addrow(2) + "</tr>"
        tableb += "<tr><td> Major </td><td> 3 </td><td>" + dc_3 + "</td><td>" + addrow(3) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 4 </td><td>" + dc_4 + "</td><td>" + addrow(4) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 5 </td><td>" + dc_5 + "</td><td>" + addrow(5) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 6 </td><td>" + dc_6 + "</td><td>" + addrow(6) + "</tr>"
        tableb += "<tr><td> Major </td><td> 7 </td><td>" + dc_7 + "</td><td>" + addrow(7) + "</tr>"
        tableb += "<tr><td> Major </td><td> 8 </td><td>" + dc_8 + "</td><td>" + addrow(8) + "</tr>"
        tableb += "<tr><td> Minor </td><td> 9 </td><td>" + dc_9 + "</td><td>" + addrow(9) + "</tr>"
        tableb += "<tr><td> Major </td><td> 10 </td><td>" + dc_10 + "</td><td>" + addrow(10) + "</tr>"

    if checklist_type == 'Writer':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Highlights </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_A.get(1) + "</td><td>" + addrow(1) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_A.get(2) + "</td><td>" + addrow(2) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_A.get(3) + "</td><td>" + addrow(3) + "</td></tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Illustrations </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_B.get(1) + "</td><td>" + addrow(4) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_B.get(2) + "</td><td>" + addrow(5) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_B.get(3) + "</td><td>" + addrow(6) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_B.get(4) + "</td><td>" + addrow(7) + "</td></tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Warnings and Cautions </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_C.get(1) + "</td><td>" + addrow(8) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_C.get(2) + "</td><td>" + addrow(9) + "</td></tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Text </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_D.get(1) + "</td><td>" + addrow(10) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_D.get(2) + "</td><td>" + addrow(11) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_D.get(3) + "</td><td>" + addrow(12) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_D.get(4) + "</td><td>" + addrow(13) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + writer_D.get(5) + "</td><td>" + addrow(14) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + writer_D.get(6) + "</td><td>" + addrow(15) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + writer_D.get(7) + "</td><td>" + addrow(16) + "</td></tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + writer_D.get(8) + "</td><td>" + addrow(17) + "</td></tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + writer_D.get(9) + "</td><td>" + addrow(18) + "</td></tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + writer_D.get(10) + "</td><td>" + addrow(19) + "</td></tr>"
        tableb += "<tr><td></td><td> 11 </td><td>" + writer_D.get(11) + "</td><td>" + addrow(20) + "</td></tr>"
        tableb += "<tr><td></td><td> 12</td><td>" + writer_D.get(12) + "</td><td>" + addrow(21) + "</td></tr>"
        tableb += "<tr><td></td><td> 13 </td><td>" + writer_D.get(13) + "</td><td>" + addrow(22) + "</td></tr>"
        tableb += "<tr><td></td><td> 14 </td><td>" + writer_D.get(14) + "</td><td>" + addrow(23) + "</td></tr>"
        tableb += "<tr><td></td><td> 15 </td><td>" + writer_D.get(15) + "</td><td>" + addrow(24) + "</td></tr>"
        tableb += "<tr><td></td><td> 16 </td><td>" + writer_D.get(16) + "</td><td>" + addrow(25) + "</td></tr>"
        tableb += "<tr><td></td><td> 17 </td><td>" + writer_D.get(17) + "</td><td>" + addrow(26) + "</td></tr>"
        tableb += "<tr><td></td><td> 18 </td><td>" + writer_D.get(18) + "</td><td>" + addrow(27) + "</td></tr>"
        tableb += "<tr><td></td><td> 19 </td><td>" + writer_D.get(19) + "</td><td>" + addrow(28) + "</td></tr>"
        tableb += "<tr><td></td><td> 20 </td><td>" + writer_D.get(20) + "</td><td>" + addrow(29) + "</td></tr>"
        tableb += "<tr><td></td><td> 21 </td><td>" + writer_D.get(21) + "</td><td>" + addrow(30) + "</td></tr>"
        tableb += "<tr><td></td><td> 22 </td><td>" + writer_D.get(22) + "</td><td>" + addrow(31) + "</td></tr>"
        tableb += "<tr><td></td><td> 23 </td><td>" + writer_D.get(23) + "</td><td>" + addrow(32) + "</td></tr>"
        tableb += "<tr><td></td><td> 24 </td><td>" + writer_D.get(24) + "</td><td>" + addrow(33) + "</td></tr>"
        tableb += "<tr><td></td><td> 25 </td><td>" + writer_D.get(25) + "</td><td>" + addrow(34) + "</td></tr>"
        tableb += "<tr><td></td><td> 26 </td><td>" + writer_D.get(26) + "</td><td>" + addrow(35) + "</td></tr>"
        tableb += "<tr><td></td><td> 27 </td><td>" + writer_D.get(27) + "</td><td>" + addrow(36) + "</td></tr>"
        tableb += "<tr><td></td><td> 28 </td><td>" + writer_D.get(28) + "</td><td>" + addrow(37) + "</td></tr>"
        tableb += "<tr><td></td><td> 29 </td><td>" + writer_D.get(29) + "</td><td>" + addrow(38) + "</td></tr>"
        tableb += "<tr><td></td><td> 30 </td><td>" + writer_D.get(30) + "</td><td>" + addrow(39) + "</td></tr>"
        tableb += "<tr><td></td><td> 31 </td><td>" + writer_D.get(31) + "</td><td>" + addrow(40) + "</td></tr>"
        tableb += "<tr><td></td><td> 32 </td><td>" + writer_D.get(32) + "</td><td>" + addrow(41) + "</td></tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> IPC/IPL </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_E.get(1) + "</td><td>" + addrow(42) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_E.get(2) + "</td><td>" + addrow(43) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + writer_E.get(3) + "</td><td>" + addrow(44) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + writer_E.get(4) + "</td><td>" + addrow(45) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + writer_E.get(5) + "</td><td>" + addrow(46) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + writer_E.get(6) + "</td><td>" + addrow(47) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + writer_E.get(7) + "</td><td>" + addrow(48) + "</td></tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + writer_E.get(8) + "</td><td>" + addrow(49) + "</td></tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + writer_E.get(9) + "</td><td>" + addrow(50) + "</td></tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + writer_E.get(10) + "</td><td>" + addrow(51) + "</td></tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> SGML</b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_F.get(1) + "</td><td>" + addrow(52) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_F.get(2) + "</td><td>" + addrow(53) + "</td></tr>"
        tableb += "<tr><td><b> G</b><td></td></td><td><b> QA Requirements </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + writer_G.get(1) + "</td><td>" + addrow(54) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + writer_G.get(2) + "</td><td>" + addrow(55) + "</td></tr>"

    if checklist_type == 'Illustration':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Illustration </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + illustration_A.get(1) + "</td><td>" + addrow(1) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + illustration_A.get(2) + "</td><td>" + addrow(2) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + illustration_A.get(3) + "</td><td>" + addrow(3) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + illustration_A.get(4) + "</td><td>" + addrow(4) + "</td></tr>"

    if checklist_type == 'Editor':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> File Names </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_A.get(1) + "</td><td>" + addrow(1) + "</td></tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Highlight Letter </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_B.get(1) + "</td><td>" + addrow(2) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_B.get(2) + "</td><td>" + addrow(3) + "</td></tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Title Page </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_C.get(1) + "</td><td>" + addrow(4) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_C.get(2) + "</td><td>" + addrow(5) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_C.get(3) + "</td><td>" + addrow(6) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_C.get(4) + "</td><td>" + addrow(7) + "</td></tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Text </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_D.get(1) + "</td><td>" + addrow(8) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_D.get(2) + "</td><td>" + addrow(9) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_D.get(3)  + "</td><td>" + addrow(10) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_D.get(4) + "</td><td>" + addrow(11) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_D.get(5) + "</td><td>" + addrow(12) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + editor_D.get(6) + "</td><td>" + addrow(13) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + editor_D.get(7) + "</td><td>" + addrow(14) + "</td></tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + editor_D.get(8) + "</td><td>" + addrow(15) + "</td></tr>"
        tableb += "<tr><td></td><td> 9 </td><td>" + editor_D.get(9) + "</td><td>" + addrow(16) + "</td></tr>"
        tableb += "<tr><td></td><td> 10 </td><td>" + editor_D.get(10) + "</td><td>" + addrow(17) + "</td></tr>"
        tableb += "<tr><td></td><td> 11 </td><td>" + editor_D.get(11) + "</td><td>" + addrow(18) + "</td></tr>"
        tableb += "<tr><td></td><td> 12 </td><td>" + editor_D.get(12) + "</td><td>" + addrow(19) + "</td></tr>"
        tableb += "<tr><td></td><td> 13 </td><td>" + editor_D.get(13) + "</td><td>" + addrow(20) + "</td></tr>"
        tableb += "<tr><td></td><td> 14 </td><td>" + editor_D.get(14) + "</td><td>" + addrow(21) + "</td></tr>"
        tableb += "<tr><td></td><td> 15 </td><td>" + editor_D.get(15) + "</td><td>" + addrow(22) + "</td></tr>"
        tableb += "<tr><td></td><td> 16 </td><td>" + editor_D.get(16) + "</td><td>" + addrow(23) + "</td></tr>"
        tableb += "<tr><td></td><td> 17 </td><td>" + editor_D.get(17) + "</td><td>" + addrow(24) + "</td></tr>"
        tableb += "<tr><td></td><td> 18 </td><td>" + editor_D.get(18) + "</td><td>" + addrow(25) + "</td></tr>"
        tableb += "<tr><td></td><td> 19 </td><td>" + editor_D.get(19) + "</td><td>" + addrow(26) + "</td></tr>"
        tableb += "<tr><td></td><td> 20 </td><td>" + editor_D.get(20) + "</td><td>" + addrow(27) + "</td></tr>"
        tableb += "<tr><td></td><td> 21 </td><td>" + editor_D.get(21) + "</td><td>" + addrow(28) + "</td></tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> References </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_E.get(1) + "</td><td>" + addrow(29) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_E.get(2) + "</td><td>" + addrow(30) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_E.get(3) + "</td><td>" + addrow(31) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_E.get(4) + "</td><td>" + addrow(32) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_E.get(5) + "</td><td>" + addrow(33) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + editor_E.get(6) + "</td><td>" + addrow(34) + "</td></tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> IPL </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_F.get(1) + "</td><td>" + addrow(35) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_F.get(2) + "</td><td>" + addrow(36) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_F.get(3) + "</td><td>" + addrow(37) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_F.get(4) + "</td><td>" + addrow(38) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + editor_F.get(5) + "</td><td>" + addrow(39) + "</td></tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Table of Contents </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_G.get(1) + "</td><td>" + addrow(40) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_G.get(2) + "</td><td>" + addrow(41) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_G.get(3) + "</td><td>" + addrow(42) + "</td></tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> List of Effective Pages </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_H.get(1) + "</td><td>" + addrow(43) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_H.get(2) + "</td><td>" + addrow(44) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_H.get(3) + "</td><td>" + addrow(45) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_H.get(4) + "</td><td>" + addrow(46) + "</td></tr>"
        tableb += "<tr><td><b> I </b><td></td></td><td><b> Illustrations </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_I.get(1) + "</td><td>" + addrow(47) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + editor_I.get(2) + "</td><td>" + addrow(48) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + editor_I.get(3) + "</td><td>" + addrow(49) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + editor_I.get(4) + "</td><td>" + addrow(50) + "</td></tr>"
        tableb += "<tr><td><b> J </b><td></td></td><td><b> QA Requirements </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + editor_J.get(1) + "</td><td>" + addrow(51) + "</td></tr>"

    if checklist_type == 'QA':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> Title and Front Matter Pages </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_A.get(1) + "</td><td>" + addrow(1) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_A.get(2) + "</td><td>" + addrow(2) + "</td></tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> List of Effective Pages (LEP) </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_B.get(1) + "</td><td>" + addrow(3) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_B.get(2) + "</td><td>" + addrow(4) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_B.get(3) + "</td><td>" + addrow(5) + "</td></tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Text (Spot Checks) </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_C.get(1) + "</td><td>" + addrow(6) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_C.get(2) + "</td><td>" + addrow(7) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_C.get(3) + "</td><td>" + addrow(8) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_C.get(4) + "</td><td>" + addrow(9) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + qa_C.get(5)  + "</td><td>" + addrow(10) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + qa_C.get(6) + "</td><td>" + addrow(11) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + qa_C.get(7) + "</td><td>" + addrow(12) + "</td></tr>"
        tableb += "<tr><td></td><td> 8 </td><td>" + qa_C.get(8) + "</td><td>" + addrow(13) + "</td></tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Illustrations </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_D.get(1) + "</td><td>" + addrow(14) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_D.get(2) + "</td><td>" + addrow(15) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_D.get(3) + "</td><td>" + addrow(16) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_D.get(4) + "</td><td>" + addrow(17) + "</td></tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> Highlights Page </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_E.get(1) + "</td><td>" + addrow(18) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_E.get(2) + "</td><td>" + addrow(19) + "</td></tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Miscellaneous </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_G.get(1) + "</td><td>" + addrow(20) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_G.get(2) + "</td><td>" + addrow(21) + "</td></tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> QA2 </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_H.get(1) + "</td><td>" + addrow(22) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_H.get(2) + "</td><td>" + addrow(23) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_H.get(3) + "</td><td>" + addrow(24) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_H.get(4) + "</td><td>" + addrow(25) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + qa_H.get(5) + "</td><td>" + addrow(26) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + qa_H.get(6) + "</td><td>" + addrow(27) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + qa_H.get(7) + "</td><td>" + addrow(28) + "</td></tr>"
        tableb += "<tr><td><b> I </b><td></td></td><td><b> Delivery for Review </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + qa_I.get(1) + "</td><td>" + addrow(29) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + qa_I.get(2) + "</td><td>" + addrow(30) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + qa_I.get(3) + "</td><td>" + addrow(31) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + qa_I.get(4) + "</td><td>" + addrow(32) + "</td></tr>"

    if checklist_type == 'Final Delivery':
        tableb += "<tr><td><b> A </b><td></td></td><td><b> File Names and Folder Structure </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_A.get(1) + "</td><td>" + addrow(1) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_A.get(2) + "</td><td>" + addrow(2) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_A.get(3) + "</td><td>" + addrow(3) + "</td></tr>"
        tableb += "<tr><td><b> B </b><td></td></td><td><b> Temporary Revisions </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_B.get(1) + "</td><td>" + addrow(4) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_B.get(2) + "</td><td>" + addrow(5) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_B.get(3) + "</td><td>" + addrow(6) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_B.get(4) + "</td><td>" + addrow(7) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + dl_B.get(5) + "</td><td>" + addrow(8) + "</td></tr>"
        tableb += "<tr><td><b> C </b><td></td></td><td><b> Manual Revisions </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_C.get(1) + "</td><td>" + addrow(9) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_C.get(2)  + "</td><td>" + addrow(10) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_C.get(3) + "</td><td>" + addrow(11) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_C.get(4) + "</td><td>" + addrow(12) + "</td></tr>"
        tableb += "<tr><td><b> D </b><td></td></td><td><b> Final Review </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_D.get(1) + "</td><td>" + addrow(13) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_D.get(2) + "</td><td>" + addrow(14) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_D.get(3) + "</td><td>" + addrow(15) + "</td></tr>"
        tableb += "<tr><td><b> E </b><td></td></td><td><b> Workflow Requirements </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_E.get(1) + "</td><td>" + addrow(16) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_E.get(2) + "</td><td>" + addrow(17) + "</td></tr>"
        tableb += "<tr><td><b> F </b><td></td></td><td><b> Front Matter </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_F.get(1) + "</td><td>" + addrow(18) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_F.get(2) + "</td><td>" + addrow(19) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_F.get(3) + "</td><td>" + addrow(20) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_F.get(4) + "</td><td>" + addrow(21) + "</td></tr>"
        tableb += "<tr><td></td><td> 5 </td><td>" + dl_F.get(5) + "</td><td>" + addrow(22) + "</td></tr>"
        tableb += "<tr><td></td><td> 6 </td><td>" + dl_F.get(6) + "</td><td>" + addrow(23) + "</td></tr>"
        tableb += "<tr><td></td><td> 7 </td><td>" + dl_F.get(7) + "</td><td>" + addrow(24) + "</td></tr>"
        tableb += "<tr><td><b> G </b><td></td></td><td><b> Miscellaneous </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_G.get(1) + "</td><td>" + addrow(25) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_G.get(2) + "</td><td>" + addrow(26) + "</td></tr>"
        tableb += "<tr><td></td><td> 3 </td><td>" + dl_G.get(3) + "</td><td>" + addrow(27) + "</td></tr>"
        tableb += "<tr><td></td><td> 4 </td><td>" + dl_G.get(4) + "</td><td>" + addrow(28) + "</td></tr>"
        tableb += "<tr><td><b> H </b><td></td></td><td><b> Notifications </b></td><td></td><td></td>"+addth()+"</tr>"
        tableb += "<tr><td></td><td> 1 </td><td>" + dl_H.get(1) + "</td><td>" + addrow(29) + "</td></tr>"
        tableb += "<tr><td></td><td> 2 </td><td>" + dl_H.get(2) + "</td><td>" + addrow(30) + "</td></tr>"

    if checklist_type == 'DPMO':
        tableb += "<tr><td></td><td><b> Change Identification </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_A.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_A.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_A.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td></td><td><b> Cross-Reference </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_B.get(1) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td><b>Illustrated Parts List / Detailed Parts List / Engines </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(1) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(2) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(3) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(4) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_C.get(5) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_C.get(6)  + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td><b> Illustration / Figure </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(1) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(2) + "</td>" + addrow(12) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_D.get(3) + "</td>" + addrow(13) + "</tr>"
        tableb += "<tr><td></td><td><b> Unit of Measure </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_E.get(1) + "</td>" + addrow(14) + "</tr>"
        tableb += "<tr><td></td><td><b> Part Nomenclature </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_F.get(1) + "</td>" + addrow(15) + "</tr>"
        tableb += "<tr><td></td><td><b> Part Number </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_G.get(1) + "</td>" + addrow(16) + "</tr>"
        tableb += "<tr><td></td><td><b> Source Data </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_H.get(1) + "</td>" + addrow(17) + "</tr>"
        tableb += "<tr><td></td><td><b> Table </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_I.get(1) + "</td>" + addrow(18) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_I.get(2) + "</td>" + addrow(19) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_I.get(3) + "</td>" + addrow(20) + "</tr>"
        tableb += "<tr><td></td><td><b> Template </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(1) + "</td>" + addrow(21) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(2) + "</td>" + addrow(22) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_J.get(3) + "</td>" + addrow(23) + "</tr>"
        tableb += "<tr><td></td><td><b> Text </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_K.get(1) + "</td>" + addrow(24) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_K.get(2) + "</td>" + addrow(25) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_K.get(3) + "</td>" + addrow(26) + "</tr>"
        tableb += "<tr><td></td><td><b> TR Collation </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_L.get(1) + "</td>" + addrow(27) + "</tr>"
        tableb += "<tr><td></td><td><b> Warnings / Cautions </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_M.get(1) + "</td>" + addrow(28) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_M.get(2) + "</td>" + addrow(29) + "</tr>"
        tableb += "<tr><td></td><td><b> Other </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_N.get(1) + "</td>" + addrow(30) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_N.get(2) + "</td>" + addrow(31) + "</tr>"
        tableb += "<tr><td></td><td><b> Final Quality Check </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(1) + "</td>" + addrow(32) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(2) + "</td>" + addrow(33) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(3) + "</td>" + addrow(34) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(4) + "</td>" + addrow(35) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(5) + "</td>" + addrow(36) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(6) + "</td>" + addrow(37) + "</tr>"
        tableb += "<tr><td>Major</td><td>" + dpmo_O.get(7) + "</td>" + addrow(38) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_O.get(8) + "</td>" + addrow(39) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_O.get(9) + "</td>" + addrow(40) + "</tr>"
        tableb += "<tr><td></td><td><b> Software / Code </b></td>"+addth()+"</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_P.get(1) + "</td>" + addrow(41) + "</tr>"
        tableb += "<tr><td>Minor</td><td>" + dpmo_P.get(2) + "</td>" + addrow(42) + "</tr>"

    if checklist_type == 'Translation':
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(1) + "<br><br>" + trans_french.get(1) + "</td>" + addrow(1) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(2) + "<br><br>" + trans_french.get(2) + "</td>" + addrow(2) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(3) + "<br><br>" + trans_french.get(3) + "</td>" + addrow(3) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(4) + "<br><br>" + trans_french.get(4) + "</td>" + addrow(4) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(5) + "<br><br>" + trans_french.get(5) + "</td>" + addrow(5) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(6) + "<br><br>" + trans_french.get(6) + "</td>" + addrow(6) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(7) + "<br><br>" + trans_french.get(7) + "</td>" + addrow(7) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(8) + "<br><br>" + trans_french.get(8) + "</td>" + addrow(8) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(9) + "<br><br>" + trans_french.get(9) + "</td>" + addrow(9) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(10) + "<br><br>" + trans_french.get(10) + "</td>" + addrow(10) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(11) + "<br><br>" + trans_french.get(11) + "</td>" + addrow(11) + "</tr>"
        tableb += "<tr><td></td><td></td><td>" + trans_english.get(12) + "<br><br>" + trans_french.get(12) + "</td>" + addrow(12) + "</tr>"

    tableb += "</tbody></table>"

    table = all_headers + tableb + "</html>"
    return table

