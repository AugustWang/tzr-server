<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<title>
	玩家师徒数据统计
</title><link href="../css/style.css" rel="stylesheet" type="text/css" /></head>

<body style="margin:0">
<b>数据分析：玩家师徒数据统计</b>

</div>


<table cellspacing="1" cellpadding="3" border="0" class='table_list' >



<br><br>
开始等级:<input type="text" id="start_index">
结束等级:<input type="text" id="end_index">
<input type='button' value="确定" id="omit">
<br><br>


<tR class='table_list_head '>
			<td>级别</td>
			<td>有师徒</td>
			<td>没师徒</td>
			<td>活跃玩家</td>
			<td>活跃&有师徒</td>
			<td>活跃&没师徒</td>
			<td>不活跃&有师徒</td>
			<td>不活跃&没师徒</td>
			<td>有师徒&RMB</td>
			<td>无师徒&RMB</td>
			<td>有师徒&非RMB</td>
			<td>无师徒&非RMB</td>
</tr>
<tR class='table_list_head content'>
			<td>汇总统计</td>
			<td id="t1"></td>
			<td id="t2"></td>
			<td id="t3"></td>
			<td id="t4"></td>
			<td id="t5"></td>
			<td id="t6"></td>
			<td id="t7"></td>
			<td id="t8"></td>
			<td id="t9"></td>
			<td id="t10"></td>
			<td id="t11"></td>
</tr>

<{foreach key=key item=item from=$finalAry}>

	<{if $key % 30 == 0}>
	<!-- 	<tr class='table_list_head'>
			<td id="">级别</td>
			<td>有师徒</td>
			<td>没师徒</td>
			<td>活跃玩家</td>
			<td>活跃&有师徒</td>
			<td>活跃&没师徒</td>
			<td>不活跃&有师徒</td>
			<td>不活跃&没师徒</td>
			<td>有师徒&RMB</td>
			<td>无师徒&RMB</td>
			<td>有师徒&非RMB</td>
			<td>无师徒&非RMB</td>
		</tr>
	-->
	<{/if}>

	<{if $key % 2 == 0}>
	<tr class='trEven main' id="level_<{$item.level}>">
	<{else}>
	<tr class='trOdd main' id="level_<{$item.level}>">
	<{/if}>
			<td><{$item.level}></td>
			<td class="t1"><{$item.master}></td>
			<td class="t2"><{$item.withoutMaster}></td>
			<td class="t3"><{$item.active}></td>
			<td class="t4"><{$item.activeMaster}></td>
			<td class="t5"><{$item.activeWithoutMaster}></td>
			<td class="t6"><{$item.nonactiveWithMaster}></td>
			<td class="t7"><{$item.nonactiveNonmaster}></td>
			<td class="t8"><{$item.paidWithMaster}></td>
			<td class="t9"><{$item.paidWithoutMaster}></td>
			<td class="t10"><{$item.nopaidWithMaster}></td>
			<td class="t11"><{$item.nopaidWithoutMaster}></td>
	</tr>
<{/foreach}>
</table>

<script><!--

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



/*
$(function(){
	$('.content td').each(function(idx,val){
		if(idx == 0){
			$(this).text('综合统计');
		}else{
			var tempItr = $(this);
			var sum = 0;

			tempItr = tempItr.next('.main').find('td');
			while(tempItr = tempItr.next('.main').find('td')  && tempItr.eq(idx) != null){
					try {
						sum += parseInt(tempItr.text());
					}catch(err){
						sum += 0;
					}
			}							
		}
	});
});
*/




$(function(){
	$('#end_index').keydown(function(event){
		event.keyCode == 13 && $('#omit').trigger('click');				
	})
})




$(function(){
	//omit 1~10 level
	var omitLevels = jQuery.range(0,10);
	$.each(omitLevels,function(id,val){
		$('#level_'+val).hide();
	})
	
	$('#omit').click(function(){
		var start = parseInt($('#start_index').val());
		var end = parseInt($('#end_index').val());
		var range = $.range(start,end); 
		$(".main").hide();
		$.each(range,function(idx,val){
			$('#level_'+val).show();
		});
		//$(".main:visible:last")			
		//update total
		updateSum();


		
				
	})
	
})

function updateSum(){
	var ary = $.range(1,11);
	$.each(ary,function(id,val){
			var sum = 0;
			$('.t'+val+':visible').each(function(idx,val){
				try{
					sum += parseInt($(this).text());
				}catch(e){
					
				}	
			});
			$('#t'+val).text(sum);
		})
}


$(function(){
	updateSum();
})

--></script>
