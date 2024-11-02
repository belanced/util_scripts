#!/bin/bash

SCRIPT_DIR="$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )"
PROJ_DIR=$(dirname $SCRIPT_DIR)

parse_args() {
    CRT_VERSION="1.0.1"
    DEBUG=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --version|-v)
                VERSION="$2"
                shift 2
                ;;
            --debug|-d)
                DEBUG=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Validate required arguments
    if [[ -z "$VERSION" ]]; then
        echo "Error: VERSION is required"
        show_help
        exit 1
    fi
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  --version, -v VERSION   Specify the version (required)"
    echo "  --debug, -d             Enable debug mode"
    echo "  --help, -h              Show this help message"
}

# Call the function to parse arguments
parse_args "$@"

get_os_info() {
    if [ -f /etc/os-release ]; then
        # Source the os-release file
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERSION=$VERSION_ID
    elif [ -f /etc/lsb-release ]; then
        # Source the lsb-release file
        . /etc/lsb-release
        OS_NAME=$DISTRIB_ID
        OS_VERSION=$DISTRIB_RELEASE
    else
        echo "Unable to determine OS"
        exit 1
    fi
}

get_os_info

if [ "$OS_NAME" = "Ubuntu" ]; then
    case $OS_VERSION in
        20.04)
            echo "This is Ubuntu 20.04"
            sudo apt install -y \
                build-essential qmlscene qt5-qmake qt5-default qtdeclarative5-dev qml-module-qtquick-controls2 \
                qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage \
                qml-module-qtquick-window2 qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel qtquickcontrols2-5-dev
            sudo apt install -y qtquickcontrols2-5-dev qml-module-qt-labs-platform qml-module-qtquick-controls \
                qml-module-qtquick-layouts qml-module-qtquick-localstorage

            ;;
        22.04)
            echo "This is Ubuntu 22.04"
            sudo apt install -y build-essential qmlscene qt5-qmake qtbase5-dev qtdeclarative5-dev \
                qml-module-qtquick-controls2 qml-module-qtgraphicaleffects qml-module-qtquick-dialogs qml-module-qtquick-localstorage \
                qml-module-qtquick-window2 qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel qml-module-qt-labs-platform qtquickcontrols2-5-dev
            sudo apt install -y qtquickcontrols2-5-dev qml-module-qt-labs-platform qml-module-qtquick-controls \
                qml-module-qtquick-layouts qml-module-qtquick-localstorage
            ;;
        24.04)
            echo "This is Ubuntu 24.04"
            # Add your specific actions for Ubuntu 24.04 here
            ;;
        *)
            echo "$OS_NAME-$OS_VERSION is not supported!"
            exit -1
            ;;
    esac
else
    echo "$OS_NAME-$OS_VERSION is not supported!"
    exit -1
fi

SRC_DIR=$PROJ_DIR/src
echo "SRC_DIR: $SRC_DIR"
mkdir -p $SRC_DIR
git clone -b $CRT_VERSION --recursive https://github.com/Swordfish90/cool-retro-term.git $SRC_DIR/cool-retro-term
cd $SRC_DIR/cool-retro-term
qmake && make -j
sudo make install
rm -rf $SRC_DIR/cool-retro-term

# Refresh desktop icon cache
sudo gtk-update-icon-cache -f -t /usr/share/icons/*
sudo update-icon-caches /usr/share/icons/*
sudo update-desktop-database
sudo fc-cache -f -v