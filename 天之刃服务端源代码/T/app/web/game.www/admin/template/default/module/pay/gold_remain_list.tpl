<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
	玩家的当前拥有元宝排行
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#goldType").change(function(){
			$("#frm").submit();
		});
	});
</script>

</head>

<body style="margin:0; padding:20px;">
<b>充值与消费：玩家当前元宝排行</b><br><br>

<div>
<form id="frm"  method="post" action="<{$URL_SELF}>">
	元宝类型：
	<select name="goldType" id="goldType">
	<{html_options options=$goldTypes selected=$goldType}>
	</select>
<b>注：</b><font color="red">只列出元宝余额大于100的玩家<!--，点击角色名、账号名可以直接查看该玩家的元宝使用记录--></font>
</form>
</div>
<div>
<{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?goldType=<{$type}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
<table cellspacing="1" class="DataGrid" width="800">
<!-- SECTION  START -------------------------->
<{section name=loop loop=$rs}>
	<{if $smarty.section.loop.rownum % 50 == 1}>
	<tr>
		<th>排名</th>
		<th>角色名</th>
		<th>帐号名</th>		
		<th>元宝余额</th>
		<{if 0==$goldType }>
		<th>元宝余额</th>
		<th>绑定元宝余额</th>
		<{/if}>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr>
	<{else}>
	<tr class='odd'>
	<{/if}>
			<td>
			<{$smarty.section.loop.rownum+$offset}>
			</td>
			<td><{*<a href="<{SYSDIR_ADMIN}>/admin/pay/gold_use_log_view.php?nickname=<{$rs[loop].nickname}>">*}>
			<{$rs[loop].role_name}><{*</a>*}>
			</td><td><{*<a href="<{SYSDIR_ADMIN}>/admin/pay/gold_use_log_view.php?acname=<{$rs[loop].AccountName}>">*}>
			<{$rs[loop].account_name}><{*</a>*}>
			</td>
			<td><{$rs[loop].golds}></td>	
			<{if 0==$goldType }>
			<td><{$rs[loop].unbind_gold}></td>	
			<td><{$rs[loop].bind_gold}></td>	
			<{/if}>
	</tr>
<{sectionelse}>
<tr><td>暂时没有排行数据</td></tr>
<{/section}>
</table>
<{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?goldType=<{$goldType}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
</div>
<br>

</body>
</html>