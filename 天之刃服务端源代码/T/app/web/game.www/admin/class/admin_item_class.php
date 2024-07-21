<?php

if ( ! defined('ADMIN_CLASS_ADMIN_ITEM_CLASS_PHP_FILE') )
{
	define('ADMIN_CLASS_ADMIN_ITEM_CLASS_PHP_FILE', 1);
	
	class AdminItemClass{
		
		function __construct(){
		}
		
		function __destruct(){
		}
		
		/**
		 * 获取所有道具的ItemTypeID-ItemName的映射列表
		 */
		public static function getItemMap() {
			$sql = "SELECT  `typeid`, `item_name` FROM `". T_ITEM_LIST ."` ";
			$rs = GFetchRowSet($sql);
			
			$arr = array();
			foreach ($rs as &$row) {
				$arr[$row['typeid']] = "【". $row['item_name'] ."】";
			}
			return $arr;
		}
		
		/**
		 * 获取所有的道具列表（包括道具、宝石、装备）
		 */
		public static function getItemList() {
			$sql = "SELECT  `typeid`, `type`, `item_name`, `sell_price`, `is_overlap` FROM `". T_ITEM_LIST ."` ";
			$rs = GFetchRowSet($sql);
			
			return $rs;
		}
		
		/**
		 * 根据名称获取对应的道具
		 */
		public static function getItemByName($item_name) {
			$sql = "SELECT  `typeid`, `type`, `item_name`, `sell_price`, `is_overlap` FROM `". T_ITEM_LIST ."` " .
				" where `item_name` like '%" .SS($item_name). "%'";
			$rs = GFetchRowSet($sql);
			
			return $rs;
		}
		
		/**
		 * 根据typeid获取对应的道具
		 */
		public static function getItemByTypeid($typeid) {
			$sql = "SELECT  `typeid`, `type`, `item_name`, `sell_price`, `is_overlap` FROM `". T_ITEM_LIST ."` " .
				" where `typeid` = '{$typeid}' ";
			$rs = GFetchRowOne($sql);
			return $rs;
		}
		
		public static function getItemHash($witdIdPre=false,$withAll=false)
		{
			$sql = "SELECT  `typeid`, `item_name`  FROM `". T_ITEM_LIST ."` ";
			$rs = GFetchRowSet($sql);
			$arr = array();
			if ($withAll) {
				$arr[0] = '显示全部';
			}
			if ($witdIdPre) {
				foreach ($rs as &$row) {
					$arr[$row['typeid']] = $row['typeid'].'--'.$row['item_name'];
				}
			}else {
				foreach ($rs as &$row) {
					$arr[$row['typeid']] = $row['item_name'];
				}
			}
			return $arr;
		}
	}
}
