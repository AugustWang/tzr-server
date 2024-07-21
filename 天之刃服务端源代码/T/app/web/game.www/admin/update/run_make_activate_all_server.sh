#!/bin/bash

#############################################
## 该脚本用于生成激活码的数据，谨慎使用
#############################################

INIT_DIR=`dirname $0`
cd ${INIT_DIR}/


echo =====================开始生成激活码数据==================

##########注意，请先修改以下参数！！##########

##生成多少个激活码
MAKE_ACTIVE_NUM_COUNT=120;
##发放类型，1表示新手卡；2表示官网活动；3表示媒体发放；4表示门派卡发放
PUBLISH_TYPE=2;
##发放批次
PUBLISH_TIMES=1;

/usr/bin/php ./makeActivateCodeAllServer.php ${PUBLISH_TYPE} ${PUBLISH_TIMES} ${MAKE_ACTIVE_NUM_COUNT}

