<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>商贸活动查询</title>
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
<b>统计：商贸活动</b>


<form action="trading_log.php" method='post' onsubmit=''>
<input type='hidden' name='action' id='action' value='update' />

  

<tr style="background-color:#EDF2F7;"><td align="right">开始时间</td>
	<td>
		<input type='text' class='text' name='start' id='start' size='25' maxlength='60' value='<{$start}>' />
		<img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	</td>
</tr>

<tr style="background-color:#EDF2F7;"><td align="right">结束时间</td>
	<td>
		<input type='text' class='text' name='end' id='end' size='25' maxlength='60' value='<{$end}>' />
		<img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
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

<h3>国家统计</h3>
		<b>汇总统计:</b>
		<table cellspacing="1" cellpadding="5" border="0" class='table_list' style='width:auto'>
			<tr class='table_list_head' style='font-weight:bold;text-align:center;'>
				<td colspan=12>
					<div style='height:24px;line-height:24px;'></div>
				</td>
			</tr>
			
			<tr class='table_list_head' style='text-align:center;'>
				<td>国家</td>
				<td>总共赚钱数(文)</td>
				<td>接受角色数目</td>
				<td>接受任务次数</td>
				<td>放弃任务次数</td>
				<td>完成任务次数</td>
				<td>完成任务角色数</td>
								
			</tr>
			
			
			<{foreach from=$factionStat item=item key=key}>
			<tr class='trOdd'>
				<td style='text-align:center;'><{$item.factionName}></td>
				<td><{$item.all_earn}></td>
				<td><{$item.role_accept}></td>
				<td><{$item.all_accept}></td>
				<td><{$item.all_des}></td>
				<td><{$item.all_complete}></td>
				<td><{$item.role_complete}></td>
			</tr>
			<{/foreach}>
			
			
		</table>
		
				
		
		<br/><br/><br/>
		<b>分小时统计:</b>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<tr style="height:30px">
				<th>云州接受</th>
				<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom" width="10px">
					 <{$item.rec.1}><br/>
					</td>
				<{ /foreach}>
			</tr>
			
			
			<tr style="height:30px">
				<th>沧州接受</th>
				<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom" width="10px">
					<{$item.rec.2}><br/>
					</td>
				<{ /foreach}>
			</tr>
			
			<tr style="height:30px">
				<th>幽州接受</th>
				<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom" width="10px">
					 <{$item.rec.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			
		
			
			<tr style="height:30px">
				<th>云州完成</th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					 <{$item.done.1}><br/>
					</td>
				<{ /foreach}>
			</tr>
			
			
			
			<tr style="height:30px">
				<th>沧州完成 </th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					<{$item.done.2}><br/>
					</td>
				<{ /foreach}>
			</tr>
			
			
			
			
			<tr style="height:30px">
				<th>幽州完成</th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					<{$item.done.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			
			
			
			
			
			
			
			<tr style="height:30px">
				<th>云州放弃</th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					<{$item.drop.1}><br/>
	
					</td>
				<{ /foreach}>
			</tr>
			
			
			
			
			<tr style="height:30px">
				<th>沧州放弃</th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					<{$item.drop.2}><br/>
					</td>
				<{ /foreach}>
			</tr>
			
				<tr style="height:30px">
				<th>幽州放弃</th>
					<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
					<{$item.drop.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			

			
			
			<tr style="height:30px">
				<th>时间</th>
				<{ foreach from=$finalAry item=item }>
					<td align="center" height="15px" valign="bottom">
						<{$item.time|date_format:"%y-%m-%d"}><br/>
						<{$item.time|date_format:"%H:00:00"}>
						
					</td>
				<{ /foreach }>
			</tr>
			
		</table>
		
		<br/><br/><br/>
		<b>分天统计:</b>
		<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
			<tr class="nice">
				<th><div style="width:30px;text-align:center;clear:both; margin: 0px auto;">接受</div></th>
				<{ foreach from=$dailyAry item=item }>
					<td align="center"  valign="bottom">
					云州: <{$item.rec.1}><br/>
					沧州: <{$item.rec.2}><br/>
					幽州: <{$item.rec.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			
			
			<tr class="nice">
				<th>完成</th>
				<{ foreach from=$dailyAry item=item }>
					<td align="center" valign="bottom">
					云州: <{$item.rec.1}><br/>
					沧州: <{$item.rec.2}><br/>
					幽州: <{$item.rec.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			
			
			<tr class="nice">
				<th>放弃</th>
				<{ foreach from=$dailyAry item=item }>
					<td align="center"  valign="bottom">
					云州: <{$item.drop.1}><br/>
					沧州: <{$item.drop.2}><br/>
					幽州: <{$item.drop.3}></br>
					</td>
				<{ /foreach}>
			</tr>
			
			<tr class="nice">
				<th>时间</th>
				<{ foreach from=$dailyAry item=item }>
				<td align="center"  valign="bottom">
						<{$item.time|date_format:"%D "}>
				</td>
				<{ /foreach }>
			</tr>
	
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