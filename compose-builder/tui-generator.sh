#!/usr/bin/env bash

# /*******************************************************************************
#  * Copyright 2022 Shantanoo Desai <shantanoo.desai@gmail.com>
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

# Check if whiptail exists to render the UI, if not, exit script
WHIPTAIL=$(which whiptail)

if [ -z $WHIPTAIL ]
then
    echo "This script requires whiptail to render the UI."
    exit 1;
fi

MAKE=$(which make)

SELECTED_DEVSERVICES=()
SELECTED_APPSERVICES=()
SELECTED_BUS=()
LINES=$(tput lines)
COLUMNS=$(tput cols)

## General Options Description
declare -A additionalOptsDesc=(
    [modbus-sim]="Include ModBus Simulator"
    [mqtt-broker]="Include MQTT Broker"
    [mqtt-verbose]="Enable MQTT Broker verbose logging"
)

## App Service Descriptions
declare -A appServiceDesc=(
    [asc-http]="Include HTTP Export App Service"
    [asc-mqtt]="Include MQTT Export App Service"
    [asc-metrics]="Include Metrics to InfluxDB App Service"
    [asc-sample]="Include Sample App Service"
    [as-llrp]="Include RFID LLRP Inventory App Service"
    [as-record-replay]="Include Record & Replay App Service"
    [asc-ex-mqtt]="Include External MQTT Trigger App Service"
)

## Device Service Descriptions
declare -A deviceServiceDesc=(
    [ds-bacnet-ip]="Include BACnet-IP Device Service"
    [ds-bacnet-mstp]="Include BACnet-MSTP Device Service"
    [ds-onvif-camera]="Include ONVIF Camera Device Service"
    [ds-usb-camera]="Include USB Camera Device Service"
    [ds-modbus]="Include ModBus Device Service"
    [ds-mqtt]="Include MQTT Device Service"
    [ds-rest]="Include REST Device Service"
    [ds-snmp]="Include SNMP Device Service"
    [ds-virtual]="Include Virtual Device Service"
    [ds-coap]="Include CoAP Device Service"
    [ds-gpio]="Include GPIO Device Service"
    [ds-uart]="Include UART Device Service"
    [ds-llrp]="Include RFID LLRP Device Service"
    [ds-s7]="Include S7 Device Service"
)

## Message Bus Descriptions
declare -A msgBusDesc=(
    [mqtt-bus]="Configure MQTT Message Bus"
    [nats-bus]="Configure NATS Message Bus"
)


####################################################################
#    Additional Services Options Display Function                  #
####################################################################
function additionalServiceOption() {
    local message="Some Additional Services are available that can also be included. \n
            Press <SPACEBAR> to Select \n
            Press <ENTER> to Skip
            "

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    local arglist=()
    for index in "${!additionalOptsDesc[@]}";
    do
        arglist+=("$index" "${additionalOptsDesc[$index]}" "OFF") # Nothing is selected by-default
    done
    readarray -t SELECTED_OTHERS < <("$WHIPTAIL" --title "Additional Services" \
                --notags --separate-output \
                --ok-button Next \
                --nocancel \
                --checklist "$message" $LINES $COLUMNS $(( LINES - 12 )) \
                -- "${arglist[@]}" \
                3>&1 1>&2 2>&3)
}


####################################################################
#    App Services Options Display Function                         #
####################################################################
function appServiceOption() {
    local message="Available App Services to include in your compose file. \n
            Press <SPACEBAR> to Select \n
            Press <ENTER> to Skip
            "

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    local arglist=()
    for index in "${!appServiceDesc[@]}";
    do
        arglist+=("$index" "${appServiceDesc[$index]}" "OFF") # Nothing is selected by-default
    done
    readarray -t SELECTED_APPSERVICES < <("$WHIPTAIL" --title "App Services" \
                --ok-button Next \
                --nocancel \
                --notags --separate-output \
                --checklist "$message" $LINES $COLUMNS $(( LINES - 12 )) \
                -- "${arglist[@]}" \
                3>&1 1>&2 2>&3)
}



####################################################################
#    ARM64 Question Display Function                               #
####################################################################
function displayArm64() {
    local message="Would you like to use ARM64 Images to generate the Compose file?"
    $WHIPTAIL --title "Images Architecture" --yesno --defaultno "$message" $LINES $COLUMNS
}


####################################################################
#    No-Security Question Display Function                         #
####################################################################
function displayNoSecty() {
    local message="Select a Security Configuration for EdgeX"
    $WHIPTAIL --title "Security Configuration for EdgeX" \
            --yes-button "Secure" \
            --no-button "Non-Secure" \
            --yesno "$message" $LINES $COLUMNS
}


####################################################################
#    Device Services Options Display Function                      #
####################################################################
function devServiceOption() {
    local message="Available Device Services to include in your compose file.\n
            Press <SPACEBAR> to Select \n
            Press <ENTER> to Skip
            "

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    local arglist=()
    for index in "${!deviceServiceDesc[@]}";
    do
        arglist+=("$index" "${deviceServiceDesc[$index]}" "OFF") # Nothing is selected by-default
    done
    readarray -t SELECTED_DEVSERVICES < <("$WHIPTAIL" --title "Device Services" \
                --ok-button Next \
                --nocancel \
                --notags --separate-output \
                --checklist "$message" $LINES $COLUMNS $(( LINES - 12 )) \
                -- "${arglist[@]}" \
                3>&1 1>&2 2>&3)
}

####################################################################
#    Message Bus Options Display Function                          #
####################################################################
function msgBusOption() {
    local message="Alternative Message Buses to replace the default one.\n
            Press <SPACEBAR> to Select \n
            Press <ENTER> to Skip
            "

    # Generate a Specific form of Array required by whiptail checklist
    # FORMAT: "<INDEX> <DESCRIPTION> <OFF>"
    local arglist=()
    for index in "${!msgBusDesc[@]}";
    do
        arglist+=("$index" "${msgBusDesc[$index]}" "OFF") # Nothing is selected by-default
    done
    readarray -t SELECTED_BUS < <("$WHIPTAIL" --title "Message Bus Alternatives" \
                --ok-button Next \
                --nocancel \
                --notags --separate-output \
                --radiolist "$message" $LINES $COLUMNS $(( LINES - 12 )) \
                -- "${arglist[@]}" \
                3>&1 1>&2 2>&3)
}

####################################################################
#    Generate / Generate & Run Option Display Function             #
####################################################################
function finalStep() {
    local message="What would you like to do?"
    $WHIPTAIL --title "Generate / Run EdgeX" \
        --yes-button "Generate File" \
        --no-button "Generate File and Run" \
         --yesno "$message" $LINES $COLUMNS
}

## Step - 1: Start by Asking about whether Images should be pulled for ARM64?
ARM64_OPT=""
if displayArm64; then
    ARM64_OPT="arm64"
fi

## Step - 2: Ask for Security Configuration is needed
## DEFAULT: always secure, only if user selects Non-Secure in TUI, should `no-secty` be set
SECURITY_OPT=""
if ! displayNoSecty; then
    SECURITY_OPT="no-secty"
fi  

## Step - 3: Add Device Services Option
devServiceOption

## Step - 4: App Services Option
appServiceOption

## Step - 5: Configure Message Bus
msgBusOption

## Step -6: Ask for Additional Options
additionalServiceOption

if finalStep; then
    echo "Generating Compose file..."
    $MAKE gen ${ARM64_OPT} ${SECURITY_OPT} ${SELECTED_OTHERS[@]} ${SELECTED_DEVSERVICES[@]} ${SELECTED_APPSERVICES[@]} ${SELECTED_BUS[@]}
else
    echo "Generating Compose file and Running the Stack....\n"
    $MAKE run  ${ARM64_OPT} ${SECURITY_OPT} ${SELECTED_OTHERS[@]} ${SELECTED_DEVSERVICES[@]} ${SELECTED_APPSERVICES[@]} ${SELECTED_BUS[@]}
fi
