<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>boss状态查看
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

<body style="margin:0">


<b>boss状态查看</b>
<div class='divOperation'>
<form name="myform" method="post" action="<{$URL_SELF}>?page_no=<{$page_no}>">
&nbsp;boss名称：
<input type='text' id="bossname" name='bossname' size='10' value='<{$bossname}>' />
&nbsp;统计起始时间：
<input type='text' id="start" name='start' size='10' value='<{$start}>' />
<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

&nbsp;终止时间：
<input type='text' name='end' id="end" size='10' value='<{$end}>' />
<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>


<div class='boss_state' width='50%'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' width="50%">
		<tr class='table_list_head'>
			<td  width="5%">ID</td>
			<td  width="10%">BOSS名称</td>
			<td  width="10%">BOSS状态</td>
			<td  width="10%">地图</td>
			<td  width="10%">门派名称</td>
            <td  width="10%">时间</td>
			<td  width="10%">最后攻击的玩家</td>
            <td  width="10%">掉落物品</td>
            <td  width="5%">昨日热度</td>
		</tr>
			
	
	<{foreach key=key item=item from=$logs}>
		<tr class="each">
			<td><{$item.id}></td>
			<td><{$item.display_name}></td>
			<td><{$item.display_state}></td>
			<td><{$item.map_name}></td>
            <td><{$item.family_name}></td>
			<td><{$item.display_time}></td>
			<td><{$item.display_player}></td>
			<td class="item_disply"><{$item.display_item}></td>			
			<td><{$item.popularity}></td>
		</tr>
		
		<tr class="data hidden" >
			<td colspan="7" align="center"><{$item.display_item}></td>			
		</tr>
		
	<{/foreach}>
	</table>
	<div>
	 <{foreach key=key item=item from=$pagelist}>
	 <a href="<{$URL_SELF}>?start=<{$start}>&amp;end=<{$end}>&amp;page_no=<{$item}>&bossname=<{$bossname}>"><{$key}></a><span style="width:5px;"></span>
	 <{/foreach}>
	 </div>
<script>
var cursor = ['trOdd','trEven'];
$(".each").each(function(idx,val){
	$(this).addClass(cursor[idx%2]);
});
$(function(){
	$('.item_disply').each(function(){
			$(this).text($(this).text().substring(0,10)+"  ...详情")
		})
	
	$(".each").click(function(){
		$(this).next('.data').toggleClass('hidden');
	});
	
});

</script>




<style>
.hidden{
	display:none;
}
</style>