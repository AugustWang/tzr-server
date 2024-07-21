<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<title>
	玩家门派数据统计
</title><link href="../css/style.css" rel="stylesheet" type="text/css" /></head>

<body style="margin:0">
<b>数据分析：玩家门派数据统计</b>

</div>


<table cellspacing="1" cellpadding="3" border="0" class='table_list' >

开始等级:<input id="start_index" >
结束等级:<input id="end_index" >
<input type="button" id="filter" value="等级过滤">

<tR class='table_list_head'>
			<td>级别</td>
			<td>有门派</td>
			<td>没门派</td>
			<td>活跃玩家</td>
			<td>活跃&没门派</td>
			<td>门派&RMB</td>
			<td>门派&非RMB</td>
			<td>没门派&RMB</td>
			<td>没门派&非RMB</td>
</tr>
<tR class='table_list_head'>
			<td>全部汇总</td>
			<td id="t1">0</td>
			<td id="t2">0</td>
			<td id="t3">0</td>
			<td id="t4">0</td>
			<td id="t5">0</td>
			<td id="t6">0</td>
			<td id="t7">0</td>
			<td id="t8">0</td>
</tr>

<{foreach key=key item=item from=$finalAry}>

	<{if $key % 30 == 0}>
	<!-- 
		<tr class='table_list_head'>
			<td>级别</td>
			<td>有门派</td>
			<td>没门派</td>
			<td>活跃玩家</td>
			<td>活跃&没门派</td>
			<td>门派&RMB</td>
			<td>门派&非RMB</td>
			<td>没门派&RMB</td>
			<td>没门派&非RMB</td>
		</tr>
		 -->
	<{/if}>

	<{if $key % 2 == 0}>
	<tr class='trEven main' id="level_<{$item.level}>">
	<{else}>
	<tr class='trOdd main' id="level_<{$item.level}>">
	<{/if}>
		<td ><{$item.level}></td>
		<td class="t1"><{$item.withFamily}></td>
		<td class="t2"><{$item.withoutFamily}></td>
		<td class="t3"><{$item.active}></td>
		<td class="t4"><{$item.activeWithoutFamily}></td>
		<td class="t5"><{$item.rmbWithFamily}></td>
		<td class="t6"><{$item.nonrmbWithFamily}></td>
		<td class="t7"><{$item.rmbWithoutFamily}></td>
		<td class="t8"><{$item.nonFamilyNoneRmb}></td>
	</tr>
	
<{/foreach}>

</table>


<script>
jQuery.extend({
	range:function(start,final,level){
		var ret = new Array();
		level = arguments[2] || 1;
		for(var i = start;i<final+1;i=i+level){
			ret.push(i);
		}
		return ret;
	}
})




$('#end_index').keydown(function(event){
	if(event.keyCode == 13){
		$('#filter').trigger('click');
	}
});



$('#filter').click(function(){
	try{
 		var start = parseInt($('#start_index').val());
 		var end = parseInt($('#end_index').val());
		var range = $.range(start,end);
		$('.main').hide();
		$.each(range,function(idx,val){
			$('#level_'+val).show();
		})
            updateSum();
	}catch(e){		
	}
})



function updateSum(){
	var ary = $.range(1,8);
	$.each(ary,function(idx,val){
		var sum = 0;
		$('.t'+val+":visible").each(function(){
			    if($(this).text()!="")
			    {
			         sum += parseInt($(this).text());
				}
				
			})
		$('#t'+val).text(sum);
		})	
}


$(function(){
	updateSum();
})



</script>

