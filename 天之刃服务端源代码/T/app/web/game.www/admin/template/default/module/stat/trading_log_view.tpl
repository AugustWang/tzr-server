<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>个人商贸查询</title>
<link href="../css/style.css" rel="stylesheet" type="text/css" /></head>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script src="/admin/static/js/jquery.min.js"></script>
</head>


<style>
.SumDataGrid th{
	width:60px;
}

.SumDataGrid .nice{
	height:20px;
}
</style>


<body style="margin:10px">
<b>查询：个人商贸查看</b>

       

<form action="trading_log_view.php" method='post' onsubmit=''>
<input type='hidden' name='action' id='action' value='update' />


<tr style="background-color:#EDF2F7;"><td align="right">开始时间</td>
	<td>
		<input type='text' class='text' name='start' id='start' size='25' maxlength='60' value='<{$start}>' />
		<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	</td>
</tr>

<tr style="background-color:#EDF2F7;"><td align="right">结束时间</td>
	<td>
		<input type='text' class='text' name='end' id='end' size='25' maxlength='60' value='<{$end}>' />
		<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	</td>
</tr>


<tr style="background-color:#EDF2F7;"><td align="right">角色名(可选):</td>
	<td>
		<input type='txet' class='text' name='roleName' id='roleName' size='25' maxlength='60' value='<{$roleName}>' />
	</td>
</tr>

<tr style="color:#232323;background-color:#D7E4F5;font-weight:bold;"><td align="right" colspan=2>
<input type='submit' class='button' name='submit'  id='submit' value='查询' />
&nbsp;&nbsp;
<font color=red><{$message}></font>
</td></tr>

</table>
</form>

<br/>
<b>统计从<{$start}>到<{$end}>期间的数据<font color="red"></font></b>
<br/><br/>



	<table cellspacing="1" cellpadding="5" border="0" class='table_list' style='width:auto'>
			<tr class='table_list_head' style='font-weight:bold;text-align:center;'>
				<td colspan=12>
					<div style='height:24px;line-height:24px;'>商贸活动统计</div>
				</td>
			</tr>
			
			<h3><font color="red"><{$roleName}></font>的商贸统计</h3>
			<tr class='table_list_head' style='text-align:center;'>
				<td>
					接次数</td><td>
					放弃任务次数</td><td>
					完成次数</td><td>
					总赚钱数量			
				</td>
			</tr>
			
			<tr style='text-align:center;'>
				<td><{$single.accept}></td>
				<td><{$single.drop}></td>
				<td><{$single.complete}></td>
				<td><{$single.earn}></td>
			</tr>
			
	</table>
	
	
	<h3>所有列表:</h3>
	<table cellspacing="1" cellpadding="5" border="0" class='table_list' style='width:auto'>
			<tr class='table_list_head' style='font-weight:bold;text-align:center;'>
				<td colspan=12>
					<div style='height:24px;line-height:24px;'>商贸活动统计</div>
				</td>
			</tr>
			
			<tr class='table_list_head' style='text-align:center;'>
				<td>
					玩家名称</td><td>
					国家</td><td>
					初始商票金额</td><td>
					商票余额</td><td>
					最终商票金额</td><td>
					门派收益金额</td><td>
					门派贡献度</td><td>
					商贸状态</td><td>
					领取时间</td><td>
					交还时间</td><td>
					奖励类型
				</td>
			</tr>
			
			<{foreach from=$singleAry item=item }>
			<tr class='main'>
				<td>
						<{$item.role_name}></td><td>
						<{$item.faction_name}></td><td>
						<{$item.base_bill}></td><td>
						<{$item.bill}></td><td>
						<{$item.last_bill}></td><td>
						<{$item.family_money}></td><td>
						<{$item.family_contribution}></td><td>
						<{$item.my_status}></td><td>
						<{$item.start_time|date_format:"%D %H:%M:%S"}></td><td>
						<{$item.end_time|date_format:"%D %H:%M:%S"}></td><td>
						<{$item.award_type}>
				</td>
			</tr>
			<{/foreach}>
	</table>
		




<script>
$(function(){
	$('.main:odd').addClass('trOdd');
	$('.main:even').addClass('trEven');

});
</script>

<style>
.red{
	background-color:red;
}


</style>
<br/>
</body>
</html>