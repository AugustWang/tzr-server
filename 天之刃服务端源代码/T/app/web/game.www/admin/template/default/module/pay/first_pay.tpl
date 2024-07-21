<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>

<body>
<b>充值与消费：首充情况</b>
	<form action="#" method="POST">
	<table style="margin:5px;">
		<tr>
			<td>开始日期：<input type="text" size="10" name="dateStart" id="dateStart" value="<{ $dateStart }>"><img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="10" name="dateEnd" id="dateEnd" value="<{ $dateEnd }>"><img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		</tr>
	</table>
	</form>
	<div>每日首充情况：
	<{ if $resultFirstByDate }>
		<div><{$dateStart}>至<{$dateEnd}>，首充总金额：￥<{$allMoney}> ，总人数：<{$allPerson}> ；单日首充金额最多：￥<{$maxMoneyByDate}> ，单日首充平均金额：￥<{$avgMoneyByDate}> ；单日首充人数最多：<{$maxPersonByDate}></div>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<tr>
				<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">充值金额</div></th>
				<{ foreach from=$resultFirstByDate item=row }>
					<td align="center" height="120" valign="bottom">
					<{ $row.total_money }><hr class="<{if $row.total_money/$maxMoneyByDate > 0.75 }>hr_red<{else}>hr_green<{/if}>" title="￥<{$row.total_money}>" style="height:<{ $row.total_money*120/$maxMoneyByDate|round }>px;" />
					</td>
				<{ /foreach}>
			</tr>
			<tr>
				<th>人数</th>
				<{ foreach from=$resultFirstByDate item=row }>
					<td align="center" height="120" valign="bottom">
					<{ $row.person }><hr class="<{if  $row.person/$maxPersonByDate > 0.75 }>hr_red<{else}>hr_green<{/if}>" title="<{$row.person}>人"  style="height:<{ $row.person*120/$maxPersonByDate|round }>px;" />
					</td>
				<{ /foreach}>
			</tr>
			<tr>
				<th>日期</th>
				<{ foreach from=$resultFirstByDate item=row }>
					<th align="center" style="font-size:10px;"><{ if 0 == $row.date|date_format:"%w" }><font color="red"><{ $row.date|date_format:"%m.%d" }><br>周日</font><{ else }><{ $row.date|date_format:"%m.%d" }><{ /if }></th>
				<{ /foreach }>
			</tr>
			<tr>
				<th>开服天数</th>
				<{ foreach from=$resultFirstByDate item=row }>
					<th align="center"><b><{ $row.index }></b></th>
				<{ /foreach }>
			</tr>
		</table>
	<{ else }>
		查不到数据
	<{ /if }>
	</div>
	<br>
	<div>首充等级分布情况：
	<{ if $rsLevel }>
		
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<tr>
				<th width="100">百分比</th>
				<{ foreach from=$rsLevel item=row }>
					<td align="center" height="120" valign="bottom"><{ $row.rate }>%<hr class="<{if $row.rate > 75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.rate*2|round }>px;" /></td>
				<{ /foreach}>
			</tr>
			<tr>
				<th width="100">人数</th>
				<{ foreach from=$rsLevel item=row }>
					<td align="center" height="120" valign="bottom"><{ $row.cnt }><hr class="<{if $row.rate > 75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{ $row.rate*2|round }>px;" /></td>
				<{ /foreach}>
			</tr>
			<tr>
				<th width="100">等级</th>
				<{ foreach from=$rsLevel item=row }>
					<th align="center"><{ $row.role_level }></th>
				<{ /foreach }>
			</tr>
		</table>
	<{ else }>
		查不到数据
	<{ /if }>
	</div>
</body>
</html>