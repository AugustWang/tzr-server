<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

<title>
	玩家的银两使用统计
</title>
</head>

<body style="margin:0">
<b>数据分析：银两使用统计</b>
<em>没有必要的情况下时间跨度不要太长(一个月范围内最好)</em>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type='hidden' name='order' value='<{$order}>' />

统计起始时间：<input type='text' id="dateStart" name='dateStart' size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">



&nbsp;终止时间：<input type='text' name='dateEnd' id="dateEnd" size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

<br />
		请输入玩家登录帐号:
		<input type='text' id="acname" name='acname' size='10' value='<{$search1}>' onkeydown="document.getElementById('nickname').value=''" />
		或者角色名:
		<input type='text' id="nickname" name='nickname' size='10' value='<{$search2}>' onkeydown="document.getElementById('acname').value=''" />
<!--
&nbsp;选择类型：
<select name="type" >
	<option  value='0' />可留空</option>
	<{foreach item=typex key=key from=$tlist}>
		<option value='<{$key}>' <{if $type == $key}>selected<{/if}> >
			<{$typex}>
		</option>
	<{/foreach}>
</select>
-->

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />

&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=ALL&dateEnd=ALL';">

</form>



</div>

<{if $keywordlist}>
	<table cellspacing="1" cellpadding="3" border="0" class='paystat' >
	<!-- SECTION  START -------------------------->

	<tr class='table_list_head'>
		<td colspan=7 >
	    银两使用统计&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0
	    至 <{$search_keyword2}> 23:59:59</td>
		<{if $type}><td></td><td></td><{/if}>
	</tr>
	<form id="form1" name="form1" method="post" action="">
		<tr>
			<td ></td>
			<td><em>类型</em></td>
			<{if $type}>
			<td><em>玩家角色</em></td>
			<td><em>银两数量</em></td>
			<{/if}>
			<td><em>总银两(文)</em></td>
			<td><em>绑定银两(文)</em></td>
			<td><em>不绑定银两(文)</em></td>
			<td><em>实际数量(实际开宝箱次数、实际购物道具总数量等)</em></td>
			<td><em>记录操作次数</em></td>
		</tr>
		
		
	<{foreach from=$keywordlist item=item key=key}>
		<tr class='trEven'>
			<td>
			</td>
			<td>
			<{$item.desc}>
			</td>
			<{if $type}>
				<td>
				<{$item.user_name}>
				</td>
				<td>
				<{$item.silver}>
				</td>
			<{/if}>

			<td>
			<{$item.silver}>
			</td>
			<td>
			<{$item.silver_bind}>
			</td>
			<td>
			<{$item.silver_unbind}>
			</td>
			<td>
			<{$item.ss}>
			</td>
			<td>
			<{$item.c}>
			</td>
		</tr>
	<{/foreach}>

	</form>
	</table>
<{/if}>
<br>
<{if $buy_stat}>
	<table cellspacing="1" cellpadding="3" border="0" class='paystat' >
		<tr class='table_list_head'>
			<td colspan=10>
				(银两购买的)道具统计&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$item_start}> 0:0:0 至 <{$item_end}> 23:59:59
			</td>
		<tr>
		<tr class='table_list_head'>
			<td><a href="<{$URL_SELF}>?order=itemid&dateStart=<{$search_keyword1}>&dateEnd=<{$search_keyword2}>">道具名</a></td>
			<td><a href="<{$URL_SELF}>?order=amount&dateStart=<{$search_keyword1}>&dateEnd=<{$search_keyword2}>">总个数</a></td>
			<td><a href="<{$URL_SELF}>?order=silver&dateStart=<{$search_keyword1}>&dateEnd=<{$search_keyword2}>">总银两(文)</a></td>
			<td><a href="<{$URL_SELF}>?order=silver_bind&dateStart=<{$search_keyword1}>&dateEnd=<{$search_keyword2}>">绑定银两(文)</a></td>
			<td><a href="<{$URL_SELF}>?order=silver_unbind&dateStart=<{$search_keyword1}>&dateEnd=<{$search_keyword2}>">不绑定银两(文)</a></td>
		</tr>
	<{foreach item=row from=$buy_stat}>
		<tr class="<{cycle values='trOdd, trEven'}>">
			<td><{$row.item_data.item_name}></td>
			<td><{$row.amount}></td>
			<td><{$row.silver}></td>
			<td><{$row.silver_bind}></td>
			<td><{$row.silver_unbind}></td>
		</tr>
	<{/foreach}>
	</table>
<{else}>
<br>没有道具购买数据(银两购买的)
<{/if}>

</body>
</html>