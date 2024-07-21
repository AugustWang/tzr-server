SHELL := /bin/bash

.PHONY: all erlang_proto as3_proto server_map behavior_proto admin_proto

all: erlang_proto server_map  behavior_proto admin_proto ../hrl/all_pb.hrl
	

GAME_PROTO := $(wildcard ../proto/*.proto)

../hrl/all_pb.hrl:$(GAME_PROTO)
	@(php build_protobuf.php erlang)
	
../hrl/mm_define.hrl:../hrl/server_map.xml
	@(php build_mm_map.php)
	
../config/mm_map.config:../hrl/server_map.xml
	@(php build_mm_map.php)
	
../hrl/behavior/behavior_pb.hrl:../proto/behavior/behavior.proto
	@(php rebuild_behavior_proto.php)



erlang_proto: ../hrl/all_pb.hrl
	
as3_proto: $(GAME_PROTO)
	@(bash make_as3_proto.sh)
	
server_map: ../hrl/mm_define.hrl ../config/mm_map.config
	
behavior_proto: ../hrl/behavior/behavior_pb.hrl
