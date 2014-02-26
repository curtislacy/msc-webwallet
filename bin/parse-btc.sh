#!/bin/bash

echo "Spawned BTC Parsing Loop."

remove_lock() {
	rm -f $LOCK_FILE
}

# Ctrl-C trap. Catches INT signal
trap "remove_lock 1 $$; exit 0" EXIT

APPDIR=`pwd`
DATADIR="/var/lib/omniwallet/btc"
LOCK_FILE=$DATADIR/btc_cron.lock

TOOLSDIR=$APPDIR/lib/bitcoin-tools

mkdir -p $DATADIR

while true
do

	# check lock (not to run multiple times)
	if [ ! -f $LOCK_FILE ]; then

		# lock
		touch $LOCK_FILE

		cd $DATADIR
		mkdir -p tx addr general www

		# Actually doing the work here.

		# parse until full success
		x=1 # assume failure
		echo -n > $PARSE_LOG
		while [ "$x" != "0" ];
		do
			python $TOOLSDIR/btc_parse.py -r $TOOLSDIR 2>&1 >> $PARSE_LOG
  			x=$?
		done
		mkdir -p $DATADIR/www/tx $DATADIR/www/addr
	        cp $DATADIR/tx/* $DATADIR/www/tx
		cp $DATADIR/addr/* $DATADIR/www/addr

	
		# unlock
		rm -f $LOCK_FILE
	fi

	# Wait half a minute, and do it all again (Actually, we'll wait a little offset, so that our loops don't collide too often.
	sleep 29
done
