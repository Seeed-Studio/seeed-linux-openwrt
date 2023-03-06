#!/bin/bash

# This script is used to build the OpenWrt firmware.

# help function
help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --help, -h"
    echo "  --version, -v"
    echo "  --package, -p"
}

# if no parameters are specified, print help
if [ $# -eq 0 ]; then
    help
    exit 0
fi

# Parse the command line parameters
while [ ! -z "$1" ]; do
    case $1 in
    -h | --help)
        help
        ;;
    -v | --version)
        echo $(cat .version)
        ;;
    esac
    shift
done