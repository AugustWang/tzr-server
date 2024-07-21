<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script language="javascript">

</script>



<style>
.l_align{
display:inline:
	float:left;
	width:70px;	
}

.t_align{
display:inline:
	float:left;
	width:220px;	
}
</style>

<title>个人拉镖</title>
</head>

<body>
<b>玩家管理：个人拉镖</b><br />
<div style="padding:5px;">

</div>
<span>
<form action="personal_ybc_log.php" method="POST" >
<div>
        账号名:<input type="text" name="accountName" value="<{$accountName}>" id="accountName">
        角色名:<input type="text" name="roleName" value="<{$roleName}>" id="roleName">&nbsp;&nbsp;
输入日期:<input type="text" name="date" id="date" value="<{$date}>">
<img onclick="WdatePicker({el:'date'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle" />
</div>
</form>

<form action="personal_ybc_log.php" method="post" class="l_align" style="display:inline;float:left;">
	<input type="hidden" name="date" value="<{$today}>"></input>
	<input type="hidden" name="roleName" value="<{$roleName}>"></input>
	<input type="submit" name="btn" value="今天"></input>
</form>


<form action="personal_ybc_log.php" method="post" class="l_align" style="display:inline;float:left;">
	<input type="hidden" name="date" value="<{$preDay}>"></input>
	<input type="hidden" name="roleName" value="<{$roleName}>"></input>
	<input type="submit" name="btn" value="前一天:"></input>
</form>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<form action="personal_ybc_log.php" method="post" class="t_align" style="display:inline;float:left;">
	<input type="hidden" name="date" value="<{$nextDay}>"></input>
	<input type="hidden" name="roleName" value="<{$roleName}>"></input>
	<input type="submit" name="btn" value="后一天:"></input>
</form>



<table class="DataGrid">
  <tr>
    <th>角色ID</th>
    <th>角色名</th>
    <th>开始时间</th>
    <th>镖车颜色</th>
    <th>最终状态</th>
    <th>结束时间</th>
  </tr>
  <{ foreach from=$result item=item key=key }>
	<{if $key % 2 == 0}>
  <tr align="center" class='odd'>
	<{else}>
  <tr align="center">
	<{/if}>
   		<td><{$item.role_id}></td>
   		<td><{$item.role_name}></td>
   		<td><{$item.start_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
   		<td><{$item.color}></td>
   		<td><{$item.state}></td>
   		<td><{$item.end_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
  </tr>
  <{/foreach}>
</table>

</form>
<br>
</table>

</body>
</html>
