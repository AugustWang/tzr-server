<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<title>
	玩家的元宝消费排行
</title>
</head>

<body style="margin:0">
<b>充值与消费：元宝消费排行</b>
<div class='divOperation'>
<form name="myform" method="post" action="<{$URL_SELF}>">
&nbsp;统计起始时间：<input type='text' name='dateStart' id='dateStart' size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />

&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&resetPage=1';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&resetPage=1';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&resetPage=1';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=ALL&dateEnd=ALL&resetPage=1';">

</form>

</div>
<div>
<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
<{section name=loop loop=$rs}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td>排名</td>
		<td>角色ID</td>
		<td>角色名</td>
		<td>帐号名</td>		
		<td>元宝消费总数</td>	
		<td>绑定元宝总数</td>	
		<td>元宝总数</td>
		<td>报警</td>		
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
			<td>
			<{$rs[loop].rank_no}>
			</td><td>
			<{$rs[loop].user_id}>
			</td><td>
			<{$rs[loop].user_name}>
			</td><td>
			<{$rs[loop].account_name}>
			</td><td>
			<{$rs[loop].ug}>
			</td><td>
			<{$rs[loop].gb}>
			</td><td>
			<{$rs[loop].gub}>
			</td>
			<td style="color:red;"><{if $rs[loop].diff_day >= 3 }><{$rs[loop].diff_day}>天未登录<{/if}>&nbsp;</td>
	</tr>
<{sectionelse}>
<tr><td>暂时没有排行数据</td></tr>
<{/section}>
</table>
</div>

	<div style="padding:5px;">
		<{foreach key=key item=item from=$page_list}>
		 <a href="<{$URL_SELF}>?page=<{$item}>&amp;dateStart=<{$search_keyword1}>&amp;dateEnd=<{$search_keyword2}>"><span style="padding:3px;"><{ $key }></span></a>
		 <{/foreach}>
	</div>
<br>

</body>
</html>