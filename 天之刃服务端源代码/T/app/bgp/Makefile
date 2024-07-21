####################################################################
## @author bisonwu <wuzesen@mingchao.com>
## @datetime 2011-04-06
## @description beam文件被放在ebin下或者ebin子目录下，所以启动时要
##				注意-pa参数是否设置正确
##
####################################################################

SHELL := /bin/bash
.PHONY: all dialyzer clean hrl
PLT="/data/mtzr/.dialyzer_plt"

## ebin 根目录
APP_EBIN_ROOT := /data/tzr/server/ebin

ERL := erl
ERLC := $(ERL)c
EMULATOR := beam

INCLUDE_DIRS := include

##指定编译时查找common.doc/trunk/hrl中的文件
ERLC_FLAGS := -Werror -I $(INCLUDE_DIRS) -I ../../hrl $(EBIN_DIRS:%=-pa %) -pa  ${APP_EBIN_ROOT}/common
##这里可以通过 make DEBUG=true来达到打开debug_info选项的目的
ifdef DEBUG
  ERLC_FLAGS += +debug_info
endif

ifdef TEST
  ERLC_FLAGS += -DTEST
endif

default: all
      
hrl:
	@(cd /data/mtzr/script; $(MAKE))
    

##指定当前项目在svn仓库中的名字
APP_NAME := bgp
EBIN_DIR := $(APP_EBIN_ROOT)/$(APP_NAME)

##所有的erl源码文件
ERL_SOURCES := $(wildcard src/*.erl) $(wildcard src/mod/*.erl)
##替换src为ebin
ERL_SOURCES2 := $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(ERL_SOURCES))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))
##app配置文件
APP_FILES := $(wildcard $(SERVER_ROOT)/$(APP_NAME)/config/*.app)
##输出文件
EBIN_FILES = $(ERL_OBJECTS) $(APP_FILES)

$(EBIN_DIR)/%.$(EMULATOR): $(hrl) src/%.erl 
	$(ERLC) $(ERLC_FLAGS) -o $(subst src,$(APP_EBIN_ROOT)/$(APP_NAME),$(dir $<)) $<
	 

all: hrl mk_dir $(EBIN_FILES)

all_no_cp : hrl  mk_dir  $(EBIN_FILES) 

all_emake:	all emake

emake:
	@(erl -make)
	
wc: hrl common mk_dir $(EBIN_FILES)

common:
	@(cd ../common;$(MAKE))
	
mk_dir:
	@(echo "")
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME))
	@(mkdir -p $(APP_EBIN_ROOT)/$(APP_NAME)/mod)
	
	
debug: clean
	(rm -rf $(APP_EBIN_ROOT)/common/*)
	@(cd ../common;$(MAKE) DEBUG=true)
	$(MAKE) DEBUG=true

	
test: clean
	@($(MAKE) all_no_cp TEST=true)
	@$(ERL) -pa $(APP_EBIN_ROOT)/$(APP_NAME)/mod/ -noshell -eval "eunit:test(\"$(APP_EBIN_ROOT)/$(APP_NAME)/mod\", [verbose]), init:stop()"
	
dialyzer: clean
	($(MAKE) DEBUG=true)
	(dialyzer --plt $(PLT) -Werror_handling -Wrace_conditions -Wno_return -r $(APP_EBIN_ROOT)/$(APP_NAME))

clean:
	(rm -rf $(APP_EBIN_ROOT)/$(APP_NAME)/*)
