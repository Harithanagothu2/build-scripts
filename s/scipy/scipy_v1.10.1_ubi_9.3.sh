#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package : scipy
# Version : v1.10.1
# Source repo : https://github.com/scipy/scipy
# Tested on : UBI 9.3
# Language : Python, C, Fortran, C++, Cython, Meson
# Travis-Check : True
# Script License: Apache License, Version 2 or later
# Maintainer : Sai Kiran Nukala <sai.kiran.nukala@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ========== platform using the mentioned version of the package.
# It may not work as expected with newer versions of the
# package and/or distribution. In such case, please
# contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

# Exit immediately if a command exits with a non-zero status
set -e
PACKAGE_NAME=scipy
PACKAGE_VERSION=${1:-v1.10.1}
PACKAGE_URL=https://github.com/scipy/scipy
 
echo "Installing core dependencies..."
# install core dependencies
yum install -y gcc gcc-c++ gcc-fortran pkg-config openblas-devel python python3-pip python3 python3-devel git atlas
echo "Core dependencies installed."
 
echo "Installing scipy dependencies and build-setup dependencies..."
# install scipy dependency (numpy wheel gets built and installed) and build-setup dependencies
pip install meson ninja 'numpy<1.23' 'setuptools<60.0' Cython==0.29.37 'meson-python<0.15.0,>=0.12.1' pybind11 'patchelf>=0.11.0' 'pythran<0.15.0,>=0.12.0' pooch pytest build
echo "Dependencies installed."
 
echo "Cloning source repository..."
# clone source repository
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION
git submodule update --init
echo "Source repository cloned and checked out to version $PACKAGE_VERSION."
 
echo "Building and installing $PACKAGE_NAME..."
# build and install
if ! pip install -e . --no-build-isolation; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail | Install_Fails"
    exit 1
fi
echo "Build and installation completed successfully."
 
echo "Running specific tests using pytest..."
# run specific tests using pytest
if ! (pytest scipy/interpolate/tests/test_polyint.py scipy/linalg/tests/test_basic.py); then
    echo "------------------$PACKAGE_NAME::Test_Fail-------------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | Fail | Test_Fail"
    exit 2
else
    echo "------------------$PACKAGE_NAME::Test_Pass---------------------"
    echo "$PACKAGE_VERSION $PACKAGE_NAME"
    echo "$PACKAGE_NAME | $PACKAGE_URL | $PACKAGE_VERSION | Pass | Test_Success"
    exit 0
fi