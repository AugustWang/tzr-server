%%内部通信用的接口名 模块名不需要设置两个
-define(B_SERVER, <<"server">>).
-define(B_SERVER_AUTH, <<"auth">>).

-define(B_SERVER_MSG, <<"msg">>).
-define(B_SERVER_UNIQUE, <<"unique">>).

%%===========================================================

-define(B_ROLE, {<<"role">>, <<"GameRole">>}). %%角色模块
-define(B_ROLE_NEW, {<<"new">>, <<"AddRole">>}). %%创建新角色
-define(B_ROLE_LEVEL, {<<"level">>, <<"level">>}).
-define(B_ROLE_LOGIN, {<<"login">>, <<"LoginLog">>}). %%角色登录
-define(B_ROLE_LOGOUT, {<<"logout">>, <<"LogoutLog">>}). %%角色退出


-define(B_ACCOUNT, {<<"account">>, <<"GameAccount">>}). %%帐号模块
-define(B_ACCOUNT_INIT, {<<"init">>, <<"AddAccount">>}). %%创建帐号
-define(B_ACCOUNT_LOGIN, {<<"login">>, <<"LoginLog">>}). %%帐号登录
-define(B_ACCOUNT_LOGOUT, {<<"logout">>, <<"LogOutLog">>}).%%帐号退出



%%消费日志记录,包括元宝消费
-define(B_CONSUME, {<<"consume">>, <<"Consume">>}).
-define(B_CONSUME_GOLD, {<<"gold">>, <<"ConsumeGold">>}). 
%% 充值日志
-define(B_PAY, {<<"pay">>, <<"Pay">>}).
-define(B_PAY_LOG, {<<"log">>, <<"PayLog">>}). 

%%GM投诉相关的定义
-define(B_GM, {<<"GM">>, <<"GmComplaint">>}).
-define(B_GM_COMPLAINT, {<<"GM">>, <<"New">>}).
-define(B_GM_EVALUATE, {<<"GM">>, <<"Evaluate">>}).
-define(B_GM_NOTIFY_REPLY, {<<"GM">>, <<"NotifyReply">>}).




