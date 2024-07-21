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
<h4 align="left">宠物训练</h5>
	<form action="#" method="POST" id="frm">
	<table style="margin:5px;">
		<tr>
			<td>统计开始日期：<input type="text" size="12" name="startDate" id="startDate" value="<{$startDate}>"><img onclick="WdatePicker({el:'startDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>统计结束日期：<input type="text" size="12" name="endDate" id="endDate" value="<{$endDate}>"><img onclick="WdatePicker({el:'endDate'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		  <td>	
		  </td>
		</tr>
	</table>
    <!--宠物训练-->
    <table class="SumDataGrid" style="margin:5px; width:500px; text-align:center;">
    	<tr>
       	  <td>宠物id</td>
          <td>角色名</td>
          <td>宠物等级</td>
          <td>训练时长(h)</td>
          <td>训练消费(文)</td>
        </tr>
        <{foreach from=$rowResult item=row}>
        <tr>
        	<td><{$row.pet_id}></td>
            <td><{$row.role_name}></td>
            <td><{$row.pet_level}></td>
            <td><{$row.training_hours}></td>
            <td><{$row.training_cost}></td>
        </tr>
        <{foreachelse}>
        <tr>
        	<td colspan="4">没有数据</td>
        </tr>
        <{/foreach}>
    </table>
	</form>
</body>
</html>