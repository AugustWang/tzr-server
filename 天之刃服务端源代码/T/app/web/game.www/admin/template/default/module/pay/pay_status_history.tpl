<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>所有充值记录明细</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style type="text/css">
	#tblFix input[type="text"]{
		text-align:center;
		height:15px;
	}
</style>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$(".showAll").click(function(){
			$(this).parent().parent().find(".summary").hide();
			$(this).parent().parent().find(".detail").show();
		});
		$(".close").click(function(){
			$(this).parent().parent().find(".summary").show();
			$(this).parent().parent().find(".detail").hide();
		});
		$("#switch").click(function(){
			$("#tblFix").toggle();
		});
		
		$("#btnSubmit").click(function(){
			if(checkData()){
//				$("#frm").attr("action","?action=do");
				$("#frmFix").submit();
			}
		});
		$("#PayMoney").keyup(function(){
			var pay_money = $("#PayMoney").val();
			if(!isNaN(pay_money) && parseFloat(pay_money) > 0){
				$("#PayGold").val( parseFloat(pay_money)*10 ); //把充值获得元宝 自动填上 ，比率 1RMB:10元宝
			}else{
				$("#PayGold").val("");
			}
		});
	});

function checkData(){
	var err = [];
	var pay_money = $("#PayMoney").val();
	var pay_gold = $("#PayGold").val();
	
	if("" == $.trim($("#PayNum").val())){
		err.push("请填写订单号");
	}
	if("" == $.trim($("#PayToUser").val())){
		err.push("请填写玩家帐号");
	}
	if(""==pay_money || isNaN(pay_money) || parseFloat(pay_money) < 0){
		$("#PayMoney").val("");
		err.push("充值金额必须为正数");
	}
	if(""==pay_gold || isNaN(pay_gold) || parseFloat(pay_gold) < 0){
		$("#PayGold").val("");
		err.push("充值获得元宝必须为正数");
	}
	if(err.length > 0){
		var str = err.join("\n");
		alert(str);
		return false;
	}
	return true;
}	
</script>
<body style="margin:0">
<b>充值与消费：所有充值日志</b>




<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">

&nbsp;统计起始时间：<input type='text' name='dateStart' id='dateStart' size='10' value='<{$dateStart}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$dateEnd}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
<input type="image" src="/admin/static/images/search.gif" class="input2" align="absmiddle" />

&nbsp;&nbsp;
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?dateStart=ALL&dateEnd=ALL&sort_1=<{$search_sort_1}>&sort_2=<{$search_sort_2}>';">



&nbsp;&nbsp;&nbsp;&nbsp;
总共<{$record_count}>个记录

</form>
</div>

<table width="100%"  border="0" cellspacing="0" cellpadding="0"  class='table_page_num'>
  <tr>
    <td height="30">
       <{if $page_count>0}>
		<form method="get" action="">
		 <{foreach key=key item=item from=$page_list}>
		 <a href="<{$URL_SELF}>?brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
		 <{/foreach}>
		总页数(<{$page_count}>)
			<input name="brand_id" type="hidden" value="<{$search_brandid}>">
			<input name="q" type="hidden" value="<{$search_keyword}>">
			<input name="series_id" type="hidden" value="<{$search_seriesid}>">
			<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
			<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
		  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
		</form>
		<{else}>
		&nbsp;
		<{/if}>
    </td>
    <td><input type="button" id="switch" name="switch" value="补单/改单" /></td>
  </tr>
</table>


<form id="frmFix" action="?action=update" method="POST">
<table class="DataGrid" id="tblFix" style="<{$displayFix}>">
	<tr>
		<th>充值日期</th>
		<th>玩家帐号</th>
		<th>IP</th>
		<th>订单号</th>
		<th>充值金额(￥)</th>
		<th>充值获得元宝数</th>
		<th>&nbsp;</th>
	</tr>
	<tr align="center">
		<td>
		<input type="hidden" name="Log[id]" id="LogId" value="<{$Log.id}>" />
		<input type="text" size="22" style="text-align:left;height:15px;" class="Wdate" name="Log[PayTime]" id="PayTime" value="<{$Log.PayTime}>" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'});"></td>
		<td><input type="text" name="Log[PayToUser]" id="PayToUser" value="<{$Log.PayToUser}>"></td>
		<td><input type="text" name="Log[IP]" id="IP" value="<{$Log.IP}>"></td>
		<td><input type="text" name="Log[PayNum]" id="PayNum" value="<{$Log.PayNum}>"></td>
		<td><input type="text" name="Log[PayMoney]" id="PayMoney" value="<{$Log.PayMoney}>"></td>
		<td><input type="text" name="Log[PayGold]" id="PayGold" value="<{$Log.PayGold}>"></td>
		<td><input type="button" name="btnSubmit" id="btnSubmit" value="确 定"/></td>
	</tr>
	<{if $msg}>
	<tr>
		<td colspan="7" style="color:red;"><b><{$msg}></b></td>
	</tr>
	<{/if}>
</table>
</form>
<{if $ok}>
	<span style="color:red;"><b><{$ok}></b></span>
<{/if}>

<table cellspacing="1" cellpadding="3" border="0"  class='DataGrid' >
<!-- SECTION  START -------------------------->
<form id="form1" name="form1" method="post" action="">
<{section name=loop loop=$keywordlist}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr>
		<th>ID</th><th>充值时间</th><th>用户名</th><th >IP地址</th><th>参数内容</th><th>备注</th><th style="width:30px;">操作</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd' <{if "true"!=$keywordlist[loop].desc}>style="color:red;font-weight:bold;"<{/if}>>
	<{else}>
	<tr <{if "true"!=$keywordlist[loop].desc}>style="color:red;font-weight:bold;"<{/if}>>
	<{/if}>
		<td>
		<{$keywordlist[loop].id}>
		</td><td>
		<{$keywordlist[loop].mtime|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>
		<{$keywordlist[loop].payto_user}>
		</td><td>
		<{$keywordlist[loop].user_ip}>
		</td><td>
			<{ $keywordlist[loop].detail }>
		</td><td>
		<{$keywordlist[loop].desc}>
		</td><td>
		<a style="color:blue;text-decoration:underline;" href="?action=update&id=<{$keywordlist[loop].id}>">修改</a>
		</td>
	</tr>
<{sectionelse}>
	&nbsp;&nbsp;<b>暂无数据</b>
<{/section}>
<!-- SECTION  END -------------------------->

</form>
</table>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
    <{if $page_count>0}>
		<form method="get" action="">
		 <{foreach key=key item=item from=$page_list}>
		 <a href="<{$URL_SELF}>?brand_id=<{$search_brandid}>&amp;q=<{$search_keyword|escape:"url"}>&amp;series_id=<{$search_seriesid}>&amp;sort_1=<{$search_sort_1}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
		 <{/foreach}>
		
		总页数(<{$page_count}>)
			<input name="brand_id" type="hidden" value="<{$search_brandid}>">
			<input name="q" type="hidden" value="<{$search_keyword}>">
			<input name="series_id" type="hidden" value="<{$search_seriesid}>">
			<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
			<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
		  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
		</form>
		<{else}>
		&nbsp;
		<{/if}>
    </td>
  </tr>
</table>

</div>

</body>
</html>