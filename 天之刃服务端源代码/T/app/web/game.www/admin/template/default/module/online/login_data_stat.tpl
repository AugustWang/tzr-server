<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
	登录数据统计分析
</title><link href="/admin/static/css/style.css" rel="stylesheet" type="text/css" /></head>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>


<body style="margin:0">
<b>统计：登录数据统计</b>

<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

统计起始时间：<input type='text' name='dateStart' id="dateStart" size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">


&nbsp;终止时间：<input type='text' name='dateEnd' id="dateEnd" size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
		
				</form>
</div>	

<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->

	<tr class='table_list_head'>
		<td colspan=3 >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0 至 <{$search_keyword2}> 23:59:59</td>
	</tr>
	
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$keywordlist}>	
	<{if $smarty.section.loop.rownum % 20 == 1}> 
	<tr class='table_list_head'>
		<td ></td><td title='用开区间，闭区间的表示方法'>登录次数</td>
		<td>人数（有多少角色ID，在指定时间范围内，有这么多的登录次数）</td>
	</tr>
	<{/if}> 

	<{if $smarty.section.loop.rownum % 2 == 0}> 
	<tr class='trEven'>
	<{else}> 
	<tr class='trOdd'>
	<{/if}> 
		<td>				
		<{$keywordlist[loop].mtime|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>		
		<{$keywordlist[loop].prompt}>
		</td><td>		
		<{$keywordlist[loop].value}>
		</td>
	</tr>
<{sectionelse}>

<{/section}>	
<!-- SECTION  END -------------------------->		
	<tr class='trRollup'>
		<td></td>
		<td>合计</td>
		<td><{$sum}></td>
	</tr>
</form>
</table>
</body>
</html>