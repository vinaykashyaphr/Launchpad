import traceback
from pathlib import Path
from datetime import datetime, timedelta
from zipfile import ZipFile
from flask import (flash, jsonify, request, redirect, url_for, render_template,
                   make_response, session)
from flask_login import login_required, current_user

from launchpad import APP, CELERY, DB
from launchpad.views import log_event, allowed_file, update_status
from launchpad.Arecibo_1.ar_interface import run_qa
from launchpad.Arecibo_1.dictionary_adder import dictionary_add, dictionary_remove
from launchpad.models import Upload, User, Message
from launchpad.functions import tab_ids
from launchpad.IETM_Hotspots.ietm_hotspots import main as insert_hotspots
from socketio import Client
import re


@CELERY.task(bind=True)
def qa_pdf(self, filename, upload_folder, user, job_no, file_type, has_D, _flask_request_context=None, **checks):
    """Run Arecibo on a pdf"""
    # print(f"Starting task: {qa_pdf.request.id}")
    
    # sio was causing 500 Handshake errors
    # sio = Client()
    # sio.connect(
    #     f"http://{APP.config['HOST']}:{APP.config['PORT']}",
    #     transports=['websocket', 'polling'])
    update_status(user, upload_folder.split('\\')[-1], "In Progress")
    try:
        directory = Path(upload_folder)
        file = Path(filename)
        # arecibo(filename, upload_folder, user, qa_pdf.request.id)
        # arecibo(filename, upload_folder, user, sio)

        # run Arecibo
        run_qa(job_no, file_type, upload_folder, filename, has_D, user, **checks)
    except Exception: # if run into error when running Arecibo
        error = True
        with APP.app_context():
            Message.send_message(
                User.query.filter_by(username=user).first().id,
                f'{file.name} Arecibo Error(s)',
                f"""QA Review of {file.name} (ID: {directory.name}) completed with error:
{traceback.format_exc()}""",
                for_admin=True)
    else:
        error = False
    finally:
        # sio.disconnect()
        update_status(user, upload_folder.split('\\')[-1],
                      "Error" if error else "Completed", completed=True)


@APP.route('/qa', methods=['POST'])
@login_required
def qa_pub():
    """Run Automated QA"""
    try:
        # interpret data sent through json and send to qa_pdf
        checks = request.json['checks'].split(' ')
        job_no = re.search(r'job_no\[([-\d]+)', request.json['checks']).group(1)
        file_type = re.search(r'file_type\[(\d)', request.json['checks']).group(1)
        qa_pdf.delay(
            str(Path(request.json['up_folder']) / request.json['fname']),
            request.json['up_folder'], request.json['user'], job_no,
            file_type, 'has_D' in checks,
            auto_qa='auto_QA' in checks,
            lep='LEP_Check' in checks,
            graphic='miss_graphic' in checks,
            acronym='acro'in checks,
            foldouts='foldouts'in checks,
            simple_english='simp_eng'in checks,
            highlight='highlight'in checks,
            spelling='spelling'in checks)

        log_event("QA Document")
    except Exception as exc:
        flash('QA failed with the following exception:\n{}'
              .format(exc))
        print(traceback.format_exc(), '\n\n')

    return jsonify({}), 202

@CELERY.task(bind=True)
def hotspots(self, user, upload_path, _flask_request_context=None):
    upload_path = Path(upload_path)
    upload_id = upload_path.name
    try:
        update_status(user, upload_id, "Inserting Hotspots")
        insert_hotspots(upload_path, upload_path)
    except Exception:
        with APP.app_context():
                Message.send_message(
                    User.query.filter_by(username=user).first().id,
                    f'Hotspots Error(s)',
                    f"""Hotspots Process (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""",
                    for_admin=True)
        update_status(user, upload_id, "Error", completed=True)
    else:
        update_status(user, upload_id, "Completed", completed=True)

@APP.route('/upload_techwrite', methods=['GET', 'POST'])
@login_required
def upload_techwrite():
    upload_type = request.form["upload_type"]
    if 'hotspots' in request.form:
        request_files = request.files.getlist('zip_file')
    for f in request_files:
        if allowed_file(f.filename, upload_type):
            filename = f.filename
            # Add database item
            upload = Upload.query.filter_by(
                user=current_user, filename=str(Path(filename).stem),
                upload_type=upload_type).first()
            if upload is not None:
                # Reset upload timer on reupload
                upload.timestamp = datetime.now()

            else:
                upload = Upload(
                    filename=str(Path(filename).stem), user=current_user,
                    upload_type=upload_type)

                DB.session.add(upload)
                upload = Upload.query.filter_by(
                    user=current_user, filename=str(Path(filename).stem)).first()
            upload_folder = r"{}\\{}".format(APP.config['UPLOAD_FOLDER'],
                                            str(upload.id))
            upload_folder_path = Path(upload_folder)
            upload_folder_path.mkdir(exist_ok=True)

            if upload_type in {"hot"}:
                with ZipFile(f) as myzip:
                    myzip.extractall(str(upload_folder_path))
            else:
                f.save(str(upload_folder_path / filename))
                for zipfile in list(upload_folder_path.glob("*.zip")):
                    zipfile.unlink()

            DB.session.commit()
            # return redirect(url_for('technical_writing', tab=tab_ids.get(upload_type)))
            # return render_template('converting.html', title="Running QA",
            #                     filename=filename,
            #                     upload_folder=upload_folder,
            #                     upload_id=str(upload.id),
            #                     url='qa_pub', checks=checks)
        else:
            flash('Invalid file selected')
            return redirect(url_for('technical_writing', tab=tab_ids.get(upload_type)))
    if upload_type == "hot":
        hotspots.delay(current_user.username, upload_folder)
    return redirect(url_for('technical_writing', tab=tab_ids.get(upload_type)))

@APP.route('/upload_techwrite_arecibo', methods=['GET', 'POST'])
@login_required
def upload_techwrite_arecibo():
    if 'pdf_file' not in request.files:
        flash('No file part')
        return redirect(url_for('technical_writing'))

    pdf_file = request.files['pdf_file']
    job_no = re.search(r'([-\d]+)', request.form['job_no'])
    file_type = re.search(r'(\d)', request.form['file_type'])

    if job_no is not None:
        job_no = job_no.group(1)
    else:
        flash('Error: Invalid Job Number.')
        return redirect(url_for('technical_writing'))

    if file_type is not None:
        file_type = file_type.group(1)
    else:
        flash('Error: Unreconized file type.')
        return redirect(url_for('technical_writing'))

    # format the data to send arecibo the info it needs to run
    checks = ''
    if 'all' in request.form or 'auto_QA' in request.form:
        checks += 'auto_QA '
    if 'all' in request.form or 'LEP_Check' in request.form:
        checks += 'LEP_Check '
    if 'all' in request.form or 'miss_graphic' in request.form:
        checks += 'miss_graphic '
    if 'all' in request.form or 'acro' in request.form:
        checks += 'acro '
    if 'all' in request.form or 'foldouts' in request.form:
        checks += 'foldouts '
    if 'simp_eng' in request.form:
        checks += 'simp_eng '
    if 'all' in request.form or 'highlight' in request.form:
        checks += 'highlight '
    if 'all' in request.form or 'spelling' in request.form:
        checks += 'spelling '    
    if 'has_D' in request.form:
        checks += 'has_D '
    if 'job_no' in request.form:
        checks += 'job_no[' + job_no + '] '
    if 'file_type' in request.form:
        checks += 'file_type[' + file_type +'] '

    if pdf_file.filename == '':
        flash('No selected PDF')
        return redirect(url_for('technical_writing'))

    if pdf_file and allowed_file(pdf_file.filename, "tw"):
        filename = pdf_file.filename
        # Add database item
        upload = Upload.query.filter_by(
            user=current_user, filename=str(Path(filename).stem),
            upload_type="tw").first()
        if upload is not None:
            # Reset upload timer on reupload
            upload.timestamp = datetime.now()

        else:
            upload = Upload(
                filename=str(Path(filename).stem), user=current_user,
                upload_type="tw")

            DB.session.add(upload)
            upload = Upload.query.filter_by(
                user=current_user, filename=str(Path(filename).stem)).first()
        upload_folder = r"{}\\{}".format(APP.config['UPLOAD_FOLDER'],
                                         str(upload.id))
        upload_folder_path = Path(upload_folder)
        upload_folder_path.mkdir(exist_ok=True)

        for zipfile in list(upload_folder_path.glob("*.zip")):
            zipfile.unlink()

        DB.session.commit()
        
        pdf_file.save(str(upload_folder_path / pdf_file.filename))
        return render_template('converting.html', title="Running QA",
                               filename=filename,
                               upload_folder=upload_folder,
                               upload_id=str(upload.id),
                               url='qa_pub', checks=checks)
    else:
        flash('Invalid file selected')
        return redirect(url_for('technical_writing', tab=tab_ids.get(upload_type)))

@APP.route('/technical_writing', defaults={'tab': 'tab_arec'}, methods=['GET', 'POST'])
@APP.route('/technical_writing/<tab>', methods=['GET', 'POST'])
@login_required
def technical_writing(tab):
    files = {}
    if 'delete' in request.form:
        ftype = request.form['dl_type']
        session['delete'] = request.form.getlist('upload_item')
        if session['delete'] != []:
            return redirect(url_for('delete_files', directory="-1", ftype=ftype, tab=tab))
        else:
            flash('No files were selected.')        
    elif 'download' in request.form:
        ftype = request.form['dl_type']
        upload_list = request.form.getlist('upload_item')
        if len(upload_list) > 1:
            session['download'] = upload_list
            return redirect(
                url_for(
                    'multi_download',
                    ftype=ftype))        
        else:
            try:
                upload = Upload.query.get(int(upload_list[0]))
                return redirect(
                    url_for(
                        'single_download',
                        directory=upload_list[0],
                        filename=upload.filename + ".zip",
                        ftype=ftype))
            except IndexError:
                flash('No files were selected.')
    elif 'dict_modify' in request.form:
        tab = "tab_dict"
        if request.form['modify_w'] == "add_w":
            flash(dictionary_add(request.form['dict_w']))
        else:
            flash(dictionary_remove(request.form['dict_w']))
    limit = datetime.now() - timedelta(
        seconds=APP.config['DIRECTORY_LIFETIME'])
    current_user.user_type = 'tw'
    uploads = User.query\
        .filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="tw")\
        .filter(Upload.timestamp > limit).all()
    hot_uploads = User.query\
        .filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="hot")\
        .filter(Upload.timestamp > limit).all()
    resp = make_response(
        render_template('technical_writing.html', url='upload_techwrite',
                        files=files, uploads=uploads, hot_uploads=hot_uploads, title="technical_writing", tab=tab
                        ))
    resp.set_cookie(f'{current_user.username}', 'tw')
    return resp
