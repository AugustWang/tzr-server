%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mm_parser).

%%
%% Include files
%%
%%
%% Include files
%%
 
-compile(export_all).
-include("mm_parse_list.hrl").
-include("common_server.hrl").
-include("mm_define.hrl").

%%
%% Exported Functions
%%
-export([]).

%%
%% API Functions
%%
parse(_Mod,_Method,_Rec) ->
    ignore.

%%开发阶段使用，可以打开下面的注释，已方便调试
%% parse(Mod,Method,Rec) ->
%%     parse2(Mod,Method,Rec).

parse2(_Mod,?SYSTEM_HEARTBEAT,_Rec)->
    ignore;
parse2(Mod,Method,Rec)->
    {StrMod,StrMethod} = get_mm(Mod,Method),
    
    Format = "[~w] - [~w],Rec=~w",
    ?ERROR_MSG(Format,[StrMod,StrMethod,Rec]).
%%     LoggerMsg = {module, info_msg, group_leader(), {self(), Format, [StrMod,StrMethod,Rec]}},
%%     gen_event:notify(error_logger, LoggerMsg).

get_mm(Mod,Method)-> 
    case Mod of
        -1 -> StrMod = toc;
        _ ->
            case lists:keyfind(Mod, 1, ?MM_PARSE_LIST) of
                {_,StrMod}->
                    ok;
                _ ->
                    StrMod = unKnownModule
            end
    end,
    case lists:keyfind(Method, 1, ?MM_PARSE_LIST) of
        {_,StrMethod}->
            ok;
        _ ->
            StrMethod = unKnownMethod
    end,
    
    {StrMod,StrMethod}.
    
    
    
    