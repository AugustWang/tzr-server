%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     运维瑞士军刀，for mnesia
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
-module(mt_mnesia).

%%
%% Include files
%%

-compile(export_all).
-define( DEBUG(F,D),io:format(F, D) ).

%%
%% Exported Functions
%%
-export([]).
-export([show_tables/0,show_tables_notempty/0]).
-export([show_table/1,show_schema/1,show_schema/0]).

%%
%% API Functions
%%


show_tables_notempty()->
	Tabs = show_tables(),
    List = lists:filter(fun({_Tab,Size})->
                         Size>0
                 end, Tabs),
    sort_list(List).

show_tables_notempty(Type)->
	Tabs = show_tables(Type),
	List = lists:filter(fun({_Tab,Size})->
						 Size>0
				 end, Tabs),
    sort_list(List).

show_tables()->
	Tabs = mnesia:system_info(tables),
    List = [ {SourceTab,mnesia:table_info(SourceTab,size)} || SourceTab <- Tabs ],
    sort_list(List).

show_tables(Type)->
	Tabs = db_loader:define_table_mapping(),
	case Type of
		m->
			List = [ {SourceTab,mnesia:table_info(SourceTab,size)} || {_DbTab,SourceTab} <- Tabs ],
            sort_list(List);
		p->
			List = [ {DbTab,mnesia:table_info(DbTab,size)} || {DbTab,_SourceTab} <- Tabs ],
            sort_list(List)
	end.

sort_list(List)->
    lists:sort(fun({_Tab1,Size1}, {_Tab2,Size2}) -> Size1>Size2 end, List).

show_schema()->
	show_schema("/data/database/tzr/schema.DAT").
show_schema(SchemaFilePath)->
	TmpSchemaFile = "/tmp/tmpSchema.DAT",
	TmpOutFile = "/tmp/tmpOut.txt",
	
	file:delete(TmpOutFile),
	file:copy(SchemaFilePath,TmpSchemaFile),
	{ok, N} = dets:open_file(schema, [{file, TmpSchemaFile },{repair,false}, 
									  {keypos, 2}]),
	F = fun(X) -> 
				io:format("~p~n", [X]), 
				Str = io_lib:format("~p~n", [X]),
				file:write_file(TmpOutFile, list_to_binary(Str), [append]), continue end,
	dets:traverse(N, F),
	file:delete(TmpSchemaFile),
	dets:close(N).

%% 获取指定表的所有数据
%% mt_mnesia:show_table(db_map_online).
show_table(SourceTable)->
	Pattern = get_whole_table_match_pattern(SourceTable),
    Res = mnesia:dirty_match_object(SourceTable, Pattern),
	Res.

%% 根据Set表的key去查询对应记录。
%% 例如获取某地图的人数
%%  mt_mnesia:show_table(db_map_online,"mgee_map_11100").
show_table(SourceTable,Key)->
    Pattern = get_whole_table_match_pattern(SourceTable),
    Res = mnesia:dirty_match_object(SourceTable, Pattern),
    case is_list(Res) andalso length(Res)>0 of
        true->
            lists:keyfind(Key, 2, Res);
        _ ->
            Res
    end.

get_whole_table_match_pattern(SourceTable) ->
    A = mnesia:table_info(SourceTable, attributes),
    RecordName = mnesia:table_info(SourceTable, record_name),
    lists:foldl(
      fun(_, Acc) ->
              erlang:append_element(Acc, '_')
      end, {RecordName}, A).
