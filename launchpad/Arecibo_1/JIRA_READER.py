from jira import JIRA
import re
import subprocess
import os
import datetime
import warnings
try:
    from launchpad.Arecibo_1.ar_interface import jobs_in_progress as jip
except:
    from ar_interface import jobs_in_progress as jip

warnings.filterwarnings("ignore", message="Unverified HTTPS request is being made.")

def main(job_number, directory):
    username = 'appsteam'
    password = 'Personal#4434'
    jira_options = {'server': 'https://jira.appendix.ca:8443/jira/',
                    'verify': False}

    try:
        jira = JIRA(options=jira_options, basic_auth=(username, password))                                              #Authorization steps, place username in the first field and password in the second (Same as the one use to login to JIRA)
    except:
        jip[directory.name].log_print("Authentication Error, Please see if username or password is correct")

    # ##Getting the Job number 10 tries
    # for test in range(0, 10):
    #     try:
    #         for x in range(0, 10):
    #             print("--------------------------------------------------------------------------------")
    #             print("Please input the job number:")
    #             job_number = input()
    #             check = re.search(r"^\d{6,7}$", job_number)
    #             if check:
    #                 break
    #             else:
    #                 print("Invalid job number")
    #         #Getting all the relevant information
    #         allfields = jira.fields()                                       ##
    #         nameMap = {field['name']: field['id'] for field in allfields}  ##Gets all the available customfields available
    #         mult_issues = jira.search_issues('text ~ "' + job_number + '" and NOT type = "TI Sub-task" ')  ##Get the issue by their job number (ignores subtasks)
    #         issue = jira.issue(mult_issues[0])
    #         break
    #     except IndexError:
    #         print("JOB NUMBER NOT FOUND:")
    #         print("     This job could not be found, please try again")
    try:
        allfields = jira.fields()                                       ##
        nameMap = {field['name']: field['id'] for field in allfields}  ##Gets all the available customfields available
        mult_issues = jira.search_issues('text ~ "' + job_number + '" and NOT type = "TI Sub-task" ')  ##Get the issue by their job number (ignores subtasks)    
        issue = jira.issue(mult_issues[0])
    except IndexError:
        # invalid job number?
        return ['invalid']
    #print(nameMap)    ##This will show all the fields currently available in all the jobs in JIRA
    ##Gets all the required fields from the Job
    ATA = str(getattr(issue.fields, nameMap['ATA Number'])).strip()
    try:    
        Pub_Num = getattr(issue.fields, nameMap['Publication Number']).strip()
    except:                                            
        Pub_Num = str(getattr(issue.fields, nameMap['D Number'])).strip()
    #Title = getattr(issue.fields, nameMap['Publication Title'])                                                        #Activate once these fields are included in JIRA
    Title = "0"
    CAGE = str(getattr(issue.fields, nameMap['Cage Code']).value).strip()
    ECCN = str(getattr(issue.fields, nameMap['ECCN Code'])).strip()
    D_Num = str(getattr(issue.fields, nameMap['D Number'])).strip()
    Final_date = str(getattr(issue.fields, nameMap['Final Due Date'])).strip()
    try:
        TR_Rev = str(getattr(issue.fields, nameMap['Revision Number:'])).strip()
    except:
        pass
    Date = Final_date.split('-')
    try:
        cDate = datetime.datetime(int(Date[0]), int(Date[1]), int(Date[2])).strftime("%#d %b %Y")
    except ValueError:
        Final_date = str(getattr(issue.fields, nameMap['DueDate'])).strip()
        Date = Final_date.split('-')
        cDate = datetime.datetime(int(Date[0]), int(Date[1]), int(Date[2])).strftime("%#d %b %Y")
    try:
        list = CAGE, ATA, Pub_Num, Title, ECCN, cDate, D_Num, TR_Rev
    except UnboundLocalError:
        list = CAGE, ATA, Pub_Num, Title, ECCN, cDate, D_Num
    print(list)
    return list







