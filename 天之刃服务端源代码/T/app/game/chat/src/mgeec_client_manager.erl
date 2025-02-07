%%%-------------------------------------------------------------------
%%% @author QingliangCn <>
%%% 玩家聊天进程管理进程，网关上玩家上下线都会通知这里
%%% @end
%%% Created :  7 Apr 2011 by QingliangCn <>
%%%-------------------------------------------------------------------
-module(mgeec_client_manager).

-behaviour(gen_server).

-include("mgeec.hrl").

%% API
-export([
         start/0,
         start_link/0
        ]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {}).

%%%===================================================================
%%% API
%%%===================================================================

start() ->
    {ok, _} = supervisor:start_child(
                mgeec_sup, 
                {?MODULE, 
                 {?MODULE, start_link, []}, 
                 permanent, 10000, worker, [?MODULE]}).

%%--------------------------------------------------------------------
%% @doc
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link() ->
    gen_server:start_link({global, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    erlang:process_flag(trap_exit, true),
    {ok, #state{}}.

%%--------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%%--------------------------------------------------------------------
handle_cast(_Msg, State) ->
    {noreply, State}.

%%--------------------------------------------------------------------
handle_info(Info, State) ->
    ?DO_HANDLE_INFO(Info, State),
    {noreply, State}.

%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% @end
%%--------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

do_handle_info({online, GatewayPID, RoleID, RoleBase, RoleAttr, RoleExt}) ->
    do_online(GatewayPID, RoleID, RoleBase, RoleAttr, RoleExt);
do_handle_info({offline, AccountName, RoleID}) ->
    do_offline(AccountName, RoleID);
do_handle_info(Info) ->
    ?ERROR_MSG("~ts:~w", ["收到未知消息", Info]).

%% 玩家上线了
do_online(GatewayPID, RoleID, RoleBase, RoleAttr, RoleExt) ->
    RoleName = RoleBase#p_role_base.role_name,
    ChatRolePName = common_misc:chat_get_role_pname(RoleName),
    ChannelList = mgeec_misc:get_channel_list(RoleBase, RoleAttr),
    NewChannelList = 
            lists:map(
              fun(Item) ->
                      ChannelType = Item#p_channel_info.channel_type,
                      case ChannelType of
                          ?CHANNEL_TYPE_LEVEL ->
                              ChannelSign = Item#p_channel_info.channel_sign,
                              gen_server:cast({global, ChannelSign}, {online_notify, RoleID}),
                              %%玩家上线时更新下自己的信息
                              {_, NewChannelInfo} =
                                  mgeec_misc:dn_update_channel_role_info(RoleID, 
                                                                         ChannelSign, 
                                                                         ?CHANNEL_TYPE_LEVEL, 
                                                                         true, 
                                                                         RoleBase, 
                                                                         RoleAttr,
                                                                         RoleExt),
                              NewChannelInfo;
                          _ ->
                              Item
                      end

              end, ChannelList),   
    case global:whereis_name(ChatRolePName) of
        undefined ->
            do_online2(GatewayPID, RoleID, RoleName, ChatRolePName, RoleBase, RoleAttr, RoleExt, NewChannelList);
        PID ->
            PID ! {set_gateway_pid, GatewayPID},
            GatewayPID ! {chat_process, PID, NewChannelList}
    end.

do_online2(GatewayPID, RoleID, RoleName, ChatRolePName, RoleBase, RoleAttr, RoleExt, NewChannelList) ->
    RoleChatInfo = #p_chat_role{roleid=RoleID, 
                                rolename=common_tool:to_list(RoleBase#p_role_base.role_name), 
                                factionid=RoleBase#p_role_base.faction_id,
                                faction_name=mgeec_misc:get_faction_name(RoleBase#p_role_base.faction_id),
                                sex=RoleBase#p_role_base.sex,
                                head=RoleBase#p_role_base.head,
                                sign=RoleExt#p_role_ext.signature,
                                titles=common_title:get_role_chat_titles(RoleID)
                               },
    
    {ok, Pid} = supervisor:start_child(mgeec_role_sup, 
                                       [{RoleID, 
                                         RoleName, 
                                         ChatRolePName, 
                                         {RoleBase, RoleAttr, RoleExt, RoleChatInfo, NewChannelList}, 
                                         GatewayPID}]),
    %% 通知网关对应的聊天进程PID
    GatewayPID ! {chat_process, Pid, NewChannelList},
    Pid ! {set_channels, RoleID, RoleName, RoleChatInfo, Pid, NewChannelList},
    ok.

%% 玩家下线了
do_offline(_AccountName, RoleID) ->
    [#p_role_base{role_name=RoleName}] = db:dirty_read(?DB_ROLE_BASE, RoleID),
    ChatRolePName = common_misc:chat_get_role_pname(RoleName),
    erlang:exit(global:whereis_name(ChatRolePName), normal),
    ok.
