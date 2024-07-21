<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style type="text/css">
#all {
	text-align: left;
	margin-left: 4px;
	line-height: 1;
}

#nodes {
	width: 100%;
	float: left;
	border: 1px #ccc solid;
}

#result {
	width: 100%;
	height: 100%;
	clear: both;
	border: 1px #ccc solid;
}
</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
</script>
</head>

<body>
<div id="all">
<div id="main">
<!--start 查找玩家-->
<b>玩家：查看玩家任务状态</b><br>
<form action="?action=search" style="margin:20px;" method="POST">
	<span style='margin-right:20px;'>角色ID: <input type='text' id='role_id' name='role_id' size='11' value='<{ $role.role_id }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_name').value ='';" /></span>
	<span style='margin-right:20px;'>登录帐号: <input type='text' id='account_name' name='account_name' size='12' value='<{ $role.account_name }>' onkeydown="document.getElementById('role_name').value =''; document.getElementById('role_id').value ='';" /></span>
	<span style='margin-right:20px;'>角色名: <input type='text' id='role_name' name='role_name' size='12' value='<{ $role.role_name }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';" /></span>
	<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
</form>
<!--end 查找玩家-->

<{ if $role.role_id }>
<table class="DataGrid">
  <tr>
    <th>任务ID</th>
    <th>任务名称</th>
    <th>类型</th>
    <th>状态</th>
    <th>总次数</th>
    <th>时间</th>
    <th>玩家等级</th>
  </tr>
 <{section name=i loop=$tasks}>
  <{if $smarty.section.i.rownum % 2 == 0}>
   <tr class='odd'>
	<{else}>
   <tr>
   <{/if}>
    <td><{$tasks[i].mission_id}></td>
    <td><{$tasks[i].mission_name}></td>
    <td><{$tasks[i].mission_type_name}></td>
    <td><{$tasks[i].status_name}></td>
    <td><{$tasks[i].total}></td>
    <td><{$tasks[i].mtime}></td>
    <td><{$tasks[i].level}></td>
  </tr>
  <{sectionelse}>
	<tr>
 		<td colspan="6">无数据</td>
 	</tr>
<{/section}>
 	
</table>
<{ /if }>
<{ if $err }>
     <table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
        <tr bgcolor="#FFFFFF"> 
            <td align="center">
            	<font color="red"><b><{ $err }></b></font>
            </td>
        </tr>
     </table>
<{ /if }>
</div>
</div>
</body>
</html>
