####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-05-30
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################
include ../../../hrl/include.mk

##指定当前项目在svn仓库中的名字
APP_NAME := world
EBIN_DIR := $(APP_EBIN_ROOT)/$(APP_NAME)
EBIN_PA := $(EBIN_DIR)/behaviour
##指定编译时查找common.doc/trunk/hrl中的文件
ERLC_FLAGS := -Werror -I $(INCLUDE_DIRS) -I ../../../hrl $(EBIN_PA:%=-pa %)

##所有的erl源码文件
ERL_SOURCES :=  $(wildcard src/behaviour/*.erl) $(wildcard src/*.erl) $(wildcard src/hook/*.erl) $(wildcard src/mod/*.erl) $(wildcard src/library/*.erl) $(wildcard src/mod/missions_model/*.erl) $(wildcard src/mod/event/*.erl) $(wildcard src/ranking/*.erl)  $(wildcard src/admin/*.erl)  $(wildcard src/user_event/*.erl)
##替换src为ebin
ERL_SOURCES2 := $(subst src,$(EBIN_DIR),$(ERL_SOURCES))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))
##输出文件
EBIN_FILES = $(ERL_OBJECTS)

##使用通配符方式指定每个文件的编译规则
$(EBIN_DIR)/%.$(EMULATOR): $(hrl) src/%.erl 
	$(ERLC) $(ERLC_FLAGS) -o $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(dir $<)) $<
	 
all: hrl mk_dir $(EBIN_FILES)

all_no_cp : hrl mk_dir  $(EBIN_FILES) 

all_emake:	all emake

emake:
	@(erl -make)
	

wc: hrl common mk_dir $(EBIN_FILES)

common:
	@(cd ../common;$(MAKE))

mk_dir:
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME))
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/behaviour)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod/missions_model)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod/event)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/hook)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/ranking)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/admin)
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/user_event)
	
	
debug: clean
	(rm -rf $(APP_EBIN_ROOT)/common/*)
	@(cd ../common;$(MAKE) DEBUG=true)
	$(MAKE) DEBUG=true

test: clean
	@($(MAKE) all_no_cp TEST=true)
	@$(ERL) -pa $(APP_EBIN_ROOT)/$(APP_NAME)/mod/ -noshell -eval "eunit:test(\"$(APP_EBIN_ROOT)/$(APP_NAME)\", [verbose]), init:stop()"
	
dialyzer: clean
	($(MAKE) all_no_cp DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions -Wno_return -r $(APP_EBIN_ROOT)/$(APP_NAME))

clean:
	(rm -rf $(APP_EBIN_ROOT)/$(APP_NAME)/*)
