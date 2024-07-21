<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>所有充值记录明细</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body style="margin:20px">
<b>基础数据统计：钱庄挂单统计</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

&nbsp;统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;类型：
<select name="type">
	<{html_options options=$arrType selected=$type}>
</select>
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
		<th>日期</th>
		<th>挂单次数</th>
		<th>挂单总元宝</th>
		<th>挂单总银子数</th>
		<th>成功交易次数</th>
		<th>成交总元宝</th>
		<th>成交总银子数</th>
		<th>平均成交价</th>
		<th>最低成交价</th>
		<th>最高成交价</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd'>
	<{else}>
	<tr>
	<{/if}>
		<td><{$rs[loop].mtime|date_format:"%Y-%m-%d %H:%M:%S"     }></td>
		<td><{$rs[loop].sheet_cnt     }></td>
		<td><{$rs[loop].sheet_gold     }></td>
		<td><{$rs[loop].sheet_silver      }></td>
		<td><{$rs[loop].deal_cnt    }></td>
		<td><{$rs[loop].deal_gold }></td>
		<td><{$rs[loop].deal_silver }></td>
		<td><{$rs[loop].avg_price }></td>
		<td><{$rs[loop].min_price }></td>
		<td><{$rs[loop].max_price }></td>
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
<table class="SumDataGrid">
	<tr><th colspan="<{$rsCnt+1}>"><{$dateStart}> -- <{$dateEnd}>  挂单平均价格趋势 </th></tr>
  <tr>
    <th>平均价格</th>
    <{foreach from=$rs item=row}>
	<td align="center" height="120" valign="bottom">
		<{$row.avg_price}><hr class="<{if  $row.avg_price/$max_avg_price > 0.75 }>hr_red<{else}>hr_green<{/if}>"  style="height:<{$row.avg_price*120/$max_avg_price|round}>px;" />
	</td>
	<{/foreach}>
  </tr>  
  <tr>
    <th>日期</th>
    <{foreach from=$rs item=row}>
	<td>
		<span style="font-size:10px"><{$row.mtime|date_format:"%Y-%m-%d"}></span>
	</td>
	<{/foreach}>
  </tr>  
</table>

</div>

</body>
</html>
