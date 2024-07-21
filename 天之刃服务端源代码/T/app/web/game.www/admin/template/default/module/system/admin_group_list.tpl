<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>管理客服</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
</head>

<body style="margin:10px">

<div class='divOperation'>
	<input type='button' class='button' value='新增组' onclick="javascript:location.href='<{$URL_SELF}>?action=add';" />
</div>

<table cellspacing="1" cellpadding="3" border="0" class='table_list' style='width:auto;' >
<{section name=loop loop=$groups}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td width='70px' align="center">操作</td>
		<td width='50px' >组名</td>
		<td width='80px'>说明</td>
		<td>权限</td>
	</tr>
	<{/if}>
	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
		<td align="center">
			<a style="color:blue;" href='<{$URL_SELF}>?action=modify&id=<{$groups[loop].id}>' > 修改 </a>
			| <a style="color:red;" href='<{$URL_SELF}>?action=del_submit&id=<{$groups[loop].id}>}>' onclick="javasrcipt:return confirm('确认要删除吗？删除不可修复');"> 删除 </a>
		</td>
		<td>
			<{$groups[loop].name}>
		</td>
		<td>
			<{$groups[loop].comment}>
		</td>
		<td>
			<{$groups[loop].page_access_string}>
		</td>

	</tr>
<{/section}>
</table>

</body>
</html>