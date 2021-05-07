
#include <WaspSensorCities_PRO.h>
#include <WaspXBee900HP.h>
#include <WaspFrame.h>
 
// SETUP FOR COMMUNUNICATION
// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A200416A5F5A";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "Node1_SmartCity";
char TypesOfData[] = "O2?temp?hum?pre";

// define variable
uint8_t error;


/*
   Define object for sensor: gas_sensor
   Input to choose board socket.
   Waspmote OEM. Possibilities for this sensor:
    - SOCKET_1
    - SOCKET_3
    - SOCKET_5
   P&S! Possibilities for this sensor:
    - SOCKET_B
    - SOCKET_C
    - SOCKET_F
*/
Gas gas_sensor(SOCKET_1);

/*
   Waspmote OEM. Possibilities for this sensor:
    - SOCKET_1
    - SOCKET_2
    - SOCKET_3
    - SOCKET_4
    - SOCKET_5
   P&S! Possibilities for this sensor:
    - SOCKET_A
    - SOCKET_B
    - SOCKET_F
    - SOCKET_C
    - SOCKET_E
*/
bmeCitiesSensor bme(SOCKET_2);


// variables
float concentration;  // Stores the concentration level in ppm
float temperature;  // Stores the temperature in ºC
float humidity;   // Stores the realitve humidity in %RH
float pressure;   // Stores the pressure in Pa


void setup()
{
  USB.ON();
  USB.println(F("Starting ...."));
  
  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );

  // init XBee
  xbee900HP.ON();
}


void loop()
{

  ///////////////////////////////////////////
  // 1. Read Temperature, humidity and pressure sensor (BME)
  ///////////////////////////////////////////
  
  // switch off gas sensor for better performance
  gas_sensor.OFF();
  // switch on BME sensor (temperature, humidity and pressure)
  bme.ON();
  
  // Read enviromental variables
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();
 
  // switch off BME sensor (temperature, humidity and pressure)
  bme.OFF();
  // switch on gas sensor again
  gas_sensor.ON();


  ///////////////////////////////////////////
  // 2. Read gas sensor
  ///////////////////////////////////////////

  // Wait heating time
  // some sensors demand at least one minute 
  // of heating time after switching them on

  
  // Read the electrochemical sensor and compensate with the temperature internally
  concentration = gas_sensor.getConc(temperature);

  // And print the values via USB
  USB.println(F("***************************************"));
  USB.print(F("Gas concentration: "));
  USB.printFloat(concentration, 3);
  USB.println(F(" ppm"));
  USB.print(F("Temperature: "));
  USB.printFloat(temperature, 3);
  USB.println(F(" Celsius degrees"));
  USB.print(F("RH: "));
  USB.printFloat(humidity, 3);
  USB.println(F(" %"));
  USB.print(F("Pressure: "));
  USB.printFloat(pressure, 3);
  USB.println(F(" Pa"));
  USB.println(F("***************************************"));

  // Setup Frame data
  frame.createFrame(ASCII);  


  //add frame fields
  frame.addSensor(SENSOR_STR, TypesOfData);
  frame.addSensor(SENSOR_STR, concentration);
  frame.addSensor(SENSOR_STR, temperature);
  frame.addSensor(SENSOR_STR, humidity);
  frame.addSensor(SENSOR_STR, pressure);
  

  //show frame
  frame.showFrame();
  
  // send frame
  error = xbee900HP.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
  }
  else 
  {
    USB.println(F("send error"));
  }


  delay(2000);
}


