#!/usr/bin/env python3
import parameters
import serial
import datetime
import requests
from pymongo import MongoClient
import schedule

#----------------------PARAMATERS--------------------------------------
portPath = parameters.SERIAL_PORT_URL
baubrate = parameters.BAUDRATE
timeout = parameters.TIMEOUT
EdgeName = parameters.EDGE_NAME + "." + parameters.EDGE_ID
url = parameters.URL_CLOUD_SERVER
header = {"content-type":"application/x-www-form-urlencoded"}
url_db = parameters.URL_MONGO_DB
alpha = 0.1

data = {
    'GPS': None, 
    'O2': None, 
    'Temp': None, 
    'Hum': None,
    'Pre': None, 
    'PM10': None, 
    'PM25': None, 
    'PM100': None
}

#---------------------FUNCTIONS-----------------------------------------

#return a serial obj if fail return -1
def create_serial_obj():
    try:
        serial_listen = serial.Serial(portPath, baubrate, timeout = timeout)
        return serial_listen
    except Exception as e:
        print("Create Serial Obj Error !")
        print(e)
        return -1



#return a index if fail return -1
''' data frame format

Data Waspmote & Arduino to Edge
# <> # <> # DeviceID # <> # DeviceType # TypesOfData # <data01> # <data02> # <data...> # <>
  0    1     2          3    4             5             6           7        ...    

  record[2]: DeviceID
  record[4]: DeviceType
  record[5]: TypesOfData
  record[6] -> end : data
''' 
def handle_message(mess):
    mess = mess.decode('utf8','ignore')
    record = mess.replace('STR:', '').split('#')
    record = list(filter(None, record))

    if len(record) != 0 and len(record) >= 5:   
        TypesOfData = record[4].split('?')

        k=5
        for i in TypesOfData:
            if data[i] == None:
                try:
                    data[i] = float(record[k])
                except Exception as e:
                    print("Data from Sensor Node not in Data Form in Edge !")
                    print(e)
            else:
                data[i] = float(record[k]) * (1 - alpha) + alpha * data[i]
            k = k + 1
        
        print(data)



def store_to_mongodb(index):
    try: 
        #connect mongodb
        client = MongoClient(url_db)
        #client = MongoClient("mongodb://mongo:27017/")
        db=client.Sensor_Data_Collection
        result=db.DataCache.insert_one(index)
        print('Added record : {0}'.format(result.inserted_id))
        print(index)
    except Exception as e:
        print("Connect to mongodb error !")
        print(e)


    

def read_serial_data(serial_listen):
    #do somethings
    try:
        serial_listen.flushInput()
        while True:
            raw_message = serial_listen.readline()
            handle_message(raw_message)

            schedule.run_pending()


    except Exception as e:
        print("Read serial error !")
        print(e)

    finally:
        serial_listen.close()


def request_to_server_and_store_to_mongodb():
    try:
        #format lai data
        data_to_server = data
        data_to_server['EdgeName'] = EdgeName
        data_to_server['Time'] = datetime.datetime.now().strftime("%c")

        #Request to server
        res = requests.post(url, data = data_to_server, headers=header)
        print(res.status_code)

        #Store to mongodb
        store_to_mongodb(data_to_server)

    
    except Exception as e:
        print("Request to server error !")
        print(e)
    

# --------------------------------RUNNING CODE-------------------------------
print("starting....")
serial_listen = create_serial_obj()

schedule.every(5).seconds.do(request_to_server_and_store_to_mongodb)     #request every 5s

if serial_listen != -1:
    read_serial_data(serial_listen)

