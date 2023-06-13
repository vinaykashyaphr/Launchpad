"""Launchpad App"""
from launchpad import APP, DB, SOCKETIO
from launchpad.models import Log, Upload, User
import os

@APP.shell_context_processor
def make_shell_context():
    """Create shell context for command line"""
    return {'DB': DB,
            'User': User,
            'Upload': Upload,
            'Log': Log}

if __name__ == "__main__":
    for k,v in APP.config.items():
        if isinstance(v, str):
            os.environ[k] = v

    SOCKETIO.run(
        APP,
        debug=APP.config['DEBUG'],
        port=APP.config['PORT'],
        host='0.0.0.0')
