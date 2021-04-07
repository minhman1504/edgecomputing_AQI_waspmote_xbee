#!/usr/bin/env python3
print("starting....")

import serial
import datetime
from pymongo import MongoClient

#connect mongodb
client = MongoClient("mongodb+srv://minhman1504:minhman1504@cluster0.vyij7.mongodb.net/")
#client = MongoClient("mongodb://mongo:27017/")
db=client.Sensor_Data_Collection

# This is the default serial port
PORT = '/dev/ttyUSB0'
#PORT = 'COM4'

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
        record = message.split('#')
        record = list(filter(None, record))
        
        if len(record) != 0:
            
            
            raw_frame_data = {
                '4_Bytes_Header' : record[0],
                '10_Bytes_SerialID' : record[1],
                'WaspmoteID' : record[2],
                'FrameSequence' : record[3],
                'Sensor_01' : record[4],
                'Sensor_02' : record[5],
                'Sensor_03' : record[6]
            }
            print(raw_frame_data)
            
            db_index = {
                'NameDevice': raw_frame_data["WaspmoteID"],
                'SerialID': raw_frame_data["10_Bytes_SerialID"],
                'Data':{
                    'FrameSequence': raw_frame_data["FrameSequence"],
                    'Sensor_01': raw_frame_data["Sensor_01"],
                    'Sensor_02': raw_frame_data["Sensor_02"],
                    'Sensor_03': raw_frame_data["Sensor_03"]
                },
                'datetime': datetime.datetime.now().strftime("%c")
            }
            print(db_index)
            
            result=db[db_index["NameDevice"]].insert_one(db_index)
            print('Added record : {0}'.format(result.inserted_id))

finally:
    ser.close()
    