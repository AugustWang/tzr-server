<?php
if (!defined('INCLUDE_CLASS_MAP_CLASS_PHP_FILE')) {
	define('INCLUDE_CLASS_MAP_CLASS_PHP_FILE', 1);

	/**
	 * 接口: getList, ban, unban
	 */
	class MapClass {
		
		/**
		 * 获取地图的ID和名称的映射列表
		 */
		public static function getMapList() {
			$sql = "SELECT  `map_id`, `map_name` FROM `t_map_list` ";
			$rs = GFetchRowSet($sql);
			
			$arr = array();
			foreach ($rs as &$row) {
				$arr[$row['map_id']] = $row['map_name'];
			}
			return $arr;
		}
		
		/**
		 * 获取门派ID和门派名称的映射关系
		 */
		public static function getFamilyNameList() {
			$sql = "SELECT  `family_id`, `family_name` FROM `t_family_summary` ";
			$rs = GFetchRowSet($sql);
			
			$arr = array();
			foreach ($rs as &$row) {
				$arr[$row['family_id']] = $row['family_name'];
			}
			return $arr;
		}
		
	}
}