<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
	道具消耗统计
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

</head>

<body style="margin-left:10px;">
<b>数据分析：道具消耗排行</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type='hidden' name='order' value='<{$order}>' />
		
<select name="class">
	<{foreach from=$itemclass item=row key=key}>
	<{if $row==$class}>
		<{assign var="select" value="selected"}>		
	<{else}>
		<{assign var="select" value=""}>
	<{/if}>
		<option value="<{$key}>" <{$select}>><{$row}></option>
	<{/foreach}>
</select>


统计起始时间：<input type='text' name='dateStart' id="dateStart" size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

&nbsp;终止时间：<input type='text' name='dateEnd' id="dateEnd" size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">


<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
<!---------
&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=ALL&dateEnd=ALL';">
--------------->
</form>

</div>

<table cellspacing="1" class='DataGrid' style="margin-left:5px;width:600px;">
		<tr>
			<th colspan=8 align="center">
			所属大类：<{$class}>（按操作显示）<{$dateStart}>~<{$dateEnd}>
			</th>
		</tr>
		<tr>				
			<th>所属分类</th>
			<th>操作</th>
			<th>操作ID</th>
			<th>总个数</th>
			<th>总元宝</th>
			<th>绑定元宝</th>
			<th>元宝</th>
			<th>记录操作次数</th>
		</tr>
	<{foreach key=key item=row from=$output}>
		<tr class="<{cycle values='trOdd, trEven'}>">
			<td><{$row.class}></td>
			<td><{$row.opt_name}></td>
			<td><{$row.mtype}></td>
			<td><{$row.count}></td>
			<td><{$row.total}></td>
			<td><{$row.bind}></td>
			<td><{$row.unbind}></td>
			<td><{$row.times}></td>
			
		</tr>
	<{/foreach}>
	</table>
<br>
<table cellspacing="1" class='DataGrid' style="margin-left:5px;width:600px;">
		<tr>
			<th colspan=8 align="center">
			所属大类：<{$class}>（按道具显示）<{$dateStart}>~<{$dateEnd}>
			</th>
		</tr>
		<tr>				
			<th>所属分类</th>
			<th>名称</th>
			<th>道具ID</th>
			<th>总个数</th>
			<th>总元宝</th>
			<th>绑定元宝</th>
			<th>元宝</th>
			<th>记录操作次数</th>
		</tr>
	<{foreach key=key item=row from=$class_output}>
		<tr class="<{cycle values='trOdd, trEven'}>">
			<td><{$row.class}></td>
			<td><{$row.item_name}></td>
			<td><{$row.itemid}></td>
			<td><{$row.count}></td>
			<td><{$row.total}></td>
			<td><{$row.bind}></td>
			<td><{$row.unbind}></td>
			<td><{$row.times}></td>
			
		</tr>
	<{/foreach}>
	</table>
</body>
</html>