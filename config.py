import os
from datetime import timedelta
basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    APTCUSTOM = os.environ.get('APTCUSTOM', "V:\\500\\00-Printing-Tools\Honeywell_Print-S1000D") # Per Site
    ARBORTEXT_HOME = "C:\Program Files\PTC\Arbortext Editor" # Verify
    ARECIBO_CHECKLISTS = os.environ.get('ARECIBO_CHECKLISTS', 'V:/500/500 - Catch All/TECHWRITE/Shawn/Arecibo Checklist2')
    HONEYWELL_GRAPHICS = os.environ.get('HONEYWELL_GRAPHICS', "P:/HPS/Honeywell Templates/graphics/Output") # Per Site?
    FINALS_DB = os.environ.get('FINALS_DB', "V:/600/640 - Production Tools/645 - Transition/640013_Client_Tool/Release/launchpad.db")
    XML_SCHEMA_PATH = os.environ.get('XML_SCHEMA_PATH', "C:/S1000D_4-1/xml_schema_flat")
    DEBUG = os.environ.get('FLASK_DEBUG', True)
    HOST = 'localhost'
    PORT = 80
    SECRET_KEY = os.environ.get('SECRET_KEY', 'shh_its_a_secret')
    DIRECTORY_LIFETIME = 604800 # 1 week
    CLEANUP_DELAY = 60
    INPUT_TIMEOUT = 30
    SITE = "Ottawa" # Per Site
    UPLOAD_FOLDER = os.environ.get('UPLOAD_FOLDER', 'Uploads')
    LOG_FOLDER = os.environ.get('LOG_FOLDER', 'Logs') 
    # CHECKLISTEXCEL_FOLDER = os.environ.get('CHECKLISTEXCEL_FOLDER') or 'Checklistexcel'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
    #     'sqlite:///' + os.path.join(basedir, 'launchpad.db')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        ("sqlite:///V:/600/640 - Production Tools/645 - Transition"
         "/640013_Client_Tool/Release/launchpad.db") # Per Site
    
    CELERY_BROKER_URL = 'redis://localhost:6379/0'
    result_backend = 'redis://localhost:6379/0'
    # CELERYBEAT_SCHEDULE = {
    beat_schedule = {
        'clear_expired_files': {
            'task': 'launchpad.cleanup.clear_expired_files',
            'schedule': CLEANUP_DELAY
        }
        # 'print_queue': {
        #     'task': 'launchpad.views_conv.print_queue',
        #     'schedule': 15
        # }
    }
    # Password Timeout Constants
    MAX_ATTEMPTS = 3
    TIMEOUT_LENGTH = timedelta(days=36500)

    # # Email Constants
    # MAIL_DEBUG = os.environ.get('MAIL_DEBUG') or False
    # MAIL_SERVER = os.environ.get('MAIL_SERVER')
    # MAIL_PORT = int(os.environ.get('MAIL_PORT') or 25)
    # MAIL_USE_TLS = os.environ.get('MAIL_USE_TLS') is not None
    # MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
    # MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
    # ADMINS = ['vinay.kashyap@sonovision-aetos.in',
    #           'david.dunkelman@sonovisiongroup.com']
