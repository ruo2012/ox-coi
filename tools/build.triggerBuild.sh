#!/usr/bin/env bash

# System flags
set -e

# User / CI input
platforms=$1
mode=$2
flavor=$3
buildName=$4
buildNumber=$5

# Constants
PLUGIN_FOLDER="flutter-deltachat-core";
CORE_BUILD_SCRIPT="./build-dcc.sh"

# Functions
function isAndroid {
    if [[ ${platforms} == "android" || ${platforms} == "all" ]]; then
        true
    else
        false
    fi
}

function isIos {
    if [[ ${platforms} == "ios" || ${platforms} == "all" ]]; then
        true
    else
        false
    fi
}

function isRelease {
    if [[ ${mode} == "release" ]]; then
        true
    else
        false
    fi
}
#flutter build apk --build-name=${BUILD_NAME} --build-number=${CI_PIPELINE_ID} --flavor development --debug
function androidDebugBuild {
    echo "Android debug build started"
    flutter build apk --build-name=${buildName} --build-number=${buildNumber} --flavor ${flavor} --debug
}

function androidReleaseBuild {
    echo "Android release build started"
    flutter build apk --build-name=${buildName} --build-number=${buildNumber} --flavor ${flavor} --split-per-abi
}

function iosDebugBuild {
    echo "iOS debug build started"
    echo "TODO: iOS debug build is missing"
}

function iosReleaseBuild {
    echo "iOS release build started"
    echo "TODO: iOS release build is missing"
}

function getCore {
    if [[ -d "$PLUGIN_FOLDER" ]]; then
        cd ${PLUGIN_FOLDER}
        git pull
        git submodule update
    else
        git clone --recurse-submodules https://github.com/open-xchange/flutter-deltachat-core.git
    fi
}

function buildCore {
    if [[ -f "$CORE_BUILD_SCRIPT" ]]; then
        if isAndroid; then
            ${CORE_BUILD_SCRIPT} android | sed 's/^/    /'
        elif isIos; then
            ${CORE_BUILD_SCRIPT} ios | sed 's/^/    /'
        fi
     else
        exit 2
     fi
}

# Execution
echo "-- Setup --"
cd .. || error 1
echo "Building / updating core"
(
    cd .. || error 3
    getCore
    buildCore
)
echo "-- Building --"
if isAndroid; then
    if isRelease; then
        androidReleaseBuild
    else
        androidDebugBuild
    fi
elif isIos; then
    if isRelease; then
        iosReleaseBuild
    else
        iosDebugBuild
    fi
fi
echo "-- Finishing --"
