#!/bin/bash
# BASED ON:
#	    https://github.com/brezlord/iDRAC7_fan_control
# 		A simple script to control fan speeds on Dell generation 12 PowerEdge servers. 
#		If the CPU temperature is above 75deg C enable iDRAC dynamic control and exit program.
# 		If CPU temp is below 75deg C set fan control to manual and set fan speed to predetermined value.

# modified by kanadork using poweredge R320 :)

# Variables
IDRAC_IP="192.168.0.160" #commands are running locally 
IDRAC_USER=" " #not used
IDRAC_PASSWORD=" " #not used
# Fan speed in %
SPEED0="0x00"
SPEED5="0x05"
SPEED7="0x07"
SPEED10="0x0a"
SPEED15="0x0f"
SPEED20="0x14"
SPEED25="0x19"
SPEED30="0x1e"
SPEED35="0x23"
SPEED50="0x32" #additional speed levels 50-80 for reference 
SPEED70="0x46"
SPEED80="0x50"
TEMP_THRESHOLD="75" # iDRAC dynamic control enable thershold
#TEMP_SENSOR="04h"   # Inlet Temp
#TEMP_SENSOR="01h"  # Exhaust Temp (unavailable)
TEMP_SENSOR="0Eh"  # CPU 1 Temp
#TEMP_SENSOR="0Fh"  # CPU 2 Temp (unavailable)

#open the loop for running as service
while true
do

# Get system date & time.
DATE=$(date +%d-%m-%Y\ %H:%M:%S)
echo "Date $DATE"

# Get temperature from iDARC.
T=$(ipmitool  sdr type temperature | grep $TEMP_SENSOR | cut -d"|" -f5 | cut -d" " -f2)
#echo "--> iDRAC IP Address: $IDRAC_IP"
echo "--> Current CPU Temp in degC: $T" #added unit

# If ambient temperature is above 75deg C enable dynamic control and exit, if below set manual control.
if [[ $T -ge $TEMP_THRESHOLD ]]
then
  echo "--> Temperature is above 75 deg C"
  echo "--> Enabled dynamic fan control"
  ipmitool raw 0x30 0x30 0x01 0x01
  exit 1
else
  echo "--> Temperature is below 75 deg C"
  echo "--> Disabled dynamic fan control"
  ipmitool raw 0x30 0x30 0x01 0x00
fi

# Set fan speed dependant on ambient temperature if CPU temperaturte is below 35deg C.
# If CPU temperature between 0 and 40deg C then set fans to 5%.
if [ "$T" -ge 0 ] && [ "$T" -le 41 ]
then
  echo "--> Setting fan speed to 5%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED5

elif [ "$T" -ge 42 ] && [ "$T" -le 44 ]
then
  echo "--> Setting fan speed to 7%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED7

elif [ "$T" -ge 45 ] && [ "$T" -le 49 ]
then
  echo "--> Setting fan speed to 10%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED10

elif [ "$T" -ge 50 ] && [ "$T" -le 54 ]
then
  echo "--> Setting fan speed to 15%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED15

elif [ "$T" -ge 55 ] && [ "$T" -le 59 ]
then
  echo "--> Setting fan speed to 20%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED20
  
elif [ "$T" -ge 60 ] && [ "$T" -le 65 ]
then
  echo "--> Setting fan speed to 25%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED25
  
elif [ "$T" -ge 66 ] && [ "$T" -le 69 ]
 then
  echo "--> Setting fan speed to 30%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED30
  
elif [ "$T" -ge 70 ] && [ "$T" -le 75 ]
 then
  echo "--> Setting fan speed to 35%"
  ipmitool raw 0x30 0x30 0x02 0xff $SPEED35  

#elif [ "$T" -ge 66 ] && [ "$T" -le 69 ]
# then
#  echo "--> Setting fan speed to 50%"
#  ipmitool raw 0x30 0x30 0x02 0xff $SPEED50 
  
fi

#close the loop
 sleep 10
 
done
