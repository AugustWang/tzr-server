#!/bin/bash
echo "生成地图位置数据txt文件---开始"
cd ./maploader
erlc map_pos_loader.erl
erl -run map_pos_loader
echo "生成地图出生点born_point.config文件---结束"
echo "生成地图位置数据txt文件---结束"