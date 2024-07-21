<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<title>
	查询用户元宝使用记录
</title>
</head>



<body style="margin:0">
<b>充值与消费：元宝使用记录</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

请输入玩家登录帐号：<input type='text' id="acname" name='acname' size='10' value='<{$search_keyword1}>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('userid').value ='';"/>

&nbsp;或者角色名：<input type='text' id="nickname" name='nickname' size='10' value='<{$search_keyword2}>' onkeydown="document.getElementById('acname').value =''; document.getElementById('userid').value ='';"/>
&nbsp;或者角色id：<input type='text' id="userid" name='userid' size='10' value='<{$search_keyword3}>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('acname').value ='';"/>
&nbsp;严格匹配：<input type='checkbox' name='forceFlag' checked="checked" />
<br/>
&nbsp;起始时间(YYYY-mm-dd)：<input type="text" id="start" name="start" value="<{$start}>" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" >
&nbsp;结束时间(YYYY-mm-dd)：<input type="text" id="end" name="end" value="<{$end}>" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" >
&nbsp;操作类型：
<select name="mtype_name">
    <{html_options options=$typelist selected=$mtype}>
</select>

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />

<br/>排序
<select name="sort_1">
	<{html_options options=$sortoption selected=$search_sort_1}>
</select>

<select name="sort_2">
	<{html_options options=$sortoption selected=$search_sort_2}>
</select>


&nbsp;&nbsp;&nbsp;
<{if $record_count}>
总共<{$record_count}>个记录
<{/if}>
				</form>
</div>
<span style="color:red;font-weight: bold;">元宝流水统计：<{$balance}>元宝</span>
<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?acname=<{$search_keyword1|escape:"url"}>&amp;nickname=<{$search_keyword2|escape:"url"}>&amp;userid=<{$search_keyword3|escape:"url"}>&amp;sort_1=<{$search_sort_1}>&amp;start=<{$start|escape:"url"}>&amp;end=<{$end|escape:"url"}>&amp;sort_2=<{$search_sort_2}>&amp;mtype_name=<{$mtype}>&amp;page=<{$item}>&amp;forceFlag=<{$forceFlag}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
<{if $page_count > 0}>

总页数(<{$page_count}>)

<{if $page_count > 5}>
	<input name="acname" type="hidden" value="<{$search_keyword1}>" >
	<input name="nickname" type="hidden" value="<{$search_keyword2}>" >
	<input name="userid" type="hidden" value="<{$search_keyword3}>" >
	<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
	<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
	<input name="start" type="hidden" value="<{$start}>">
    <input name="end" type="hidden" value="<{$end}>">
	<input name="mtype_name" type = "hidden" value = "<{$mtype}>" >
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
<{/if}>

[ <a href="<{$URL_SELF}>?excel=true&acname=<{$search_keyword1|escape:"url"}>&amp;nickname=<{$search_keyword2|escape:"url"}>&amp;userid=<{$search_keyword3|escape:"url"}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;start=<{$start|escape:"url"}>&amp;end=<{$end|escape:"url"}>&amp;mtype_name=<{$mtype}>&amp;forceFlag=<{$forceFlag}>">导出Excel文件</a> ]
<{/if}>
</form>
    </td>
  </tr>
</table>
<{$warning}>
<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$keywordlist}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td >ID</td><td >使用时间</td>
		<td>绑定元宝</td>
		<td>元宝</td>
		<td>操作类型</td>
		<td>数量</td>
		<td>道具</td>
		<td>详细内容</td>
		<td>帐号名</td><td>角色名</td><td >角色ID</td>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='trEven'>
	<{else}>
	<tr class='trOdd'>
	<{/if}>
		<td>
		<{$keywordlist[loop].id}>
		</td><td>
		<{$keywordlist[loop].mtime|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td <{if $keywordlist[loop].gold_bind < 0}>style="color:red;"<{/if}>>
		<{$keywordlist[loop].gold_bind}>
		</td><td <{if $keywordlist[loop].gold_unbind < 0}>style="color:red;"<{/if}>>
		<{$keywordlist[loop].gold_unbind}>
		</td><td>
		<{$keywordlist[loop].mtype}>:<{$keywordlist[loop].mtype_name}>
		</td><td>
		<{$keywordlist[loop].amount}>
        </td><td>
        <{$keywordlist[loop].item_name}>
        </td><td>
		<{$keywordlist[loop].mdetail}>
		</td><td>
		<{$keywordlist[loop].account_name}>
		</td><td>
		<{$keywordlist[loop].user_name}>
		</td><td>
		<{$keywordlist[loop].user_id}>
		</td>
	</tr>
<{sectionelse}>

<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

</body>
</html>
