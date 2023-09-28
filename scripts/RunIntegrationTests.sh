#!/usr/bin/env sh

DEVICE_NAME="iPhone 15"
DEVICE_OS="latest"

# CALCULATE $SCRIPTDIR
AUX_SCRIPTDIR="${BASH_SOURCE[0]}"
while [ -h "$AUX_SCRIPTDIR" ]; do # resolve $AUX_SCRIPTDIR until the file is no longer a symlink
	SCRIPTDIR="$( cd -P "$( dirname "$AUX_SCRIPTDIR" )" && pwd )"
	AUX_SCRIPTDIR="$(readlink "$AUX_SCRIPTDIR")"
	[[ $AUX_SCRIPTDIR != /* ]] && AUX_SCRIPTDIR="$SCRIPTDIR/$AUX_SCRIPTDIR" # if $AUX_SCRIPTDIR was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPTDIR="$( cd -P "$( dirname "$AUX_SCRIPTDIR" )" && pwd )"

show_usage()
{
	ENABLE_UNDERLINE=`tput smul`
	DISABLE_UNDERLINE=`tput rmul`
	ENABLE_BOLD=`tput bold`
	DISABLE_BOLD=`tput sgr0`
	echo
	echo "usage: RunIntegrationTests.sh [options]"
	echo
	echo "   The options are as follows:"
	echo
	echo "      -d ${ENABLE_UNDERLINE}device_name${DISABLE_UNDERLINE}       The device model to use when running tests. Default value: $DEVICE_NAME"
	echo
	echo "      -o ${ENABLE_UNDERLINE}device_os${DISABLE_UNDERLINE}         The device OS to use when running tests. Default value: $DEVICE_OS"
	echo
	echo "      -h                  Help, shows usage."
	echo
}

# PARSE PARAMETERS
while getopts ":d:ho:" opt; do
	case $opt in
	d)
		DEVICE_NAME="$OPTARG"
		;;
    h)
        show_usage
        exit 0
        ;;
	o)
		DEVICE_OS="$OPTARG"
		;;
	:)
		echo "Option -$OPTARG requires an argument."
		show_usage
		exit 1
		;;
	esac
done

TEST_DESTINATION="platform=iOS Simulator,name=$DEVICE_NAME,OS=$DEVICE_OS"

echo "Running integration tests on $TEST_DESTINATION"

xcrun xcodebuild -quiet -project "$SCRIPTDIR/../Tests/IntegrationTests/UITestingSampleApp/UITestingSampleApp.xcodeproj" -scheme UITestingSampleApp clean test -testPlan UITestingSampleApp -destination "$TEST_DESTINATION"
