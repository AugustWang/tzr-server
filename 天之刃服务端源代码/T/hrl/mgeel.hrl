%%%----------------------------------------------------------------------
%%% File    : mgeel_logger_h.erl
%%% Author  : Qingliang
%%% Created : 2010-01-01
%%% Description: Ming game engine erlang
%%%----------------------------------------------------------------------

-define(APP_NAME, login.server).

-define(DEV(Format, Args),
        common_logger:dev(?APP_NAME, ?MODULE, ?LINE, Format, Args)).

-define(DEBUG(Format, Args),
    common_logger:debug_msg(?APP_NAME, ?MODULE,?LINE,Format, Args)).

-define(INFO_MSG(Format, Args),
    common_logger:info_msg( node(), ?MODULE,?LINE,Format, Args)).
			      
-define(WARNING_MSG(Format, Args),
    common_logger:warning_msg( node(), ?MODULE,?LINE,Format, Args)).
			      
-define(ERROR_MSG(Format, Args),
    common_logger:error_msg( node(), ?MODULE,?LINE,Format, Args)).

-define(CRITICAL_MSG(Format, Args),
    common_logger:critical_msg( node(), ?MODULE,?LINE,Format, Args)).


-record(listener, {node, protocol, host, port}).

-define(TEAM_MAX_ROLE_COUNT, 5).

-define(HEARTBEAT_TICKET_TIME, 3000).

-define(HEARTBEAT_MAX_FAIL_TIME, 1).

-define(ACCOUNT_ROLE_COUNT_MAX, 1).

-define(RECV_TIMEOUT, 5000).

-define(LOGIN_MODULE, <<"login">>).

-define(CROSS_FILE, "<?xml version=\"1.0\"?>\n<!DOCTYPE cross-domain-policy SYSTEM "
       ++"\"http://www.macromedia.com/xml/dtds/cross-domain-policy.dtd\">\n"
       ++"<cross-domain-policy>\n"
    ++"<allow-access-from domain=\"*\" to-ports=\"80,8888\"/>\n"
    ++"</cross-domain-policy>\n\0").

%% equal to <<"<policy-file-request/>\0">>
-define(CROSS_DOMAIN_FLAG, <<60,112,111,108,105,99,121,45,102,105,108,101,45,114,101,113,117,101,115,116,47,62,0>>).

-define(HEART_BEAT, <<"00">>).

-define(ETS_MM_MAP, ets_mm_map).
%%地图出生点ets表
-define(ETS_BORN_POINT, ets_born_point).
-define(ETS_ROLE_ATTR, ets_role_attr).
-define(ETS_BORN_INFO, ets_born_info).
-define(ETS_ACCOUNT, ets_account).
-define(ETS_ROLENAME, ets_account_rolename).
-include("common.hrl").

%% 登录ticket过期时间 (秒)
-define(LOGIN_TICKET_EXPIRED, 3600).
