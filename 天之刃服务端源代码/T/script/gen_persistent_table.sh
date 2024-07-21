#!/bin/sh 

#set +x
## erl -env ERL_MAX_PORTS 10000 -s mcs_autochat help
erl -pa /data/tzr/server/ebin -pa /data/tzr/server/ebin/common -pa /data/tzr/server/ebin/common/mod  -eval 'mysql_persistent_util:generate_sql_create_table(),init:stop()'
echo 
echo
