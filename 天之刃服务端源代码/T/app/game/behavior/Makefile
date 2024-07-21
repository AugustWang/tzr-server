####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-05-30
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################
include ../../../hrl/include.mk

##指定当前项目在svn仓库中的名字
APP_NAME := behavior
EBIN_DIR := $(APP_EBIN_ROOT)/$(APP_NAME)
##指定编译时查找common.doc/trunk/hrl中的文件
ERLC_FLAGS := -W -I $(INCLUDE_DIRS) -I ../../../hrl/behavior $(EBIN_DIRS:%=-pa %) -pa  /data/tzr/server/ebin/common

##所有的erl源码文件
ERL_SOURCES := $(wildcard src/*.erl)
##替换src为ebin
ERL_SOURCES2 := $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(ERL_SOURCES))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))
##输出文件
EBIN_FILES = $(ERL_OBJECTS)

##使用通配符方式指定每个文件的编译规则
$(EBIN_DIR)/%.$(EMULATOR): $(hrl) src/%.erl 
	$(ERLC) $(ERLC_FLAGS) -o $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(dir $<)) $<

all: hrl mk_dir $(EBIN_FILES)

all_emake:	all emake

emake:
	@(erl -make)
	
wc: hrl common mk_dir $(EBIN_FILES)

common:
	(cd ../common;$(MAKE))
	
debug: clean
	(rm -rf $(APP_EBIN_ROOT)/common/*)
	@(cd ../common;$(MAKE) DEBUG=true)
	$(MAKE) DEBUG=true
	
mk_dir:
	@(echo "")
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/)

../../../hrl/behavior/behavior_pb.hrl: ../../../proto/behavior/behavior.proto
	(cd ../../../script;./rebuild_admin_proto.sh)
    
test: clean
	@($(MAKE) all TEST=true)
	@$(ERL) -pa $(APP_EBIN_ROOT)/$(APP_NAME)/mod/ -noshell -eval "eunit:test(\"$(APP_EBIN_ROOT)/$(APP_NAME)/mod\", [verbose]), init:stop()"
	
	
dialyzer: clean
	($(MAKE) DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions -Wno_return  -r $(APP_EBIN_ROOT)/$(APP_NAME))

clean:
	(rm -rf $(APP_EBIN_ROOT)/$(APP_NAME)/*)
