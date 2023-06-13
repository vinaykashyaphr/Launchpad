from datetime import datetime
import os
import random
import re
# import json
from pathlib import Path
import shutil
from zipfile import ZipFile
import traceback
import sys

from flask import (abort, flash, jsonify, redirect, render_template, request,
                   send_from_directory, url_for, session)

from flask_login import current_user, login_required, login_user, logout_user
from werkzeug.urls import url_parse
from launchpad import APP, DB, SOCKETIO
from launchpad.cleanup import time_until_next_cleanup
from launchpad.forms import AdminForm, LoginForm, ChangePassForm, LogForm
from launchpad.graphing import PlotGraph
from launchpad.models import Log, Upload, User, Message, Check
from launchpad.functions import socket_io, tab_ids


# from urllib import unquote_plus

ALLOWED_EXTENSIONS_CONV = set(['xml', 'sgm', 'pdf', 'txt', 'pickle'])
ALLOWED_EXTENSIONS_TR = set(['pdf', 'html'])
ALLOWED_EXTENSIONS_FC = set(["xls", "xlsx", "csv"]) #folder creation
ALLOWED_EXTENSIONS_QA = set(['zip'])
ALLOWED_EXTENSIONS_FINALS = set(['zip'])
ALLOWED_EXTENSIONS_HOT = set(['zip'])

ALLOWED_EXTENSIONS_DL = {
    "conv": {".xml", ".xlsx", ".txt", ".log", ".pdf", ".html"},
    "tw": {".txt", ".pdf", ".csv", ".log"},
    "hl": {".pdf"},
    "bl": {".txt", ".pdf"},
    "fc": {"", ".xlsx", ".xls"},
    "qa": {".html"},
    "finals": {".xml", ".txt", ".log", ".cgm", ".tif", ".html"},
    "hot": {".xml", ".log"},
}

# ftype_tab_ids = {
#     'conv': 'upload_item',
#     'hl': 'p_upload_item',
#     'bl': 'b_upload_item',
#     'fc': 'f_upload_item',
#     'qa': 'q_upload_item',
# }

# Methods
def update_status(user, up_id, status, completed=False):
    print(up_id)
    Upload.query.get(up_id).status = status
    DB.session.commit()
    socket_io.emit(
        'status' if not completed else 'completed',
        {'status': status, 'id': up_id},
        room=user)


def allowed_file(filename, upload_type="conv"):
    """Check if file is allowed"""
    if upload_type == "conv":
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_CONV
    elif upload_type == "jobfolder":
        # print(filename.rsplit('.', 1)[1].lower())
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_FC
    elif upload_type == "qa":
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_QA
    elif upload_type == "finals":
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_FINALS
    elif upload_type == "hot":
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_HOT
    else:
        return '.' in filename and \
            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS_TR


def log_event(event_name="Unknown Event"):
    """Log an event on Launchpad"""
    logged_event = Log(user=current_user, event=event_name,
                       address=request.environ.get('REMOTE_ADDR', ''))
    DB.session.add(logged_event)
    DB.session.commit()

# Launchpad Pages


@APP.route('/user_input', methods=['POST'])
def user_input():
    user = request.json['user']
    message = request.json['message']
    SOCKETIO.emit('prompt_input', message, room=user)


@APP.route('/home', methods=['GET', 'POST'])
@login_required
def home():
    return render_template('home.html', title="Home Page")


@APP.route('/', methods=['GET', 'POST'])
@APP.route('/login', methods=['GET', 'POST'])
def login():
    """Logs a user into the website."""
    if current_user.is_authenticated:
        return redirect(url_for('home'))
    form = LoginForm()

    if form.validate_on_submit():
        # TODO: Move this to loginform
        user = User.query.filter_by(username=form.username.data).first()
        if user is None:
            flash('Invalid username or password')
            return redirect(url_for('login'))
        if user.retired:
            flash(f'{user.username} is retired.')
            return redirect(url_for('login'))
        if user.timeout is not None:
            if datetime.now() < user.timeout:  # if the user is still timed out
                flash('Max attempts exceeded. You are locked out.')
                return redirect(url_for('login'))
            # else the user is timed in
            user.attempts = 0
            user.timeout = None
            DB.session.commit()
        if not user.check_password(form.password.data):
            user.attempts += 1
            # Log: Failed login attempt
            if user.attempts >= APP.config['MAX_ATTEMPTS']:
                user.timeout = datetime.now() + APP.config['TIMEOUT_LENGTH']
                flash('Max attempts exceeded. You have been locked out.')
                # Email send to admins
                Message.send_message(0, f'Lockout: {user.username}',
                                     f'{user.fname} {user.lname}'
                                     f' has been locked out.', True)
                APP.logger.error(user.username + ' has been locked out.')

                # Log: locked out
            else:
                flash('Invalid username or password')
            DB.session.commit()
            return redirect(url_for('login'))
        user.attempts = 0
        DB.session.commit()
        login_user(user, form.remember_me.data)
        log_event("Logged in")
        next_page = request.args.get('next')
        if not next_page or url_parse(next_page).netloc != '':
            if request.cookies.get(user.username) == 'conv':
                next_page = url_for('data_conversion')
            elif request.cookies.get(user.username) == 'tw':
                next_page = url_for('technical_writing')
            else:
                next_page = url_for('home')
        return redirect(next_page)
    return render_template('login.html', title="Sign In", form=form)


@APP.route('/logout')
def logout():
    """Logs a user out of the website."""
    log_event("Logged out")
    logout_user()
    return redirect(url_for('login'))


@APP.route('/change_pass', methods=['GET', 'POST'])
@login_required
def change_pass():
    """Changes a user's password."""
    form = ChangePassForm()
    # TODO: Move this to change password form
    if form.validate_on_submit():
        if not current_user.check_password(form.current_password.data):
            flash('Current password invalid.')
            return redirect(url_for('login'))
        current_user.set_password(form.new_password.data)
        DB.session.commit()
        log_event("Changed password")
        flash('Password changed successfully!')
        if request.cookies.get(current_user.username) == 'conv':
            return redirect(url_for('data_conversion'))
        elif request.cookies.get(current_user.username) == 'tw':
            return redirect(url_for('technical_writing'))
        else:
            return redirect(url_for('home'))
    return render_template('change_pass.html', title="Change Pass", form=form)

# File Pages


@APP.route('/files_ready/<filedir>?<filename>')
@login_required
def files_ready(filedir, filename):
    upload = Upload.query.get_or_404(filedir)
    remaining = APP.config['DIRECTORY_LIFETIME'] - \
        (datetime.now() - upload.timestamp).total_seconds()
    remaining += APP.config['CLEANUP_DELAY'] - \
        ((remaining - time_until_next_cleanup()) % APP.config['CLEANUP_DELAY'])
    return render_template('files_ready.html', fname=filename, fdir=filedir,
                           rem=remaining, ftype=upload.upload_type)


@APP.route('/delete/<directory>?<ftype>', methods=['GET', 'POST'])
@APP.route('/delete/<directory>', methods=['GET', 'POST'])
@login_required
def delete_files(directory, ftype="conv"):
    try:
        if request.method == "GET":
            dirs = list(directory) if directory != "-1" \
                else session.pop('delete', [])
        else:
            # print(json.loads(request.data))
            dirs = [request.json['directory']]
        for drct in dirs:
            if not drct:
                continue
            upload = Upload.query.get_or_404(int(drct))
            DB.session.delete(upload)
            try:
                shutil.rmtree(Path(APP.config['UPLOAD_FOLDER']) / drct)
            except FileNotFoundError:
                pass
        DB.session.commit()
        if request.method == "GET":
            flash('Files successfully deleted')
            user_type = request.cookies.get(current_user.username)
            if user_type == 'conv':
                return redirect(url_for('data_conversion', tab=tab_ids.get(ftype)))
            elif user_type == 'tw':
                return redirect(url_for('technical_writing'))
            else:
                return redirect(url_for('home'))
        else:
            return jsonify({}), 202
    except Exception:
        # Email admin with traceback info
        print(traceback.format_exc())
        abort(500)


@APP.route('/download/<path:directory>/<path:filename>?<ftype>',
           methods=['GET', 'POST'])
@login_required
def single_download(directory, filename, ftype):
    if not ftype in ALLOWED_EXTENSIONS_DL:
        flash(f'Error: Upload [{ftype}] type not recognized')
        abort(500)

    if request.method == "POST":
        directory = request.json['directory']
        filename = request.json['filename']
    uploads = os.path.join(os.getcwd(), APP.config['UPLOAD_FOLDER'], directory)
    print(directory, file=sys.stderr)
    if not Path(uploads).is_dir():
        flash('That upload no longer exists')
        abort(404)

    # If the zip file already exists, no need to recreate it
    if not (Path(uploads) / filename).is_file():
        try:
            with ZipFile(os.path.join(uploads, filename), 'w') as zip_file:
                for f in Path(uploads).iterdir():
                    # if f.stem != filename.split('.')[0] and not f.is_dir():
                    #     if f.suffix.lower() in ALLOWED_EXTENSIONS_DL[ftype]:
                    #         zip_file.write(f, os.path.basename(f))      

                    if f.stem != filename.split('.')[0]:
                        if f.suffix.lower() in ALLOWED_EXTENSIONS_DL[ftype]:
                            zip_file.write(f, os.path.basename(f))
                        if f.is_dir():
                            for sub in Path(f).iterdir():
                                if sub.suffix.lower() in ALLOWED_EXTENSIONS_DL[ftype]:
                                    zip_file.write(sub, f'{os.path.basename(f)}\{os.path.basename(sub)}')
                                if sub.is_dir():
                                    for subsub in Path(sub).iterdir():
                                        if subsub.suffix.lower() in ALLOWED_EXTENSIONS_DL[ftype]:
                                            zip_file.write(subsub, f'{os.path.basename(f)}\{os.path.basename(sub)}\{os.path.basename(subsub)}')




                    # Once we've zipped the files, no need to keep them
                    # This will save some space on the server
                    if (not APP.config['DEBUG'] and
                            not f.suffix.lower() == ".zip"):
                        if f.is_dir():
                            shutil.rmtree(f)
                        else:
                            f.unlink()
                # zip_file.close()
        except FileNotFoundError:
            flash('An error occured while zipping files')
            abort(404)

    return send_from_directory(directory=uploads, filename=filename,
                               as_attachment=True)


@APP.route('/batch?<ftype>')
@login_required
def multi_download(ftype):
    dirs = session.pop('download', [])
    if not ftype in ALLOWED_EXTENSIONS_DL:
        flash('Error: Upload type not recognized')
        abort(500)

    zip_name = f"Batch-Download_{id(request)}.zip"
    with ZipFile(os.path.join(
            os.getcwd(), APP.config['UPLOAD_FOLDER'],
            zip_name), 'w') as zip_file:
        for drct in dirs:
            if not drct:
                continue
            uploads = os.path.join(
                os.getcwd(), APP.config['UPLOAD_FOLDER'], drct)

            if not Path(uploads).is_dir():
                continue

            filename = Upload.query.get(drct).filename + ".zip"
            zip_path = (Path(uploads) / filename)
            # If the zip file already exists, no need to recreate it
            if not zip_path.is_file():
                try:
                    with ZipFile(os.path.join(uploads, filename), 'w') \
                            as nested_zip_file:
                        for f in Path(uploads).iterdir():
                            if f.stem != filename.split('.')[0] \
                                    and not f.is_dir():
                                if f.suffix.lower() in ALLOWED_EXTENSIONS_DL[ftype]:
                                    nested_zip_file.write(
                                        f, os.path.basename(f))
                            # Once we've zipped the files, no need to keep them
                            # This will save some space on the server
                            if not APP.config['DEBUG']:
                                if f.is_dir():
                                    shutil.rmtree(f)
                                else:
                                    f.unlink()
                        # nested_zip_file.close()

                except FileNotFoundError:
                    flash('An error occured while zipping files')
                    abort(404)
            zip_file.write(zip_path, os.path.basename(zip_path))
        # zip_file.close()
    return send_from_directory(
        directory=os.path.join(
            os.getcwd(),
            APP.config['UPLOAD_FOLDER']),
        filename=zip_name,
        as_attachment=True)
# Admin Pages


@APP.route('/logs', methods=['GET', 'POST'])
@login_required
def log_manager():
    if not current_user.admin:
        abort(403)
    checked_jobs = Check.query.with_entities(Check.job_no).distinct()
    acc_tables = []
    form = LogForm()
    if form.validate_on_submit():
        # TODO: Move this to logform
        if form.erase.data or form.dump.data or form.graph.data:
            query = DB.session.query(Log)

            if form.dump.data or form.graph.data:
                log_dump = "Username,IP Address,Event,Date,Time\n"
                filters = form.filters()
                if "User" in filters:
                    user_ids = []

                    users = filters["User"].split(',')

                    for u in users:
                        user = User.query.filter_by(username=u.strip()).first()
                        if user:
                            user_ids.append(user.id)
                    query = query.filter(Log.user_id.in_(user_ids))
                else:
                    users = []

                if "Event" in filters:
                    events = filters["Event"]
                    event_type = [e.split(' ')[0] if not len(users) == 1 and
                                  not form.total.data else e for e in events]
                    query = query.filter(Log.event.in_(events))
                else:
                    event_type = None

                if "After" in filters:
                    after = filters["After"]
                    query = query.filter(Log.timestamp >= after)

                if "Before" in filters:
                    before = filters["Before"]
                    query = query.filter(Log.timestamp <= before)
            logs = query.all()
            print(logs)
            if len(logs) == 0:
                flash('There are no log entries matching the current filters')
                return render_template('log_manager.html',
                                       title='Logs', form=form,
                                       graph="", acc_jobs=checked_jobs, acc_tables=acc_tables)

            if form.limit_type.data == 'last':
                logs = reversed(logs)
            elif form.limit_type.data == 'random':
                random.shuffle(logs)

            for i, log in enumerate(logs):
                if form.limit.data and i == form.limit.data:
                    break
                log_dump += log.print_csv()

            if form.dump.data or form.erase.data:
                try:
                    log_name = "{}_{}.csv"\
                        .format("Dump" if form.dump.data
                                else "Backup", datetime.now()
                                .strftime("%d-%m-%Y_%H-%M-%S"))
                    log_file = Path(APP.config['LOG_FOLDER']) / log_name
                    log_file.write_text(log_dump, encoding="utf-8")
                except Exception:
                    flash('Failed to write log file')
                else:
                    if form.erase.data:
                        print("Backed up and erased log files")
                        for log in logs:
                            DB.session.delete(log)
                        DB.session.commit()
                    elif form.graph.data:
                        print("Graphed log files")
                    else:
                        print("Dumped log files")

            if form.graph.data:
                if form.total.data:
                    total = form.x_axis.data
                else:
                    total = None

                def get_plot_title():

                    def add_line_breaks(title):
                        MAX_LINE_CHARS = 50

                        new_title = ""
                        while MAX_LINE_CHARS < len(title):
                            line = title[0:MAX_LINE_CHARS]
                            line = line.rsplit(' ', 1)
                            new_title += line[0] + '<br>'
                            title = line[1] + title[MAX_LINE_CHARS:]

                        new_title += title
                        return new_title

                    event_str = "All Activity" if event_type is None else \
                        ', '.join(['"{}"'.format(e) for e in filters["Event"]])

                    if event_str != "All Activity":
                        event_str = " and ".join(event_str.rsplit(', ', 1)) \
                            + " Events"

                    user_str = "All Users" if not users else \
                        ', '.join(['"{}"'.format(u) for u in users])

                    if user_str != "All Users":
                        user_str = "User{} "\
                            .format("s" if len(users) != 1 else "") \
                            + " and ".join(user_str.rsplit(', ', 1))

                    if "After" in filters and "Before" in filters:
                        date_str = " between {} and {}"\
                            .format(filters["After"], filters["Before"])
                    elif "After" in filters:
                        date_str = " after {}".format(filters["After"])
                    elif "Before" in filters:
                        date_str = " before {}".format(filters["Before"])
                    else:
                        date_str = ""
                    full_title = '{3}{0} for {1}{2}{4}'\
                        .format(event_str, user_str, date_str,
                                "Totalled " if total else "",
                                " (Limited to {} {} results)"
                                .format(form.limit_type.data,
                                        form.limit.data)
                                if form.limit.data else "")

                    full_title = add_line_breaks(full_title)
                    return re.sub(r"\s?00:00:00", "", full_title)

                graph_div = PlotGraph(
                    log_dump, event_type, users,
                    form.incr.data, total, get_plot_title(),
                    form.blank_days.data)

                return render_template('log_manager.html', title='Logs',
                                       form=form, graph=graph_div, acc_jobs=checked_jobs, acc_tables=acc_tables)
            else:
                return send_from_directory(
                    directory=os.path.join(
                        os.getcwd(),
                        APP.config['LOG_FOLDER']),
                    filename=log_name, as_attachment=True)
        elif form.accuracy_table.data:
                if not form.job_no.data:
                    flash('A job number must be entered.')
                else:
                    # generate table based on which job number was entered.
                    job_no = str(form.job_no.data)
                    job_no = job_no.replace(' ', '').split(',')
                    for job in job_no:
                        acc_table = []
                        checks = Check.query.filter(Check.job_no == job).all()
                        if checks == []:
                            flash(f'There have been no checks under job number {job}.')
                        else:
                            for check in checks:
                                acc_table.append([check.job_no, check.step, check.timestamp.strftime('%Y-%m-%d %H:%M:%S'), check.accuracy])
                            acc_table.reverse()
                        acc_tables.append(acc_table)

        
    return render_template('log_manager.html', title='Logs',
                           form=form, graph="", acc_jobs=checked_jobs, acc_tables=acc_tables)


@APP.route('/admintools', methods=['GET', 'POST'])
@login_required
def admintools():
    """Controls the administrator tools form that allows an administrator
       to add or remove a user, unlock or unlock a user,
       or change a user's password."""
    if not current_user.admin:
        abort(403)  # Forbidden

    unretired_users = User.query.filter(User.retired == 0)
    retired_users = User.query.filter(User.retired == 1)
    locked_users = User.query.filter(User.attempts >= 3,
                                     User.timeout is not None)
    unlocked_users = User.query.filter(User.attempts < 3)

    all_users = User.query.all()
    form = AdminForm()
    if form.validate_on_submit():
        # TODO: Move this to adminform
        if form.new_user_submit.data:  # If 'New User' submit
            # Register the new user
            user = User(username=form.new_user_username.data,
                        fname=form.new_user_fname.data,
                        lname=form.new_user_lname.data,
                        email=form.new_user_email.data)
            user.set_password(form.new_user_password.data)
            DB.session.add(user)
            DB.session.commit()
            log_event("Registered user: " + user.username)
            flash(user.username + ' has been registered!')
            return redirect(url_for('admintools'))
        if form.locked_submit.data:  # If 'Unlock User' submit
            # if not a valid user, don't continue
            user = User.query.filter_by(
                username=form.locked_username.data).first()
            if user is None:
                flash('Invalid Username.')
            elif user.timeout is None or user.timeout < datetime.now():
                flash(f'{user.username} is already unlocked.')
            else:  # if successful
                user.attempts = 0
                user.timeout = None
                DB.session.commit()
                log_event("Unlocked " + user.username)
                flash(f'{user.username} has been unlocked!')
            return redirect(url_for('admintools'))
        if form.to_lock_submit.data:  # If 'lock User' submit
            # if not a valid user, don't continue
            user = User.query.filter_by(
                username=form.to_lock_username.data).first()
            if user is None:
                flash('Invalid Username.')
            elif user.id == current_user.id:
                flash('Cannot lock current user.')
            elif user.timeout is not None and user.timeout > datetime.now():
                flash(f'{user.username} is already locked.')
            else:  # if successful
                user.attempts = 3
                user.timeout = datetime.now() + APP.config['TIMEOUT_LENGTH']
                DB.session.commit()
                log_event("Locked " + user.username)
                flash(f'{user.username} has been locked!')
            return redirect(url_for('admintools'))
        if form.pass_change_submit.data:  # If 'Change Password' submit
            user = User.query.filter_by(
                username=form.pass_change_username.data).first()
            if user is None:  # If the no user was entered or invalid name
                flash('Invalid Username.')
            else:  # if successful
                user.set_password(form.pass_change_password.data)
                DB.session.commit()
                log_event("Changed password for user: " + user.username)
                flash(f'Password changed successfully for {user.username}')
            return redirect(url_for('admintools'))
        if form.to_delete_submit.data:  # If 'Delete User' submit
            # if not a valid user, don't continue
            user = User.query.filter_by(
                username=form.to_delete_username.data).first()
            if user is None:
                flash('Invalid Username.')
            elif user.id == current_user.id:
                flash('Cannot delete current user.')
            else:
                uploads = Upload.query.filter_by(user_id=user.id).all()
                for upload in uploads:
                    DB.session.delete(upload)
                messages = Message.query.filter_by(recipient_id=user.id).all()
                for message in messages:
                    DB.session.delete(message)
                DB.session.delete(user)
                DB.session.commit()
                log_event("Deleted " + user.username)
                flash(f'{user.username} has been deleted.')
            return redirect(url_for('admintools'))
        if form.to_retire_submit.data:  # If 'Retire User' submit
            # if not a valid user, don't continue
            user = User.query.filter_by(
                username=form.to_retire_username.data).first()
            if user is None:
                flash('Invalid Username.')
            elif user.id == current_user.id:
                flash('Cannot retire current user.')
            elif user.retired:
                flash(f'{user.username} is already retired.')
            else:  # if successful
                user.retired = True
                DB.session.commit()
                log_event(user.username + ' has retired.')
                flash(f'{user.username} has retired!')
            return redirect(url_for('admintools'))

        if form.to_unretire_submit.data:  # If 'Un-Retire User' submit
            # if not a valid user, don't continue
            user = User.query.filter_by(
                username=form.to_unretire_username.data).first()
            if user is None:
                flash('Invalid Username.')
            elif not user.retired:
                flash(f'{user.username} is not retired.')
            else:  # if successful
                user.retired = False
                DB.session.commit()
                log_event(user.username + ' returned from retirement.')
                flash(f'{user.username} has returned from retirement!')
            return redirect(url_for('admintools'))
        # if no action taken and still submitted
        flash('No action taken.')
        return redirect(url_for('admintools'))
    return render_template(
        'admintools.html', title="Administrator Tools", form=form,
        locked_users=locked_users, unlocked_users=unlocked_users,
        all_users=all_users, unretired_users=unretired_users,
        retired_users=retired_users)

# Error Pages


@APP.errorhandler(403)
def forbidden(error):
    """Error 403: Forbidden"""
    return render_template('403.html', title="Forbidden"), 403


@APP.errorhandler(404)
def not_found_error(error):
    """Error 404: Page Not Found"""
    return render_template('404.html', title="Not Found"), 404


@APP.errorhandler(500)
def internal_error(error):
    """Error 500"""
    DB.session.rollback()
    return render_template('500.html', title="Error"), 500


@APP.route('/version', methods=['GET', 'POST'])
def version():
    return render_template('version.html', title="Version Information")

@APP.route('/help', methods=['GET', 'POST'])
def help():
    return render_template('help.html', title="Launchpad Help")

@APP.route('/messages', methods=['GET', 'POST'])
@login_required
def messages():
    if 'delete' in request.form:
        for item in request.form.getlist('message_item'):
            Message.query.filter_by(id=int(item)).delete()
        DB.session.commit()
    message_list = current_user.get_messages()
    message_count = len(message_list)
    if message_count != 0:
        # for message in message_list:
        #     message.read = True
        while message_count > 20:
            # go to last message
            # remove that message from the database
            Message.query.filter_by(id=message_list[0].id).delete()
            # refresh list and count
            message_list = current_user.get_messages()
            message_count = len(message_list)
        DB.session.commit()

    return render_template(
        'messages.html', title='Messages',
        message_list=message_list, message_count=message_count)


@APP.route('/read_message', methods=['POST'])
@login_required
def read_message():
    message_id = request.values['message_id']
    message = Message.query.get(int(message_id))
    message.read = True
    DB.session.commit()
    return jsonify({}), 202