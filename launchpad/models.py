import json
from datetime import datetime
from flask_login import UserMixin
from werkzeug.security import check_password_hash, generate_password_hash
from launchpad import DB, LOGIN
from sqlalchemy.orm import backref

@LOGIN.user_loader
def load_user(uid):
    """Get user ID"""
    return User.query.get(int(uid))


# pylint: disable=no-member
class User(UserMixin, DB.Model):
    """User table"""
    id = DB.Column(DB.Integer, primary_key=True)
    username = DB.Column(DB.String(64), index=True, unique=True)
    fname = DB.Column(DB.String(64))
    lname = DB.Column(DB.String(64))
    email = DB.Column(DB.String(120), index=True, unique=True)
    admin = DB.Column(DB.Boolean(), default=False)
    password_hash = DB.Column(DB.String(128))
    uploads = DB.relationship('Upload', backref='user', lazy='dynamic')
    activity = DB.relationship('Log', backref='user', lazy='dynamic')
    arecibo = DB.relationship('Arecibo', backref='user', lazy='dynamic')
    messages = DB.relationship('Message', backref='recipient', lazy='dynamic')
    retired = DB.Column(DB.Boolean(), default=False)
    role = DB.Column(DB.Integer, default=0)

    # Password Timeout Vars
    attempts = DB.Column(DB.Integer, default=0)
    timeout = DB.Column(DB.DateTime) 

    def get_user_type(self):
        try:
            return self.user_type
        except AttributeError:
            self.user_type = 'None'
            return self.user_type

    def __repr__(self):
        return '<User {}>'.format(self.username)

    def set_password(self, password):
        """Set user password"""
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        """Check user password"""
        return check_password_hash(self.password_hash, password)

    def get_messages(self):
        return self.messages.all()

    def count_unread_messages(self):
        return len(self.messages.filter_by(read=False).all())


class Upload(DB.Model):
    """File upload table"""
    id = DB.Column(DB.Integer, primary_key=True)
    filename = DB.Column(DB.String(140), index=True)
    timestamp = DB.Column(DB.DateTime, index=True, default=datetime.now)
    user_id = DB.Column(DB.Integer, DB.ForeignKey('user.id'))
    upload_type = DB.Column(DB.String(4))
    status = DB.Column(DB.String(32), default="Pending")

    def __repr__(self):
        return '<Upload {} by User {}>'.format(self.filename, self.user_id)


class Log(DB.Model):
    """Log entry table"""
    id = DB.Column(DB.Integer, primary_key=True)
    timestamp = DB.Column(DB.DateTime, index=True, default=datetime.now)
    user_id = DB.Column(DB.Integer, DB.ForeignKey('user.id'))
    address = DB.Column(DB.String(32))
    event = DB.Column(DB.String(128), index=True)

    def __repr__(self):
        return '<User {} ({}): {} on {}>'\
            .format(User.query.get(self.user_id).username,
                    self.address, self.event,
                    self.timestamp.strftime("%m/%d/%Y, %H:%M:%S"))

    def print_csv(self):
        """Print CSV row"""
        return '{},{},{},{}\n'\
            .format(User.query.get(self.user_id).username,
                    self.address, self.event,
                    self.timestamp.strftime("%m/%d/%Y, %H:%M:%S"))


class Arecibo(DB.Model):
    """Arecibo output table"""
    id = DB.Column(DB.Integer, primary_key=True)
    job_no = DB.Column(DB.String(7), index=True)
    user_id = DB.Column(DB.Integer, DB.ForeignKey('user.id'))
    timestamp = DB.Column(DB.DateTime, index=True, default=datetime.now)
    pages = DB.Column(DB.Integer)
    errors = DB.Column(DB.String)

    def get_error_data(self):
        """Returns serialized data in a dict"""
        return json.loads(self.errors)

    def __repr__(self):
        return '<Job {} checked by {} on {}>'\
            .format(self.job_no, User.query.get(self.user_id).username,
                    self.timestamp.strftime("%m/%d/%Y, %H:%M:%S"))


class Jobs(DB.Model):
    __tablename__ = "jobs"
    id = DB.Column(DB.Integer, primary_key=True)
    job_no = DB.Column(DB.String, index=True, unique=True)
    ata_number = DB.Column(DB.String)
    d_number = DB.Column(DB.String)
    project = DB.Column(DB.String)
    type_of_publication = DB.Column(DB.String)
    software = DB.Column(DB.String)
    type_of_job = DB.Column(DB.String)
    location_of_authoring = DB.Column(DB.String)
    stage = DB.Column(DB.String)
    checklists = DB.relationship("Checklists", secondary="jobs_checklists")

    def __repr__(self):
        return '<Job Number: {}, ATA Number: {}, D Number: {},'\
                'Publication Type: {}, Software: {},'\
                'Job Type: {}, Location of Authoring: {}>'\
                .format(self.job_no, self.ata_number, self.d_number,
                        self.type_of_publication, self.software,
                        self.type_of_job,
                        self.location_of_authoring)


class Checklists(DB.Model):
    __tablename__ = "checklists"
    id = DB.Column(DB.Integer, primary_key=True)
    completed = DB.Column(DB.Boolean)
    checklist_type = DB.Column(DB.String)
    date_created = DB.Column(DB.DateTime)
    created_by = DB.Column(DB.String)
    revision = DB.Column(DB.Integer, default=1)
    checklist_history = DB.Column(DB.String)
    data = DB.Column(DB.String)
    op_manager = DB.Column(DB.String)
    jobs = DB.relationship("Jobs", secondary="jobs_checklists")
    er = DB.Column(DB.Integer, default=0) # Placeholder for JIRA

    def __repr__(self):
        return '<_id: {}, Completed: {}, Type of Checklist: {}, Date Created: {},'\
                'Revision: {}, Created by: {}, Data: {}, History: {}>'\
                .format(self.id, self.completed, self.checklist_type, 
                        self.date_created.strftime("%m/%d/%Y, %H:%M:%S"),
                        self.revision, self.created_by, self.data, self.checklist_history)


class Jobs_Checklists(DB.Model):
    __tablename__ = "jobs_checklists"
    __mapper_args__ = {'confirm_deleted_rows': False}
    id = DB.Column(DB.Integer, primary_key=True)
    jobs_id = DB.Column(DB.Integer, DB.ForeignKey("jobs.id"))
    checklists_id = DB.Column(DB.Integer, DB.ForeignKey("checklists.id"))
    job = DB.relationship(Jobs,
                          backref=backref("jobs_checklists",
                                          cascade="all, delete-orphan"))
    checklist = DB.relationship(Checklists,
                                backref=backref("jobs_checklists",
                                                cascade="all, delete-orphan"))
from launchpad.functions import socket_io  # noqa: E402


class Message(DB.Model):
    id = DB.Column(DB.Integer, primary_key=True)
    recipient_id = DB.Column(DB.Integer, DB.ForeignKey('user.id'))
    timestamp = DB.Column(DB.DateTime, index=True, default=datetime.now)
    title = DB.Column(DB.String(64))
    content = DB.Column(DB.String(4096))
    read = DB.Column(DB.Boolean(), default=False)

    @staticmethod
    def send_message(recipient, subject, contents, for_admin=False,
                     to_all=False):
        if to_all:
            users = User.query.all()
            for user in users:
                message = Message(recipient_id=user.id, title=subject,
                                  content=contents)
                DB.session.add(message)
                socket_io.emit(
                    'message', {'unread': user.count_unread_messages()},
                    room=user.username)
        else:
            if for_admin:
                admins = User.query.filter_by(admin=True).all()
                for admin_user in admins:
                    message = Message(recipient_id=admin_user.id,
                                      title=subject, content=contents)
                    DB.session.add(message)
                    socket_io.emit(
                        'message',
                        {'unread': admin_user.count_unread_messages()},
                        room=admin_user.username)

            if recipient != 0:
                user = User.query.get(recipient)
                if not all([for_admin, user.admin]):
                    message = Message(recipient_id=recipient,
                                      title=subject, content=contents)
                    DB.session.add(message)
                    socket_io.emit(
                        'message', {'unread': User.query.get(recipient)
                                    .count_unread_messages()},
                        room=User.query.get(recipient).username)
        DB.session.commit()


class Check(DB.Model):
    id = DB.Column(DB.Integer, primary_key=True)
    timestamp = DB.Column(DB.DateTime, index=True, default=datetime.now)
    job_no = DB.Column(DB.String(16), index=True)
    step = DB.Column(DB.String(32), index=True)
    accuracy = DB.Column(DB.Float())
