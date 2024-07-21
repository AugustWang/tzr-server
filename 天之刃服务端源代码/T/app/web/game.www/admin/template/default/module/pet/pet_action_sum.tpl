<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#showType").change(function(){
			$("#frm").submit();
		});
	});
</script>
</head>

<body>
	<form action="#" method="POST" id="frm">
	<table style="margin:5px;">
		<tr>
			<td>开始日期：<input type="text" size="12" name="startDate" id="startDate" value="<{$startDate}>"><img onclick="WdatePicker({el:'startDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="12" name="endDate" id="endDate" value="<{$endDate}>"><img onclick="WdatePicker({el:'endDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>玩家角色名：<input type="text" name="role_name" id="role_name" value="<{$role_name}>" /></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrToday}>&amp;endDate=<{$dateStrToday}>&amp;role_name=<{$role_name}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrPrev}>&amp;endDate=<{$dateStrPrev}>&amp;role_name=<{$role_name}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrNext}>&amp;endDate=<{$dateStrNext}>&amp;role_name=<{$role_name}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$serverOnLineTime}>&amp;endDate=<{$dateStrToday}>&amp;role_name=<{$role_name}>';">
			</td>
		</tr>
	</table>
	</form>
	<hr />
	统计对象：<{if $role_name}>玩家【<{$role_name}>】<{else}>所有玩家<{/if}><hr />
	<div>
	<b>从 <{$startDate}> 到 <{$endDate}> 宠物相关操作按天统计 ：</b>
	</div>
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>&nbsp;</th>
			<{foreach from=$arrDate item=row key=date}>
			<th width="50"><span<{if 6==$date|date_format:"%w"}> style="color:red;"<{/if}>><{$date|date_format:"%m.%d"}></span></th>
			<{/foreach}>
		</tr>
		<{foreach from=$arrActionByDate item=rowDate key=date}>
		<tr>
			<th width="100">&nbsp;<{$rowDate.action_str}></th>
			<{foreach from=$rowDate.action_cnt item=cnt key=date}>
			<td><{if $cnt}><{$cnt}><{else}>&nbsp;<{/if}></td>
			<{/foreach}>
		</tr>
		<{/foreach}>
	</table>
	<br/>
	
	<div>
	<b>从 <{$startDate}> 到 <{$endDate}> 宠物学技能按天统计 ：</b>
	</div>
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>&nbsp;</th>
			<{foreach from=$arrDate item=row key=date}>
			<th width="50"><span<{if 6==$date|date_format:"%w"}> style="color:red;"<{/if}>><{$date|date_format:"%m.%d"}></span></th>
			<{/foreach}>
		</tr>
		<{foreach from=$arrActionDetailByDate item=rowDate key=date}>
		<tr>
			<th width="100">&nbsp;<{$rowDate.action_detail_str}></th>
			<{foreach from=$rowDate.action_detail_cnt item=cnt key=date}>
			<td><{if $cnt}><{$cnt}><{else}>&nbsp;<{/if}></td>
			<{/foreach}>
		</tr>
		<{/foreach}>
	</table>
	<br/>
	<hr />	
	<div>
	<b>从 <{$startDate}> 到 <{$endDate}> 宠物相关操作按时统计 ：</b>
	</div>
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>&nbsp;</th>
			<{foreach from=$arrHour item=row key=hour}>
			<th width="50"><{$hour}>时</th>
			<{/foreach}>
		</tr>
		<{foreach from=$arrActionByHour item=rowHour key=hour}>
		<tr>
			<th width="100">&nbsp;<{$rowHour.action_str}></th>
			<{foreach from=$rowHour.action_cnt item=cnt}>
			<td><{if $cnt}><{$cnt}><{else}>&nbsp;<{/if}></td>
			<{/foreach}>
		</tr>
		<{/foreach}>
	</table>

	<br/>
	<div>
	<b>从 <{$startDate}> 到 <{$endDate}> 宠物学技能按时统计 ：</b>
	</div>
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>&nbsp;</th>
			<{foreach from=$arrHour item=row key=hour}>
			<th width="50"><{$hour}>时</th>
			<{/foreach}>
		</tr>
		<{foreach from=$arrActionDetailByHour item=rowHour key=hour}>
		<tr>
			<th width="100">&nbsp;<{$rowHour.action_detail_str}></th>
			<{foreach from=$rowHour.action_detail_cnt item=cnt}>
			<td><{if $cnt}><{$cnt}><{else}>&nbsp;<{/if}></td>
			<{/foreach}>
		</tr>
		<{/foreach}>
	</table>
</body>
</html>