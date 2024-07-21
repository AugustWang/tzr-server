<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<title>
	当前在线玩家列表
</title>
</head>



<body style="margin:0">
<b>在线与注册：当前在线用户</b>
<span id='user_list'></span>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

<!--
&nbsp;排序
<select name="sort_1">
	<{html_options options=$sortoption selected=$search_sort_1}>
</select>

<select name="sort_2">
	<{html_options options=$sortoption selected=$search_sort_2}>
</select>



					<input type="image" src="../images/search.gif" class="input2"  />
-->

&nbsp;&nbsp;&nbsp;&nbsp;
<a href='#user_list'>当前在线玩家数：<{$record_count}></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='#ip_list'>当前在线的不同IP数：<{$ip_count}></a>

				</form>
</div>


<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$data}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td >用户ID</td><td >角色名</td>
		<td >登录帐号名</td><td >当前已在线时间（分钟）</td>
		<td>国家</td><td>IP</td><td>分线端口</td>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
		<td>
		<{$data[loop].role_id}>
		</td><td>
		<{$data[loop].role_name}>
		</td><td>
		<{$data[loop].account_name}>
		</td><td>
		<{if $data[loop].real_online_time == 0}>
	       0
	    <{else}>
	       <{$data[loop].real_online_time/60|string_format:"%.0f"}>
	    <{/if}>
		</td><td>
        <{$data[loop].faction_name}>
        </td><td>
		<{$data[loop].login_ip}>
		</td>
		<td>
        <{$data[loop].line}>
        </td>
	</tr>
<{sectionelse}>

<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

<br/>
<span id='ip_list'></span><br/>
&nbsp;&nbsp;&nbsp;&nbsp;
<a href='#user_list'>当前在线玩家数：<{$record_count}></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href='#ip_list'>当前在线的不同IP数：<{$ip_count}></a>

<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
	<tr class='table_list_head'>
		<td>IP地址</td><td >相同IP在线人数</td><td >角色名</td><td >登录帐号名</td><td>&nbsp;</td>
	</tr>
<{foreach item=item key=ip from=$iplist}>
	<tr class='trEven'>
		<td>
		<{$ip}>
		</td><td>
		<{$item.count}>
		</td><td>
		<{$item.nickname_list}>
		</td><td>
		<{$item.accname_list}>
		</td><td>
		<a href='http://www.ip138.com/ips.asp?ip=<{$ip}>' target='_blank'>IP地理位置</a>
		</td>
	</tr>
<{/foreach}>
</table>

</div>

</body>
</html>