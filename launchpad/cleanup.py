from datetime import datetime, timedelta
import shutil
from pathlib import Path

# from celery import task

from launchpad import APP, DB, LAST_CLEANUP, CELERY
from launchpad.models import Upload


def time_until_next_cleanup():
    """Returns the time until the next cleanup sweep"""
    if LAST_CLEANUP is None:
        return APP.config['CLEANUP_DELAY']
    else:
        return (APP.config['CLEANUP_DELAY'] -
                (datetime.now() - LAST_CLEANUP).total_seconds())


def delete_all_files():
    """Clear the database of file uploads"""
    for dty in Path(APP.config['UPLOAD_FOLDER']).resolve().iterdir():
        if dty.is_dir():
            shutil.rmtree(dty)

    # Clear database
    for upl in Upload.query.all():
        DB.session.delete(upl)

    DB.session.commit()

@CELERY.task
def clear_expired_files():
    global LAST_CLEANUP
    """Cleanup files that have expired"""
    now = datetime.now()
    for upl in Upload.query.filter(
            Upload.timestamp < now - timedelta(
                seconds=APP.config['DIRECTORY_LIFETIME'])).all():
        directory = Path(APP.config['UPLOAD_FOLDER']) / str(upl.id)
        if directory.is_dir():
            print("Cleaning up old files...")
            shutil.rmtree(directory)
        DB.session.delete(upl)
    DB.session.commit()
    for zip_file in list(Path(APP.config['UPLOAD_FOLDER']).glob("Batch*.zip")):
        if (now - datetime.fromtimestamp(zip_file.stat().st_mtime))\
                .seconds > 300:
            print("Cleaning up old batch downloads...")
            zip_file.unlink()
    LAST_CLEANUP = now
    return
