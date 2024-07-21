<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>每天活跃用户数</title>
<link href="/admin/static/css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>


<body style="margin:0">
<b>数据分析：活跃与忠诚用户数</b>
<div class='divOperation'>


<form name="myform" method="post">

开始时间:<input type="text"  id="start" name="start" value=<{$start}> > 
<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
结束时间:<input type="text"  id="end" name="end" value=<{$end}> >
<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<input type="image" src="/admin/static/images/search.gif" class="input2"  />
</form>
</div>


<br>
</br>
总共<{$count}>个记录
<br>
<{$pager}>
<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
	<tr class='table_list_head'>
		<td>日期</td>
		<td>活跃用户数</td>
		<td>忠诚用户数</td>
		<td>最大在线</td>
		<td>平均在线</td>
		<td>当天新注册用户数</td>
		<td>全部注册用户数</td>
	</tr>

	<{foreach from=$result item=item key=key}>
	<tr class="main">
		<td>
			<{$item.date}>
		</td><td>
			<{$item.active}>
		</td><td>
			<{$item.loyal}>
		</td><td>
			<{$item.max_online}>
		</td><td>
			<{$item.avg_online}>
		</td><td>
			<{$item.new_user}>
		</td><td>
			<{$item.total_user}>
		</td>
	</tr>
	<{/foreach}>
</table>
</tr>
</table>






<br />

<div style='margin:10px; padding:2px; border: 1px solid #CCCCCC;'>
	<b>活跃用户</b>：最近7天总在线时间不低于7小时的用户。并且最近三天有登录
	<br/>
	<b>忠诚用户</b>：最近7天(不是周区间)最少有3次登录，每天登录多次只算1次，并且玩家级别大于等于20级。
	<br/>
	<b>平均在线</b>：某一天的 09:00:00--23:59:59 期间，游戏实际在线数的平均数值。

	（不是24小时平均，因为0点到8点，半夜，人数太少，没有实际统计意义）
</div>

<script>
$(function(){
	$('.main:odd').addClass('trOdd');
	$('.main:odd').addClass('trEven');

})


</script>


</body>
</html>