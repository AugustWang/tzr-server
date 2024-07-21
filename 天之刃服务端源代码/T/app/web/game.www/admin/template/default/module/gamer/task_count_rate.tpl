<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>任务分析</title>
<script type="text/javascript" src="/static/js/jquery.js"></script>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style>
	.current {
		color:#9966FF;
		font-weight:bold;
	}
	.hover{
		background-color:#D7C8EA;
	}
</style>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" language="javascript" src="http://www.codefans.net/ajaxjs/jquery-1.3.2.js"></script>
<script type="text/javascript" language="javascript" src="/admin/static/js/jquery1.3.2.js"></script>
<script type="text/javascript" src="/admin/static/js/table_sort.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
	$(document).ready(function(){
	
		$("#btnFaction1").click(function(){
			$("#btnFactions :button").not($(this)).removeClass("current");
			$(this).addClass("current");
			$("#faction_1").show();
			$("#faction_2").hide();
			$("#faction_3").hide();
		});
		$("#btnFaction2").click(function(){
			$("#btnFactions :button").not($(this)).removeClass("current");
			$(this).addClass("current");
			$("#faction_1").hide();
			$("#faction_2").show();
			$("#faction_3").hide();
		});
		$("#btnFaction3").click(function(){
			$("#btnFactions :button").not($(this)).removeClass("current");
			$(this).addClass("current");
			$("#faction_1").hide();
			$("#faction_2").hide();
			$("#faction_3").show();
		});
		
		$("#btnFaction1").click();
		$(".DataGrid tr").hover(
			function () {
				$(this).find("td").addClass("hover");
			},
			function () {
				$(this).find("td").removeClass("hover");
			}
		); 
		$(".DataGrid>tbody>tr:odd").addClass("odd");
	});
</script>
</head>

<body>
<div>
	注：流失用户即最近三天没有登录过游戏的用户。玩家等级为0-0即表示所有等级。
	<form method="POST" action="<{$URL_SELF}>">
	角色注册日期：<input type="text" name="start_date" id="start_date" size="10" value="<{$startDate}>"><img onclick="WdatePicker({el:'start_date'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"> 到 <input type="text" name="end_date" id="end_date"  size="10" value="<{$endDate}>" /><img onclick="WdatePicker({el:'end_date'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
	任务类型：<select name="mission_type">
			<{ html_options options=$allMissionType selected=$missionType }>
		</select> 
	&nbsp;&nbsp;玩家等级：<input type="text" size="3" name="startLevel" value="<{$startLevel}>" /> — <input size="3" type="text" name="endLevel" value="<{$endLevel}>" />
	&nbsp;&nbsp;玩家类型：<select name="userType">
			<{ html_options options=$allUserType selected=$userType }>
		</select> 
	<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"/>
	</form>
</div>
<hr />
<div id="btnFactions">
<input type="button" id="btnFaction1" value="云 州" />
<input type="button" id="btnFaction2" value="沧 州" />
<input type="button" id="btnFaction3" value="幽 州" />
</div>
<div id="missionList">
<{ foreach key=faction_id item=faction from=$result }>
<div id="faction_<{ $faction_id }>">
	  <form id="form1" runat="server">
	单击带*号列可按列排序
	<table cellspacing="0" class="myTable" width="800" id="myTalbe">
		<thead>
		<tr  style="background-color: #D7E4F5;">
			<th>任务ID</th>
			<th>任务名称</th>
			<th>任务类型</th>
			<th class="sort-numeric">总数(*)</th>
			<th class="sort-numeric">接受数(*)</th>
			<th class="sort-numeric">接受率(*)</th>
			<th class="sort-numeric">完成数(*)</th>
			<th class="sort-numeric">完成率(*)</th>
			<th class="sort-numeric">领奖数(*)</th>
			<th class="sort-numeric">领奖率(*)</th>
			<th class="sort-numeric">放弃数(*)</th>
			<th class="sort-numeric">放弃率(*)</th>
		</tr>
		</thead>
		<tbody>
		<{ foreach key=key item=row from=$faction }>
		<tr >
			<td><{ $key }></td>
			<td><{ $row.mission_name }></td>
			<td><{ $row.mission_type_name }></td>
			<td style="color:red;" title="总数"><{ if $row.total }><{ $row.total }><{ else }>0<{ /if }></td>
			<td style="color:red;" title="接受数"><{ if $row.accept }><{ $row.accept }><{ else }>0<{ /if }></td>
			<td style="color:green;" title="接受率"><{ $row.accept_rate }>%</td>
			<td style="color:red;" title="完成数"><{ if $row.finish }><{ $row.finish }><{ else }>0<{ /if }></td>
			<td style="color:green;" title="完成率"><{ $row.finish_rate }>%</td>
			<td style="color:red;" title="领奖数"><{ if $row.reward }><{ $row.reward }><{ else }>0<{ /if }></td>
			<td style="color:green;" title="领奖率"><{ $row.reward_rate }>%</td>
			<td style="color:red;" title="放弃数"><{ if $row.cancel }><{ $row.cancel }><{ else }>0<{ /if }></td>
			<td style="color:green;" title="放弃率"><{ $row.cancel_rate }>%</td>
		</tr>
		<{ /foreach }>
		</tbody>
	</table>
	</form>
</div>
<{ /foreach }>	
</div>
</body>
</html>
