<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>玩家刺探任务查询</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>玩家管理:玩家刺探任务查询</b>
<form id="myform" method="POST" action="<{$URL_SELF}>">
<table cellpadding="5" cellspacing="1" class="SumDataGrid">
	<tr>
		<td>开始日期:<input type="text" name="dateStart" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"  value="<{$dateStart}>" /></td>
		<td>结束日期:<input type="text" name="dateEnd" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"  value="<{$dateEnd}>" /></td>
		<td>角色名:<input type="text" name="role_name"  value="<{$role_name}>" /></td>
		<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		<td><input type="button"  name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateToday}>&dateEnd=<{$dateToday}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button"  name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$datePrev}>&dateEnd=<{$datePrev}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button"  name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateNext}>&dateEnd=<{$dateNext}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button" name="dateAll" value="从开服至今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$serverOnLineDate}>&dateEnd=<{$dateToday}>&role_name=<{$role_name}>';">
</td>
	</tr>
</table>
</form>

<{if $strMsg}><div style="color:red; padding:10px;border:1px solid #CCC;"><{$strMsg}></div><{/if}>
<br/>
<div>
<table cellspacing="1" class="DataGrid">
	<tr>
		<th>ID</th>
		<th>国家</th>
		<th>领取类型</th>
		<th>领取任务时间</th>
		<th>任务次数</th>
		<th>成功次数</th>
		<th>最终状态</th>
	</tr>
	<{foreach from=$result item=row key=key}>
	<{if $key%2==0}>
	<tr class="odd">
	<{else}>
	<tr>
	<{/if}>
		<td><{$row.id}></td>
		<td><{$row.faction_name}></td>
		<td><{$row.type}></td>
		<td><{$row.mdate}></td>
		<td><{$row.total}></td>
		<td><{$row.success}></td>
		<td><{$row.status}></td>
	</tr>
	<{/foreach}>
</table>
</div>

<div>
 <{foreach key=key item=item from=$pagelist}>
 	<span style="padding:2px;"><a href="<{$URL_SELF}>?dateStart=<{$dateStart}>&amp;dateEnd=<{$dateEnd}>&amp;role_name=<{$role_name}>&amp;page=<{$item}>"><{$key}></a></span>
 <{/foreach}>
</div>

</body>
</html>
