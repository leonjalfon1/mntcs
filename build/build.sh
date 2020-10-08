#!/bin/bash

set -e

PACKAGE_VERSION="1.0"
PROJECT_DIRECTORY="mntcs-${PACKAGE_VERSION}"

# Clean workspace
rm -rf mntcs*

# Compile the script into a binary file
shc -f ../src/mntcs.sh -o ./mntcs

# Create the project directory
mkdir ${PROJECT_DIRECTORY}

# Copy files into the project directory
cp ./mntcs ./${PROJECT_DIRECTORY}/mntcs
cp ../src/mntcs.conf ./${PROJECT_DIRECTORY}/mntcs.conf
cp ../src/mntcs.service ./${PROJECT_DIRECTORY}/mntcs.service

# Generate Debian package files
cd ./${PROJECT_DIRECTORY}
DEBEMAIL="leonjalfon1@gmail.com"
DEBFULLNAME="Leon Jalfon"
export DEBEMAIL DEBFULLNAME
dh_make --indep --createorig --copyright apache -y 

# Configure the install file
echo mntcs bin >> debian/install
echo mntcs.conf etc/mntcs >> debian/install
echo mntcs.service lib/systemd/system >> debian/install

# Build the package using debuild
debuild -us -uc

# Return to the origin path
cd ..