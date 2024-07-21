####################################################################
## @author QingliangCn <qing.liang.cn@gmail.com>
## @datetime 2010-12-03
## @description 公用makefile文件
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
ERLC_FLAGS := -Werror -I $(INCLUDE_DIRS) -I ../../../hrl $(EBIN_DIRS:%=-pa %)
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
	  


