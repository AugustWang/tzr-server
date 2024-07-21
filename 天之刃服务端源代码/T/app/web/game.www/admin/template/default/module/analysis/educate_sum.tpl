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
			<td>开始日期：<input type="text" size="12" name="startDate" id="startDate" value="<{$startDate}>"><img onclick="WdatePicker({el:'startDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="12" name="endDate" id="endDate" value="<{$endDate}>"><img onclick="WdatePicker({el:'endDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td>
				&nbsp;&nbsp
					<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$dateStrPrev}>&amp;endDate=<{$dateStrPrev}>';">
					&nbsp;&nbsp
					<input type="button" class="button" name="dateAll" value="开服至昨天" onclick="javascript:location.href='<{$URL_SELF}>?startDate=<{$serverOnLineTime}>&amp;endDate=<{$dateStrToday}>';">
			</td>
		</tr>
	</table>
	</form>
	<table class="DataGrid" cellspacing="0" style="margin:5px;">
		<tr>
			<th>日期</th>
			<th>参与副本人数</th>
			<th>活跃且参与副本人数</th>
			<th>有师徒人数</th>
			<th>活跃且有师徒人数</th>
			
			<th>活跃且参与副本人数 / 参与副本人数 </th>
			<th>参与副本人数/有师徒人数</th>
			<th>参与人数/活跃且有师徒人数</th>
			
			<th>师徒副本刷幸运积分扣除元宝总数</th>
			<th>当天最高在线用户量</th>
		</tr>
		<{foreach from=$rsStatEducate item=row key=key}>
		<{if $key%2==0}>
		<tr align="center" class="odd">
		<{else}>
		<tr align="center">
		<{/if}>
			<td><{$row.date}></td>
			<td><{$row.join_count}></td>
			<td><{$row.active_join}></td>
			<td><{$row.total_educate}></td>
			<td><{$row.active_educate}></td>
			
			<td><{$row.active_join_rate}>%</td>
			<td><{$row.rate}>%</td>
			<td><{$row.active_educate_rate}>%</td>
			
			<td><{$row.total_gold}></td>
			<td><{$row.max_online}></td>
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