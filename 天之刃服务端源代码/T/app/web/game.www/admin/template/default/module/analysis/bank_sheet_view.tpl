<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>所有充值记录明细</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>游戏基础数据统计：钱庄挂单记录 </b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">


&nbsp;类型：
<select name="type">
	<{html_options options=$arrType selected=$type}>
</select>
&nbsp;状态：
<select name="state">
	<{html_options options=$arrState selected=$state}>
</select>


&nbsp;统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
<span style='margin-left:20px;'>角色名: <input type='text' id='role_name' name='role_name' size='12' value='<{ $role_name }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';" /></span>
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
<br/>
&nbsp;&nbsp;
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="从开服至今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=ALL&dateEnd=ALL&role_name=<{$role_name}>&type=<{$type}>&state=<{$state}>';">
				</form>
</div>

<div style="border:2px solid #CCC;">
	初始数量:最初要出售或求购的元宝数量.<br/>
	当前数量:还差多少个没买到或还剩下多少个没卖出.<br/>
	当前总银子:此单还剩下多少银子或此单已经获得多少银子<br>
	状态:<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;已结单:此单已经全数买到或卖完.<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;已撤单:此单已经被撤.可能已交易了部分<br/>
	&nbsp;&nbsp;&nbsp;&nbsp;挂单中:你懂的...<br/>
</div>
<table cellspacing="0" class="DataGrid">
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$rs}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr>
		<th>挂单单号</th>
		<th>角色名</th>
		<th>单价(文)</th>
		<th>初始数量</th>
		<th>当前数量</th>
		<th>当前总银子(文)</th>
		<th>状态</th>
		<th>创建时间</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd'>
	<{else}>
	<tr>
	<{/if}>
		<td><{$rs[loop].sheet_id     }></td>
		<td><{$rs[loop].role_name     }></td>
		<td><{$rs[loop].price      }></td>
		<td><{$rs[loop].num    }></td>
		<td><{$rs[loop].current_num }></td>
		<td><{$rs[loop].current_silver }></td>
		<td><{$rs[loop].state_str }></td>
		<td><{$rs[loop].create_time|date_format:"%Y-%m-%d %H:%M:%S"     }></td>
	</tr>
<{sectionelse}>
	<tr>
		<th>未找到相应数据</th>
	</tr>
<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?dateStart=<{$dateStart}>&dateEnd=<{$dateEnd}>&amp;role_name=<{$role_name}>&amp;type=<{$type}>&amp;state=<{$state}>page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)
    </td>
  </tr>
</table>

</div>

</body>
</html>
