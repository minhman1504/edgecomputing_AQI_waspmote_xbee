#!/usr/bin/env python3
print("starting....")

import asyncio
import serial

s = serial.Serial('COM4', 115200, Timeout=1)


def test_serial():
    '''
    read a line and print.
    '''
    text = ""
    msg = s.read().decode()
    while (msg != '\n'):
        text += msg
        msg = s.read().decode()
    print(text)
    loop.call_soon(s.write, "ok\n".encode())

loop = asyncio.get_event_loop()
loop.add_reader(s, test_serial)
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass
finally:
    loop.close()