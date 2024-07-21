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
			<td>国家：
				<select name="faction" id="faction" >
					<option value="0">全部</option>
					<{html_options options=$arrFaction selected=$faction}>
				</select>
			</td>
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
	
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th colspan="<{$firstCnt+1}>">从 <{$startDate}> 到 <{$endDate}><br>首次获得宠物的玩家数量 按玩家等级分布情况:<br/>
			最高：<{$maxFirst}>；最低：<{$minFirst}>
			</th>
		</tr>
		<tr>
			<th width="100" height="160">数量<br/>（百分比）</th>
			<{foreach from=$arrFirst item=row key=key}>
			<td align="center" valign="bottom"><{$row.total_person}><br />(<{$row.rate}>%)<hr class="<{if $maxFirst >0 &&$row.total_person/$maxFirst >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{$row.rate*1.2}>px;" /></td>
			<{/foreach}>
		</tr>
		<tr>
			<th width="100">玩家等级</th>
			<{foreach from=$arrFirst item=row key=key}>
			<td align="center"><{$row.role_level}></td>
			<{/foreach}>
		</tr>
	</table>
	
	<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th colspan="<{$diaoLuoCnt+1}>">从 <{$startDate}> 到 <{$endDate}><br>使用宠物召唤符统计:<br/>
			最高：<{$maxDiaoLuo}>；最低：<{$minDiaoLuo}>
			</th>
		</tr>
		<tr>
			<th width="100" height="160">数量<br/>（百分比）</th>
			<{foreach from=$arrDiaoLuo item=row key=key}>
			<td align="center" valign="bottom"><{$row.total_pet}><br />(<{$row.rate}>%)<hr class="<{if $maxDiaoLuo >0 &&$row.total_pet/$maxDiaoLuo >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{$row.rate*1.2}>px;" /></td>
			<{/foreach}>
		</tr>
		<tr>
			<th width="100">宠物类型</th>
			<{foreach from=$arrDiaoLuo item=row key=key}>
			<td align="center"><{$row.pet_type_str}></td>
			<{/foreach}>
		</tr>
	</table>
	
</body>
</html>