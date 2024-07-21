<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>注册数据统计
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/js/jquery.min.js"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>




<body style="margin:0">
<b>在线与注册：注册数据统计</b>

<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">


&nbsp;终止时间：<input type='text' id="dateEnd" name='dateEnd' size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />

				</form>
</div>

<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
	<tr class='trRollup'>
		<td colspan=6 >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;全服总注册用户数：<{$reg_count}></td>
	</tr>


	<tr class='table_list_head'>
		<td colspan=6 >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0 至 <{$search_keyword2}> 23:59:59</td>
	</tr>
	<tr class='table_list_head'>
		<td ></td><td>年</td><td>月</td><td>日</td><td>注册人数</td>
	</tr>

<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$keywordlist}>

	<{if $keywordlist[loop].day==null || $keywordlist[loop].month==null || $keywordlist[loop].year==null}>
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
		<{if $keywordlist[loop].year==null}>全部结果总计
		<{else}>
		<{$keywordlist[loop].year}>
		<{/if}>
		</td><td>
		<{if $keywordlist[loop].day==null && $keywordlist[loop].month==null && $keywordlist[loop].year!=null}>年总计
		<{else}>
		<{$keywordlist[loop].month}>
		<{/if}>
		</td><td>
		<{if $keywordlist[loop].day==null && $keywordlist[loop].month!=null && $keywordlist[loop].year!=null}>月总计
		<{else}>
		<{$keywordlist[loop].day}>
		<{/if}>
		</td><td>
		<{$keywordlist[loop].c}>
		</td>
	</tr>
<{sectionelse}>

<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

</body>
</html>