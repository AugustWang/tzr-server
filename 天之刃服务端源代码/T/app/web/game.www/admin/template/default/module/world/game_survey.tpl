<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>单服概况说明</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>

<body style="margin:0px;padding:20px;">
<b>充值与消费：单服概况说明</b>
<div class='divOperation'>
<form name="myform" method="post" action="<{$URL_SELF}>">

&nbsp;统计起始时间：<input type='text' name='dateStart' size='12' value='<{$dateStart}>'  class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" />

&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' size='12' value='<{$dateEnd}>'  class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" />

&nbsp;&nbsp;

<input type="image" name='search' align="absmiddle" src="/admin/static/images/search.gif" class="input2"  />

&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=ALL&dateEnd=ALL';">
　　
</form>

</div>
<br />
<div>
	<table height="" cellspacing="0" border="0" class="DataGrid">
		<tr>
			<td width="25%">代理：<{$agent}></td>
			<td width="25%">区名：<{$area_name}></td>
			<td colspan="2"></td>
		</tr>
		<tr>
			<td width="25%">开服日期：<{$server_online_day}></td>
			<td width="25%">已开服天数：<{$has_online_day}></td>
			<td colspan="2">当前程序版本：<{$version}></td>
		</tr>

		<tr>
			<td width="25%">总注册帐号数：<{$total_account}></td>
			<td width="25%">总注册角色数：<{$total_role}></td>
			<td colspan="2">角色最高等级:<{$role_max_level}></td>
		</tr>
		<tr>
			<td width="25%">总充值金额：<{ $allTotalPay }></td>
			<td width="25%">总充值人数：<{ $payAccountCnt }></td>
			<td colspan="2">ARPU值：<{ if $payAccountCnt }><{ $allTotalPay/$payAccountCnt|string_format:"%.2f" }><{ else }>0<{ /if }></td>
		</tr>
		<tr>
			<td width="25%">单日最高在线：<{ $allMaxOnline }></td>
			<td width="25%">单日充值最多：<{ $allMaxPay }></td>
			<td colspan="2">&nbsp;</td>
		</tr>
		
	</table>
</div>
<br />

<div>
	<div style="border:1px solid SkyBlue; background:#D7E4F5;width:98%;"><{$dateStart}>--<{$dateEnd}> 共<{$diffDay}>天每天充值金额、最高在线柱状图</div>
	<table cellspacing="0" class="SumDataGrid">
		<tr>
			<th width="20" height="150">每天充值金额</th>
			<{ if $payOnline }>
			<{ foreach item=row key=key from=$payOnline }>
			<td align="center" valign="bottom"><{ $row.total_pay }><hr class="<{if $row.total_pay/$allMaxPay >= 0.75 }>hr_red<{else}>hr_green<{/if}>" style="height:<{ $row.total_pay*120/$allMaxPay|round }>px;"></td>
			<{ /foreach }>
			<{ /if }>
		</tr>
		<tr>
			<th width="20" height="150">每天最高在线</th>
			<{ if $payOnline }>
			<{ foreach item=row key=key from=$payOnline }>
			<td align="center" valign="bottom"><{ $row.max_online }><hr class="<{if $row.max_online/$allMaxOnline >= 0.75 }>hr_red<{else}>hr_green<{/if}>" style="height:<{ $row.max_online*120/$allMaxOnline|round }>px;"></td>
			<{ /foreach }>
			<{ /if }>
		</tr>
		<tr>
			<th width="20">日期</th>
			<{ if $payOnline }>
			<{ foreach item=row key=key from=$payOnline }>
			<td align="center"><{ if 0 == $key|date_format:"%w" }><font color="red"><{ $key|date_format:"%m.%d" }><br>周日</font><{ else }><{ $key|date_format:"%m.%d" }><{ /if }></td>
			<{ /foreach }>
			<{ /if }>
		</tr>
	</table>
</div>
</body>
</html>