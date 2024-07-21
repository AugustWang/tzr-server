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
	按天统计
	<form action="#" method="POST" id="frm">
	<table style="margin:20px;">
		<tr>
			<td>开始日期：<input type="text" size="12" name="dateStart" id="dateStart" value="<{ $dateStart }>"><img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="12" name="dateEnd" id="dateEnd" value="<{ $dateEnd }>"><img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>
			<select name="showType" id="showType">
				<{html_options options=$arrShowType selected=$showType}>
			</select>
			</td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&showType=<{$showType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrOnline}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>';">
			</td>
		</tr>
	</table>
	</form>
	
	<{ if $payDays }>
	  从 <{ $dateStart }> 到 <{ $dateEnd }> 总共充值：￥<{ $allTotalMoney }> ，单日最高充值：￥<{ $maxMoney }>， 每日平均充值：￥<{ $avgMoney }>，单日充值人数最多：<{$maxPerson}>，单日ARPU值最高：<{$maxArpu}>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<{if 9 == $showType}>
			<tr>
				<th>日期</th>
				<{ foreach from=$payDays item=row key=key }>
					<th align="center" style="padding:0px 5px;"><{ $key }></th>
				<{ /foreach }>
			</tr>
			<{/if}>
			<{if 9 == $showType || 1 == $showType }>
			<tr>
				<th>金额(￥)</th>
				<{ foreach from=$payDays item=row key=key }>
				<td align="center" height="150" valign="bottom"><{ $row.total_money }><hr title="<{$row.tip}>" class="<{ if $maxMoney > 0 && $row.total_money/$maxMoney >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxMoney > 0}><{ $row.total_money*120/$maxMoney|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 2 == $showType }>
			<tr>
				<th style="color:#FF6600"><b>人数</b></th>
				<{ foreach from=$payDays item=row key=key }>
				<td align="center" height="150" valign="bottom"><{ $row.total_person }><hr title="<{$row.tip}>" class="<{ if $maxPerson > 0 && $row.total_person/$maxPerson >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxPerson > 0}><{ $row.total_person*120/$maxPerson|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 3 == $showType }>
			<tr>
				<th style="color:#4D4DB3"><b>人次</b></th>
				<{ foreach from=$payDays item=row key=key }>
				<td align="center" height="150" valign="bottom"><{ $row.total_person_time }><hr title="<{$row.tip}>" class="<{ if $maxPersonTime >0 &&$row.total_person_time/$maxPersonTime >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxPersonTime > 0}><{ $row.total_person_time*120/$maxPersonTime|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 4 == $showType }>
			<tr>
				<th>ARPU值</th>
				<{ foreach from=$payDays item=row key=key }>
					<td align="center" height="150" valign="bottom"><{ $row.arpu }><hr title="<{$row.tip}>" class="<{ if $maxArpu >0 &&$row.arpu/$maxArpu >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxArpu > 0}><{ $row.arpu*120/$maxArpu|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			
			<tr>
				<th>日期</th>
				<{ foreach from=$payDays item=row key=key }>
					<th align="center" style="padding:0px 5px;"><{ $key }></th>
				<{ /foreach }>
			</tr>
		</table>
	<{ else }>
		 <{ $dateStart }> 至<{ $dateEnd }> 没有人充值
	<{ /if }>
</body>
</html>