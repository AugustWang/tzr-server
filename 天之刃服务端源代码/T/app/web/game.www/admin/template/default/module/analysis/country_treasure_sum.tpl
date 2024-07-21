<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style>
	.hover{
		background-color:#D7C8EA;
	}
</style>
</head>

<body>
<b>数据统计：大明宝藏统计</b>

<form action="<{$URL_SELF}>" method="POST" id="frm">
<table>
	<tr>
		<td>
		统计起始日期：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" size="12" name="startDate" value="<{$startDate}>" />&nbsp;结束时间：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"  size="12" name="endDate" value="<{$endDate}>" />&nbsp; 
		</td>
		<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		<td>
			&nbsp;&nbsp
			<input type="button" class="button" name="dateToday" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrToday}>&endDate=<{$dateStrToday}>';">
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrPrev}>&endDate=<{$dateStrPrev}>';">
				&nbsp;&nbsp
				<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrNext}>&endDate=<{$dateStrNext}>';">
				&nbsp;&nbsp
				<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrOnline}>&endDate=<{$dateStrToday}>';">
		</td>
	</tr>
</table>
</form>
<br />
从<b><{$startDate}>到<{$endDate}> 大明宝藏参数人数变化趋势图：</b><br/>
<table class="SumDataGrid">
	<tr align="center" valign="bottom" height="150">
		<th valign="middle">参与人数</th>
		<{foreach from=$arrRsPerson item=row}>
		<td><{$row.total}>
			<hr class="<{if $row.total>$maxDatePerson*0.75}>hr_red<{else}>hr_green<{/if}>" style=" height:<{if $maxDatePerson>0}><{$row.total*120/$maxDatePerson|round}><{else}>0<{/if}>px;" />
		</td>
		<{/foreach}>
	</tr>
	<tr align="center">
		<th>日期</th>
		<{foreach from=$arrRsPerson item=row}>
		<td>
			<{if 0==$row.week}><span style="color:red;"><{$row.date}><br />周日<br /></span><{else}><{$row.date}><br /><{/if}>
		</td>	
		<{/foreach}>
	</tr>
</table>
<br/><b>从<{$startDate}>到<{$endDate}> 大明宝藏参数人数按等级分布表：</b><br/>
<table class="SumDataGrid" width="600">
	<thead>
	<tr>
		<th>日期</th>
		<th>总人数</th>
		<th>20~29</th>
		<th>30~39</th>
		<th>40~49</th>
		<th>50~59</th>
		<th>60~69</th>
		<th>70~79</th>
		<th>80~89</th>
		<th>90~99</th>
		<th>100以上</th>
	</tr>
	</thead>
	<tbody>
		<{foreach from=$arrRsPerson item=row}>
		<tr align="center">
			<td><{if 0==$row.date}><span style="color:red;"><{$row.date}><br />周日<br /></span><{else}><{$row.date}><br /><{/if}></td>
			<td><{$row.total}></td>
			<td><{$row.20_29}></td>
			<td><{$row.30_39}></td>
			<td><{$row.40_49}></td>
			<td><{$row.50_59}></td>
			<td><{$row.60_69}></td>
			<td><{$row.70_79}></td>
			<td><{$row.80_89}></td>
			<td><{$row.90_99}></td>
			<td><{$row.100_MAX}></td>
		</tr>
		<{/foreach}>
	</tbody>		
</table>

<br/><b>从<{$startDate}>到<{$endDate}> 玩家挖到的宝物及数量：</b><br/>
<table class="SumDataGrid" width="400">
	<thead>
	<tr>
		<th>道具名</th>
		<th>个数</th>
	</tr>
	</thead>
	<tbody>
		<{foreach from=$arrRsItem item=row}>
		<tr align="center">
			<td><{if $row.itemName}><{$row.itemName}><{else}><{$row.itemid}><{/if}></td>
			<td><{$row.amount}></td>
		</tr>
		<{/foreach}>
	</tbody>		
</table>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
		$(".SumDataGrid tr").hover(
			function () {
				$(this).find("td").addClass("hover");
			},
			function () {
				$(this).find("td").removeClass("hover");
			}
		); 
		$(".SumDataGrid>tbody>tr:odd").addClass("odd");
	});
</script>
</body>
</html>
