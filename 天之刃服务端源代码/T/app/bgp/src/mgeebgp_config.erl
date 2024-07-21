%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     common_config 的动态加载实现版本，之后可以取缔common_config
%%%     目前只支持key-value或者record（首字段为key）的配置文件
%%% @end
%%% Created : 2010-12-2
%%%-------------------------------------------------------------------
-module(mgeebgp_config).

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

-include("common.hrl").
-include("mgeebgp_comm.hrl").


%% API
-export([init/0,reload/1]).
 
-export([list/1]).

-export([find/2]).

-export([load_gen_src/2,load_gen_src/3]).

-define(MGE_ROOT_CONFIG, "/data/tzr/server/config/bgp/").

-define(DEFINE_CONFIG_MODULE(Name,FilePath,FileType),{ Name, codegen_name(Name),
                                                       ?MGE_ROOT_CONFIG ++ FilePath, FileType }).

%% 支持4种文件类型：record_consult,key_value_consult,key_value_list,record_list,

-define(BASIC_CONFIG_FILE_LIST,[    %%配置模块名称,路径,类型
                                    ?DEFINE_CONFIG_MODULE(bgp,"bgp.config",key_value_consult)
                               ]).

-define(FOREACH(Fun,List),lists:foreach(fun(E)-> Fun(E)end, List)).

%% ====================================================================
%% API Functions
%% ====================================================================

init()->
    ?FOREACH(catch_do_load_config,?BASIC_CONFIG_FILE_LIST),
    ok.


%%@spec reload(ConfigName::atom())
%%@result   ok | {error,not_found}
reload(ConfigName) when is_atom(ConfigName)->
    AllFileList = lists:concat( [?BASIC_CONFIG_FILE_LIST]),
    case lists:keyfind(ConfigName, 1, AllFileList) of
        false->
            {error,not_found};
        ConfRec->
            catch_do_load_config(ConfRec),
            ok
    end.
 
 
%%@spec list/1
%%@doc 为了尽量少改动，接口符合ets:lookup方法的返回值规范，
%%@result   [] | [Result]
list(ConfigName)->
    case do_list(ConfigName) of
        undefined-> [];
        not_implement -> [];
        Val -> Val
    end.

%%@spec find/2
%%@doc 为了尽量少改动，接口符合ets:lookup方法的返回值规范，
%%@result   [] | [Result]
find(ConfigName,Key)->
    case do_find(ConfigName,Key) of
        undefined-> [];
        not_implement -> [];
        Val -> [Val]
    end.



%%@spec do_list/1
do_list(ConfigName) ->
    ModuleName = common_tool:list_to_atom( codegen_name(ConfigName) ),
    ModuleName:list().

%%@spec do_find/2
do_find(ConfigName,Key) ->
    ModuleName = common_tool:list_to_atom( codegen_name(ConfigName) ),
    ModuleName:find_by_key(Key).

%%@spec load_gen_src/2
%%@doc ConfigName配置名，类型为atom(),KeyValues类型为[{key,Value}|...]
load_gen_src(ConfigName,KeyValues) ->
    load_gen_src(ConfigName,KeyValues,[]).

%%@spec load_gen_src/2
%%@doc ConfigName配置名，类型为atom(),KeyValues类型为[{key,Value}|...]
load_gen_src(ConfigName,KeyValues,ValList) ->
    do_load_gen_src(codegen_name(ConfigName),KeyValues,ValList).

%% ====================================================================
%% Local Functions
%% ====================================================================

codegen_name(Name)->
    lists:concat([Name,"_config_codegen"]).

catch_do_load_config({AtomName,ConfigModuleName,FilePath,_}=ConfRec)->
        try
            do_load_config(ConfRec)
        catch
            Err:Reason->
                ?ERROR_MSG("Reason=~w,AtomName=~w,ConfigModuleName=~p,FilePath=~p",[Reason,AtomName,ConfigModuleName,FilePath]),
                throw({Err,Reason})
        end.

do_load_config({_AtomName,ConfigModuleName,FilePath,record_consult})->
    {ok,RecList} = file:consult(FilePath),
    KeyValues = [ begin
                      Key = element(2,Rec), {Key,Rec}
                  end || Rec<- RecList ],
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,KeyValues,ValList);

do_load_config({_AtomName,ConfigModuleName,FilePath,record_list})->
    {ok,[RecList]} = file:consult(FilePath),
    KeyValues = [ begin
                      Key = element(2,Rec), {Key,Rec}
                  end || Rec<- RecList ],
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,KeyValues,ValList);

do_load_config({_AtomName,ConfigModuleName,FilePath,key_value_consult})->
    {ok,RecList} = file:consult(FilePath),
    KeyValues = RecList,
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,KeyValues,ValList);
do_load_config({_AtomName,ConfigModuleName,FilePath,key_value_list})->
    {ok,[RecList]} = file:consult(FilePath),
    KeyValues = RecList,
    ValList = RecList,
    do_load_gen_src(ConfigModuleName,KeyValues,ValList).

%%@doc 生成源代码，执行编译并load
do_load_gen_src(ConfigModuleName,KeyValues,ValList)->
    try
        Src = common_config_code:gen_src(ConfigModuleName,KeyValues,ValList),
        {Mod, Code} = dynamic_compile:from_string( Src ),
        code:load_binary(Mod, ConfigModuleName ++ ".erl", Code)
    catch
        Type:Reason -> 
            Trace = erlang:get_stacktrace(), string:substr(erlang:get_stacktrace(), 1,200),
            ?CRITICAL_MSG("Error compiling ~p: Type=~w,Reason=~w,Trace=~w,~n", [ConfigModuleName, Type, Reason,Trace ])
    end.






