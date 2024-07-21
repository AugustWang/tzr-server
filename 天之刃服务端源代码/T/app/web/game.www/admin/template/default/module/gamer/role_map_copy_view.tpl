<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>角色讨伐敌营记录查看
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script src="/admin/static/js/jquery.min.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body style="margin:0">


<b>角色讨伐敌营记录查看</b>
<div class='divOperation'>
<form name="myform" method="post" action="role_map_copy_view.php">
查看开始日期：
<input type='text' name='start' id='start' size='10' value='<{$start}>' />
<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
查看结束日期:
<input type='text' name='end' id='end' size='10' value='<{$end}>' />
<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
角色名称：
<input type='text' name='rolename' size='10' value='<{$rolename}>' />

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>

<form action="role_map_copy_view.php" method="post" class="l_align" style="display:inline;float:left;">
	<input type="hidden" name="start" value="<{$start}>"></input>
	<input type="hidden" name="end" value="<{$end}>"></input>
	<input type="hidden" name="rolename" value="<{$rolename}>"></input>
	<input type="submit" name="btn" value="今天"></input>
</form>




<br/><br/>
<{$pager}>
<div class='family_ybc_view' width='50%'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' width="50%">
		<tr class='table_list_head'>
			<td  width="10%">国家</td>
			<td  width="10%">地图ID</td>
			<td  width="10%">地图名称</td>
			<td  width="10%">角色名称</td>
			<td  width="10%">队长ID</td>
			<td  width="10%">NPC ID</td>
			<td  width="10%">开始时间</td>
			<td  width="10%">结束时间</td>
			<td  width="10%">怪物等级</td>
	
		</tr>
			
			
	<{foreach key=key item=item from=$result}>
		<tr class="each">
			<td  width="10%"><{$item.faction_name}></td>
			<td  width="10%"><{$item.map_id}></td>
			<td  width="10%"><{$item.map_name}></td>
			<td  width="10%"><{$item.role_name}></td>
			<td  width="10%"><{$item.leader_role_name}></td>
			<td  width="10%"><{$item.npc_id}></td>
			<td  width="10%"><{$item.start_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
			<td  width="10%"><{$item.end_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
			<td  width="10%"><{$item.vwf_monster_level}></td>

		</tr>
		
	<{/foreach}>
	</table>
</div>
</div>
<script >
$(function(){
	$('.each:even').addClass('trOdd');
	$('.each:odd').addClass("trEven");

})



</script>



</body>
</html>