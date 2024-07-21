<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>交易查询</title>
<link href="/admin/static/css/style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>

<style type="text/css">
.warning td { background:red;}
.pager{
	width:auto;
	
}

.pager a{ 
	display:inline;
	background-color:red;
	width:30px;
	height:30px;
	color:blue;
}

</style>
</head>

<body style="margin:10px">
<div><b>玩家：交易查询</b></div>




<div style="font-weight:bold; color:#d6aaff; font-size:12px;">交易整条为粉红色，表示某方交易的元宝数量大于 10 锭银子、灵石等级≥3级、材料等级≥3级、强化石≥4级、所有银票、装备颜色≥紫色
<br/>如交易成功，则每个用户下方的物品为本次交易获得的物品、资源、铜钱和元宝等
<br/>如没查到该玩家,将显示当天所有记录</div>


<div class='divOperation'>
	<form action="<{$URL_SELF}>" method="POST" accept-charset="utf-8">
		账号名&nbsp;&nbsp;:<input type="text/submit/hidden/button" name="accountName" value="<{$accountName}>" id="accountName"><br/>
		角色名&nbsp;&nbsp;:<input type="text/submit/hidden/button" name="roleName" value="<{$roleName}>" id="roleName"><br/>
	开始时间:<input type="text/submit/hidden/button" name="start" value="<{$start}>" id="start"><img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"><br/>
	结束时间:<input type="text/submit/hidden/button" name="end" value="<{$end}>" id="end"><img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
		
	<p><input type="submit" value="查询"></p>
	
	</form>
	
<div class='tbl_user_msg_list'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list'>
		<tr class='table_list_head'>
			<td  width="6%">ID</td>
			<td  width="12%">发起的玩家</td>
			<td  width="10%">发起方获得银两(文)</td>
			<td  width="10%">发起方获得元宝</td>
			<td  width="7%">目标玩家</td>
            <td  width="10%">目标方获得银两(文)</td>
            <td  width="10%">目标方获得元宝</td>
			<td  width="20%">时间</td>			
		</tr>
		
		
	<{$pager}>
	<{foreach key=key  item=item from=$list}>
		<{if $smarty.foreach.key % 2 == 0}> 
		<tr class='trEven main' style="background-color:<{$item.color}>" id="am_<{$key}>">
		<{else}> 
		<tr class='trOdd main' style="background-color:<{$item.color}>">
		<{/if}>
			<td  width="6%"><{$item.id}></td>
			<td  width="12%"><{$item.from_role_name}></td>
			
			<{if $item.to_silver >= 100000}>
				<td  width="10%"><font color="red"><{$item.to_silver}></font></td>
			<{else}>
				<td  width="10%"><{$item.to_silver}></td>
			<{/if}>
			<{if $item.to_gold >= 100}>
                <td  width="10%"><font color="red"><{$item.to_gold}></font></td>
            <{else}>
                <td  width="10%"><{$item.to_gold}></td>
            <{/if}>

            
			<td  width="7%"><{$item.to_role_name}></td>
			
			<{if $item.from_silver >= 100000}>
                <td  width="10%"><font color="red"><{$item.from_silver}></font></td>
            <{else}>            
                <td  width="10%"><{$item.from_silver}></td>
            <{/if}>
            <{if $item.from_gold >= 100}>
                <td  width="10%"><font color="red"><{$item.from_gold}></font></td>
            <{else}>            
                <td  width="10%"><{$item.from_gold}></td>
            <{/if}>
            
			<td  width="20%"><{$item.date_format}></td>		
		</tr >
		
		<tr class="showdata hidden am_<{$key}>">
            <td colspan="6" class="table_list_head" style="background-color:#CCC;">发起方获得物品:</td>
        </tr>
        <{foreach from=$item.to_goods item=each}>
        <tr class="showdata hidden am_<{$key}>">
            <td>物品名称:<span class="t"><{$each.name}></span></td>
            <td>数量:<span class="t"><{$each.num}></span></td>
            <td>品质:<span class="t"><{$each.fineness}></span>  &nbsp;&nbsp;&nbsp;&nbsp;颜色:<span class='t'><{$each.color}></span></td>
            <td>打孔数:<span class='t'><{$each.punch_num}></span> </td>
            <td>强化ID:<span class='t'><{$each.rein_id}></span></td>
            <td>镶嵌石头:<span class='t'><{$each.stones}></span></td>
        </tr>
        <{/foreach}>
		
		<tr class="showdata hidden am_<{$key}>">
			<td colspan="6" class="table_list_head"  style="background-color:#CCC;">目标方获得物品:</td>
		</tr>
		
		
		<{foreach from=$item.from_goods item=each}>
		<tr class="showdata hidden am_<{$key}>">
			<td>物品名称:<span class="t"><{$each.name}></span></td>
			<td> 数量:<span class="t"><{$each.num}></span></td>
			<td>品质:<span class="t"><{$each.fineness}></span>  &nbsp;&nbsp;&nbsp;&nbsp;颜色:<span class='t'><{$each.color}></span></td>
			<td>打孔数:<span class='t'><{$each.punch_num}></span> </td>
			<td>强化ID:<span class='t'><{$each.rein_id}></span></td>
			<td>镶嵌石头:<span class='t'><{$each.stones}></span></td>
		</tr>
		<{/foreach}>
		
		
		
		
	<{/foreach}>
	</table>
	

</div>


<script>
$(function(){
	$(".main").click(function(){
		$("."+$(this).attr('id')).toggleClass('hidden');
	})
});


$(function(){


	
})

</script>

<style>
.hidden{
	display:none;
}
.t{
	color:red;
}
.title{
	font-size:1.1em;
	border-left:20px;
		
}
</style>


</body>
</html>
