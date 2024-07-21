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
		$("#viewType").change(function(){
			$("#frm").submit();
		});
	});
</script>
</head>

<body>
	充值与消费：分时统计
	<form action="#" method="POST" id="frm">
	<table style="margin:8px;">
		<tr>
			<td>开始日期：<input type="text" size="10" name="dateStart" id="dateStart" value="<{ $dateStart }>"><img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="10" name="dateEnd" id="dateEnd" value="<{ $dateEnd }>"><img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>
			<select name="viewType" id="viewType">
				<{html_options options=$arrViewType selected=$viewType}>
			</select>
			</td>
			<td>
			<select name="showType" id="showType">
				<{html_options options=$arrShowType selected=$showType}>
			</select>
			</td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>&viewType=<{$viewType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&showType=<{$showType}>&viewType=<{$viewType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&showType=<{$showType}>&viewType=<{$viewType}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrOnline}>&dateEnd=<{$dateStrToday}>&showType=<{$showType}>&viewType=<{$viewType}>';">
			</td>
		</tr>
	</table>
	</form>
	
	<{if $paySumHours}>
	<div style="padding:5px;border:1px solid #BBB">
	从 <{ $dateStart }> 到 <{ $dateEnd }> 总共充值：￥<{ $allSumTotalMoney }> ，单小时最高充值：￥<{ $maxSumMoney }>， 平均每小时充值：￥<{ $avgSumMoney }>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<{if 9 == $showType || 1 == $showType }>
			<tr>
				<th>金额(￥)</th>
				<{ foreach from=$paySumHours item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_money }><hr title="<{$subRow.tip}>" class="<{ if $maxSumMoney > 0 && $subRow.total_money/$maxSumMoney >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxSumMoney > 0}><{ $subRow.total_money*120/$maxSumMoney|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 2 == $showType }>
			<tr>
				<th>人数</th>
				<{ foreach from=$paySumHours item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_person }><hr title="<{$subRow.tip}>" class="<{ if $maxSumPerson > 0 && $subRow.total_person/$maxSumPerson >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxSumPerson > 0}><{ $subRow.total_person*120/$maxSumPerson|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 3 == $showType }>
			<tr>
				<th>人次</th>
				<{ foreach from=$paySumHours item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_person_time }><hr title="<{$subRow.tip}>" class="<{ if $maxSumPersonTime > 0 && $subRow.total_person_time/$maxSumPersonTime >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxSumPersonTime > 0}><{ $subRow.total_person_time*120/$maxSumPersonTime|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 4 == $showType }>
			<tr>
				<th>ARPU值</th>
				<{ foreach from=$paySumHours item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.arpu }><hr title="<{$subRow.tip}>" class="<{ if $maxSumArpu > 0 && $subRow.arpu/$maxSumArpu >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxSumArpu > 0}><{ $subRow.arpu*120/$maxSumArpu|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<tr>
				<th>&nbsp;</th>
				<{ foreach from=$paySumHours key=subkey item=any }>
					<th align="center"><{ $subkey }>时</th>
				<{ /foreach }>
			</tr>
		</table>
	</div>
	<br />
	<{else}>
		<{if 1==$viewType}>
		 <{ $dateStart }> 至 <{ $dateEnd }> 没有人充值
		 <{/if}>
	<{ /if }>
	

	
	
	<{ if $payHours }>
	<div style="padding:5px;border:1px solid #BBB">
	  从 <{ $dateStart }> 到 <{ $dateEnd }> 总共充值：￥<{ $allTotalMoney }> ，单小时最高充值：￥<{ $maxMoney }>， 平均每小时充值：￥<{ $avgMoney }>
	<{ foreach from=$payHours item=row key=key }>
		<{ if $row }>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<{if 9 == $showType || 1 == $showType }>
			<tr>
				<th width="100" rowspan="<{if 9 == $showType}>5<{else}>2<{/if}>"><{ $key }></th>
				<th>金额(￥)</th>
				<{ foreach from=$row item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_money }><hr title="<{$subRow.tip}>" class="<{ if $maxMoney > 0 && $subRow.total_money/$maxMoney >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxMoney > 0}><{ $subRow.total_money*120/$maxMoney|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 2 == $showType }>
			<tr>
				<{if  2 == $showType }><th width="100" rowspan="<{if 9 == $showType}>5<{else}>2<{/if}>"><{ $key }></th><{/if}>
				<th>人数</th>
				<{ foreach from=$row item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_person }><hr title="<{$subRow.tip}>" class="<{ if $maxPerson > 0 && $subRow.total_person/$maxPerson >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxPerson > 0}><{ $subRow.total_person*120/$maxPerson|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 3 == $showType }>
			<tr>
			<{if  3 == $showType }><th width="100" rowspan="<{if 9 == $showType}>5<{else}>2<{/if}>"><{ $key }></th><{/if}>
				<th>人次</th>
				<{ foreach from=$row item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.total_person_time }><hr title="<{$subRow.tip}>" class="<{ if $maxPersonTime > 0 && $subRow.total_person_time/$maxPersonTime >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxPersonTime > 0}><{ $subRow.total_person_time*120/$maxPersonTime|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<{if 9 == $showType || 4 == $showType }>
			<tr>
				<{if  4 == $showType }><th width="100" rowspan="<{if 9 == $showType}>5<{else}>2<{/if}>"><{ $key }></th><{/if}>
				<th>ARPU值</th>
				<{ foreach from=$row item=subRow }>
					<td align="center" height="150" valign="bottom"><{ $subRow.arpu }><hr title="<{$subRow.tip}>" class="<{ if $maxArpu > 0 && $subRow.arpu/$maxArpu >= 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{if $maxArpu > 0}><{ $subRow.arpu*120/$maxArpu|round }><{else}>0<{/if}>px;" /></td>
				<{ /foreach}>
			</tr>
			<{/if}>
			<tr>
				<th>&nbsp;</th>
				<{ foreach from=$row key=subkey item=any }>
					<th align="center"><{ $subkey }>时</th>
				<{ /foreach }>
			</tr>
		</table>
		<{ /if }>
	<{ /foreach }>
	</div>
	<{else}>
		<{if 2==$viewType}>
	 	<{$dateStart}> 至 <{$dateEnd}> 没有人充值
		<{/if}>
	<{ /if }>
	
</body>
</html>