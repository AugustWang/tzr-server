<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>疑似流失统计</title>
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

</head>

<body style="padding:5px">
<b>统计：流失率统计</b>
<div id='input_panel' class='divOperation'>
	<br/>
	<h3 color=red>上次离线时间超过三天为疑似流失用户</h3>
	<br/>
	<form name="myform" method="post" action="<{$URL_SELF}>">
		<input type='hidden' name='ac' value="get" />
	<table cellspacing="1" cellpadding="3" border="0" >
		<tr><td>
				注册开始时间:
				<input type='text' name='start' id='start' value="<{if $start}><{$start|date_format:'%Y-%m-%d %H:%M:%S'}><{/if}>" />
				<img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
				注册结束时间:
				<input type='text' name='end' id='end' value="<{if $end}><{$end|date_format:'%Y-%m-%d %H:%M:%S'}><{/if}>" />
				<img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
		</td></tr>
		<tr><td>
				玩家等级
				从 <input type='text' name='minlv' size=4 value="<{$minlv}>" />
				到 <input type='text' name='maxlv' size=4 value="<{$maxlv}>" />
		</td></tr>
		<tr><td>
				<input class='button' type='submit' value='查询' />
		</td></tr>
	</table>
	</form>
</div>
<br>
<div>
	<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' >
		<tr class='table_list_head'>
			<td>
				等级</td><td>
				段人数</td><td>
				疑似流失</td><td>
				流失比例
			</td>
		</tr>
<{foreach item=eachLevel from=$rs}>
        <{if $smarty.section.i.rownum % 2 == 0}>
           <tr class='odd'>
            <{else}>
           <tr>
        <{/if}>
			<td>
				<{$eachLevel.level}></td><td>
				<{$eachLevel.totalNum}></td><td>
				<{$eachLevel.lossNum}></td><td>
				<{math equation="((x/y)* 100)" x=$eachLevel.lossNum y=$eachLevel.deviedNum format="%.2f"}>%
			</td>
		</tr>
<{/foreach}>
	</table>
</div>
</body>
</html>
