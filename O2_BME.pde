
#include <WaspSensorCities_PRO.h>
#include <WaspXBee900HP.h>
#include <WaspFrame.h>
 
// SETUP FOR COMMUNUNICATION
// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A20040A63E21";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";

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
//float dustdensity; //Store the dust density


/*
//--------------------------------------------------------------------------------------------------
//dust sensor connect to socket5 in board "SmartCitys_PRO"
//using ANALOG5 to read data from sensor
void Dust_init(){
  pinMode(ANALOG5, INPUT);
}

void Dust_on(){
  PWR.setSensorPower(SENS_3V3, SENS_ON);
  delay(100);
}

float Get_DustDensiy(){
  int vMeasured = analogRead(ANALOG5);
  float calcVoltage = vMeasured*(5.0/1024);
  return 0.17*calcVoltage-0.1;
}

void Dust_off(){
  PWR.setSensorPower(SENS_3V3, SENS_OFF);
  delay(100);
}
*/
//--------------------------------------------------------------------------------------------------


void setup()
{
  USB.ON();

  //Dust_init();
  
  USB.println(F("Starting ...."));
  
  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee
  xbee900HP.ON();

  pinMode(ANALOG5, INPUT);
  PWR.setSensorPower(SENS_3V3, SENS_ON);
}




void loop()
{

  ///////////////////////////////////////////
  // 1. Read Temperature, humidity and pressure sensor (BME)
  ///////////////////////////////////////////
  
  // switch off gas sensor for better performance
  gas_sensor.OFF();
  //Dust_off();
  
  
  // switch on BME sensor (temperature, humidity and pressure)
  bme.ON();
  //Dust_on();

  
  // Read enviromental variables
  temperature = bme.getTemperature();
  humidity = bme.getHumidity();
  pressure = bme.getPressure();
  int testpin = analogRead(ANALOG5);
  
  
  // switch off BME sensor (temperature, humidity and pressure)
  bme.OFF();
  //Dust_off();
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


  // Setup Frame data
  frame.createFrame(ASCII);  


  //add frame fields
  frame.addSensor(SENSOR_STR, "nhan duoc rôi nhe ....");
  frame.addSensor(SENSOR_O2, concentration);
  frame.addSensor(SENSOR_TCB, temperature);
  frame.addSensor(SENSOR_HUMB, humidity);
  frame.addSensor(SENSOR_PA, pressure);
  frame.addSensor(SENSOR_DUST, (float)testpin);

  //show frame
  frame.showFrame();


  /*
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
`*/

  delay(2000);
}


