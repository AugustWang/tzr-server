<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style type="text/css">
	.hr_red{
		background-color:red;
		width:6px;
	}
</style>
</head>

<body>
	充值与消费：玩家充值排行
	
	<table class="DataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>排序</th>
			<th>帐号</th>
			<th>角色ID</th>
			<th>角色名</th>
			<th>总充值</th>
			<th>单次最少</th>
			<th>单次最多</th>
			<th>平均</th>
			<th>总充值次数</th>
			<th>最后一次充值时间</th>
			<th>报警</th>
		</tr>
		
	<{ foreach from=$rankList item=row key=key }>
		<tr<{ if 0==$row.rank_no%2 }> class="odd"<{ /if }>>
			<th><{ $row.rank_no }>&nbsp;</th>
			<td><{ $row.account_name }>&nbsp;</td>
			<td><{ $row.role_id }>&nbsp;</td>
			<td><{ $row.role_name }>&nbsp;</td>
			<td><{ $row.total }>&nbsp;</td>
			<td><{ $row.min_pay }>&nbsp;</td>
			<td><{ $row.max_pay }>&nbsp;</td>
			<td><{ $row.avg_pay }>&nbsp;</td>
			<td><{ $row.times }>&nbsp;</td>
			<td><{ $row.max_pay_time|date_format:"%Y-%m-%d %H:%M:%S" }>&nbsp;</td>
			<td style="color:red;"><{if $row.diff_day >= 3 }><{$row.diff_day}>天未登录<{/if}>&nbsp;</td>
		</tr>
	<{ /foreach}>
	</table>
	<div style="padding:10px;">
		<{foreach key=key item=item from=$page_list}>
		 <a href="<{$URL_SELF}>?page=<{ $item }>"><span style="padding:3px;"><{ $key }></span></a>
		 <{/foreach}>
	</div>
</body>
</html>