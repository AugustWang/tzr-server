%%%-------------------------------------------------------------------
%%% @author bisonwu <wuzesen@mingchao.com>
%%% @copyright (C) 2010, mingchao.com
%%% @doc
%%%     Mysql持久化的实现模块
%%% @end
%%% Created : 2010-10-25
%%%-------------------------------------------------------------------
%%	负责对MySQL DB的持久化处理
 
-module(mysql_persistent_handler).

%%
%% Include files
%%
-include("common.hrl").
-include("common_server.hrl").

%%
%% Exported Functions
%%
-export([load_whole_table/2,dirty_delete/2,dirty_delete_object/3]).
-export([dirty_write/2]).
-export([dirty_write_batch/2,dirty_write_batch/3]).
-export([dirty_insert/2,dirty_update/3]).
-export([dump_tables/1,get_table_records/1]).
-export([dump_all_tables/0]).
-export([]).

-define(PAGE_SIZE,10000).	%%	默认的分页的大小

%%
%% API Functions
%%

%% @doc load_whole_table from mysql
load_whole_table(DbTable, TargetTable)->
	do_load_table(DbTable, TargetTable).


%% @doc dump all table's data to mysql
dump_all_tables()->
	TabList = init_define_ram_tables(),
	dump_tables(TabList).

%% @doc dump table's data to mysql
dump_tables(TabList) when is_list(TabList)->
	Mapping = init_define_table_mapping(),
	[ do_dump_table(Tab,Mapping) || Tab <- TabList ].


%% @doc 获取指定的mnesia内存表的所用记录
get_table_records(SourceTable)->
	Pattern = get_whole_table_match_pattern(SourceTable),
    Res = mnesia:dirty_match_object(SourceTable, Pattern),
	Res.


dirty_insert(DbTable, Record)-> 
	{ok,_R} = do_save_record(insert,DbTable,Record).

dirty_write_batch(DbTable, RecordList)-> 
    dirty_write_batch(DbTable, RecordList,200).

dirty_write_batch(DbTable, RecordList,MaxCountPerTime)-> 
    FieldNames = mysql_persistent_util:get_fieldname_list(DbTable),
    BatchFieldValuesList = [ get_fields_value_list(DbTable, Rec) || Rec<-RecordList ],
    
    mod_mysql:batch_replace(DbTable,FieldNames,BatchFieldValuesList,MaxCountPerTime).

%% @doc dirty_write/2
%%      replace into 
dirty_write(DbTable, Record)-> 
    {ok,_R} = do_save_record(write,DbTable,Record).


dirty_update(set,DbTable, Record)-> 
	WhereExpr = do_get_whereexpr_for_keyrecord(DbTable,Record),
	{ok,_R} = do_save_record(update,DbTable,Record,WhereExpr);
dirty_update(bag,DbTable, Record)-> 
	WhereExpr = do_concat([ get_whereexpr(DbTable, Record)," limit 1"]),
	{ok,_R} = do_save_record(update,DbTable,Record,WhereExpr).


%% @doc dirty_delete record to mysql
dirty_delete(DbTable, KeyVal)-> 
	?DEBUG("dirty_delete,DbTable=~w,KeyVal=~w",[DbTable,KeyVal]),

	WhereExpr = do_get_whereexpr_for_key(DbTable,KeyVal),
	SqlDelete = mod_mysql:get_esql_delete(DbTable,WhereExpr),
	{ok,_R} = mod_mysql:update(SqlDelete).


%% @doc dirty_delete_object record to mysql
dirty_delete_object(set,DbTable, Record)->
	?DEBUG("dirty_delete_object,DbTable=~w,Record=~w",[DbTable,Record]),
	KeyVal = element(2,Record),
	dirty_delete(DbTable, KeyVal);
dirty_delete_object(bag,DbTable, Record)->
	?DEBUG("dirty_delete_object,DbTable=~w,Record=~w",[DbTable,Record]),
	WhereExpr = get_whereexpr(DbTable, Record),
	SqlDelete = mod_mysql:get_esql_delete(DbTable,WhereExpr),
	{ok,_R} = mod_mysql:update(SqlDelete).



%%
%% Local Functions
%%

do_get_whereexpr_for_keyrecord(DbTable,Record)->
	do_get_whereexpr_for_key(DbTable, element(2,Record) ).

do_get_whereexpr_for_key(DbTable,KeyVal)->
	StrKeyVal = common_mysql_misc:field_to_varchar( KeyVal ),
	{KeyName,KeyType} = mysql_persistent_util:get_key_tuple(DbTable),
	WhereExpr = case (KeyType==varchar) 
						 orelse  (KeyType==tuplechar) orelse (KeyType==binchar) of
					true-> do_concat(["`",KeyName,"`=\'",StrKeyVal,"\' limit 1"]);
					_ -> do_concat(["`",KeyName,"`=",StrKeyVal," limit 1"])
				end,
	WhereExpr.

%% @spec init_define_table_mapping/0 -> TupleList
%% @doc 返回内存表和Mysql持久化表的对应关系
init_define_table_mapping()->
	Tabs = db_loader:define_table_mapping(),
	[ {RamTab,DbTab} || {DbTab,RamTab} <- Tabs ].

init_define_ram_tables()->
	Tabs = db_loader:define_table_mapping(),
	[ RamTab || {_DbTab,RamTab} <- Tabs ].

%% @spec do_dump_table(Tab::atom(),Mapping::dictionary() ) -> ok|{error,Reason}
%% @spec 将Mnesia内存表中的数据dump到MySQL数据库中
do_dump_table(FromTab,Mapping)->
    case get_persistent_table(FromTab,Mapping) of
        false-> ignore;
        {_,DbTable} ->
            SqlDelete = mod_mysql:get_esql_delete(DbTable, [] ),
            mod_mysql:update(SqlDelete),
            
            Records = get_table_records(FromTab),
            [ do_save_record(insert,DbTable,R) || R <- Records ]
    end.


get_whole_table_match_pattern(SourceTable) ->
    A = mnesia:table_info(SourceTable, attributes),
    RecordName = mnesia:table_info(SourceTable, record_name),
    lists:foldl(
      fun(_, Acc) ->
              erlang:append_element(Acc, '_')
      end, {RecordName}, A).

%% @spec get_persistent_table(FromTab::atom(),Mapping::TupleList)
%% @doc 获取内存表对应的Mysql持久化表
get_persistent_table(FromTab,Mapping) when is_atom(FromTab)->
	lists:keyfind(FromTab, 1, Mapping).


%% @spec do_load_table
%% @doc 将mysql的表数据加载到mnesia的内存表中
do_load_table(DbTable, TargetTable)->
	mnesia:clear_table(TargetTable),
	RecordName = mysql_persistent_util:get_record_name(DbTable),
	
	{ok,[[1,TotalCount]]} = mod_mysql:select( lists:concat(["select 1,count(1) from ",DbTable]) ),
	?DEBUG("TotalCount=~w",[TotalCount]),
	case is_integer(TotalCount) of
		true->
			case mysql_persistent_util:get_mysql_field_names( DbTable ) of
				undefined->
					?ERROR_MSG("the table=~w has not defined",[DbTable]),
					ignore;
				DbTabFields ->
					do_load_paginated(DbTable,TargetTable,RecordName,DbTabFields,{0,?PAGE_SIZE,TotalCount})
			end;
		false->
			?ERROR_MSG("Error occur,TotalCount=~p",[TotalCount]),
			error
	end.

%% @spec do_load_paginated
%% @doc 分页方式加载表数据
do_load_paginated(DbTable, TargetTable,RecordName,DbTabFields,{Start,PageSize,TotalCount}) when ( TotalCount > Start)->
	
	Sql = lists:concat(["select ", DbTabFields ," from ", DbTable ," limit ", Start,",",PageSize ]),
	{ok,ResultSet} = mod_mysql:select( Sql ),
	?DEBUG("ResultSet=~w",[ResultSet]),
	
	Records = [ transform_record(DbTable,RecordName,X) || X <- ResultSet],
	
	[mnesia:dirty_write(TargetTable, R) || R <- Records],
	
	do_load_paginated(DbTable, TargetTable,RecordName,DbTabFields,{Start+PageSize,PageSize,TotalCount});
do_load_paginated(_DbTable, _TargetTable,_RecordName,_DbTabFields,_PageArgs)->
	ok.


do_concat(Things)->
	lists:concat(Things).

%% @spec transform_record
%% @doc 将查询Mysql返回的数据行，转换成Record
transform_record(DbTable,RecordName,ResultRow) when is_list(ResultRow)->
	FieldTypeList = mysql_persistent_util:get_fieldtype_list( DbTable ),
	DataList = do_transform_record(FieldTypeList,ResultRow,[]),
	
	list_to_tuple( [RecordName|DataList] ).

do_transform_record([],[],List) ->
	lists:reverse(List);
do_transform_record([HType|TTypes],[HVal|TVals],List) ->
	%% 对binary,bool,char进行特殊处理
	L2 = case HType of
			 tinyblob when is_binary(HVal) ->
				 [ undefined | List];
			 blob when is_binary(HVal) ->
				 [ undefined | List];
			 varchar when is_binary(HVal) ->
				 [binary_to_list(HVal) | List];
			 tuplechar when is_binary(HVal) ->
				 [ common_mysql_misc:tuplechar_to_tuple(HVal) | List];
			 tinyint ->
				 [ common_mysql_misc:tinyint_to_bool(HVal) | List];
			 _ ->
				 [HVal | List]
		 end,
	do_transform_record(TTypes,TVals,L2).
	
do_save_record(write,DbTable,Record)->
    FieldNames = mysql_persistent_util:get_fieldname_list(DbTable),
    FieldValues = get_fields_value_list(DbTable, Record),
    
    SqlUpdate = mod_mysql:get_esql_replace(DbTable, FieldNames,FieldValues ),
    mod_mysql:update(SqlUpdate);
do_save_record(insert,DbTable,Record)->
	FieldNames = mysql_persistent_util:get_fieldname_list(DbTable),
	FieldValues = get_fields_value_list(DbTable, Record),

    SqlUpdate = mod_mysql:get_esql_insert(DbTable, FieldNames,FieldValues ),
	mod_mysql:insert(SqlUpdate).
do_save_record(update,DbTable,Record,WhereExpr)->
	FieldTupleList = get_fields_tuple_list(DbTable, Record),
	SqlUpdate = mod_mysql:get_esql_update(DbTable, FieldTupleList,WhereExpr),
	
	mod_mysql:update(SqlUpdate).

%% @spec get_whereexpr/2
%% @doc 返回 类似" AKey=AVal and BKey=BVal "的语句
get_whereexpr(DbTable, Record)->
	case mysql_persistent_util:get_key_tuplelist(DbTable) of
		[]->
			AttrList = mysql_persistent_util:get_attributes(DbTable),
			[_H| FieldVals ] = tuple_to_list(Record);
		KeyTupleList ->
			AttrList = KeyTupleList,
			FieldVals = [ element(Idx+1,Record) || Idx <-mysql_persistent_util:get_keys_index(DbTable) ]
	end,
	
	do_get_whereexpr(AttrList,FieldVals,"").

do_get_whereexpr([],[],List)->
	List;
do_get_whereexpr([HAttr|FAttrs],[HVal|FVals],List) when length(List) =:= 0->
	HName = element(1,HAttr),
	L2 = case element(2,HAttr) of
			 varchar ->
				 lists:concat([ HName,"=\'",HVal,"\' "]);
			 tuplechar when is_tuple(HVal) ->
				 lists:concat([ HName,"=\'",common_mysql_misc:field_to_varchar(HVal),"\' "]);
			 binchar ->
				 lists:concat([ HName,"=\'",common_mysql_misc:field_to_varchar(HVal),"\' "]);
			 %%: may not support blob
			 _Other -> 
				 lists:concat([ HName,"=",HVal])
		 end,
	do_get_whereexpr(FAttrs,FVals,L2);
do_get_whereexpr([HAttr|FAttrs],[HVal|FVals],List) when length(List) > 0->
	HName = element(1,HAttr),
	L2 = case element(2,HAttr) of
			 varchar ->
				 lists:concat([List," and ",HName,"=\'",HVal,"\' "]);
			 tuplechar when is_tuple(HVal) ->
				 lists:concat([List," and ",HName,"=\'",common_mysql_misc:field_to_varchar(HVal),"\' "]);
			 binchar ->
				 lists:concat([List," and ",HName,"=\'",common_mysql_misc:field_to_varchar(HVal),"\' "]);
			 %%: may not support blob
			 _Other -> 
				 lists:concat([List," and ",HName,"=",HVal])
			 end,
do_get_whereexpr(FAttrs,FVals,L2).


%% @spec get_fields_value_list/2 -> List
%% @doc 返回 类似 [AVal,BVal]
get_fields_value_list(DbTable, Record)->
	FieldTypeList = mysql_persistent_util:get_fieldtype_list( DbTable ),
	[_H|FieldVals ] = tuple_to_list(Record),
	do_get_fields_value_list(FieldTypeList,FieldVals,[]).

do_get_fields_value_list([],[],List)->
	lists:reverse(List);
do_get_fields_value_list([HType|TTypes],[HVal|TVars],List)->
	%% 对binary,boolean,char,blob进行特殊处理
	L2 = case HType of
			 tinyblob->
				 [ undefined | List];
			 blob->
				 [ undefined | List];
			 tuplechar when is_tuple(HVal)->
				 [ common_mysql_misc:field_to_varchar(HVal)| List];
			 tinyint->
				 [ common_mysql_misc:to_tinyint(HVal) | List];
			 _ ->
				 [HVal | List]
		 end,
	do_get_fields_value_list(TTypes,TVars,L2).


%% @spec get_fields_tuple_list/2 -> TupleList
%% @doc 返回 类似 [{AKey,AVal},{BKey,BVal}]
get_fields_tuple_list(DbTable, Record)->
	Attributes = mysql_persistent_util:get_attributes(DbTable),
	[_H| FieldVals ] = tuple_to_list(Record),
	do_get_fields_tuple_list(Attributes,FieldVals,[]).

do_get_fields_tuple_list([],[],List)->
	lists:reverse(List);
do_get_fields_tuple_list([HAttr|TAttrs],[HVal|TVars],List)->
	HKey = element(1,HAttr),
	HType = element(2,HAttr),
	%% 对binary,boolean,blob进行特殊处理
	L2 = case HType of
			 tinyblob->
				 [{HKey,undefined} | List];
			 blob->
				 [{HKey,undefined} | List];
			 tuplechar->
				 [{HKey,common_mysql_misc:field_to_varchar(HVal)} | List];
			 tinyint->
				  [{HKey,common_mysql_misc:to_tinyint(HVal)} | List];
			 _ -> %% including varchar,binchar
				 [{HKey,HVal} | List]
		 end,
	do_get_fields_tuple_list(TAttrs,TVars,L2).
