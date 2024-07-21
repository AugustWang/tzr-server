<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>最后离线时间分布</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>

<body style="padding:10px">
<b>统计：流失率分析</b>
	<h3>最后离线时间分布</h3>
	<div>当前系统时间：<{$smarty.now|date_format:"%Y-%m-%d %H:%M:%S"}></div>
	<div style="margin:5px 0;">
<form action="" method="post">
		<input name="dateStart" id="dateStart" value="<{$dateStart}>" size="12"/>
		<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
		到
		<input name="dateEnd" value="<{$dateEnd}>"  id="dateEnd" size="12"/>
		<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
		注册的玩家
		<input name="submit" type="submit" value="查看" />
</form>
	</div>
	
	<div style='float:left;margin-right:5px;'>
		<table cellspacing=1 cellpadding=3 border=0 class='table_list' style='width:auto;'>
			<tr>
				<td colspan=3>第一天</td>
			</tr>
			<tr class='table_list_head'>
				<td width="100"><b>最后离线-注册</b></td>
				<td width="100"><b>人数</b></td>
				<td width="100"><b>百分比</b></td>
			</tr>
			
			
			

			

<{if $newLabelValue}>
	<{foreach key=key from=$newLabelValue item=item}>
			<tr class='<{if $key%2 == 1}>trOdd<{else}>trEven<{/if}>'>
				<td width="90"><{$item.label}></td>
				<td width="90"><{$item.num}></td>
				<td width="90"><{$item.percentage}>%</td>
			</tr>
	<{/foreach}>
<{/if}>


		</table>
	</div>

	<div style='float:left;'>
		<table cellspacing=1 cellpadding=3 border=0 class='table_list' style='width:auto;'>
			<tr>
				<td colspan=3>第一月</td>
			</tr>
			<tr class='table_list_head'>
				<td width="100"><b>最后离线-注册</b></td>
				<td width="100"><b>人数</b></td>
				<td width="100"><b>百分比</b></td>
			</tr>
<{if $dayArrCount}>
	<{foreach key=key from=$dayArrName name=dayNamed item=dayName}>
			<tr class='<{if $key%2 == 1}>trOdd<{else}>trEven<{/if}>'>
				<td width="90"><{$dayName}></td>
				<td width="90"><{$dayArrCount.$key.lostplayer}></td>
				<td width="90"><{$dayArrCount.$key.percentLost}>%</td>
			</tr>
	<{/foreach}>
<{/if}>
		</table>
	</div>

</body>
</html>
