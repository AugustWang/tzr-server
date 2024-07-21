<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>副本统计</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style type="text/css">
#all {
	text-align: left;
	margin-left: 4px;
	line-height: 1;
}

#nodes {
	width: 100%;
	float: left;
	border: 1px #ccc solid;
}

#result {
	width: 100%;
	height: 100%;
	clear: both;
	border: 1px #ccc solid;
}




</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</script>
</head>

<body>
<div id="all">
<div id="main">
<!--start 查找玩家-->
<b>玩家：副本统计 </b><br>
<form action="" method="post">
	开始时间:<input type="text" id="start" name="start" value=<{$start}> >
	<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	(YYYY-mm-dd)
	<br/>
	结束时间:<input type="text" id="end" name="end" value=<{$end}> >
	<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	(YYYY-mm-dd)<br/>
	
	
	</select><br/>
	查看方式:<select name="view_type" id="view_type" >
	<option value='1'
		<{if $view_type == 1}>
		selected="selected"
		<{/if}>
	>列表</option>
	<option value='2'
		<{if $view_type == 2}>
		selected="selected"
		<{/if}>
	>统计图</option>
	</select>
	
	<input type="hidden" name="action" value="faction_stat"/>
	<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
</form>


<!--end 查找玩家-->
<{if !$graph}>
<br/><br/><br/>
总共有<font color="red"><{$total}></font>条记录
<br/>
<{$pager}>
<table class="DataGrid">
  <tr>
    <th>国家</th>
    <th>地图</th>
    <th>队长</th>
    <th>进入时间</th>
    <th>副本状态</th>
    <th>副本怪物级别</th>
    <th>进入副本玩家</th>
    <th>进入人数/完成人数</th>
    <th>完成时间</th>
    <th>使用时间</th>
  </tr>
 <{foreach from=$result item=item key=key}>
<tr>
	<td><{$item.faction_name}></td>
	<td><{$item.map_name}></td>
	<td><{$item.leader_role_name}></td>
	<td><{$item.enter_time}></td>
	<td><{$item.final_status}></td>
	<td><{$item.monster_lv}></td>
	<td><{$item.enter_names}></td>
	<td><{$item.enter_num}>/<{$item.final_num}></td>
	<td><{$item.complete_time}></td>
	<td><{$item.life_span}></td>
</tr>
<{/foreach}>
</table>
<{/if}>



<{if $graph}>
<br/><br/><br/>
趋势统计:(时间格式:月-日 小时)
<br/>



<table class="SumDataGrid" cellspacing="0" style="margin:5px;">
<tr>
<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">时间</div></th>
<{foreach from=$graph item=item}>
	<td><{$item.time}></td>
<{/foreach}>
</tr>


<tr>
<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">总共</div></th>
<{foreach from=$graph item=item}>
		<td align="center" height="120" valign="bottom"><{$item.all}><hr class="<{if $item.all/$max > 0.75}>hr_red<{else}>hr_green<{/if}>" style="height:<{$item.all*120/$max}>px"></td>
<{/foreach}>
</tr>


<tr>
<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">云州</div></th>
<{foreach from=$graph item=item}>
		<td align="center" height="120" valign="bottom"><{$item.1}><hr class="<{if $item.1/$max > 0.75}>hr_red<{else}>hr_green<{/if}>" style="height:<{$item.1*120/$max}>px"></td>
<{/foreach}>
</tr>


<tr>
<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">沧州</div></th>
<{foreach from=$graph item=item}>
		<td align="center" height="120" valign="bottom"><{$item.2}><hr class="<{if $item.2/$max > 0.75}>hr_red<{else}>hr_green<{/if}>" style="height:<{$item.2*120/$max}>px"></td>
<{/foreach}>
</tr>


<tr>
<th><div style="width:60px;text-align:center;clear:both; margin: 0px auto;">幽州</div></th>
<{foreach from=$graph item=item}>
	<td align="center" height="120" valign="bottom"><{$item.3}><hr class="<{if $item.3/$max > 0.75}>hr_red<{else}>hr_green<{/if}>" style="height:<{$item.3*120/$max}>px"></td>
<{/foreach}>
</tr>

</table>

<{/if}>


</div>
</div>
</body>
</html>