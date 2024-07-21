#!/bin/bash
## 根据config文件生成beam文件
echo "正在预编译config文件中，请稍等..."
/usr/local/bin/erl -pa /data/tzr/server/ebin/common/ -s common_config_dyn gen_all_beam -noinput -s erlang halt
mkdir -p /data/tzr/server/ebin/config/
cd /data/mtzr/config/src
erl -make
rm -f /data/mtzr/config/src/*.erl
echo "config文件编译成功!"
