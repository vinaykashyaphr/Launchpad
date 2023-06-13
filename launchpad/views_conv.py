from datetime import datetime, timedelta
import re
import traceback
from pathlib import Path
import shutil
from zipfile import ZipFile

# from celery import task
from flask import (flash, jsonify, request, redirect, render_template, url_for,
                   make_response, session)
from flask_login import login_required, current_user
# from socketio import Client

from launchpad import APP, CELERY, DB
from launchpad.models import Upload, User, Check, Message
from launchpad.PDF_Conv.Digital_Sunshine import DigitalSunshine
from launchpad.PDF_Conv.Supernova import main as Supernova
from launchpad.views import log_event, allowed_file, update_status
from launchpad.XML_Conv._Distant_Pluto import EMConvert
from launchpad.XML_Conv._Imposing_Jupiter import EIPCConvert
from launchpad.XML_Conv._Radiant_Mars import CMMConvert

from launchpad.Gemini import farsight_gemini
from launchpad.functions import socket_io, tab_ids
from launchpad.print import consolidate, print_PDF
from launchpad.validate_s1000D import main as validate_s1kd

from launchpad.Pulsar import pulsar_2
from launchpad.functions import ConversionClient, sqlite_select, sqlite_update

from launchpad.BeyondMeasure import beyond_measure_0_4a

from launchpad.foldermaker import Job_Folder_Creation_v1_00
from launchpad.Finals.finals import main as finals
from sonovision_qa import qa

up_item = {
    'conv': 'upload_item',
    'hl': 'p_upload_item',
    'bl': 'b_upload_item',
    'fc': 'f_upload_item',
    'qa': 'q_upload_item',
    'finals': 'fn_upload_item',
}

@CELERY.task(bind=True)
def print_doc(self, user, upload_id, upload_path, print_dm_codes, manual_type, manual_variant, _flask_request_context=None):
    try:
        update_status(user, upload_id, "Consolidating")
        cons = consolidate(upload_path, print_dm_codes, manual_type, manual_variant)
    except Exception:
        update_status(user, upload_id, "Consolidate Error")
        print(traceback.format_exc())
    else:
        if cons is None:
            update_status(user, upload_id, "Consolidate Error")
        update_status(user, upload_id, "Printing")
        try:
            print_PDF(upload_path, cons, manual_type)
        except Exception:
            update_status(user, upload_id, "Print Error")
            print(traceback.format_exc())
        else:
            update_status(user, upload_id, "Printed")

@CELERY.task(bind=True)
def qa_task(self, user, upload_path, conv_pdf, source_pdf, job_no="513005-000", manual_type=None, _flask_request_context=None):
    upload_path = Path(upload_path)
    upload_id = upload_path.name
    try:
        update_status(user, upload_id, "QA Running")
        qa(upload_path, job_number=job_no, user=user, conv_pdf=conv_pdf, source_pdf=source_pdf, doctype=manual_type)
    except Exception:
        with APP.app_context():
                Message.send_message(
                    User.query.filter_by(username=user).first().id,
                    f'{job_no} QA Error(s)',
                    f"""QA Validation For {job_no} (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""",
                    for_admin=True)
        update_status(user, upload_id, "QA Error", completed=True)
    else:
        update_status(user, upload_id, "QA Complete", completed=True)
    finally:
        # Clean up
        for f in upload_path.glob("*"):
            if f.is_dir():
                shutil.rmtree(str(f))
            elif f.suffix != ".html":
                f.unlink()

@CELERY.task(bind=True)
def finals_task(self, user, upload_path, job_no="513005-000", manual=None, modellic=None, cage=None, ata=None, data_type=None, _flask_request_context=None):
    # print(modellic, cage, ata, job_no, manual)
    upload_path = Path(upload_path)
    upload_id = upload_path.name
    try:
        update_status(user, upload_id, "Finals Running")
        finals(upload_path, job_number=job_no, manual=manual, ata_number=ata, modellic=modellic, cage=cage, data_type=data_type)
    except Exception:
        with APP.app_context():
                Message.send_message(
                    User.query.filter_by(username=user).first().id,
                    f'{job_no} Finals Error(s)',
                    f"""Finals Process For {job_no} (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""",
                    for_admin=True)
        update_status(user, upload_id, "Finals Error", completed=True)
    else:
        update_status(user, upload_id, "Finals Complete", completed=True)

# @task
# def print_queue():
#     uploads = Upload.query.filter_by(status='Converted').all()
#     for upload in uploads:
#         user = User.query.get(upload.user_id).username
#         upload_id = upload.id
#         upload_path = f"{APP.config['UPLOAD_FOLDER']}\\{upload_id}"

#         update_status(user, upload_id, "Print Queued")
#         print_doc.delay(user, upload_id, upload_path)


def conv_pdf(filename, upload_folder, cc):
    """Convert a PDF or .pickle file"""
    # sio = Client()
    # sio.connect(
    #     f"http://{APP.config['HOST']}:{APP.config['PORT']}",
    #     transports=['websocket', 'polling'])
    directory = Path(upload_folder)
    file = Path(filename)
    if file.suffix.lower() == ".pdf" or file.suffix.lower() == ".pickle":
        Supernova(file, directory, cc)
        if (directory / "parsed_text.txt").is_file():
            DigitalSunshine(directory / "parsed_text.txt",
                            upload_folder, cc)
        else:
            flash(f'Failed to parse {file.suffix.lower()} file')
    elif file.suffix.lower() == ".txt":
        DigitalSunshine(file, upload_folder, cc)
    else:
        raise ValueError("Invalid file type")

    # sio.disconnect()


def convert_xml(filename, upload_folder, cc, dtd):
    """Convert an ATA2200 XML File"""
    if dtd is not None:
        if dtd == "em":
            EMConvert(filename, upload_folder, cc)
        elif dtd == "eipc":
            EIPCConvert(filename, upload_folder, cc)
        else:
            CMMConvert(filename, upload_folder, cc)
    else:
        CMMConvert(filename, upload_folder, cc)

    (Path(upload_folder) / "Backup").mkdir(exist_ok=True)
    (Path(upload_folder) / "Backup/Source").mkdir(exist_ok=True)
    Path(filename).rename(Path(upload_folder) / "Backup/Source/" / Path(filename).name)


def convert_task(files, user, do_print, print_dm_codes, manual_type, manual_variant):
    # received_response = ping(user)
    # if not received_response:
    #     raise RuntimeError("No response from the client.")
    # soon = datetime.now() + timedelta(seconds=90)
    
    for fname, upload in files.items():
        cc = ConversionClient(upload, user, "conversion_log.txt")
        error = False
        try:
            upload_id = Path(upload).name
            update_status(user, upload_id, "Converting")
            if '.xml' in fname.lower() \
                    or '.sgm' in fname.lower():

                source_file = Path(upload) / fname

                source = source_file.read_text(encoding='utf-8')
                dtd = re.search(r'"(\w+)\.dtd"', source)

                convert_xml(
                    str(source_file),
                    upload, cc,
                    dtd.group(1) if dtd else None)
            else:
                conv_pdf(
                    str(Path(upload) / fname),
                    upload, cc)
            try:
                update_status(user, upload_id, "Validating")
                validate_s1kd(Path(upload))
            except ImportError:
                print("Import Error: Failed to validate conversion.")

            update_status(user, upload_id, "Running QA Validation")
            qa(Path(upload), user=user, job_number=fname.split('.')[0], doctype=manual_variant, has_pdf=False)
            if do_print:
                status_message = "Print Queued"
                # print_doc.apply_async(args=[user, upload_id, upload], kwargs={}, eta=soon)
                print_doc.delay(user, upload_id, upload, print_dm_codes, manual_type, manual_variant)
            else:
                status_message = "Converted"
        except Exception:
            error = True
            with APP.app_context():
                Message.send_message(
                    User.query.filter_by(username=user).first().id,
                    f'{fname} Conversion Error(s)',
                    f"""Conversion {fname} (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""",
                    for_admin=True)
        finally:
            update_status(user, upload_id,
                          "Conversion Error" if error else status_message, completed=True)


@CELERY.task(bind=True)
def convert_pub(self, files, user, do_print, print_dm_codes, manual_type, manual_variant, _flask_request_context=None):
    """Convert"""
    # files = ast.literal_eval(request.json['files'].replace("&#39;", '"'))
    for fname, upload in files.items():
        if '.xml' in fname.lower() \
                or '.sgm' in fname.lower():

            source_file = \
                Path(upload) / fname

            source = source_file.read_text(encoding='utf-8')
            dtd = re.search(r'"(\w+)\.dtd"', source)
            if dtd is not None:
                if dtd == "em":
                    log_event("Conversion (EM)")
                elif dtd == "eipc":
                    log_event("Conversion (EIPC)")
                else:
                    log_event("Conversion (CMM)")
            else:
                log_event("Conversion (CMM)")
        else:
            log_event("Conversion (PDF)")
    convert_task(files, user, do_print, print_dm_codes, manual_type, manual_variant)

@APP.route('/check_job_number', methods=['POST'])
@login_required
def check_job_number():
    job_number = request.form['job_number']
    print(f"Checking job number {job_number}")
    try:
        result = sqlite_select(f"SELECT * FROM 'Delivery Info' WHERE job='{job_number}'")[0]
    except IndexError:
        print("Does Not Exist")
        return jsonify({'result': False, 'modellic': None, 'type': None, 'cage': None}), 202
    else:
        print(result)
        return jsonify({'result': True, 'modellic': result[4], 'type': result[2], 'cage': result[5]}), 202

@APP.route('/convert', methods=['POST'])
@login_required
def upload_conversion():
    upload_type = ''
    job_no = ''
    try:
        if 'convert' in request.form:
            request_files = request.files.getlist('file')
        elif 'highlight' in request.form:
            request_files = [request.files['cnv_file']]
            source_file = request.files['src_file']
            job_no = request.form["job_no"]
        elif 'blocks' in request.form:
            request_files = [request.files['pdf_file']]
        elif 'jobfolder' in request.form:
            request_files = [request.files['excel_file']]
        elif 'upload' in request.form:
            request_files = [request.files['upfile_qa_zip']]
            source_file = request.files['upfile_qa_pdf2']
            conv_file = request.files['upfile_qa_pdf1']
            job_no = request.form["job_no"]
        elif 'finals' in request.form:
            request_files = [request.files['upfile_zip']]
            job_no = request.form["job_no"]
        upload_type = request.form["upload_type"]
        files = {}
        for f in request_files:
            print(f.filename, upload_type)
            if f and allowed_file(f.filename, upload_type):
                filename = f.filename
                # Add database item
                upload_name = job_no or Path(filename).stem
                upload = Upload.query.filter_by(
                    user=current_user, filename=upload_name,
                    upload_type=upload_type).first()

                if upload is not None:
                    # Reset upload timer on reupload
                    upload.timestamp = datetime.now()
                else:
                    upload = Upload(
                        filename=upload_name, user=current_user,
                        upload_type=upload_type)

                    DB.session.add(upload)
                    upload = Upload.query.filter_by(
                        user=current_user,
                        filename=upload_name, upload_type=upload_type).first()

                upload_folder = r"{}\\{}".format(APP.config['UPLOAD_FOLDER'],
                                                 str(upload.id))
                files[filename] = upload_folder

                upload_folder_path = Path(upload_folder)
                upload_folder_path.mkdir(exist_ok=True)

                f.save(str(upload_folder_path / filename))
                if upload_type in {"highlight", "qa"}:
                    source_file.save(str(upload_folder_path / source_file.filename))
                    files[source_file.filename] = upload_folder
                    if upload_type == "qa":
                        conv_file.save(str(upload_folder_path / conv_file.filename))
                        files[conv_file.filename] = upload_folder
                        
                if upload_type in {"finals", "qa"}:
                    with ZipFile(f) as myzip:
                        myzip.extractall(str(upload_folder_path))

                for zipfile in list(upload_folder_path.glob("*.zip")):
                    zipfile.unlink()

                DB.session.commit()

            else:
                flash(f'Invalid file selected: "{f.filename}". Ignoring.')
                # return redirect(url_for('data_conversion'))
    except Exception:
        print(traceback.format_exc())
    if upload_type == "conv":
        convert_pub.delay(
            files,
            current_user.username,
            'print' in request.form,
            'print_dm_codes' in request.form,
            request.form.get('manual_type'),
            request.form.get('manual_variant'))
    elif upload_type == "highlight":
        highlight_pub.delay(files, job_no, current_user.username)
    elif upload_type == "blocks":
        process_blocks.delay(files, current_user.username)
    elif upload_type == "jobfolder":
        create_job_folders.delay(files, current_user.username)
    elif upload_type == "qa":
        qa_task.delay(current_user.username, str(upload_folder_path),  str(upload_folder_path / conv_file.filename), str(upload_folder_path / source_file.filename), job_no=job_no, manual_type=request.form.get('manual_variant'))
    elif upload_type == "finals":
        finals_task.delay(current_user.username, str(upload_folder_path), job_no=job_no, modellic=request.form.get('modellic'), cage=request.form.get('cage'), ata=request.form.get('ata'), manual=request.form.get('manual_variant'), data_type=request.form.get('data_type'))
    return redirect(url_for('data_conversion', tab=tab_ids.get(upload_type)))
    # return jsonify(files), 202

@APP.route('/data_conversion', defaults={'tab': 'tab_conv'}, methods=['GET', 'POST'])
@APP.route('/data_conversion/<tab>', methods=['GET', 'POST'])
@login_required
def data_conversion(tab):
    # percentage = None

    # if 'accuracy_check' in request.form:
    #     if all(i in request.files for i in {'file_A', 'file_B'}):
    #         accuracy_upload(request)
    if 'delete' in request.form:
        ftype = request.form['dl_type']
        session['delete'] = request.form.getlist(up_item[ftype])
        if session['delete'] != []:
            return redirect(url_for('delete_files', directory="-1", ftype=ftype))
        else:
            flash('No files were selected.')
    elif 'download' in request.form:
        ftype = request.form['dl_type']
        upload_list = request.form.getlist(up_item[ftype])
        if len(upload_list) > 2:
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
    # elif 'convert' in request.form:
    #     files = upload_conversion(request)

    limit = datetime.now() - timedelta(
        seconds=APP.config['DIRECTORY_LIFETIME'])
    current_user.user_type = 'conv'
    uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="conv")\
        .filter(Upload.timestamp > limit).all()
    p_uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="highlight")\
        .filter(Upload.timestamp > limit).all()
    b_uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="blocks")\
        .filter(Upload.timestamp > limit).all()
    f_uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="jobfolder")\
        .filter(Upload.timestamp > limit).all()
    q_uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="qa")\
        .filter(Upload.timestamp > limit).all()
    fn_uploads = User.query.filter_by(username=current_user.username).first()\
        .uploads.filter_by(upload_type="finals")\
        .filter(Upload.timestamp > limit).all()
    resp = make_response(
        render_template('data_conversion.html', url='upload_conversion',
                        uploads=uploads, p_uploads=p_uploads, b_uploads=b_uploads, f_uploads=f_uploads, q_uploads=q_uploads, fn_uploads=fn_uploads, tab=tab, title="Data Conversion"))
    resp.set_cookie(f'{current_user.username}', 'conv')
    return resp


@APP.route('/finals_update', methods=['POST'])
@login_required
def finals_update():
    form = request.form
    results = sqlite_select(f"SELECT modellic, cage, type  FROM 'Delivery Info' WHERE job='{form['job_no']}';", fetchall=False)
    if results:
        print("Attempting to update job number")
        try:
            sqlite_update(f"UPDATE 'Delivery Info' SET type=?, cage=?, modellic=? WHERE job=?;", (form['manual_variant'] or results[2], form['cage'] or results[1], form['modellic'] or results[0], form['job_no']))
        except Exception as e:
            flash(f"Failed to update DB: {e}")
        else:
            flash("Success")

    else:
        print("Adding new entry")
        try:
            sqlite_update(f"INSERT INTO 'Delivery Info'(job, type, modellic, cage) VALUES (?, ?, ?, ?)", (form['job_no'], form['manual_variant'], form['modellic'], form['cage']))
        except Exception as e:
            flash(f"Failed to update DB: {e}")
        else:
            flash("Success")
    return redirect(url_for('data_conversion', tab='tab_finals'))

@APP.route('/gemini', methods=['POST'])
@login_required
def accuracy_upload():
    try:
        user = current_user.username
        upload_folder_path = Path(APP.config['UPLOAD_FOLDER']) / "Accuracy"
        upload_folder_path.mkdir(exist_ok=True)
        upload_folder_path = Path(APP.config['UPLOAD_FOLDER']) / "Accuracy" / user
        upload_folder_path.mkdir(exist_ok=True)
        

        file_alpha = request.files['file_A']
        file_beta = request.files['file_B']
        for i, input_file in enumerate([file_alpha, file_beta]):
            # upload
            # accuracy_status = f'Uploading file {i+1}...'
            # upload_folder = rf"{}\\accuracy"
            input_file.save(str(upload_folder_path / input_file.filename))
            # get path local to server
            path_file = f'{upload_folder_path}/{input_file.filename}'
            if i == 0:
                path_alpha = path_file
            else:
                path_beta = path_file
        try:
            if request.form['blind'] == 'blindsight':
                blindsight = True
        except Exception:
            blindsight = False
        # socket_io.emit('accuracy_status', {'status': 'Beginning Check'}, room=user)
        accuracy_check.delay(path_alpha, path_beta,
                             str(upload_folder_path), user,
                             request.form['job_no'],
                             request.form['conversion_step'],
                             blindsight)
    except Exception as e:
        print(e)
        # status = 403
        # data = {"status": str(e)}
    # else:
    #     data = {"status": "In Progress"}
    #     status = 202
    finally:
        # return jsonify(data), status
        return redirect(url_for('data_conversion', tab=""))


@CELERY.task(bind=True)
def accuracy_check(self, path_alpha, path_beta, directory, user, job_no,
                   conversion_step, blindsight, _flask_request_context=None):
    percentage = None
    # socket_io.emit('accuracy_status', {'status': 'Check In Progress'}, room=user)
    print(f'BLINDSIGHT: {blindsight}')
    # get in 2 files to check conversion accuracy
    # update_status(user, None, "In Progress", accuracy=True)
    try:
        # send paths to gemini
        
        percentage = farsight_gemini.main(directory, user,
                                          'farsight_gemini.log',
                                          alpha=path_alpha,
                                          beta=path_beta,
                                          blind=blindsight)
        socket_io.emit('accuracy', {'percentage': percentage}, room=user)
        # upload results to database
        check = Check(job_no=job_no, step=conversion_step, accuracy=percentage)
        DB.session.add(check)
        DB.session.commit()
    except Exception:
        print(traceback.format_exc())
        socket_io.emit('accuracy_status', {'status': 'Error!'}, room=user)
        with APP.app_context():
            Message.send_message(
                User.query.filter_by(username=user).first().id,
                f'{path_alpha} Accuracy Check Error(s)',
                f"""Accuracy Check of {path_alpha} and {path_beta}) completed with error:
{traceback.format_exc()}""",
                for_admin=True)

    finally:
        # delete files when done
        # os.remove(path_alpha)
        # os.remove(path_beta)
        shutil.rmtree(directory)

    print(percentage)
    return jsonify({}), 202

@CELERY.task(bind=True)
def highlight_pub(self, files, job_no, user, _flask_request_context=None):
    """highlight"""
    for fname, upload in files.items():
        log_event("Highlight PDF")
    highlight_task(files, user, job_no)

def highlight_task(files, user, job_no):
    error = False
    try:
        file_paths = []
        # get file paths
        upload_path = ''
        for fname, upload in files.items():
            upload_id = Path(upload).name
            file_paths.append(str(Path(upload) / fname))
            upload_path = upload

        cnv_highlight_path, src_highlight_path = pulsar_2.main(job_no, upload_path, user, cnv_pdf=file_paths[0], src_pdf=file_paths[1])
        Path(file_paths[0]).unlink()
        Path(file_paths[1]).unlink()

        status_message = "Done"
        
    except Exception:
        status_message = 'Highlight Error'
        with APP.app_context():
            Message.send_message(
                User.query.filter_by(username=user).first().id,
                f'{job_no} Highlight Error(s)',
                f"""Highlight {job_no} (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""", for_admin=True)
    finally:
        update_status(user, upload_id, status_message, completed=True)
        return redirect(url_for('data_conversion'))

@CELERY.task(bind=True)
def process_blocks(self, files, user, _flask_request_context=None):
    '''process textblocks into text file'''
    print('blocks!')
    log_event("Sort and output Textblocks")
    blocks_task(files, user)

def blocks_task(files, user): # incomplete, still needs proper traceback and redirect, and getting of upload id?
    error = False
    print('blocks Task!')
    try:
        for fname, upload in files.items():
            upload_id = Path(upload).name
            file_path = str(Path(upload) / fname)
            upload_path = upload
        
        textblock_path = beyond_measure_0_4a.main(pdf=file_path)
        status_message = "Done"
    except Exception:
        status_message = "Textblock Processing Error"
        with APP.app_context():
            Message.send_message(
                User.query.filter_by(username=user).first().id,
                f'Process job Error(s)',
                f"""Processing of PDF  into sorted textblock (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""", for_admin=True)
    finally:
        update_status(user, upload_id, status_message, completed=True)
        return redirect(url_for('data_conversion'))

@CELERY.task(bind=True)
@login_required
def create_job_folders(self, files, user, _flask_request_context=None):
    try:
        for fname, upload in files.items():
            upload_id = Path(upload).name
            file_path = str(Path(upload) / fname)
            upload_path = upload
            filename = fname
        errors, messages, itar = Job_Folder_Creation_v1_00.create_multiple(file_path, upload_path)
        if errors != '':
            status_message = "Folder Creation Error"
            with APP.app_context():
                Message.send_message(User.query.filter_by(username=user).first().id,
                'Folder creation Error(s)',
                errors, for_admin=True)
        else:
            if not itar:
                status_message = "Done. No ITAR folders created"
            else:
                status_message = "Done"
        if messages != '':
            flash(messages)
    except Exception:
        status_message = "Folder Creation Error"
        with APP.app_context():
            Message.send_message(
                User.query.filter_by(username=user).first().id,
                f'Process job Error(s)',
                f"""Job Folder creation (ID: {upload_id}) completed with error:
    {traceback.format_exc()}""", for_admin=True)
    finally:
        update_status(user, upload_id, status_message, completed=True)
        # delete entry if not itar
        # if not itar:
        #     non_itar = Upload.query.filter_by(user_id=User.query.filter_by(username=user).first().id).order_by(Upload.timestamp.desc()).first()
        #     DB.session.delete(non_itar)
        #     DB.session.commit()
        return redirect(url_for('data_conversion'))
   
