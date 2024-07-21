<?php


/*
 * Created on Oct 26, 2010
 *
 * 玩家信息类
 */
if (!defined('INCLUDE_CLASS_USER_CLASS_PHP_FILE')) {
	define('INCLUDE_CLASS_USER_CLASS_PHP_FILE', 1);
	class UserClass {
		
		/**
		 * 根据角色名获取玩家ID
		 */
		public static function getUseridByRoleName($roleName) {
			$sql = "select role_id from db_role_base_p where BINARY role_name='" . SS($roleName) . "'";
			$rs = GFetchRowOne($sql);
			
			if (! isset($rs['role_id']) )
				return - 1;
			
			return intval($rs['role_id']);
		}
		
		public static function isFcmPassed($accountName){
			$sql = "select passed from db_fcm_data_p where account='" . SS($accountName) . "'";
			$rs = GFetchRowOne($sql);
			if (!isset($rs['passed']) )
				return false;
			return $rs['passed'];
		}
		
		/**
		 * 根据角色ID获取角色名称
		 */
		public static function getRoleNameByRoleId($roleId) {
			$sql = "select role_name from db_role_base_p where role_id='" . SS($roleId) . "'";
			$rs = GFetchRowOne($sql);
			if (!isset($rs['role_name']) )
				return "";
			return $rs['role_name'];
		}
		
		public static function getUseridByAccountName($accountName) {
			$sql = "select role_id from db_role_base_p where BINARY account_name='" . SS($accountName) . "'";
			$rs = GFetchRowOne($sql);
			
			
			if (! isset($rs['role_id']) )
				return - 1;
			
			return intval($rs['role_id']);
		}
		
		/**
		 * 根据ID获取玩家的装备
		 */
		public static function getUserEquips($RoleId){
			return  getJson ( ERLANG_WEB_URL ."/user?fun=getUserEquips&arg=$RoleId" );
		}
		
		/**
		 * 根据ID获取玩家的服饰
		 */
		public static function getUserSkin($RoleId){
			return  getJson ( ERLANG_WEB_URL . "/user?fun=getUserSkin&arg=$RoleId" );
		}
		
		/**
		 * 根据ID获取玩家背包里的所有物品
		 */
		public static function getBagGoods($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getBagGoods&arg=$RoleId" );
		}
		
		/**
		 * 根据玩家ID获取对应的摆摊物品
		 */
		public static function getStallGoods($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getStallGoods&arg=$RoleId" );
		}
		
		/**
		 * 根据ID获取玩家位置信息
		 */
		public static function getRolePos($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getRolePos&arg={$RoleId}" );
		}
		
		/**
		 * 根据ID获取玩家战斗信息
		 */
		public static function getRoleFight($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getRoleFight&arg={$RoleId}" );
		}
		
		/**
		 * 根据ID获取玩家BUFF信息
		 */
		public static function getRoleBase($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getRoleBase&arg={$RoleId}" );
		}
		
		/**
		 * 根据ID获取玩家宠物背包信息
		 */
		public static function getRolePetBag($RoleId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getRolePetBag&arg={$RoleId}" );
		}
		
		/**
		 * 根据ID获取玩家宠物背包信息
		 */
		public static function getPetInfo($PetId){
			return getJson ( ERLANG_WEB_URL . "/user?fun=getPetInfo&arg={$PetId}" );
		}
		
		/**
		 * 按角色名、帐号名或ID查找玩家
		 *
		 * @param string $roleName
		 * @param string $accountName
		 * @param int $roleId
		 * @return array
		 */
		public static function getUser($roleName='',$accountName='',$roleId=false) {
			$roleId = intval($roleId);
			$roleName = SS( trim( $roleName ) );
			$accountName = SS( trim( $accountName ) );
			$where = '';
			if ($roleId) {
				$where = " `role_id`={$roleId}";
			}elseif($roleName){
				$where = $roleName ?  " `role_name`='{$roleName}'" : '';
			}elseif ($accountName){
				$where .= $accountName ?  " `account_name`='{$accountName}'" : '';
			}else {
				return false;
			}
			
			$sql = "select `role_id`,`role_name`,`account_name`,`create_time` from db_role_base_p where ".$where;
			$rs = GFetchRowOne($sql);
			
			if (! isset($rs['role_id']) )
				return false;
			$result = array(
				'role_id' => $rs['role_id'],
				'role_name' => $rs['role_name'],
				'account_name' => $rs['account_name'],
				'create_time' => $rs['create_time'],
			);
			return $result;
		}
		
	}
}
?>
