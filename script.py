#!/usr/bin/env python3
import parameters
import serial
import datetime

#----------------------PARAMATERS--------------------------------------
portPath = parameters.SERIAL_PORT_URL
baubrate = parameters.BAUDRATE
timeout = parameters.TIMEOUT
EdgeName = parameters.EDGE_NAME + "." + parameters.EDGE_ID




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
    record = mess.split('#')
    record = list(filter(None, record))
    if len(record) != 0:   
        DeviceID = record[2]
        DeviceType = record[4].replace('STR:', '')
        TypesOfData = record[5].replace('STR:', '').split('?')

        framedata = {}

        framedata['DeviceName'] = EdgeName + '_' + DeviceType + '_' + DeviceID

        data = []
        k=6
        for i in TypesOfData:
            obj = {}
            obj[i] = record[k]
            k = k + 1
            data.append(obj)

        framedata['Data'] = data

        framedata['Time'] = datetime.datetime.now().strftime("%c")

        return framedata

    else:
        return -1

#store to file .csv or send to database
def store_index(index):
    ## temp to print data to console
    print(index)


    

def read_serial_data(serial_listen):
    #do somethings
    try:
        serial_listen.flushInput()
        while True:
            raw_message = serial_listen.readline()
            index = handle_message(raw_message)
            if index != -1:
                store_index(index)

    except Exception as e:
        print("Read serial error !")
        print(e)

    finally:
        serial_listen.close()



# --------------------------------RUNNING CODE-------------------------------
print("starting....")
serial_listen = create_serial_obj()

if serial_listen != -1:
    read_serial_data(serial_listen)

