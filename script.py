#!/usr/bin/env python3
print("starting....")

import serial
import pymongo

myclient = pymongo.MongoClient("mongodb://mongo:27017/test_db")

mydb = myclient["test_db"]
mycol = mydb["rev_data"]


# This is the default serial port
PORT = '/dev/ttyUSB0'

# You may need to further configure settings
# See the pyserial documentation for more info
# https://pythonhosted.org/pyserial/pyserial_api.html#classes
ser = serial.Serial(port=PORT,baudrate=115200,timeout=1)

try:
    while True:
        # Read raw data from the stream
        # Convert the binary string to a normal string
        # Remove the trailing newline character
        
        message = ser.readline().decode('utf8','ignore')
        print(message)
        print(str(message))

        if len(message) != 0:
            record = message.split('#')
            record = list(filter(None, record))
            print(record)

            db_record = {
            'flield_00' : record[0],
            'flield_01' : record[1],
            'Node_Name' : record[2],
            'flield_03' : record[3],
            'Sensor_01' : record[4],
            'Sensor_02' : record[5]
            }

finally:
    ser.close()

    
