#!/bin/bash

kill_child_processes() {
	echo "KILLING $SERVER_PID"
	kill $SERVER_PID
	echo "KILLING $MSC_LOOP_PID"
	kill $MSC_LOOP_PID
	echo "KILLING $BTC_LOOP_PID"
	kill $BTC_LOOP_PID
}

# Ctrl-C trap. Catches INT signal
trap "kill_child_processes 1 $$; exit 0" INT

APPDIR=`pwd`
TOOLSDIR=$APPDIR/node_modules/mastercoin-tools
DATADIR="/var/lib/omniwallet"

mkdir -p $DATADIR/wallets

# Mastercoin Parsing Loop
$APPDIR/bin/parse-msc.sh &
MSC_LOOP_PID=$!
echo "MSC Parse Loop PID: $MSC_LOOP_PID"

# Bitcoin Parsing Loop
$APPDIR/bin/parse-btc.sh &
BTC_LOOP_PID=$!
echo "MSC Parse Loop PID: $BTC_LOOP_PID"

# Export directories for API scripts to use
export TOOLSDIR
export DATADIR
cd $APPDIR/api
uwsgi -s 127.0.0.1:1088 -M --vhost --enable-threads --plugin python --logto $DATADIR/apps.log &
SERVER_PID=$!

while true
do
	# Sleep a really long time each loop - this is really just to keep the process from exiting.
	# and so that we know we have something to kill with ctrl-c to brinf everything else down.
	sleep 3600
done

