<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>流失用户统计
</title>
<link href="../css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style>
	td {text-align:center;}
</style>
</head>
<body style="margin:0;padding:0;">
<b>数据分析：流失用户数</b>
<div class='divOperation'>
<form name="myform" method="post" action="<{$URL_SELF}>">
统计起始时间：<input type='text' name='date1' id='date1' size='10' value='<{$date1}>' />
<img onclick="WdatePicker({el:'date1'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;终止时间：<input type='text' name='date2' id="date2" size='10' value='<{$date2}>' />
<img onclick="WdatePicker({el:'date2'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>
</div>

<br/>
日-用户登陆量()：近3天内有登录的用户量<br/>
日-历史付费用户登陆量：付费并近3天有登录的用户量<br/>
<div class="tScroll">
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">

<tr>
<td width="50" height="120" align="center" bgcolor="#EBF9FC"><b>日用户流失量</b></td>
    <{foreach  item=item from=$ary}>
    <td width="50" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="50" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.datestr}>  日用户登陆量：<{$data_one.count}>">
          	<div><{$item.onlineNum}></div>
            <img src="/admin/static/images/green.gif" width="10" height="<{$item.onlineNum*$maxOnline}>"  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<tr>
<td width="50" height="120" align="center" bgcolor="#EBF9FC"><b>日付费用户登陆量</b></td>
    <{foreach item=item from=$ary}>
    <td width="50" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="50" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.datestr}>  日付费用户登陆量：<{$item.onlinePaid}>"
          	>
          	<div><{$item.onlinePaid}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="<{$item.onlinePaid*$maxPaid}>"  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<tr>



<tr>
<td width="50" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
    <{foreach key=data_day item=item from=$ary}>
    <{if $item.weekend}>
    	<td height="50" bgcolor="#DD2020" align="center"><{$item.datestr}> <br/>开服<{$item.serverOnlineDays}></>天<br>周日</td>
    <{else}>
    <td height="50" bgcolor="#C0C0C0" align="center"><{$item.datestr}>  <br/>开服<{$item.serverOnlineDays}></>天<br></td>
    <{/if}>
    <{/foreach}>
  </tr>
<tr>

</table>
<span style="text-align:center; margin-left:25px;">
	日期一栏，分2行显示，第一行显示月日，第二行显示开服第几天。如果是星期天则背景红色显示。
</span>
<BR><BR>

周用户登陆量：近7天内有登录的用户量<br/>
周付费用户登陆量：付费并近7天有登录的用户量<br/>

<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">


<tr>
<td width="50" height="120" align="center" bgcolor="#EBF9FC"><b>周用户登录量</b></td>
    <{foreach key=date_day item=item from=$aryWeek}>
    <td width="50" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="50" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="第<{$data_week}>周  用户登录量：<{$data_one.count}>"
          	>
          	<div><{$item.onlineNum}></div>
            <img src="/admin/static/images/green.gif" width="10" height="<{$item.onlineNum*$weekMaxOnline}>"  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<tr>
<td width="50" height="120" align="center" bgcolor="#EBF9FC"><b>周付费用户登陆量</b></td>
    <{foreach key=data_week item=item from=$aryWeek}>
    <td width="50" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="50" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="第<{$data_week}>周  付费用户登陆量：<{$data_one.onlinePaid}>"
          	>
          	<div><{$item.onlinePaid}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="<{$item.onlinePaid*$weekMaxPaid}>"  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<tr>

<tr>
<td width="50" align="center" bgcolor="#EBF9FC"><b>周期</b></td>
    <{foreach key=key item=item from=$aryWeek}>
    <td width="50" bgcolor="#999999" align="center" valign="bottom">
    <{$item.startStr}><BR><{$item.endStr}> <BR>
    <{$item.weekNo}>周 
	</td>
    <{/foreach}>
  </tr>
</table>
<span style="text-align:center; margin-left:25px;">
	周期一栏，分3行显示，第一行显示该周开始月日，第一行显示该周结束月日，第三行显示开服第几周。
</span>
<BR><BR>

</div>

</body>
</html>
