##----------------------------------------------------------
## ���߳����ű�����Ҫ�ϲ����ݿ�
## QingliangCn 2011.7.10
##----------------------------------------------------------

## ��ȡmaster_host
MASTER_HOST=`cat /data/tzr/server/setting/common.config | grep "{master" | awk '{print $2}' | awk -F '}' '{print $1}' | sed 's/"//g'`
/usr/local/bin/erl -name mgeed@$MASTER_HOST -pa /data/tzr/server/ebin/db/  -pa /data/tzr/server/ebin/db/mod -pa /data/tzr/server/ebin/common/ -mnesia dir \"/data/database/tzr2/\" -s common_cheji reset_db_schema
