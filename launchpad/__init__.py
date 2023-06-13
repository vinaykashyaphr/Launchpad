import os
import datetime

from celery import Celery
from flask import Flask
from flask_login import LoginManager
from flask_migrate import Migrate
from flask_socketio import SocketIO
from flask_sqlalchemy import SQLAlchemy

from config import Config

BASEDIR = os.path.abspath(os.path.dirname(__file__))

APP = Flask(__name__, instance_relative_config=True)
APP.config.from_object(Config)

@APP.after_request
def after_request(response):
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate, public, max-age=0"
    response.headers["Expires"] = 0
    response.headers["Pragma"] = "no-cache"
    return response

os.environ['ARBORTEXT_HOME'] = APP.config['ARBORTEXT_HOME']
os.environ['APTCUSTOM'] = APP.config['APTCUSTOM']
DB = SQLAlchemy(APP)
MIGRATE = Migrate(APP, DB)
LOGIN = LoginManager(APP)
LOGIN.login_view = 'login'

CELERY = Celery(APP.name, broker=APP.config['CELERY_BROKER_URL'])
CELERY.conf.update(APP.config)
from launchpad.custom_celery import RequestContextTask  # noqa: E402
CELERY.Task = RequestContextTask

SOCKETIO = SocketIO(APP, ping_interval=60, ping_timeout=600, engineio_logger=True, logger=True,
                    message_queue=APP.config['CELERY_BROKER_URL'])

LAST_CLEANUP = datetime.datetime.now()

from . import models, socket, views, views_conv, views_techwrite, views_checklists # noqa: F401
from .cleanup import delete_all_files  # noqa: F401
