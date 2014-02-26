#!/bin/bash

echo "Spawned MSC Parsing Loop!"

remove_lock() {
	rm -f $LOCK_FILE
}

# Ctrl-C trap. Catches INT signal
trap "remove_lock 1 $$; exit 0" EXIT

APPDIR=`pwd`
TOOLSDIR=$APPDIR/node_modules/mastercoin-tools
DATADIR="/var/lib/omniwallet/msc"
LOCK_FILE=$DATADIR/msc_cron.lock
PARSE_LOG=$DATADIR/parsed.log
VALIDATE_LOG=$DATADIR/validated.log
ARCHIVE_LOG=$DATADIR/archived.log

if [ ! -d $DATADIR/tx ]; then
	cp -r $TOOLSDIR/www/tx-bootstrap $DATADIR/tx
fi

while true
do

	# check lock (not to run multiple times)
	if [ ! -f $LOCK_FILE ]; then

		# lock
		touch $LOCK_FILE

		mkdir -p $DATADIR
		cd $DATADIR
		mkdir -p tmptx tx addr general offers mastercoin_verify/addresses mastercoin_verify/transactions www

		# parse until full success
		x=1 # assume failure
		echo -n > $PARSE_LOG
		while [ "$x" != "0" ];
		do
			python $TOOLSDIR/msc_parse.py -r $TOOLSDIR 2>&1 >> $PARSE_LOG
  			x=$?
		done

		python $TOOLSDIR/msc_validate.py 2>&1 > $VALIDATE_LOG
	
		# update archive
		python $TOOLSDIR/msc_archive.py -r $TOOLSDIR 2>&1 > $ARCHIVE_LOG
	
		mkdir -p $DATADIR/www/tx $DATADIR/www/addr $DATADIR/www/general $DATADIR/www/offers $DATADIR/www/mastercoin_verify/addresses $DATADIR/www/mastercoin_verify/transactions

	        cp $DATADIR/tx/* $DATADIR/www/tx
		cp $DATADIR/addr/* $DATADIR/www/addr
		cp $DATADIR/general/* $DATADIR/www/general
		cp $DATADIR/offers/* $DATADIR/www/offers
		cp $DATADIR/mastercoin_verify/addresses/* $DATADIR/www/mastercoin_verify/addresses
		cp $DATADIR/mastercoin_verify/transactions/* $DATADIR/www/mastercoin_verify/transactions
	
		# unlock
		rm -f $LOCK_FILE
	fi

	# Wait a minute, and do it all again.  Actually, we'll wait a little offset, so that our loops don't collide too often.
	sleep 61
done
