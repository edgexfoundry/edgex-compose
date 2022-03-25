#!/usr/bin/env bash

# /*******************************************************************************
#  * Copyright 2022 
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
#  * in compliance with the License. You may obtain a copy of the License at
#  *
#  * http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software distributed under the License
#  * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  * or implied. See the License for the specific language governing permissions and limitations under
#  * the License.
#  *
#  *******************************************************************************/

# generator.sh - provide a Terminal User Interface to make generation of different EdgeX Foundry
# services more comprehensible.
# Author: Shantanoo (Shan) Desai <shantanoo.desai@gmail.com>

# Map the available options in `make compose` either as standalone strings or array of strings

# Individual Compose Descriptions that may not fall into EdgeX-Foundry Architecture Components
# Or may be an initial "out-of-the-box" configuration

MAKE=/usr/bin/make

SELECTED_DEVSERVICES=()
SELECTED_APPSERVICES=()
SELECTED_BUS=()
SELECTED_OTHERS=()

## Additional Options
additionalOpts=(
    "mqtt-broker"
    "modbus-sim"
)

## General Options Description
declare -A additionalOptsDesc=(
    [modbus-sim]="Include ModBus Simulator"
    [mqtt-broker]="Include MQTT Broker"
)


## Available App Services in EdgeX-Foundry
appServices=(
    "asc-http"
    "asc-mqtt"
    "asc-sample"
    "as-llrp"
    "asc-ex-mqtt"
)

## App Service Descriptions
declare -A appServiceDesc=(
    [asc-http]="Include HTTP Export App Service"
    [asc-mqtt]="Include MQTT Export App Service"
    [asc-sample]="Include Sample App Service"
    [as-llrp]="Include RFID LLRP Inventory"
    [asc-ex-mqtt]="Include External MQTT Trigger App Service"
)


## Available Device Services in EdgeX-Foundry
deviceServices=(
    "ds-bacnet"
    "ds-camera"
    "ds-grove"
    "ds-modbus"
    "ds-mqtt"
    "ds-rest"
    "ds-snmp"
    "ds-virtual"
    "ds-coap"
    "ds-gpio"
    "ds-llrp"
)

## Device Service Descriptions
declare -A deviceServiceDesc=(
    [ds-bacnet]="Include BACnet Device Service"
    [ds-camera]="Include Camera Device Service"
    [ds-grove]="Include Grove Device Service (valid only: arm64)"
    [ds-modbus]="Include ModBus Device Service"
    [ds-mqtt]="Include MQTT Device Service"
    [ds-rest]="Include REST Device Service"
    [ds-snmp]="Include SNMP Device Service"
    [ds-virtual]="Include Virtual Device Service"
    [ds-coap]="Include CoAP Device Service"
    [ds-gpio]="Include GPIO Device Service"
    [ds-llrp]="Include RFID LLRP Device Service"

)


## Available Message Bus Services in EdgeX-Foundry
messageBus=(
    "mqtt-bus"
    "zmq-bus"
)


## Message Bus Descriptions
declare -A msgBusDesc=(
    [mqtt-bus]="Configure MQTT Message Bus"
    [zmq-bus]="Configure ZMQ Message Bus"
)


####################################################################
#    Additional Services Options Display Function                  #
####################################################################
function additionalServiceOption() {
    message="Some Additional Services are available that can also be included."

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    arglist=()
    for index in "${additionalOpts[@]}";
    do
        arglist+=("$index")
        arglist+=("${additionalOptsDesc[$index]}")
        arglist+=("OFF") # Nothing is selected by-default
    done
    SELECTED_OTHERS+=$(/usr/bin/whiptail --title "App Services" \
                --notags --separate-output \
                --nocancel \
                --checklist "$message" 20 75 5 \
                -- "${arglist[@]})" \
                3>&1 1>&2 2>&3)
}


####################################################################
#    App Services Options Display Function                         #
####################################################################
function appServiceOption() {
    message="Available App Services to include in your compose file."

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    arglist=()
    for index in "${appServices[@]}";
    do
        arglist+=("$index")
        arglist+=("${appServiceDesc[$index]}")
        arglist+=("OFF") # Nothing is selected by-default
    done
    SELECTED_APPSERVICES+=$(/usr/bin/whiptail --title "App Services" \
                --nocancel \
                --notags --separate-output \
                --checklist "$message" 20 75 7 \
                -- "${arglist[@]}" \
                3>&1 1>&2 2>&3)
}



####################################################################
#    ARM64 Question Display Function                               #
####################################################################
function displayArm64() {
    message="Would you like to use ARM64 Images to generate the Compose file?"

    /usr/bin/whiptail --title "Images Architecture" --yesno "$message" 8 78
}


####################################################################
#    No-Security Question Display Function                         #
####################################################################
function displayNoSecty() {
    message="Would you like to generate a non-secure configuration of the Compose file?"
    
    /usr/bin/whiptail --title "Non-Secure Configuration" --yesno "$message" 8 78
}


####################################################################
#    Device Services Options Display Function                      #
####################################################################
function devServiceOption() {
    message="Available Device Services to include in your compose file."

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    arglist=()
    for index in "${deviceServices[@]}";
    do
        arglist+=("$index")
        arglist+=("${deviceServiceDesc[$index]}")
        arglist+=("OFF") # Nothing is selected by-default
    done
    SELECTED_DEVSERVICES=$(/usr/bin/whiptail --title "Device Services" \
                --nocancel \
                --notags --separate-output \
                --checklist "$message" 20 75 13 \
                -- "${arglist[@]})" \
                3>&1 1>&2 2>&3)
}

####################################################################
#    Message Bus Options Display Function                          #
####################################################################
function msgBusOption() {
    message="Available Message Buses to replace the default one."

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    arglist=()
    for index in "${messageBus[@]}";
    do
        arglist+=("$index")
        arglist+=("${msgBusDesc[$index]}")
        arglist+=("OFF") # Nothing is selected by-default
    done
    SELECTED_BUS=$(/usr/bin/whiptail --title "App Services" \
                --nocancel \
                --notags --separate-output \
                --radiolist "$message" 20 75 4 \
                -- "${arglist[@]})" \
                3>&1 1>&2 2>&3)
}


## Step - 1: Start by Asking about whether Images should be pulled for ARM64?
displayArm64
if [[ $? == 0 ]]; then
    SELECTED_OTHERS+=("arm64 ")
fi

## Step - 2: Ask whether a non-secure Configuration is needed
displayNoSecty
if [[ $? == 0 ]]; then
    SELECTED_OTHERS+=("no-secty ")
fi  

## Step - 3: Add Device Services Option
devServiceOption

## Step - 4: App Services Option
appServiceOption

## Step - 5: Configure Message Bus
msgBusOption

## Step -6: Ask for Additional Options
additionalServiceOption

# echo "additional services selected: ${SELECTED_OTHERS}" ## DEBUG
# echo "device services selected: ${SELECTED_DEVSERVICES}" ## DEBUG
# echo "app services selected: ${SELECTED_APPSERVICES}" ## DEBUG
# echo "selected message bus: ${SELECTED_BUS}" ## DEBUG

echo "Generating necessary Compose file:....."
$MAKE compose $SELECTED_OTHERS $SELECTED_DEVSERVICES $SELECTED_APPSERVICES $SELECTED_BUS