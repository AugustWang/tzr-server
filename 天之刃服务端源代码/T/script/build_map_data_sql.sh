#!/bin/bash
echo "生成地图上npc点及怪物点的数据sql文件---开始"
cd ./maploader
erlc loader.erl
erl -run loader -pa ./maploader
echo "生成地图上npc点及怪物点的数据sql文件---结束"