#!/bin/bash

# Adapted from https://stackoverflow.com/a/47436840

function lib_installed() { /sbin/ldconfig -N -v $(sed 's/:/ /' <<< $LD_LIBRARY_PATH) 2>/dev/null | grep $1; }
function check() { lib_installed $1 && echo "$1 is installed" || echo -e "\nERROR: $1 is NOT installed\n"; }
check libcuda.so
check libcudart
check libcudnn