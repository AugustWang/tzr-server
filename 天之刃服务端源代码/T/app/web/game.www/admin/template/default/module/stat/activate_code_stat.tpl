<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>激活码使用统计</title>
<link href="../css/style.css" rel="stylesheet" type="text/css" /></head>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
</head>

<body style="margin:10px">
<b>统计：激活码统计</b>

		<table cellspacing="1" cellpadding="5" border="0" class='table_list' style='width:auto'>
			<tr class='table_list_head' style='font-weight:bold;text-align:center;'>
				<td colspan=12>
					<div style='height:24px;line-height:24px;'>激活码使用统计</div>
				</td>
			</tr>
			<tr class='table_list_head' style='text-align:center;'>
				<td>
					总数</td><td>
					已使用</td><td>
					剩余</td>
				</td>
			</tr>
			<tr class='trOdd'>
				<td style='text-align:center;'>
					<{$all.count|default:'0'}></td><td>
					<{$all.used|default:'0'}></td><td>
					<{$all.not_used|default:'0'}></td>
			</tr>
		</table>
<br/>
<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<{section name=loop loop=$stat}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td ></td><td>月</td><td>日</td><td>小时</td>
		<td>激活码使用数量</td>
	</tr>
	<{/if}>

	<{if $stat[loop].day==null || $stat[loop].month==null || $stat[loop].hour==null}>
	<tr class='trRollup'>
	<{else}>
	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
	<{/if}>
		<td>
		</td><td>
		<{if $stat[loop].month==null}>全部结果总计
		<{else}>
		<{$stat[loop].month}>
		<{/if}>
		</td><td>
		<{if $stat[loop].hour==null && $stat[loop].day==null && $stat[loop].month!=null}><{$stat[loop].month}>月总计
		<{else}>
		<{$stat[loop].day}>
		<{/if}>
		</td><td>
		<{if $stat[loop].hour==null && $stat[loop].day!=null && $stat[loop].month!=null}><{$stat[loop].month}>月<{$stat[loop].day}>日总计
		<{else}>
		<{$stat[loop].hour}>
		<{/if}>
		</td><td>
		<{$stat[loop].c}>
		</td>
	</tr>
<{sectionelse}>

<{/section}>
</table>
<br/>
<br/>
</body>
</html>