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
	充值与消费：按月统计
	<form action="#" method="POST" id="frm">
	<table style="margin:20px;">
		<tr>
			<td>开始月分：<input type="text" size="10" class="Wdate" name="dateStart" id="dateStart" onfocus="WdatePicker({dateFmt:'yyyy-MM'})" value="<{ $dateStart }>"></td>
			<td>结束月份：<input type="text" size="10" class="Wdate" name="dateEnd" id="dateEnd" onfocus="WdatePicker({dateFmt:'yyyy-MM'})"  value="<{ $dateEnd }>"></td>
			<td>
			<select name="showType" id="showType">
				<{html_options options=$arrShowType selected=$showType}>
			</select>
			</td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="本月" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="上个月" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="下个月" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrOnline}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>';">
			</td>
		</tr>
	</table>
	</form>
	
	<{ if $payMonths }>
	  从 <{ $dateStart }> 到 <{ $dateEnd }> 总共充值：￥<{ $allTotalMoney }> ，单月最高充值：￥<{ $maxMoney }>， 每月平均充值：￥<{ $avgMoney }>，单月充值人数最多：<{$maxPerson}>，单月ARPU值最高：<{$maxArpu}>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
		<{if 9 == $showType}>
			<tr>
				<th>月份</th>
				<{ foreach from=$payMonths item=row key=key }>
					<th align="center" style="padding:0px 5px;"><{ $key }></th>
				<{ /foreach }>
			</tr>
		<{/if}>
		<{if 9 == $showType || 1 == $showType }>
			<tr>
				<th>金额(￥)</th>
				<{ foreach from=$payMonths item=row key=key }>
					<td align="center" height="150" valign="bottom"><{ if 0==$maxMoney }>0<hr title="<{$row.tip}>" class="hr_green" style="hight:0px;"><{ else }><{ $row.total_money }><hr title="<{$row.tip}>" class="<{if $row.total_money/$maxMoney >= 0.75}>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.total_money*120/$maxMoney|round }>px;" /><{ /if }></td>
				<{ /foreach}>
			</tr>
		<{/if}>
		<{if 9 == $showType || 2 == $showType }>
			<tr>
				<th style="color:#FF6600"><b>人数</b></th>
				<{ foreach from=$payMonths item=row key=key }>
					<td align="center" height="150" valign="bottom"><{ if 0==$maxPerson }>0<hr title="<{$row.tip}>" class="hr_green" style="hight:0px;"><{ else }><{ $row.total_person }><hr title="<{$row.tip}>" class="<{if $row.total_person/$maxPerson >= 0.75}>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.total_person*120/$maxPerson|round }>px;" /><{ /if }></td>
				<{ /foreach}>
			</tr>
		<{/if}>	
		<{if 9 == $showType || 3 == $showType }>
			<tr>
				<th style="color:#4D4DB3"><b>人次</b></th>
				<{ foreach from=$payMonths item=row key=key }>
					<td align="center" height="150" valign="bottom"><{ if 0==$maxPersonTime }>0<hr title="<{$row.tip}>" class="hr_green" style="hight:0px;"><{ else }><{ $row.total_person_time }><hr title="<{$row.tip}>" class="<{ if $row.total_person_time/$maxPersonTime >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.total_person_time*120/$maxPersonTime|round }>px;" /><{ /if }></td>
				<{ /foreach}>
			</tr>
		<{/if}>	
		<{if 9 == $showType || 4 == $showType }>			
			<tr>
				<th>ARPU值</th>
				<{ foreach from=$payMonths item=row key=key }>
					<td align="center" height="150" valign="bottom"><{ if 0==$maxArpu }>0<hr title="<{$row.tip}>" class="hr_green" style="hight:0px;"><{ else }><{ $row.arpu }><hr title="<{$row.tip}>" class="<{if $row.arpu/$maxArpu >= 0.75}>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.arpu*120/$maxArpu|round }>px;" /><{ /if }></td>
				<{ /foreach}>
			</tr>
		<{/if}>
			<tr>
				<th>月份</th>
				<{ foreach from=$payMonths item=row key=key }>
					<th align="center" style="padding:0px 5px;"><{ $key }></th>
				<{ /foreach }>
			</tr>
		</table>
	<{ else }>
		  <{ $dateStart }> 至 <{ $dateEnd }> 没有人充值
	<{ /if }>
</body>
</html>