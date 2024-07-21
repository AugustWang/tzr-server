<?php
if (!defined('INCLUDE_CLASS_CHAT_BAN_CLASS_PHP_FILE')) {
	define('INCLUDE_CLASS_CHAT_BAN_CLASS_PHP_FILE', 1);

	/**
	 * 接口: getList, ban, unban
	 */
	class ChatBanClass {
		/**
		 * 返回当前被禁言的列表
		 */
		public static function getList() {
			$params = 'method=list';
			$url =	ERLANG_WEB_URL . "/ban/ban_chat" ;
			$ch=curl_init();  
			curl_setopt($ch,CURLOPT_URL,$url);
			curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
			curl_setopt($ch,CURLOPT_POST,1);
			curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
			$data = curl_exec($ch);
			if ( $data == ""){
				return array();
			}else{
				return json_decode($data,true);
			}
		}

		/**
		 * 玩家禁言
		 * duration: 分钟数, reason: 禁言理由
		 */
		public static function ban( $role_id, $role_name, $duration, $reason) {
			$params = 'method=ban';
			$url =	ERLANG_WEB_URL . "/ban/ban_chat" ;
			$params .= "&roleid={$role_id}&rolename={$role_name}&duration={$duration}&reason={$reason}";
			$ch=curl_init();  
			curl_setopt($ch,CURLOPT_URL,$url);
			curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
			curl_setopt($ch,CURLOPT_POST,1);
			curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
			$data = curl_exec($ch);
			$result = json_decode($data,true);
			return $result;
		}

		/**
		 * 解除禁言
		 */
		public static function unban($role_id) {
			$params = 'method=unban';
			$url =	ERLANG_WEB_URL . "/ban/ban_chat" ;
			$params .= "&roleid={$role_id}";
			$ch=curl_init();  
			curl_setopt($ch,CURLOPT_URL,$url);
			curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
			curl_setopt($ch,CURLOPT_POST,1);
			curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
			$data = curl_exec($ch);
			$result = json_decode($data,true);
			return $result;
		}

		/**
		 * 批量解除禁言
		 */
		public static function unbanArray($userid_arr) {
			
		    foreach($userid_arr as $role_id){
		    	ChatBanClass::unban($role_id);
		    }
		}
		
	}
}