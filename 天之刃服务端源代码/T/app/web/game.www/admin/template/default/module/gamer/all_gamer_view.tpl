<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
	所有注册用户
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/js/jquery.min.js"></script>	
</head>



<body style="margin:0">
<b>在线与注册：所有注册用户</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">


&nbsp;排序
<select name="sort_1">
	<{html_options options=$sortoption selected=$search_sort_1}>
</select>

<select name="sort_2">
	<{html_options options=$sortoption selected=$search_sort_2}>
</select>



					<input type="image" src="/admin/static/images/search.gif" class="input2"  />

&nbsp;&nbsp;&nbsp;&nbsp;
总共<{$record_count}>个记录

				</form>
</div>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)
	<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
	<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
</form>
    </td>
  </tr>
</table>

<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="get" action="">
<{section name=loop loop=$keywordlist}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr class='table_list_head'>
		<td >角色ID</td><td >角色名</td>
		<td>帐号名</td><td>注册时间</td><td>最后一次登录时间</td><td>最后登录IP</td><td>角色等级</td><td>状态</td>
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
		<{$keywordlist[loop].nickname}>
		</td><td>
		<{$keywordlist[loop].AccountName}>
		</td><td>
		<{$keywordlist[loop].reg_time|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>
		<{if $keywordlist[loop].last_login_time <= 0}>无
		<{else}>
		<{$keywordlist[loop].last_login_time|date_format:"%Y-%m-%d %H:%M:%S"}>
		<{/if}>
		</td><td>
		<{$keywordlist[loop].last_login_ip}>
		</td><td>
		<{$keywordlist[loop].level}>
		</td><td>
		<{if $keywordlist[loop].status == 0}>正常<{else}>禁止登录<{/if}>
		</td>
	</tr>
<{sectionelse}>

<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)
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