<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>boss状态查看
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script src="/admin/static/js/jquery.min.js" type="text/javascript" charset="utf-8"></script>

<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body style="margin:0">


<b>门派拉镖状态查看</b>
<div class='divOperation'>
<form name="myform" method="post" action="family_ybc_log.php">
查看日期：
<input type='text' id="time" name='time' size='10' value='<{$time}>' />
<img onclick="WdatePicker({el:'time'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
门派名称：
<input type='text' name='family_name' size='10' value='<{$family_name}>' />

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>

<form action="family_ybc_log.php" method="post" class="l_align" style="display:inline;float:left;">
	<input type="hidden" name="time" value="<{$today}>"></input>
	<input type="hidden" name="family_name" value="<{$family_name}>"></input>
	<input type="submit" name="btn" value="今天"></input>
</form>


<form action="family_ybc_log.php" method="post" class="l_align" style="display:inline;float:left;">
	<input type="hidden" name="time" value="<{$preDay}>"></input>
	<input type="hidden" name="family_name" value="<{$family_name}>"></input>
	<input type="submit" name="btn" value="前一天:"></input>
</form>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<form action="family_ybc_log.php" method="post" class="t_align" style="display:inline;float:left;">
	<input type="hidden" name="time" value="<{$postDay}>"></input>
	<input type="hidden" name="family_name" value="<{$family_name}>"></input>
	<input type="submit" name="btn" value="后一天:"></input>
</form>





<div class='family_ybc_view' width='50%'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' width="50%">
		<tr class='table_list_head'>
			<td  width="30%">拉镖车ID</td>
			<td  width="30%">门派名称</td>
			<td  width="40%">记录内容</td>
			<div  height="0px" width="0px" style="display:hidden">记录内容</div>
		</tr>
			
	
	<{foreach key=key item=item from=$final_result}>
		<tr class="each">
			<td><{$item.ybc_no}></td>
			<td><{$item.family_name}></td>
			<td class="ybc_content"><{$item.content}>"></a></td>
		</tr>
		
		<tr id="more_<{$item.ybc_no}>" class="data invi" >
			<td colspan="3" style="text-align:center"><{$item.content}></td>
		</tr>
		
	<{/foreach}>
	</table>
</div>
</div>

<script >
$(".each:odd").addClass("trOdd");
$(".each:even").addClass("trEven");
$(function(){
	$('.ybc_content').each(function(){
			$(this).text($(this).text().substring(0,40)+'  ...打开/关闭');
		});
	
	$('.each').click(function(){
			$(this).next('.data').toggleClass('invi');
		});

});
</script>
	

<style>
.invi{
	display:none;
}


</style>




</body>
</html>