<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>所有充值记录明细</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>充值与消费：所有充值记录</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">


&nbsp;排序
<select name="sort_1">
	<{html_options options=$sortoption selected=$search_sort_1}>
</select>

<select name="sort_2">
	<{html_options options=$sortoption selected=$search_sort_2}>
</select>

&nbsp;统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<{if $mix_names != ""}>
&nbsp;混服代理:
<select name="mixselect">
        <{html_options options=$mix_names selected=$mix_selectd}>
</select>
<{/if}>
<span style='margin-left:20px;'>登录帐号: <input type='text' id='account_name' name='account_name' size='12' value='<{ $account_name }>' onkeydown="document.getElementById('role_name').value =''; document.getElementById('role_id').value ='';" /></span>
<span style='margin-left:20px;'>角色名: <input type='text' id='role_name' name='role_name' size='12' value='<{ $role_name }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';" /></span>
		
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
<br/>
&nbsp;&nbsp;
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>&mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>&mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>&mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="从开服至今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=ALL&dateEnd=ALL&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>&mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>';">
				</form>
</div>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?dateStart=<{$dateStart}>&dateEnd=<{$dateEnd}>&brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>&amp;mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)总共<{$record_count}>个记录
	<input name="brand_id" type="hidden" value="<{$search_brandid}>">
	<input name="q" type="hidden" value="<{$search_keyword}>">
	<input name="series_id" type="hidden" value="<{$search_seriesid}>">
	<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
	<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">

[ <a href="<{$URL_SELF}>?excel=true&dateStart=<{$dateStart}>&dateEnd=<{$dateEnd}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>&amp;mixselect=<{$mix_selectd}>&amp;account_name=<{$account_name}>&amp;role_name=<{$role_name}>">导出Excel文件</a> ]
</form>
    </td>
  </tr>
</table>

<table cellspacing="0" class="DataGrid">
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$keywordlist}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr>
		<th>ID</th>
		<th>订单号</th>
		<th>角色ID</th>
		<th>角色名</th>
		<th>帐号名</th>
		<th>角色等级</th>
		<th>充值时间</th>
		<th>充值获得元宝数</th>
		<th>人民币</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd'>
	<{else}>
	<tr>
	<{/if}>
		<td><{$keywordlist[loop].id     }></td>
		<td><{$keywordlist[loop].order_id     }></td>
		<td><{$keywordlist[loop].role_id      }></td>
		<td><{$keywordlist[loop].role_name    }></td>
		<td><{$keywordlist[loop].account_name }></td>
		<td><{$keywordlist[loop].role_level   }></td>
		<td><{$keywordlist[loop].pay_time|date_format:"%Y-%m-%d %H:%M:%S"     }></td>
		<td><{$keywordlist[loop].pay_gold     }></td>
		<td><{$keywordlist[loop].pay_money    }></td>
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
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?dateStart=<{$dateStart}>&dateEnd=<{$dateEnd}>&brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>&amp;mixselect=<{$mix_selectd}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)
	<input name="brand_id" type="hidden" value="<{$search_brandid}>">
	<input name="q" type="hidden" value="<{$search_keyword}>">
	<input name="series_id" type="hidden" value="<{$search_seriesid}>">
	<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
	<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
</form>
    </td>
  </tr>
</table>

</div>

</body>
</html>
