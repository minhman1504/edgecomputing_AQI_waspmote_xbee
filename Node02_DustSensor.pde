#include "Plantower_PMS7003.h"
#include <WaspXBee900HP.h>
#include <WaspFrame.h>


// SETUP FOR COMMUNUNICATION
// Destination MAC address
//////////////////////////////////////////
char RX_ADDRESS[] = "0013A200416A5F5A";
//////////////////////////////////////////

// Define the Waspmote ID
char WASPMOTE_ID[] = "Node2_DustSensor";
char TypesOfData[] = "PM_1_0?PM_2_5?PM_10_0";

// define variable
uint8_t error;

//dustsensor
Plantower_PMS7003 pms7003 = Plantower_PMS7003();

//variables
uint16_t PM_1_0;
uint16_t PM_2_5;
uint16_t PM_10_0;

//function to loop read serial return when have a new data
void getsensordata_dustsensor(){
  while(true)
  {
      pms7003.updateFrame();

      if (pms7003.hasNewData()) {
        PM_1_0 = pms7003.getPM_1_0();
        PM_2_5 = pms7003.getPM_2_5();
        PM_10_0 = pms7003.getPM_10_0();

        break;
      }
  }
}



void setup()
{
  USB.ON();
  USB.println(F("Starting ...."));
  PWR.setSensorPower(SENS_5V,SENS_ON); //my sensor need this voltatge                                                                          

  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );

  
  // init XBee
  xbee900HP.ON();

  //init dustsensor
  pms7003.init();

  //delay for stating
  delay(1000);

}

void loop()
{
//phase 1: get data
  getsensordata_dustsensor();

//phase 2: send data

  // Setup Frame data
  frame.createFrame(ASCII);  


  //add frame fields
  frame.addSensor(SENSOR_STR, TypesOfData);
  frame.addSensor(SENSOR_STR, PM_1_0);
  frame.addSensor(SENSOR_STR, PM_2_5);
  frame.addSensor(SENSOR_STR, PM_10_0);

    //show frame
  frame.showFrame();
  // send frame
  error = xbee900HP.send( RX_ADDRESS, frame.buffer, frame.length );   


//phase 3: check data
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
  }
  else 
  {
    USB.println(F("send error"));
  }
  USB.println(error);


  delay(1000);
}



