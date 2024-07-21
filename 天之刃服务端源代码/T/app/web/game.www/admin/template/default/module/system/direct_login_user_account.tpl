<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/js/jquery.min.js"></script>
<title>直接登录帐号</title>
</head>

<body style="margin:10px">

<h4>直接登录玩家帐号</h4>


<form name="myform" method="post" target='_blank' action="<{$URL_SELF}>">
	<input type='hidden' name='action' value='login' />
	请输入要登录的帐号：<input type='text' name='account' size='15' value='' />
	&nbsp;&nbsp;&nbsp;&nbsp;或角色名：<input type='text' name='role_name' size='15' value='' />
	&nbsp;&nbsp;
	<input type='submit' name='submit' value='直接登录' />

</form>

<br/><br/><br/>
<font color='red'>千万不要乱来哦，登录前，记得请GM先跟玩家说明，让玩家自己下线先。</font>

<br/><br/><br/>
<hr>
<br>

<h4>模拟平台登录帐号</h4>


<form name="myform" method="post" target='_blank' action="<{$URL_SELF}>">
	<input type='hidden' name='action' value='start' />
	请输入想要模拟登录的帐号：<input type='text' name='account' size='15' value='' />
	&nbsp;&nbsp;
	<{if $MIX_SYSTEM_OPEN}>
	平台选择：<select name="account_pre">
		<option value="">默认（acname）</option>
	<{foreach key=SID item=SERVICE from=$MIX_SERVICE}>
		<option value="<{$SID}>"><{$SID}></option>
	<{/foreach}>
	<{/if}>
	<input type='submit' name='submit' value='模拟登录' />
	<br/><br/>
	为防止和玩家帐号冲突，本功能会自动帮你加上帐号名前缀acname<br>
	本功能主要为于安装服务器后，安装人员测试一下系统是否安装正常。<br/>
	可以通过本功能直接测试，不用去代理商平台那里注册帐号，登录，选服。

</form>

<br/><br/><br/>


</body>
</html>