#!/bin/bash

ulimit -SHn 51200
ARGS=$@
COMMAND=`php /data/tzr/server/script/host_info.php start_gateway_distribution mgeeg $ARGS; exit $?`
if [ $? -eq 0 ] ; then
	bash -c "$COMMAND"
else
	echo $COMMAND;
	exit
fi

	