<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>所有充值记录明细</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>基础数据统计：日常福利统计</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

&nbsp;统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
&nbsp;
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;
<input type="button" class="button" name="dateAll" value="从开服至今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=ALL&dateEnd=ALL&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
				</form>
</div>


<table cellspacing="0" class="DataGrid">
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$rs}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr>
		<th>领奖日期</th>
		<th>完成任务数</th>
		<th>购买勋章数</th>
		<th>玩家数量</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd'>
	<{else}>
	<tr>
	<{/if}>
		<td><{$rs[loop].reward_date     }></td>
		<td><{$rs[loop].task_num     }></td>
		<td><{$rs[loop].buy_num     }></td>
		<td><{$rs[loop].role_count     }></td>
	</tr>
<{sectionelse}>
	<tr>
		<th>未找到相应数据</th>
	</tr>
<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

<br/>

</div>

</body>
</html>
