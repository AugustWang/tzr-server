<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>历史在线数据</title>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link href="../../css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:0">
<b>在线与注册：历史在线数据</b>	
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
 <a href="<{$URL_SELF}>?brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
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

<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
	<tr>
	    <td>最高在线人数：<{$maxcount}></td>
     <td>最低在线人数：<{$mincount}></td>
      <td>平均在线人数：<{$avgcount}></td>
	</tr>

	<tr class='table_list_head'>
		<td >统计时间</td><td title='统计时间：实时，Socket服务器检测，用户关掉IE立即会检测到。'><font color=red>实时</font>在线人数</td><td></td>
	</tr>

<{section name=loop loop=$keywordlist}>	
	<{if $smarty.section.loop.rownum % 2 == 0}> 
	<tr class='trEven'>
	<{else}> 
	<tr class='trOdd'>
	<{/if}> 
		<td>				
		<{$keywordlist[loop].dateline|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>		
		<{$keywordlist[loop].online}>
		</td><td width='550px'>
			<{if $keywordlist[loop].online > 0}>
			<hr style="float:left;height:10px;width:<{if $maxcount>0}><{$keywordlist[loop].online*100/$maxcount}><{else}>0<{/if}>px;background:<{if $keywordlist[loop].online/$maxcount<0.75}>green<{else}>red<{/if}>;">
			<{/if}>
		</td>
	</tr>
<{sectionelse}>
<tr><td>暂时还没有在线数据</td></tr>
<{/section}>	

</table>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
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