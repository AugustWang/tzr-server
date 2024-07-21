####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-05-30
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################
include ../../../hrl/include.mk

##指定当前项目在svn仓库中的名字
APP_NAME := login
EBIN_DIR := $(APP_EBIN_ROOT)/$(APP_NAME)

##所有的erl源码文件
ERL_SOURCES := $(wildcard src/*.erl) $(wildcard src/s2s/*.erl) $(wildcard src/s2s/mod/*.erl) $(wildcard src/hook/*.erl) $(wildcard src/mod/*.erl)
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
	@(cd ../common;$(MAKE))
	
mk_dir:
	@(echo "")
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/hook)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/s2s)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/s2s/mod)

../../../hrl/behavior/behavior_pb.hrl: ../../../proto/behavior/behavior.proto
	(cd ../../../script;./rebuild_behavior_proto.sh)
	
debug: clean
	(rm -rf $(APP_EBIN_ROOT)/common/*)
	@(cd ../common;$(MAKE) DEBUG=true)
	$(MAKE) DEBUG=true

test: clean
	@($(MAKE) all TEST=true)
	@$(ERL) -pa $(APP_EBIN_ROOT)/$(APP_NAME)/mod/ -noshell -eval "eunit:test(\"$(APP_EBIN_ROOT)/$(APP_NAME)\", [verbose]), init:stop()"
	
dialyzer: clean
	($(MAKE) DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions -Wno_return  -r $(APP_EBIN_ROOT)/$(APP_NAME))

clean:
	(rm -rf $(APP_EBIN_ROOT)/$(APP_NAME)/*)
