<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
</head>
<body style="margin:0">
<b>个人副本通关统计</b>
<div class='divOperation'>
	<form action="#" method="POST" id="frm">
	<table style="margin:5px;">
		<tr>
			<td>开始日期：<input type="text" size="12" name="startDate" id="startDate" value="<{$startDate}>"><img onclick="WdatePicker({el:'startDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="12" name="endDate" id="endDate" value="<{$endDate}>"><img onclick="WdatePicker({el:'endDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrToday}>&amp;endDate=<{$dateStrToday}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrPrev}>&amp;endDate=<{$dateStrPrev}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrNext}>&amp;endDate=<{$dateStrNext}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$serverOnLineTime}>&amp;endDate=<{$dateStrToday}>';">

			</td>
		</tr>
	</table>
	</form>
<div class='boss_state' width='50%'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' width="50%">
		<tr class='table_list_head'>
			<td  width="5%">关口</td>
			<td  width="10%">总人数人次</td>
			<td  width="10%">云州（人数/人次）</td>
			<td  width="10%">幽州（人数/人次）</td>
			<td  width="10%">沧州（人数/人次）</td>
		</tr>
		<{foreach from=$rsPersonalFB item=row key=key}>
		<{if $key%2==0}>
		<tr class="odd">
		<{else}>
		<tr>
		<{/if}>
			<td><{$row.fb_id}></td>
			<td><{$row.scount}></td>
			<td><{$row.hwrcrs}></td>
			<td><{$row.ylrcrs}></td>
			<td><{$row.wlrcrs}></td>
		</tr>
		<{/foreach}>
	</table>
	<div>
</div>
</body>
</html>