#!/bin/bash

# Get MacBook Serial Number
SERIAL_NUMBER=$(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')

# Check if serial number is obtained
if [ -z "$SERIAL_NUMBER" ]; then
    echo "Error: Unable to retrieve MacBook serial number."
    exit 1
fi

# API Endpoint
API_ENDPOINT="${SNIPEIT_URL}/api/v1/hardware?search=${SERIAL_NUMBER}"

# Make API request
RESPONSE=$(curl -s -X GET "${API_ENDPOINT}" \
    -H "Authorization: Bearer ${{ secrets.API_KEY }}" \
    -H "accept: application/json")

# Check if the request was successful
if [ "$(echo "${RESPONSE}" | jq -r '.total')" == "1" ] && [ "$(echo "${RESPONSE}" | jq -r '.rows[0].id')" != "null" ]; then
    # Display information
    ASSET_TAG=$(echo "${RESPONSE}" | jq -r '.rows[0].asset_tag')
    echo "Serial Number: ${SERIAL_NUMBER}"
    echo "Asset Tag: ${ASSET_TAG}"

    # Ask user if they want to rename the laptop
    read -p "Do you want to rename the laptop to 'cml-${ASSET_TAG}'? (y/n): " ANSWER

    if [ "$ANSWER" == "y" ]; then
        # Rename laptop
        sudo scutil --set ComputerName "cml-${ASSET_TAG}"
        sudo scutil --set LocalHostName "cml-${ASSET_TAG}"
        sudo scutil --set HostName "cml-${ASSET_TAG}"
        echo "Laptop has been renamed to 'cml-${ASSET_TAG}'."
    else
        echo "Laptop not renamed."
    fi
else
    echo "No information found for serial number: ${SERIAL_NUMBER}"
fi
