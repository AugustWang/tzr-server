-module(common_behavior).

-include("behavior/define.hrl").
-include("behavior/behavior_pb.hrl").
-include("common_server.hrl").
-include("log_consume_type.hrl").


-compile(export_all).
-export([send/1]).



send({account_login, _AccountName, _IPTuple}) ->
    ignore;
send({account_init, _AccountName}) ->
    ignore;
send({account_logout, _AccountName, _LoginTime, _IfEnterGame}) ->
    ignore;
send({role_level, _RoleID, _RoleLevel}) ->
    ignore;
send({role_login, _RoleID, _AccountName, _IPTuple}) ->
    ignore;
send({role_logout, _RoleID, _AccountName, _LoginTime}) ->
    ignore;
send({role_new, _AccountName, _PRole}) ->
    ignore;



send({consume_gold, RoleName,AccountName,Level,ConsumeLog}) ->
	#r_consume_log{ user_id=RoleId, use_bind=UseBind,use_unbind=UseUnbind, 
					mtime=MTime, mtype=MType, mdetail=MDetail, item_id=ItemId, item_amount=ItemAmount} = ConsumeLog,
	LogRecord = #b_consume_gold_tos{role_id=RoleId, role_name=RoleName, account_name=AccountName, level=Level, gold_bind=UseBind, 
								   gold_unbind=UseUnbind, mtime=MTime, mtype=MType, mdetail=MDetail, itemid=ItemId, amount=ItemAmount},
    {OpenServerDay, _} =common_config:get_open_day(),
    OpenServerTime = common_tool:datetime_to_seconds({OpenServerDay,{0,0,0}}),
    case  OpenServerTime<common_tool:now() of
        true->
            behavior_log(?B_CONSUME, ?B_CONSUME_GOLD, LogRecord );
        false->
            ignore
    end;


send({pay_log, {AccountName,RoleID,RoleName,OrderId,PayMoney,PayGold,PayTime,Year,Month,Day,Hour,Level,PayDateTime,OnlineDay} }) ->
    LogRecord = #b_pay_log_tos{role_id=RoleID,role_name= RoleName,account_name=AccountName, order_id=OrderId, pay_money=PayMoney, pay_gold=PayGold,give_gold=0, pay_time=PayTime,
                               pay_date_time= PayDateTime, year=Year, month=Month, day=Day, hour=Hour, role_level=Level, online_day=OnlineDay},
    behavior_log(?B_PAY, ?B_PAY_LOG, LogRecord );
	

send(Other) ->
    ?ERROR_MSG("~ts:~w", ["发送行为日志有错误", Other]).



%%--------------------------------------------------------------------------------------------------
%%向行为日志发送日志数据
%%Module Method DataRecord 请自行在 common.doc/trunk/proto/behavior/behavior.proto定义
behavior_log(Module, Method, DataRecord) ->
    %%检查行为日志缓存进程是否启动了
    case global:whereis_name(behavior_cache_server) of
        undefined ->
            %%根据是否开启behavior来决定日志的类型
            ?ERROR_MSG("~ts", ["行为日志缓存服务没有启动:behavior_cache_server"]);
        PID ->
           PID ! {behavior, {Module, Method, DataRecord}}
    end.


