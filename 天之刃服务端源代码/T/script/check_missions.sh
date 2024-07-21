#!/bin/sh 

#set +x
## erl -env ERL_MAX_PORTS 10000 -s mcs_autochat help
erl -pa /data/tzr/server/ebin -pa /data/tzr/server/ebin/common -pa /data/tzr/server/ebin/map \
    -pa /data/tzr/server/ebin/map/mod -eval 'mod_mission_check:check(),init:stop()'
echo 
echo
