<?php
if (!defined('MING2_WEB_ADMIN_FLAG')) {
	exit ('hack attemp');
}

	
////////////////////////////////////////////////////////////
///数据库的常用操作方法

//切换主从数据库
function useSlaveDB()
{
	global $db, $db_slave, $dbConfig_slave;
	//Slave
	if(!$db_slave && $dbConfig_slave) {
		$db_slave = new DBClass();
		$db_slave->connect($dbConfig_slave);
	}
	$db = $db_slave;
	if(!$db) die('DATABASE NOT FOUND');
	return true;
}
//切换主从数据库
function useGameDB()
{
	global $db, $db_game;
	$db = $db_game;
	if(!$db) die('DATABASE NOT FOUND');
	return true;
}

/**
 * 执行SQL查询
 * @param $sql
 */
function GQuery ($sql){
	global $db;
	return $db->query($sql);
}

/**
 * 执行SQL查询，获取结果集的第一行
 * @param $sql
 */
function GFetchRowOne ($sql){
	global $db;
	return $db->fetchOne($sql);
}

/**
 * 执行SQL查询，获取结果集的全部
 * @param $sql
 */
function GFetchRowSet($sql){
	global $db;
	return $db->fetchAll($sql);
}

/**
 * 生成这样子的SQL字符串
 * `aaa` = '1' OR `aaa` = '2' OR ....
 */
function makeOrSqlFromArray($filed, $arr){
	$str = '';
	if (is_array($arr))
		foreach($arr as $k=>$v)
		{
		if (empty($str))
			$str = "( `{$filed}`='{$k}'";
		else
			$str .= " OR `{$filed}`='{$k}'";
		}
	return $str . ') ';
}

/*
 * 由数组构造出SQL语句，用于添加数据到数据库，即INSERT
 */
function makeInsertSqlFromArray($arr, $table){
	$str1 = ''; $str2 = '';
	foreach($arr as $k=>$v)
	{
		$str1 .= "`{$k}`,";
		$str2 .= "'{$v}',";
	}
	
	$str = "INSERT INTO `{$table}` (" . trim($str1, ', ') . ") VALUES (" . trim($str2, ', ') . ")";
	return $str;
}
	
/*
 * 由数组构造出SQL语句，用于更新数据回数据库，即UPDATE
 */
function makeUpdateSqlFromArray($arr, $table, $key = 'id')
{
	$str = '';
	foreach($arr as $k=>$v)
	{
		if ($k != $key)
			$str .=  "`{$k}`='{$v}',";
		else
			$where = " WHERE `{$key}`='{$v}' LIMIT 1";
	}

	$str = "UPDATE `{$table}` SET " . trim($str, ', ') . $where;

	//if (ODINXU_DEBUG) echo $str ."\r\n";
	return $str;
}
	
	/*
	 * 由数组构造出SQL语句，用于条件查询，用来检查刚刚INSERT的数据。
	 */
function makeSelectIdWhereSqlFromArray($arr, $table, $key = 'id'){
	$where = '';
	foreach($arr as $k=>$v)
	{
		if ($k != $key)
			$where .= "`{$k}`='{$v}' AND ";
	}
	
	$str = "SELECT `{$key}` FROM `{$table}` WHERE " . substr($where, 0, strlen($where) - 4 );
	return $str;
}

function fetchLatestIDWithData($column_data, $table, $key = 'id')
{
	global $db;
	$sql = makeSelectIdWhereSqlFromArray($column_data, $table, $key) . " ORDER BY `$key` DESC LIMIT 1";
	$row = $db->fetchOne($sql);
	return $row[$key];
}


////////////////////////////////////////////////////////////
///分页显示的常用操作方法
/**
 * 查询结果的分页列表
 * 参数： 当前第几页， 总共多少条记录， 每页显示多少条记录
 */
function getPages($pageno, $record_count, $per_page_record = LIST_PER_PAGE_RECORDS) {
	$record_count = intval($record_count);
	$total_page = ceil($record_count / $per_page_record);
	if ($total_page < 2)
		return null;

	$start = ($pageno > LIST_SHOW_PREV_NEXT_PAGES) ? ($pageno -LIST_SHOW_PREV_NEXT_PAGES) : 1;
	$end = $start +LIST_SHOW_PREV_NEXT_PAGES * 2;
	if ($end > $total_page)
		$end = $total_page;

	$arr['首页'] = 1;
	$arr['上页'] = ($pageno > 1) ? ($pageno -1) : 1;
	for ($i = $start; $i <= $end; $i++) {
		if ($i == $pageno)
			$arr["<font color=red>{$i}</font>"] = $i;
		else
			$arr[$i] = $i;
	}
	$arr['下页'] = ($pageno < $total_page) ? ($pageno +1) : $total_page;
	$arr['末页'] = $total_page;

	return $arr;
}

/**
 * 查询数据库记录总数
 */
function getRecordCount($tablename, $where = '') {
	global $db;
	$sql = "SELECT COUNT(*) as c FROM `{$tablename}` ";
	
	if (!empty ($where))
		$sql .= " WHERE  " . $where;
	
	$row= $db->fetchOne($sql);
	return $row['c'];
}

/**
 * 分页取数据
 * 参数是:  表名， 条件， 页数(从1开始)， 排序字段(可多个字段)，每页多少个记录
 */
function getList($tablename, $where, $pageno = 1, $order = "id", $per_page_record = LIST_PER_PAGE_RECORDS, & $counts) {
	global $db;
	$sql = SqlSelectClass :: getInstance($tablename, true, true)->select('*')->where($where)->orderby($order)->limit(SqlFuncHelperClass :: calcLimitOffset($pageno, $per_page_record), $per_page_record)->createSql();
	$rowset = $db->fetchAll($sql);
	
	$counts = GFetchRowOne('SELECT FOUND_ROWS() as counts;');
	$counts = $counts['counts'];
			
	return $rowset;
}


