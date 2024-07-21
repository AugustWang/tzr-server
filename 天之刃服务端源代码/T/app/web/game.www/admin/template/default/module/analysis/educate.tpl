<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#showType").change(function(){
			$("#frm").submit();
		});
	});
</script>
</head>

<body>
	师徒副本查询：
	<form action="#" method="POST" id="frm">
	<table style="margin:5px;">
	    <tr>
	    <td colspan="4">
	    <input type="hidden" name='ac' value='search' />
        <span style='margin-right:20px;'>角色ID: <input type='text' id='uid' name='uid' size='11' value='<{ $base.role_id }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('nickname').value ='';" /></span>
        <span style='margin-right:20px;'>帐号: <input type='text' id='acname' name='acname' size='12' value='<{ $base.account_name }>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('uid').value ='';" /></span>
        <span style='margin-right:20px;'>角色名: <input type='text' id='nickname' name='nickname' size='12' value='<{ $base.role_name }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('uid').value ='';" /></span>
	    </td>
	    </tr>
		<tr>
			<td>开始日期：<input type="text" size="12" name="startDate" id="startDate" value="<{$startDate}>"><img onclick="WdatePicker({el:'startDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="12" name="endDate" id="endDate" value="<{$endDate}>"><img onclick="WdatePicker({el:'endDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
				<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrToday}>&amp;endDate=<{$dateStrToday}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrPrev}>&amp;endDate=<{$dateStrPrev}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrNext}>&amp;endDate=<{$dateStrNext}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至今" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$serverOnLineTime}>&amp;endDate=<{$dateStrToday}>';">
			</td>
		</tr>
	</table>
	</form>
	<table class="DataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>ID</th>
			<th>国家</th>
			<th>队长</th>
			<th>进入副本的玩家</th>
			<th>进入时间</th>
			<th>怪物级别</th>
			<th>进入人数/完成人数</th>
			<th>使用时间(秒)</th>
			<th>死亡次数</th>
			<th>副本积分</th>
		</tr>
		<{foreach from=$rsEducate item=row key=key}>
		<{if $key%2==0}>
		<tr class="odd">
		<{else}>
		<tr>
		<{/if}>
			<td><{$row.id}></td>
			<td><{$row.faction_name}></td>
			<td><{$row.leader_role_name}></td>
			<td><{$row.in_role_names}></td>
			<td><{$row.start_time}></td>
			<td><{$row.monster_level}></td>
			<td><{$row.in_number}>/<{$row.out_number}></td>
			<td><{$row.use_time}></td>
			<td><{$row.dead_times}></td>
			<td><{$row.count}></td>
		</tr>
		<{/foreach}>
	</table>
	
	<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
	  <tr>
	    <td height="30" class="even">
		 <{foreach key=key item=item from=$pagelist}>
		 <a href="<{$URL_SELF}>?startDate=<{$startDate}>&endDate=<{$endDate}>&amp;page=<{$key}>"><{$key}></a><span style="width:5px;"></span>
		 <{/foreach}>
	    </td>
	  </tr>
	</table>
</body>
</html>