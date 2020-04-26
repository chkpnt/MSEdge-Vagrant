#!/bin/bash

echo 'Trying to get the download-url for the Vagrant box of "Windows 10 with Legacy Microsoft Edge and Internet Explorer 11"'

apiEndpoint="https://developer.microsoft.com/en-us/microsoft-edge/api/tools/vms/"
url=$(curl -fsSL $apiEndpoint | jq -r '.[].software[] | select(.name == "Vagrant") | .files[].url')

if [ -z $url ]; then
    echo "... failed"
    exit 1
fi

echo ""
echo "Downloading box from $url:"
mkdir -p box
curl -C - -o box/MSEdge.Win10.Vagrant.zip -L $url

echo ""
echo "Extracting box:"
unzip box/MSEdge.Win10.Vagrant.zip -d box

echo ""
echo 'Importing box into Vagrant as "MSEdge":'
boxfiles=(box/*.box)
if [ ! -f "${boxfiles[0]}" ]; then
    echo "... failed. There is no box."
    exit 2
fi
vagrant box add --name MSEdge --force "${boxfiles[0]}"

if [ ! -f "config.ps1" ]; then
    echo "Preparing config.ps1, as it did not exist yet."
    cp "config.dist.ps1" "config.ps1"
fi