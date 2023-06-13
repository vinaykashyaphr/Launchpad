from math import log
import traceback
from threading import Event
from pathlib import Path
# import time

from flask_socketio import SocketIO

from . import APP, DB
from launchpad.models import Arecibo, User
import sqlite3

socket_io = SocketIO(message_queue=APP.config['CELERY_BROKER_URL'])

tab_ids = {
    'conv': "tab_conv",
    'qa': "tab_qa",
    'blocks': "tab_textblocks",
    'jobfolder': "tab_folder",
    "highlight": "tab_highlight",
    "hl": "tab_highlight",
    'bl': "tab_textblocks",
    'qa': "tab_qa",
    'fc': "tab_folder",
    'tw': "tab_arec",
    'hot': "tab_hot",
    'finals': "tab_finals",
}

def log_print(message, logname="report.log", log_only=False):
    if not log_only:
        print(message)
    
    with open(logname, mode='a') as f:
        f.write("\n" + message) 

DB_PATH = APP.config['SQLALCHEMY_DATABASE_URI'].replace("sqlite:///", "")
# DB_PATH = "C:/Users/asmith/Documents/GitHub/Launchpad/launchpad/Finals/data_conversion_finals.db"

def sqlite_connect(DB_PATH=DB_PATH):
    try:
        connection = sqlite3.connect(DB_PATH)
        cursor = connection.cursor()
    except sqlite3.Error as error:
        print(f"Error while connecting to sqlite: {error}")
        return None, None
    else:
        # print("Successfully connected to Database")
        return connection, cursor

def sqlite_select(query, db=None, fetchall=True):
    connection, cursor = sqlite_connect() if db is None else sqlite_connect(db)
    return_value = []
    if connection is not None and cursor is not None:
        try:
            cursor.execute(query)
        except sqlite3.Error as error:
            print(error)
        else:
            return_value = cursor.fetchall() if fetchall else cursor.fetchone()
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
            raise error
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

class ConversionClient():
    """Conversion task object to act as a
    client, instead of part of the server"""
    # pylint: disable=too-many-instance-attributes

    def arecibo_log(self, job_number, pages, errors):
        """Add Arecibo metrics to the database"""
        DB.session.add(Arecibo(job_no=job_number, user_id=self.user,
                       pages=pages, errors=errors))
        DB.session.commit()

    def get_user_input(self, message, default=None):
        """Get input from Launchpad"""
        self.log_print("Getting user input")
        self.user_input = None
        self.received_input.clear()
        self.log_print('\n>>> ' + message, True)
        socket_io.emit('prompt_input',
                       data={'message': message,
                             'timeout': APP.config['INPUT_TIMEOUT'],
                             'upload_id': self.dir.split('\\')[-1],
                             'sio': self.sio.sid if self.sio is not None else ''},
                       room=self.user)

        while not self.received_input.isSet():
            is_set = self.received_input.wait(APP.config['INPUT_TIMEOUT'] + 5)
            if is_set:
                if self.user_input is not None:
                    value = self.user_input
                elif default is not None:
                    value = default
                else:
                    self.log_print("Input timed out.")
                    return self.exit_handler(2)
            elif default is not None:
                value = default
            else:
                self.log_print("Input timed out.")
                return self.exit_handler(2)
            self.log_print(">: " + value)
            return value

    def log_print(self, print_message, print_to_log_only=False):
        """Print log"""
        if not print_to_log_only:
            print(print_message)
            socket_io.emit(
                'print_message',
                '\n{}'.format(print_message),
                room=self.user)
        self.log_text += '\n' + str(print_message)

    def exit_handler(self, status=0):
        """Handle exit event"""
        if self.log_text != "":
            try:
                (Path(self.dir) / self.log_name)\
                    .write_text(self.log_text.strip('\n'), encoding='utf-8')
            except Exception:
                print(traceback.format_exc())

    def get_user_info(self):
        return User.query.filter_by(username=self.user).first()

    def __init__(self, directory, user, log_name="log.txt", sio=None, task_id=None):
        self.dir = directory
        self.user = user
        self.task_id = task_id
        self.log_name = log_name
        self.log_text = ""
        self.user_input = None
        self.received_input = Event()

        self.sio = sio
        if self.sio is not None:
            @self.sio.on('response')
            def on_response(data):
                print("Got a response")
                self.user_input = data['input']
                self.received_input.set()

            # @self.sio.event
            # def connect():
            #     print(f"sio connected with id: {self.sio.sid}")

            # @self.sio.event
            # def disconnect():
            #     print("sio disconnected!")
