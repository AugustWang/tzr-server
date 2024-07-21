<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
</head>

<body>
<b>数据统计：银子分时消耗</b>

<form action="<{$URL_SELF}>" method="POST" id="frm">
<table>
	<tr>
		<td>
		统计起始日期：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" size="12" name="startDate" value="<{$startDate}>" />&nbsp;结束时间：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"  size="12" name="endDate" value="<{$endDate}>" />&nbsp;银子类型：<select name="silverType"><{html_options options=$arrSilverType selected=$silverType}></select>
		消耗类别：<input type="text" value="<{$typeName}>" id="typeName" name="typeName"  />
<input type="hidden" name="type" id="type" value="<{$type}>" />
<!-- ================== start autocomplete ==================== -->
<script language="javascript">
	$(document).ready(function(){
		$("#typeName").focus(showItem).keyup(showItem);
		var offset = $("#typeName").offset();
		$(".autoMain").css("top",offset.top+20).css("left",offset.left);
		$("#autoClose").click(function(){
			$(".autoMain").hide();
		});
		$(".autoList>li").click(function(){
			$("#typeName").val($(this).text());
			$(".autoMain").hide();
			arrSplit = doSplit();
			$("#type").val(arrSplit[0]);
		});
		$("#autoReSet").click(function(){
			$("#typeName").val("");
			showItem();
		});
	});
	function doSplit(){
		str = $("#typeName").val();
		arrSplit = str.split("|");
		arrSplit[0] = arrSplit[0] ? $.trim(arrSplit[0]) : '';
		arrSplit[1] = arrSplit[1] ? $.trim(arrSplit[1]) : '';
		return arrSplit;
	}
	function showItem(){
		$(".autoMain").show();
		arrSplit = doSplit();
		keyWord = arrSplit[0];
		if(keyWord && '' != keyWord){
			$(".autoList>li").each(function(){
				liText = $(this).text();
				if(-1!=liText.indexOf(keyWord)){
					$(this).show();
				}else{
					$(this).hide();
				}
			});
		}else{
			$(".autoList>li").show();
		}
	}
</script>
<style type="text/css">
	.autoMain{
		position:absolute;
		background-color:#FFF;
		width:250px;
		border:1px solid #CCC;
		display:none;
	}
	.autoClose{
		border-bottom:1px solid #DDD;
		width:95%;
	}
	.autoList{
		list-style:none;
		margin:0px;
		padding:0px;
		height:200px;
		overflow-y:auto;
	}
	.autoList li{
		border-bottom:1px solid #DDD;
		padding:2px 10px;
		cursor:pointer;
	}
	.autoList li:hover{
		background-color:#B5BDC4;
	}
</style>
<div class="autoMain">
	<div align="right" class="autoClose"><a id="autoReSet" href="javascript:void(0);">清空重选</a>&nbsp;&nbsp;<a id="autoClose" href="javascript:void(0);">关闭</a></div>
	<ul class="autoList">
		<{foreach from=$arrSpendType key=key item=itemName}>
		<li><{$key}> | <{$itemName}></li>
		<{/foreach}>
	</ul>
</div>

<!-- ================== end autocomplete ==================== -->
		&nbsp;&nbsp;<input type="submit" value="搜 索" />
		</td>
	</tr>
</table>
</form>
<br /><b>统计类别:<{if $typeName}>【<{$typeName}>】<{else}>【所有消耗类别】<{/if}></b><br />
<table class="SumDataGrid">
	<tr align="center">
		<th colspan="<{$diffDay+1}>"><{$startDate}> - <{$endDate}>  每天银子消耗变化柱状图(单位：文)  </th>
	</tr>
	<tr align="center" valign="bottom" height="150">
		<th valign="middle">银子消耗量</th>
		<{foreach from=$arrByDay.rows item=row}>
		<td><{$row.silver}>
			<hr class="<{if $row.silver>$arrByDay.max_silver*0.75}>hr_red<{else}>hr_green<{/if}>" style=" height:<{if $arrByDay.max_silver>0}><{$row.silver*120/$arrByDay.max_silver|round}><{else}>0<{/if}>px;" />
		</td>
		<{/foreach}>
	</tr>
	<tr align="center">
		<th>日期</th>
		<{foreach from=$arrByDay.rows item=row}>
		<td>
			<{if 0==$row.week}><span style="color:red;"><{$row.date}><br />周日</span><{else}><{$row.date}><{/if}>
		</td>		
		<{/foreach}>
	</tr>
</table>

<br />
<table class="SumDataGrid">
	<tr align="center">
		<th colspan="25"><{$startDate}> - <{$endDate}>  24小时银子消耗变化柱状图(单位：文)  </th>
	</tr>
	<tr align="center" valign="bottom" height="150">
		<th valign="middle">银子消耗量</th>
		<{foreach from=$arrByAllHour.rows item=row}>
		<td><{$row.silver}>
			<hr class="<{if $row.silver>$arrByAllHour.max_silver*0.75}>hr_red<{else}>hr_green<{/if}>" style=" height:<{if $arrByAllHour.max_silver>0}><{$row.silver*120/$arrByAllHour.max_silver|round}><{else}>0<{/if}>px;" />
		</td>
		<{/foreach}>
	</tr>
	<tr align="center">
		<th>时间</th>
		<{foreach from=$arrByAllHour.rows item=row}>
		<td style="padding-left:5px; padding-right:5px;">
			<{$row.hour}>
		</td>		
		<{/foreach}>
	</tr>
</table>


<br />
<table class="SumDataGrid">
	<tr align="center">
		<th colspan="26"><{$startDate}> - <{$endDate}>  银子消耗量24小时统计趋势图(单位：文)  </th>
	</tr>
	<{foreach from=$arrByHour.rows key=mtime item=rowDay}>
	<tr align="center" valign="bottom" height="150" <{if $rowDay.onlineDate%2 ==0}>class="odd" <{/if}>>
		<th rowspan="2" valign="middle">
		<{if 0==$rowDay.week}><span style="color:red;"><{$rowDay.date}><br />周日<br />开服第 <{$rowDay.onlineDate}> 天</span><{else}><{$rowDay.date}><br />开服第 <{$rowDay.onlineDate}> 天<{/if}>
		
		</th>
		<th valign="middle">银子消耗量</th>
		<{foreach from=$rowDay.subRows key=hour item=silver}>
		<td><{$silver}>
			<hr class="<{if $silver>$arrByHour.max_silver*0.75}>hr_red<{else}>hr_green<{/if}>" style=" height:<{if $arrByHour.max_silver>0}><{$silver*120/$arrByHour.max_silver|round}><{else}>0<{/if}>px;" />
		</td>
		<{/foreach}>
	</tr>
	<tr <{if $rowDay.onlineDate%2 ==0}>class="odd" <{/if}>>
		<th>时间</th>
		<{foreach from=$rowDay.subRows key=hour item=rowHour}>
		<td style="padding-left:5px; padding-right:5px;"><{$hour}></td>
		<{/foreach}>
	</tr>
	<{/foreach}>
</table>
</body>
</html>
