<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<title>
	玩家的元宝使用统计
</title>
</head>

<body style="margin:0">
<b>数据分析：元宝使用统计</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type='hidden' name='order' value='<{$order}>' />

&nbsp;选择玩家充值总额区间
<select name="level_type">
	<{html_options options=$typeoption selected=$level_type}>
</select>
&nbsp;选择排序
<select name="order">
	<{html_options options=$order_list selected=$order}>
</select>
&nbsp;&nbsp;
		或者查询指定玩家帐号:
		<input type='text' id="acname" name='acname' size='10' value='<{$search1}>' onkeydown="document.getElementById('nickname').value=''" />
		或者角色名:
		<input type='text' id="nickname" name='nickname' size='10' value='<{$search2}>' onkeydown="document.getElementById('acname').value=''"/>

<br />
&nbsp;统计起始时间：<input type='text' name='dateStart' id="dateStart" size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id="dateEnd" size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />

&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&level_type=<{$level_type}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&level_type=<{$level_type}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&level_type=<{$level_type}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=ALL&dateEnd=ALL&level_type=<{$level_type}>';">

</form>

</div>



<{if $level_type != 'all'}>

<div class="tScroll">
<table cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">

<tr class='table_list_head' align='center'><td colspan=20>
<{if $data.title == ''}>没有任何数据<{else}>元宝使用统计&nbsp;&nbsp;&nbsp;&nbsp
	<{$data.title.text}>，日期从<{$data.title.day1}>到<{$data.title.day2}>
<{/if}>
</td></tr>

		<tr class='table_list_head' align="center">
			<td ></td><td>操作类型</td>
			<td>总元宝</td>
			<td>绑定元宝</td>
			<td>元宝</td>
			<td>实际数量(实际开宝箱次数、<br>实际购物道具总数量等)</td>
			<td>记录操作次数</td>
		</tr>

<{foreach key=pay_type_name item=pay_type_list from=$data}>
<{if $pay_type_name !='title'}>
<{foreach key=one_key item=one_data from=$pay_type_list.data}>

<{if $one_key == 0}>
<tr class='trEven' align="center">
<td width="22" rowspan="<{$pay_type_list.count}>" align="center" bgcolor="#EBF9FC"><b><{$pay_type_name}></b></td>
<{else}>
		<{if $one_key % 2 == 0}>
		<tr class='trEven' align="center">
		<{else}>
		<tr class='trOdd' align="center">
		<{/if}>
<{/if}>
<td<{$one_data.bgColor}> align="left"><{$one_data.desc}></td>
<td<{$one_data.bgColor}> align="left"><{$one_data.gold}>&nbsp;</td>
<td<{$one_data.bgColor}> align="left"><{$one_data.gold_bind}>&nbsp;</td>
<td<{$one_data.bgColor}> align="left"><{$one_data.gold_unbind}>&nbsp;</td>
<td<{$one_data.bgColor}> align="left"><{$one_data.ss}></td>
<td<{$one_data.bgColor}> align="left"><{$one_data.c}></td>

</tr>

<{/foreach}>
<tr class='trEven'><td colspan=20></td></tr>
<{/if}>
<{/foreach}>
</table>
</div>

<br />

<div class="tScroll">
<table cellspacing="1" cellpadding="3" border="0" class='paystat' >
		<tr class='table_list_head' align='center'>
			<td colspan=10>
				道具购买统计&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0 至 <{$search_keyword2}> 23:59:59
			</td>
		<tr>
		<tr class='table_list_head'>
			<td>道具名</td>
			<td>总个数</td>
			<td>总元宝</td>
			<td>绑定元宝</td>
			<td>元宝</td>
			<td>记录操作次数</td>
		</tr>
	<{foreach item=row from=$buy_stat}>
		<tr class="<{cycle values='trOdd, trEven'}>">
			<td><{$row.item_data.item_name}></td>
			<td><{$row.amount}></td>
			<td><{$row.gold}></td>
			<td><{$row.gold_bind}></td>
			<td><{$row.gold_unbind}></td>
			<td><{$row.op_count}></td>
		</tr>
	<{/foreach}>
	
		<tr class='table_list_head'>
			<td>道具名</td>
			<td>总个数</td>
			<td>总元宝</td>
			<td>绑定元宝</td>
			<td>元宝</td>
			<td>记录操作次数</td>
		</tr>
		<tr class='table_list_head' align='center'>
			<td colspan=10>
				道具购买统计&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0 至 <{$search_keyword2}> 23:59:59
			</td>
		<tr>
	</table>
</div>

<{else}>

<div class="tScroll">
<table cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="table_list">

<tr class='table_list_head' align='center'><td colspan=20>
<font color=red>元宝使用统计&nbsp;&nbsp;&nbsp;&nbsp各个付费级别段放一起来看</font>，日期从<{$search_keyword1}>到<{$search_keyword2}>
</td></tr>

		<tr class='table_list_head' align="center">
			<td rowspan='2'></td><td rowspan='2'>操作类型</td>
			<td colspan="<{$type_list_count}>">总元宝</td>
			<td colspan="<{$type_list_count}>">实际数量</td>
			<td colspan="<{$type_list_count}>">记录操作次数</td>
		</tr>
		<tr class='table_list_head' align="center">
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td>
		</tr>

<{foreach key=pay_type_name item=pay_type_list from=$data}>
<{foreach key=one_key item=one_data from=$pay_type_list.data}>

<{if $one_key == 0}>
<tr class='trEven' align="center">
<td width="22" rowspan="<{$pay_type_list.count}>" align="center" bgcolor="#EBF9FC"><b><{$pay_type_name}></b></td>
<{else}>
		<{if $one_key % 2 == 0}>
		<tr class='trEven' align="center">
		<{else}>
		<tr class='trOdd' align="center">
		<{/if}>
<{/if}>
<td<{$one_data.bgColor}> align="left"><{$one_data.name}></td>
<{foreach item=itemval from=$one_data.gold}><td align="right" ><{$itemval}></td><{/foreach}>
<td bgcolor="#CCCCCC"></td>
<{foreach item=itemval from=$one_data.gold_bind}><td align="right" ><{$itemval}></td><{/foreach}>
<td bgcolor="#CCCCCC"></td>
<{foreach item=itemval from=$one_data.gold_unbind}><td align="right" ><{$itemval}></td><{/foreach}>
<td bgcolor="#CCCCCC"></td>
<{foreach item=itemval from=$one_data.ss}><td align="right" ><{$itemval}></td><{/foreach}>
<td bgcolor="#CCCCCC"></td>
<{foreach item=itemval from=$one_data.c}><td align="right" ><{$itemval}></td><{/foreach}>
<td bgcolor="#CCCCCC"></td>
</tr>

<{/foreach}>
<tr bgcolor="#CCCCCC"><td colspan=20></td></tr>
<{/foreach}>
</table>
</div>

<br />

<div class="tScroll">
	<table cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="table_list">
	<tr class='table_list_head' align='center'><td colspan=19>
		<font color=red>道具购买统计&nbsp;&nbsp;&nbsp;&nbsp;各个付费级别段放一起来看</font>，日期从<{$search_keyword1}>到<{$search_keyword2}>
	</td></tr>

		<tr class='table_list_head' align="center">
			<td rowspan='2'>道具名</td>
			<td colspan=6>总元宝</td>
			<td colspan=6>总个数</td>
			<td colspan=6>记录操作次数</td>
		</tr>
		<tr class='table_list_head' align="center">
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
		</tr>
	<{foreach key=key item=item from=$all_case_by_id}>

			  <tr class="<{cycle values='trOdd, trEven'}>">
				<td><{$item.name}></td>

				<{if $item.0.gold_bind}>
					<td align="right"><{$item.0.gold_bind}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.50.gold_bind}>
					<td align="right"><{$item.50.gold_bind}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.200.gold_bind}>
					<td align="right"><{$item.200.gold_bind}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.999999999.gold_bind}>
					<td colspan=2 align="right"><{$item.999999999.gold_bind}></td>
				<{else}>
					<td colspan=2 align="right">0</td>
				<{/if}>
				<td bgcolor="#CCCCCC"></td>

				<{if $item.0.amount}>
					<td align="right"><{$item.0.amount}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.50.amount}>
					<td align="right"><{$item.50.amount}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.200.amount}>
					<td align="right"><{$item.200.amount}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.999999999.amount}>
				 	<td colspan=2 align="right"><{$item.999999999.amount}></td>
				<{else}>
					<td colspan=2 align="right">0</td>
				<{/if}>
				<td bgcolor="#CCCCCC"></td>

				<{if $item.0.op_count}>
					<td align="right"><{$item.0.op_count}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.50.op_count}>
					<td align="right"><{$item.50.op_count}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.200.op_count}>
					<td align="right"><{$item.200.op_count}></td>
				<{else}>
					<td align="right">0</td>
				<{/if}>

				<{if $item.999999999.op_count}>
					<td colspan=2 align="right"><{$item.999999999.op_count}></td>
				<{else}>
					<td colspan=2 align="right">0</td>
				<{/if}>
			 </tr>

	<{/foreach}>
		<tr class='table_list_head' align="center">
			<td rowspan='2'>道具名</td>
			<td colspan=6>总元宝</td>
			<td colspan=6>总个数</td>
			<td colspan=6>记录操作次数</td>
		</tr>
		<tr class='table_list_head' align="center">
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
			<td>非RMB</td><td>50元以内</td><td>50到200元</td><td colspan=2>200元以上</td><td bgcolor="#CCCCCC"></td>
		</tr>
	</table>
</div>


<{/if}>


<br>

</body>
</html>