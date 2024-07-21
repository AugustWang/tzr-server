<!DOCTYPE html PUBLIC "-//W3C//Dth XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/Dth/xhtml1-transitional.dth">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#sumType").change(function(){
			$("#frm").submit();
		});
	});
</script>
</head>

<body>
<b>数据统计：财富统计</b>
<form id="frm" action="<{$URL_SELF}>" method="POST" style="padding:5px;">
	元宝类型：<select name="sumType" id="sumType"><{html_options options=$arrSumType selected=$sumType}></select>
</form>
<div>
<table class="SumDataGrid" style="float:left;" width="400">
	<tr>
		<th colspan="6">元宝统计</th>
	</tr>
	<tr>
		<th>范围</th>
		<th>人数</th>
		<th>人数比例</th>
		<th>总量</th>
		<th>总量比例</th>
		<th>人均</th>
	</tr>
	<{foreach from=$arrGold key=key item=gold}>
	<{if $key%2==0}>
	<tr class="odd">
	<{else}>
	<tr>
	<{/if}>
		<td><{$gold.gold_level}></td>
		<td><{$gold.total_role}></td>
		<td><{$gold.role_rate}>%</td>
		<td><{if '0—0'==$gold.gold_level}>&nbsp;<{else}><{$gold.total_gold}><{/if}></td>
		<td><{if '0—0'==$gold.gold_level}>&nbsp;<{else}><{$gold.gold_rate}>%<{/if}></td>
		<td><{if '0—0'==$gold.gold_level}>&nbsp;<{else}><{$gold.avg}><{/if}></td>
	</tr>
	<{/foreach}>
	<tr>
		<th align="right">累计：</th>
		<th><{$allGoldRole}></th>
		<th>&nbsp;</th>
		<th><{$allGold}></th>
		<th>&nbsp;</th>
		<th><{$allGoldAvg}></th>
	</tr>
</table>
&nbsp;
<table class="SumDataGrid" width="500" style="float:left;margin-left:10px;">
	<tr>
		<th colspan="6">银两统计(不包括银票)</th>
	</tr>
	<tr>
		<th>范围</th>
		<th>人数</th>
		<th>人数比例</th>
		<th>总量</th>
		<th>总量比例</th>
		<th>人均</th>
	</tr>
	<{foreach from=$arrSilver key=key item=silver}>
	<{if $key%2==0}>
	<tr class="odd">
	<{else}>
	<tr>
	<{/if}>
		<td><{$silver.silver_level}></td>
		<td><{$silver.total_role}></td>
		<td><{$silver.role_rate}>%</td>
		<td><{if '[0—0]'==$silver.silver_level}>&nbsp;<{else}><{$silver.total_silver_str}><{/if}></td>
		<td><{if '[0—0]'==$silver.silver_level}>&nbsp;<{else}><{$silver.silver_rate}>%<{/if}></td>
		<td><{if '[0—0]'==$silver.silver_level}>&nbsp;<{else}><{$silver.avg_str}><{/if}></td>
	</tr>
	<{/foreach}>
	<tr>
		<th align="right">累计：</th>
		<th><{$allSilverRole}></th>
		<th>&nbsp;</th>
		<th><{$allSilverStr}></th>
		<th>&nbsp;</th>
		<th><{$allSilverAvgStr}></th>
	</tr>
</table>
</div>
</body>
</html>