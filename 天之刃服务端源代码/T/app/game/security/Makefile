####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-05-30
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################
SHELL := /bin/bash
.PHONY: all dialyzer clean
PLT="../../../.dialyzer_plt"
	  
ERL := erl
ERLC := $(ERL)c
EMULATOR := beam

##指定当前项目在svn仓库中的名字
APP_NAME := security
INCLUDE_DIRS := include
EBIN_DIR := /data/tzr/server/ebin/$(APP_NAME)
##指定编译时查找common.doc/trunk/hrl中的文件
ERLC_FLAGS := -W -I $(INCLUDE_DIRS) -I ../../../hrl $(EBIN_DIRS:%=-pa %)
##这里可以通过 make DEBUG=true来达到打开debug_info选项的目的
ifdef DEBUG
  ERLC_FLAGS += +debug_info
endif
##所有的erl源码文件
ERL_SOURCES := $(wildcard src/*.erl) $(wildcard src/mod/*.erl)
##替换src为ebin
ERL_SOURCES2 := $(subst src,$(EBIN_DIR),$(ERL_SOURCES))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))
##app配置文件
APP_FILES := $(wildcard $(SERVER_ROOT)/$(APP_NAME)/config/*.app)
##输出文件
EBIN_FILES = $(ERL_OBJECTS) $(APP_FILES)

##使用通配符方式指定每个文件的编译规则
$(EBIN_DIR)/%.$(EMULATOR): $(hrl) src/%.erl 
	$(ERLC) $(ERLC_FLAGS) -o $(subst src,$(EBIN_DIR),$(dir $<)) $<
	 
#编译依赖于外部最新文件
hrl = ../../../hrl/all_pb.hrl \
	  ../../../hrl/global_lang.hrl 

all: $(hrl) mk_dir $(EBIN_FILES)

all_emake:	all emake
emake:
	@(erl -make)
	
	
mk_dir:
	@(echo "")
	@(mkdir -p /data/tzr/server/ebin/$(APP_NAME))
	
debug: clean
	$(MAKE) DEBUG=true

##proto定义产生的record文件
../../../hrl/all_pb.hrl: $(wildcard ../../../proto/proxy_pb.proto)
	(make clean)
	(cd ../../../script;./rebuild_game_proto.sh)


dialyzer: clean
	($(MAKE) DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions  -r .)

clean:
	(rm -rf /data/tzr/server/ebin/$(APP_NAME)/*)
