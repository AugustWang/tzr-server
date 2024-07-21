
<?php
//$reply_id = $_POST['reply_id'];
//$role_id = $_POST['role_id'];
//$content = $_POST['content'];
//file_put_contents('/tmp/log.log',"\n data of _POST=".print_r($_POST,true)."\n",FILE_APPEND);
//curlPost($_POST,'http://127.0.0.1:8000/GmReply');
$dataPost = $_POST;
$keyVector = '#2A1!&JKOP(YQ*HTREX$WQ=EP'; //密钥（同中央后台GM回复接口对接）
$params = '';
$url = 'http://127.0.0.1:8000/GmReply';
$postKey = '';
foreach ($dataPost as $key => $val) {
	if ('key'==$key) {
		$postKey = $val;
	}else {
		$params .= '&'.$key.'='.$val;
	}
}
$params = trim($params,'&');
$key = md5($params.$keyVector);
if ($key != $postKey) {
	exit('key error');
}

$ch=curl_init();  
curl_setopt($ch,CURLOPT_URL,$url);
curl_setopt($ch,CURLOPT_RETURNTRANSFER,1);  
curl_setopt($ch,CURLOPT_POST,1);  
curl_setopt($ch,CURLOPT_POSTFIELDS,$params);  
$dataResp=curl_exec($ch);
curl_close($ch);
echo $dataResp;
// 输出日志
// file_put_contents('/tmp/log.log',' /tmp/log.log  params= '.$params."\n url=".$url."\n data=".print_r($dataResp,true)."\n",FILE_APPEND);