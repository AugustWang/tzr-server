<?php
/*
 * created by yangyuqun@mingchao.com
 */
define(GET_BROADCAST_MSG,'admin/module/chat/get_broadcast_msg.php');//这里需要根据目标目录进行设置
define(BROADCAST_COPY_KEY,'#2A1!&JKOP(YQ*HTREX$WQ=EP'); //密钥（同游戏后台GM回复接口对接）
define(ERL_WEB_URL,'http://127.0.0.1:8000/broadcast/copy');

class  BroadcastCopyApi{
	static function curlPost($url,$params){
	if (!trim($params)) {
		return false;
	}
	$ch=curl_init();  
	curl_setopt($ch,CURLOPT_URL,$url);
	curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
	curl_setopt($ch,CURLOPT_POST,1);
	curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
	$result = curl_exec($ch);
	//if($result){return true;}
	curl_close($ch);
	return $result;
}

/*
 * @ $msg -> 传递的消息
 * @ $url   -> 传递的url
 */
	static public function sendMsg($msg,$url){
		foreach ($msg as $key => $val) {
			$params .= '&'.$key.'='.$val;
		}
		$params = trim($params,'&');
		$key = md5($params.BROADCAST_COPY_KEY);
		$params .= '&key='.$key;
		$url.= GET_BROADCAST_MSG;
		$post = curlPost($url,$params);
		return $post;
	}
	static public function getMsg($msg){
		foreach ($msg as $key => $val) {
			if ('key'==$key) {
				$postKey = $val;
			}else {
				$params .= '&'.$key.'='.$val;
			}
		}
		$params = trim($params,'&');
		$key = md5($params.BROADCAST_COPY_KEY);
		if ($key != $postKey) {
			exit('key error');
		}
		$post = BroadcastCopyApi::curlPost(ERL_WEB_URL,$params);
		return $post;
	}
}

?>