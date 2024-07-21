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

<title>国运管理</title>
</head>

<body>
<b>玩家管理：国运管理</b><br />
<div style="padding:5px;">

</div>
<span>
<form action="faction_trans.php" method="POST" >
	开始日期:<input type="text" name="start" id="start" value="<{$start}>">
	<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	(年年年年-月月-日日)
	
	结束日期:<input type="text" name="end" id="end" value="<{$end}>">
	<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	(年年年年-月月-日日)
	
	<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle" />
</form>
<input type="submit" name="btn" value="今天" onclick="window.location.href='faction_trans.php?start=<{$today}>&end=<{$today}>'" />&nbsp;&nbsp;
<input type="submit" name="btn" value="前一天" onclick="window.location.href='faction_trans.php?start=<{$prevDate}>&end=<{$prevDate}>'" />&nbsp;&nbsp;
<input type="submit" name="btn" value="后一天" onclick="window.location.href='faction_trans.php?start=<{$nextDate}>&end=<{$nextDate}>'" />

<table class="DataGrid">
  <tr>
    <th>日期</th>
    <th>活跃人数</th>
    <th>参与国运人数</th>
    <th>比例(活跃人数/参与国运人数)</th>
    <th>报名一次人数</th>
    <th>报名两次人数</th>
    <th>报名三次人数</th>
    <th>一次比例</th>
    <th>两次比例</th>
    <th>三次比例</th>
  </tr>
  
  
  
  <{foreach from=$arrResult item=item}>
  <{if $key % 2 == 0}>
  	<tr align="center" class='odd'>
  <{else}>
  	<tr align="center">
  <{/if}>
  		<td><{$item.date}></td>
  		<td><{$item.active}></td>
  		<td><{$item.gyrs}></td>
  		<td><{$item.active_rate}>%</td>
  		<td><{$item.one}></td>
  		<td><{$item.two}></td>  
  		<td><{$item.three}></td>
  		<td><{$item.one_rate}>%</td>
  		<td><{$item.two_rate}>%</td>
  		<td><{$item.three_rate}>%</td>
  </tr>
  <{/foreach}>
</table>

<br>
</table>

</body>
</html>
