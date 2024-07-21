<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>管理后台用户</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
</head>

<body style="margin:10px">

<b> 后台管理 >> 用户列表</b>

<div class='divOperation'>
	<input type='button' class='button' value='添加' onclick="javascript:location.href='<{$URL_SELF}>?action=add';" />
</div>

<table cellspacing="1" cellpadding="3" border="0" class='table_list' style='width:auto;' >
<{section name=loop loop=$enum}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td width='40px' align="center">操作</td>
		<td width='20px' align="center">ID</td>
		<td width='60px' align="center">用户名</td>
		<td align="center">备注</td>
		<td>组</td>
	</tr>
	<{/if}>
	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
		<td align="center">
			<{if $action=='del'}>
			<a style="color:red;" href='<{$URL_SELF}>?action=del_submit&id=<{$enum[loop].uid}>&username=<{$enum[loop].username}>' onclick="javasrcipt:return confirm('确认要删除吗？删除不可修复');"> 删除 </a>
			<{else}>
			<a style="color:blue;" href='<{$URL_SELF}>?action=modify&id=<{$enum[loop].uid}>&username=<{$enum[loop].username}>' > 修改 </a>
			<{/if}>
		</td>
		<td align="center">
			<{$enum[loop].uid}>
		</td>
		<td align="center">
			<{$enum[loop].username}>
		</td>
		<td align="center">
			<{$enum[loop].comment}>
		</td>
		<td>
			<{$enum[loop].groupname}>
		</td>
	</tr>
<{/section}>
</table>

</body>
</html>