####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-05-30
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################
include ../../../hrl/include.mk

##指定当前项目在svn仓库中的名字
APP_NAME := common
EBIN_DIR := $(APP_EBIN_ROOT)/$(APP_NAME)

##所有的erl源码文件
ERL_SOURCES := $(wildcard src/*.erl) $(wildcard src/mod/*.erl) $(wildcard src/library/*.erl) $(wildcard src/library/php/*.erl)  $(wildcard src/library/json/*.erl)
##替换src为ebin
ERL_SOURCES2 := $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(ERL_SOURCES))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))

##app配置文件
APP_FILES := $(wildcard $(SERVER_ROOT)/$(APP_NAME)/config/*.app)
##输出文件
EBIN_FILES = $(ERL_OBJECTS) $(ERL_OBJECTS_TEST)

##使用通配符方式指定每个文件的编译规则
$(EBIN_DIR)/%.$(EMULATOR): $(hrl) src/%.erl 
	$(ERLC) $(ERLC_FLAGS) -pa /data/tzr/server/ebin/common/ -o $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(dir $<)) $<
	

all: mk_dir  $(EBIN_FILES)
	
mk_dir:
	@(echo "")
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/library/json)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/library/php)
	
debug: clean
	$(MAKE) DEBUG=true
	
	
test: clean
	@($(MAKE) all_no_cp TEST=true)
	@$(ERL) -pa $(APP_EBIN_ROOT)/common/mod/ -noshell -eval "eunit:test(\"$(APP_EBIN_ROOT)/common\", [verbose]), eunit:test(\"$(APP_EBIN_ROOT)/common/mod\", [verbose]), init:stop()"
	

dialyzer: clean
	($(MAKE) all_no_cp DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions -Wno_return  -r $(APP_EBIN_ROOT)/$(APP_NAME))

clean:
	(rm -rf $(APP_EBIN_ROOT)/common/*)
