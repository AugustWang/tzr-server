<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>玩家刺探任务查询</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>玩家管理:国探任务统计</b>
<form id="myform" method="POST" action="<{$URL_SELF}>">
<table cellpadding="5" cellspacing="1" class="SumDataGrid">
	<tr>
		<td>开始日期:<input type="text" name="dateStart" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"  value="<{$dateStart}>" /></td>
		<td>结束日期:<input type="text" name="dateEnd" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'});"  value="<{$dateEnd}>" /></td>
		<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		<td><input type="button"  name="dateYestoday" value="昨天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateYestoday}>&dateEnd=<{$dateYestoday}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button"  name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$datePrev}>&dateEnd=<{$datePrev}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button"  name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateNext}>&dateEnd=<{$dateNext}>&role_name=<{$role_name}>';">
</td>
		<td><input type="button" name="dateAll" value="从开服至昨天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$serverOnLineDate}>&dateEnd=<{$dateYestoday}>&role_name=<{$role_name}>';">
</td>
	</tr>
</table>
</form>

<{if $strMsg}><div style="color:red; padding:10px;border:1px solid #CCC;"><{$strMsg}></div><{/if}>
<br/>
<div>
<table cellspacing="1" class="DataGrid">
	<tr>
		<th>国探日期</th>
		<th>活跃人数</th>
		<th>参与人数</th>
		<th>参与人数/活跃人数</th>
		<th>参与1次的人数</th>
		<th>参与2次的人数</th>
		<th>参与3次的人数</th>
		<th>参与4次的人数</th>
	</tr>
	<{foreach from=$result item=row key=key}>
	<{if $key%2==0}>
	<tr class="odd">
	<{else}>
	<tr>
	<{/if}>
		<td><{$row.mdate}></td>
		<td><{$row.active}></td>
		<td><{$row.join_all}></td>
		<td><{$row.join_all_rate}>%</td>
		<td><{$row.join_1}></td>
		<td><{$row.join_2}></td>
		<td><{$row.join_3}></td>
		<td><{$row.join_4}></td>
	</tr>
	<{/foreach}>
</table>
</div>


</body>
</html>
