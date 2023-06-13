from flask_wtf import FlaskForm
from wtforms import (BooleanField, DateTimeField, DateField, IntegerField,
                     PasswordField,
                     SelectField, SelectMultipleField, StringField,
                     SubmitField)
from wtforms.validators import (Email, EqualTo, InputRequired,
                                Optional, ValidationError)
from launchpad.models import User
from wtforms.widgets.html5 import NumberInput
from wtforms.fields.html5 import DateField as Calendar


class AdminForm(FlaskForm):
    """Administrator Tools Page Form"""
    # add user
    new_user_username = StringField('Username')
    new_user_fname = StringField('First name')
    new_user_lname = StringField('Last name')
    new_user_email = StringField('Email', validators=[Optional(), Email()])
    new_user_password = PasswordField('Password')
    new_user_confirm_password = PasswordField('Confirm Password', validators=[EqualTo('new_user_password', message="Passwords must match")])
    new_user_submit = SubmitField('Add User')
    # unlock user
    locked_username = StringField('Locked Username')
    locked_submit = SubmitField('Unlock User')
    # lock user
    to_lock_username = StringField('Username')
    to_lock_submit = SubmitField('Lock User')
    # change password
    pass_change_username = StringField('Username')
    pass_change_password = PasswordField('New Password')
    pass_change_confirm_password = PasswordField('Confirm New Password', validators=[EqualTo('pass_change_password', message="Passwords must match")])
    pass_change_submit = SubmitField('Change Password')
    # delete user
    to_delete_username = StringField('Username')
    to_delete_submit = SubmitField('Delete User')
    # retire user
    to_retire_username = StringField('Username')
    to_retire_submit = SubmitField('Retire User')
    # unretire user
    to_unretire_username = StringField('Username')
    to_unretire_submit = SubmitField('Un-Retire User')


    def validate(self):
        if not super().validate():
            return False
        if self.new_user_submit.data:  # If 'New User' submit
            # if the relevant fields have not been fully filled, don't continue
            if any([x == '' for x in [self.new_user_username.data, self.new_user_fname.data,
                                      self.new_user_lname.data, self.new_user_email.data,
                                      self.new_user_password.data,
                                      self.new_user_confirm_password.data]]):
                self.new_user_submit.errors.append('All registration fields must be filled in order to register new user.')
                return False
        elif self.pass_change_submit.data:  # If 'Change Password' submit
            # if the relevant fields have not been fully filled, don't continue
            if any([x == '' for x in [self.pass_change_username.data,
                                      self.pass_change_password.data,
                                      self.pass_change_confirm_password.data]]):
                self.pass_change_submit.errors.append('All Password Change fields must be filled to change user password.')
                return False
        return True

    def validate_new_user_username(self, username):
        user = User.query.filter_by(username=username.data).first()
        if user is not None:
            raise ValidationError('This username has already been taken.')

    def validate_new_user_email(self, email):
        user = User.query.filter_by(email=email.data).first()
        if user is not None:
            raise ValidationError('This email address is already in use.')


class LoginForm(FlaskForm):
    username = StringField('Username', validators=[InputRequired()])
    password = PasswordField('Password', validators=[InputRequired()])
    remember_me = BooleanField('Remember Me')
    submit = SubmitField('Sign In')


class ChangePassForm(FlaskForm):
    current_password = PasswordField('Current Password',
                                     validators=[InputRequired()])
    new_password = PasswordField(
        'New Password', validators=[InputRequired()])
    confirm_password = PasswordField(
        'Confirm Password',
        validators=[InputRequired(), EqualTo('new_password',
                    message="Passwords must match")])
    submit = SubmitField('Submit')


class LogForm(FlaskForm):
    user = StringField('Username')
    event = SelectMultipleField(
        'Event Type',
        choices=[('Logged in', 'Logged In'),
                 ('Logged out', 'Logged Out'),
                 ('Changed password', 'Changed Password'),
                 ('Conversion (CMM)', 'Conversion (CMM)'),
                 ('Conversion (EM)', 'Conversion (EM)'),
                 ('Conversion (EIPC)', 'Conversion (EIPC)'),
                 ('Conversion (PDF)', 'Conversion (PDF)')])
    graph = SubmitField('Graph')
    dump = SubmitField('Generate CSV')
    erase = SubmitField('Backup and Erase')
    before_date = DateTimeField('Before Date/Time', validators=[Optional()])
    after_date = DateTimeField('After Date/Time', validators=[Optional()])
    total = BooleanField('Total Results')
    blank_days = BooleanField('Show Days with Zero Events', default='checked')
    x_axis = SelectField(
        'X Axis', choices=[('user', 'User'), ('event', 'Event')],
        default='user')

    incr = SelectField(
        'Time Increment',
        choices=[('days', 'Days'), ('weeks', 'Weeks'),
                 ('months', 'Months'), ('years', 'Years')],
        default='days')
    limit = IntegerField('Limit Results', validators=[Optional()])
    limit_type = SelectField('Limit Type',
                             choices=[('first', 'First'),
                                      ('last', 'Last'),
                                      ('random', 'Random')],
                             default='first')

    job_no = StringField('Job Number')
    accuracy_table = SubmitField('Show Accuracy Check Data')
    
    def filters(self):
        fields = {"User": self.user.data,
                  "Event": self.event.data,
                  "Before": self.before_date.data,
                  "After": self.after_date.data}
        selected_filters = {}
        for k, v in fields.items():
            if v:
                selected_filters[k] = v
        return selected_filters

    def validate(self):
        if not super().validate():
            return False
        if self.graph.data:
            if not self.total.data:
                if len(self.user.data.split(',')) > 1 or not self.user.data:
                    if not self.event.data:
                        self.event.errors.append("""Cannot filter by all events
                            for multiple users. Please specify a specific
                            event type.""")
                        return False
                    elif len(self.event.data) > 1:
                        old_first_word = None
                        for d in self.event.data:
                            first_word = d.split(' ')[0]
                            if old_first_word is None:
                                old_first_word = first_word
                                continue

                            if old_first_word != first_word:
                                self.event.errors.append("""Cannot filter by multiple
                                    event types for multiple users. Please
                                    specify a specific event type.""")
                                return False

        if self.after_date.data and self.before_date.data:
            if self.after_date.data > self.before_date.data:
                self.after_date.errors.append(""""After" Date/Time must be
                    less than "Before" Date/Time""")
                return False

        return True

# Checklist related forms


class JobNo(FlaskForm):
    job_no = StringField('Job Number',
                         validators=[InputRequired("Input required")])
    submit = SubmitField('Submit')

class JobUpdate(FlaskForm):
    ata_number = StringField('ATA Number',
                             validators=[Optional()])
    d_number = StringField('D Number', default="",
                           validators=[Optional()])
    type_of_publication = SelectField('Type of Publication',
                                      choices=[("", '-- Select --'),
                                               ('ACMM', 'ACMM'),
                                               ('AMM', 'AMM'), ('CFTO', 'CFTO'),
                                               ('CMM', 'CMM'), ('CMP', 'CMP'),
                                               ('CMPG', 'CMPG'), ('EIPC', 'EIPC'),
                                               ('EM', 'EM'), ('FIM', 'FIM'),
                                               ('FIP', 'FIP'), ('HMM', 'HMM'),
                                               ('IM', 'IM'), ('IRM', 'IRM'), ('IPC', 'IPC'),
                                               ('LMM', 'LMM'), ('MM', 'MM'), ('OHM', 'OHM'),
                                               ('S200M IPPN', 'S200M IPPN'),
                                               ('SB', 'SB'), ('SDIM', 'SDIM'),
                                               ('SDOM', 'SDOM'),
                                               ('SIL', 'SIL'),
                                               ('SPB', 'SPB'), ('T-File', 'T-File'),
                                               ('TR', 'TR'), ('LAP', 'LAP'),
                                               ('Other', 'Other'),('None', 'None')],
                                      validators=[InputRequired
                                                  ("Input required")])
    project = SelectField('Type of Project',
                          choices=[("", '-- Select --'),
                                   ('HNYWELL', 'Honeywell'),
                                   ('CONV', 'Conversion'),
                                   ('STW', 'Technical Writing'),
                                   ('STRAN', 'Translation'),
                                   ('Other', 'Other'),
                                   ('TRAINHW', 'Training Honeywell'),
                                   ('TRAINCONV', 'Training Conversion'),
                                   ('TRAINTRL', 'Training Translation'),
                                   ('TRAINGC', 'Training Generic Customer')],
                          validators=[InputRequired
                                      ("Input required")])
    software = SelectField('Software',
                           choices=[("", '-- Select --'),
                                    ('Framemaker', 'Framemaker'),
                                    ('Microsoft Word', 'Microsoft Word'),
                                    ('Interleaf', 'Interleaf'),
                                    ('SGML/XML', 'SGML/XML'),
                                    ('PDF', 'PDF'),
                                    ('Other', 'Other'),
                                    ('None', 'None')],
                           validators=[InputRequired("Input required")])
    type_of_job = SelectField('Type of Job',
                              choices=[("", '-- Select --'),
                                       ('New Issue', 'New Issue'),
                                       ('Partial Revision',
                                        'Partial Revision'),
                                       ('Complete Revision',
                                        'Complete Revision'),
                                        ('None', 'None')],
                              validators=[InputRequired("Input required")])
    location_of_authoring = SelectField('Location of Authoring',
                                        choices=[("", '-- Select --'),
                                                 ('North America',
                                                  'North America'),
                                                 ('France', 'France'),
                                                 ('India', 'India'),
                                                 ('Other', 'Other')],
                                        validators=[InputRequired(
                                            "Input required")])
    submit = SubmitField('Submit')

class JobCreation(FlaskForm):
    ata_number = StringField('ATA Number',
                             validators=[InputRequired("Input required")])
    d_number = StringField('D Number', default="",
                           validators=[Optional()])
    type_of_publication = SelectField('Type of Publication',
                                      choices=[("", '-- Select --'),
                                               ('ACMM', 'ACMM'),
                                               ('AMM', 'AMM'),
                                               ('CMM', 'CMM'), ('CMP', 'CMP'),
                                               ('EIPC', 'EIPC'),
                                               ('EM', 'EM'), ('HMM', 'HMM'),
                                               ('IM', 'IMM'), ('IRM', 'IRM'),
                                               ('LMM', 'LMM'), ('MM', 'MM'),
                                               ('SB', 'SB'), ('SDIM', 'SDIM'),
                                               ('SDOM', 'SDOM'),
                                               ('SIL', 'SIL'),
                                               ('SPB', 'SPB'), ('TR', 'TR'),
                                               ('Other', 'Other')],
                                      validators=[InputRequired
                                                  ("Input required")])
    project = SelectField('Type of Project',
                          choices=[("", '-- Select --'),
                                   ('HNYWELL', 'Honeywell'),
                                   ('CONV', 'Conversion'),
                                   ('STW', 'Technical Writing'),
                                   ('STRAN', 'Translation'),
                                   ('Other', 'Other'),
                                   ('TRAINHW', 'Training Honeywell'),
                                   ('TRAINCONV', 'Training Conversion'),
                                   ('TRAINTRL', 'Training Translation'),
                                   ('TRAINGC', 'Training Generic Customer')],
                          validators=[InputRequired
                                      ("Input required")])
    software = SelectField('Software',
                           choices=[("", '-- Select --'),
                                    ('Framemaker', 'Framemaker'),
                                    ('Microsoft Word', 'Microsoft Word'),
                                    ('Interleaf', 'Interleaf'),
                                    ('SGML/XML', 'SGML/XML'),
                                    ('Other', 'Other')],
                           validators=[InputRequired("Input required")])
    type_of_job = SelectField('Type of Job',
                              choices=[("", '-- Select --'),
                                       ('New Issue', 'New Issue'),
                                       ('Partial Revision',
                                        'Partial Revision'),
                                       ('Complete Revision',
                                        'Complete Revision'),
                                        ('Other', 'Other')],
                              validators=[InputRequired("Input required")])
    location_of_authoring = SelectField('Location of Authoring',
                                        choices=[("", '-- Select --'),
                                                 ('North America',
                                                  'North America'),
                                                 ('France', 'France'),
                                                 ('India', 'India'),
                                                 ('Other', 'Other')],
                                        validators=[InputRequired(
                                            "Input required")])
    submit = SubmitField('Submit')

class DCUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    pages_reviewed = IntegerField('Pages Reviewed', widget=NumberInput(min=0, step=1))
    errorcount1 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount2 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount3 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount4 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount5 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount6 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount7 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount8 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount9 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    errorcount10 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class WriterUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    date = Calendar('Date', validators=[Optional()])
    changed_pages_no = IntegerField('Total Number of Changed Pages',
                                    widget=NumberInput(min=0, step=1))
    writer = StringField('Writer')
    input1 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input2 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input3 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input4 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input5 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input6 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input7 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input8 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input9 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input10 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input11 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input12 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input13 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input14 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input15 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input16 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input17 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input18 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input19 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input20 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input21 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input22 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input23 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input24 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input25 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input26 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input27 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input28 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input29 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input30 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input31 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input32 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input33 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input34 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input35 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input36 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input37 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input38 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input39 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input40 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input41 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input42 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input43 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input44 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input45 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input46 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input47 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input48 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input49 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input50 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input51 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input52 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input53 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input54 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input55 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class IllustrationUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    date = Calendar('Date', validators=[Optional()])
    illustrator = StringField('Illustrator')
    comments = StringField('Comments', default='')
    input1 = SelectField('Completed',
                            choices=[("", '-- Select --'),
                                     ('Completed', 'Completed'),
                                     ('N/A', 'N/A')])
    input2 = SelectField('Completed',
                            choices=[("", '-- Select --'),
                                     ('Completed', 'Completed'),
                                     ('N/A', 'N/A')])
    input3 = SelectField('Completed',
                            choices=[("", '-- Select --'),
                                     ('Completed', 'Completed'),
                                     ('N/A', 'N/A')])
    input4 = SelectField('Completed',
                            choices=[("", '-- Select --'),
                                     ('Completed', 'Completed'),
                                     ('N/A', 'N/A')])
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class EditorUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    date = Calendar('Date', validators=[Optional()])
    editor = StringField('Editor')
    input1 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input2 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input3 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input4 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input5 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input6 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input7 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input8 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input9 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input10 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input11 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input12 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input13 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input14 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input15 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input16 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input17 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input18 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input19 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input20 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input21 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input22 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input23 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input24 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input25 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input26 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input27 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input28 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input29 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input30 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input31 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input32 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input33 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input34 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input35 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input36 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input37 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input38 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input39 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input40 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input41 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input42 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input43 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input44 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input45 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input46 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input47 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input48 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input49 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input50 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input51 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class QAUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    qa_1 = StringField('QA (1)')
    date_1 = Calendar('Date (1)', validators=[Optional()])
    qa_2 = StringField('QA (2)', default='')
    date_2 = Calendar('Date (2)', validators=[Optional()])
    qa_3 = StringField('QA (3)', default='')
    date_3 = Calendar('Date (3)', validators=[Optional()])
    input1 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input2 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input3 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input4 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input5 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input6 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input7 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input8 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input9 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input10 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input11 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input12 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input13 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input14 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input15 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input16 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input17 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input18 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input19 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input20 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input21 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input22 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input23 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input24 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input25 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input26 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input27 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input28 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input29 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input30 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input31 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    input32 = IntegerField('Error Count', widget=NumberInput(min=0, step=1))
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')



class FinalDeliveryUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    name_fd = StringField('Name')
    date = Calendar('Date', validators=[Optional()])
    input1 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input2 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input3 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input4 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input5 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input6 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input7 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input8 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input9 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input10 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input11 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input12 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input13 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input14 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input15 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input16 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input17 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input18 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input19 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input20 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input21 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input22 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input23 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input24 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input25 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input26 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input27 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input28 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input29 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    input30 = SelectField('Completed', choices=[("", '-- Select --'), ('Completed', 'Completed'), ('N/A', 'N/A')])
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class DPMOUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    total_pages = IntegerField('Total Pages',
                               widget=NumberInput(min=0, step=1))
    date = Calendar('Date', validators=[Optional()])
    input1 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input2 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input3 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input4 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input5 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input6 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input7 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input8 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input9 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input10 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input11 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input12 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input13 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input14 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input15 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input16 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input17 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input18 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input19 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input20 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input21 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input22 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input23 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input24 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input25 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input26 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input27 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input28 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input29 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input30 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input31 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input32 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input33 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input34 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input35 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input36 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input37 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input38 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input39 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input40 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input41 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    input42 = IntegerField('Number of Errors', widget=NumberInput(min=0, step=1))
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')

class TranslationUpdate(FlaskForm):
    op_manager = StringField('Operations Manager')
    er_level = IntegerField('ER Level/ Total Customer Reviews', widget=NumberInput(min=0, step=1))
    translator = StringField('Translator')
    client = StringField('Name of Company/Client')
    date1 = Calendar('Date', validators=[Optional()])
    date2 = Calendar('Date', validators=[Optional()]) #export date?
    memory_english = StringField('Memory used')
    memory_french = StringField('Mémoire utilisée')
    input1 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input2 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input3 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input4 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input5 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input6 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input7 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input8 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input9 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input10 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input11 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    input12 = SelectField('Verified', choices=[("", '-- Select --'), ('Verified', 'Verified')])
    submit_complete = SubmitField('Submit: CHECKLIST COMPLETED')
    submit_incomplete = SubmitField('Submit: CHECKLIST STILL IN PROGRESS')


class ChecklistManager(FlaskForm):
    user = StringField('Username')
    complete = SelectField('Choose Completion Status', choices=[('Completed', 'Completed'), ('Incomplete', 'Incomplete'), ('All', 'All')])
    checklist_type = SelectField(
        'Choose Checklist Type', choices=[('DPMO', 'DPMO'),
                  ('Data Conversion', 'Data Conversion'),
                  ('Editor', 'Editor'),
                  ('Final Delivery', 'Final Delivery'),
                  ('Illustration', 'Illustration'),
                  ('QA', 'QA'),
                  ('Translation', 'Translation'),
                  ('Writer', 'Writer')])
    project = SelectField('Project',
                           choices=[('All', 'All'),
                                    ('HNYWELL', 'Honeywell'),
                                    ('CONV', 'Conversion'),
                                    ('STW', 'Technical Writing'),
                                    ('STRAN', 'Translation'),
                                    ('Other', 'Other'),
                                    ('TRAINHW', 'Training Honeywell'),
                                   ('TRAINCONV', 'Training Conversion'),
                                   ('TRAINTRL', 'Training Translation'),
                                   ('TRAINGC', 'Training Generic Customer')])
    op_manager = StringField('Operations Manager')
    before_date = DateTimeField('Before Date/Time', validators=[Optional()])
    after_date = DateTimeField('After Date/Time', validators=[Optional()])
    job_no = StringField('Job Number', validators=[Optional()])
    er_level = SelectField('ER Level/Customer Review',
                           choices=[('All', 'All'),
                                    ('Latest', 'Latest'),
                                    ('Pre-Delivery (ER Level 0)',
                                     'Pre-Delivery (ER Level 0)'),
                                    ('Engineering Review (ER Level 1+)',
                                     'Engineering Review (ER Level 1+)')])
    order = SelectField('Sort Date by:',
                        choices=[('Ascending Order', 'Ascending Order'),
                                 ('Descending Order', 'Descending Order')],
                        default='Ascending Order')
    graph = SubmitField('View Table')
    export = SubmitField('Generate CSV')

    def filters(self):
        fields = {"Job_no": self.job_no.data,
                  "User": self.user.data,
                  "Checklist_type": self.checklist_type.data,
                  "Before": self.before_date.data,
                  "Project": self.project.data,
                  "After": self.after_date.data,
                  "ER": self.er_level.data,
                  "Order": self.order.data,
                  "Complete": self.complete.data,
                  "OM": self.op_manager}
        selected_filters = {}
        for k, v in fields.items():
            if v:
                selected_filters[k] = v
        return selected_filters

class DPMOManager(FlaskForm):
    op_manager = StringField('Operations Manager')
    display_type = SelectField('Choose information to be displayed', choices=[('Monthly Metrics', 'Monthly Metrics'), ('Date Range', 'Date Range')])
    # complete = SelectField('Choose Completion Status', choices=[('Completed', 'Completed'), ('Incomplete', 'Incomplete'), ('All', 'All')])
    month = IntegerField('Month', widget=NumberInput(min=1, max=12, step=1), default=1)
    year = IntegerField('Year', widget=NumberInput(min=1, step=1), default=1)
    user = StringField('Username')
    project = SelectField('Project',
                           choices=[('HNYWELL', 'Honeywell'),
                                    ('All', 'All'),
                                    ('CONV', 'Conversion'),
                                    ('STW', 'Technical Writing'),
                                    ('STRAN', 'Translation'),
                                    ('Other', 'Other'),
                                    ('TRAINHW', 'Training Honeywell'),
                                   ('TRAINCONV', 'Training Conversion'),
                                   ('TRAINTRL', 'Training Translation'),
                                   ('TRAINGC', 'Training Generic Customer')],
                           default='HNYWELL')
    before_date = DateTimeField('Before Date/Time', validators=[Optional()])
    after_date = DateTimeField('After Date/Time', validators=[Optional()])
    job_no = StringField('Job Number', validators=[Optional()])
    er_level = SelectField('ER Level/Customer Review',
                           choices=[('All', 'All'),
                                    ('Latest', 'Latest'),
                                    ('Pre-Delivery (ER Level 0)',
                                     'Pre-Delivery (ER Level 0)'),
                                    ('Engineering Review (ER Level 1+)',
                                     'Engineering Review (ER Level 1+)')],
                           default='All')
    order = SelectField('Sort Date by:',
                        choices=[('Descending Order', 'Descending Order'),
                                ('Ascending Order', 'Ascending Order')],
                        default='Descending Order')
    submit = SubmitField('View Tables and Graphs')
    export = SubmitField('Generate CSV')

    def filters(self):
        fields = {"Job_no": self.job_no.data,
                  "User": self.user.data,
                  "Before": self.before_date.data,
                  "Project": self.project.data,
                  "After": self.after_date.data,
                  "ER": self.er_level.data,
                  "Order": self.order.data,
                #   "Complete": self.complete.data,
                  "OM": self.op_manager}
        selected_filters = {}
        for k, v in fields.items():
            if v:
                selected_filters[k] = v
        return selected_filters


class ChecklistHistory(FlaskForm):
    job_no = StringField('Job Number', validators=[InputRequired()])
    submit = SubmitField('View')
    export = SubmitField('Export as csv file')