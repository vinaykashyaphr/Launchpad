# from launchpad.functions import sql_select, sql_update
from openpyxl import load_workbook
import sqlite3

DB = "V:/600/640 - Production Tools/645 - Transition/640013_Client_Tool/Release/launchpad.db"
SPREADSHEET = "N:/513 - Honeywell - Other Sites/513005 - Conversion/Tools/Final Assembly/Data/Delivered_Finals.xlsx"

def sqlite_connect(DB_PATH=DB):
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

wb = load_workbook(SPREADSHEET)
ws =  wb["Modelics"]
ws2 =  wb["Delivery Info"]
connection, cursor = sqlite_connect()

for row in list(ws2.rows)[1:]:
    for i,cell in enumerate(row):
        if i % 5 == 0:
            job_number = typ = date = modellic = cage = pm_number = None
            continue
        elif cell.value is None:
            continue
        elif (i-1) % 5 == 0:
            job_number = cell.value
        elif (i-2) % 5 == 0:
            typ = cell.value
        elif (i-3) % 5 == 0:
            date = cell.value
        else:
            values = cell.value.split('-')
            modellic = values[1]
            cage = values[2]
            pm_number = int(values[3])
            for job in str(job_number).split(' '):
                job = job.strip('()')
                print(job, typ, date, modellic, cage, pm_number)
                try:
                    cursor.execute("INSERT INTO 'Delivery Info' (job, type, delivery_date, modellic, cage, pm_number) VALUES (?, ?, ?, ?, ?, ?);", (job, typ, date, modellic, cage, pm_number))
                except Exception as e:
                    print(e)
                    continue

for row in list(ws.rows)[1:]:
    job_number = row[0].value
    modellic = row[1].value
    print(job_number, modellic)
    try:
        cursor.execute("INSERT INTO 'Delivery Info' (job, modellic, delivery_date) VALUES (?, ?, ?);", (job_number, modellic, None))
    except Exception as e:
        print(e)
        continue

connection.commit()
cursor.close()
connection.close()
