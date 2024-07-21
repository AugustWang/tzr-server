<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>每天活跃用户数</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>


<body style="margin:0">
<b>数据分析：活跃与忠诚用户数</b>
<div class='divOperation'>


<form name="myform" method="post">

开始时间:<input type="text"  id="start" name="start" value=<{$start}> > 
<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
结束时间:<input type="text"  id="end" name="end" value=<{$end}> >
<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
<input type="image" src="/admin/static/images/search.gif" class="input2"  />
</form>
</div>





<div class="tScroll frm" id="all">
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr>
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>活跃用户</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>   活跃用户数：<{$item.active}>"
          	>
          	<div><{$item.active}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.active == 0}>
            		0
            	<{else}>
            		<{$item.active/$max.active}>
            	<{/if}>"
             />
		  </td>
        </tr>
      </table>
  </td>
    <{/foreach}>
  </tr>
<tr>
	
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>忠诚用户</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="18" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  忠诚用户：<{$item.loyal}>"
          	>
          	<div><{$item.loyal}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.active == 0}>
            		0
            	<{else}>
            		<{$item.active/$max.active}>
            	<{/if}>
            
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>



<tr>
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>最大在线</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="18" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}> 最大在线：<{$item.max_online}>"
          	>
          	<div><{$item.max_online}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.max_online ==0}>
            	0
            <{else}>
            	<{$item.max_online/$max.max_online}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>




<tr>
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>平均在线</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="18" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}> 最大在线：<{$item.avg_online}>"
          	>
          	<div><{$item.avg_online}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.avg_online ==0}>
            	0
            <{else}>
            	<{$item.avg_online/$max.avg_online}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>








<tr>
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>新注册</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="18" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}> 最大在线：<{$item.new_user}>"
          	>
          	<div><{$item.new_user}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.new_user ==0}>
            	0
            <{else}>
            	<{$item.new_user/$max.new_user}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>




<tr>
<td width="18" height="120" align="center" bgcolor="#EBF9FC"><b>总共注册</b></td>
    <{foreach key=key item=item from=$result}>
    <td width="18" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="18" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}> 最大在线：<{$item.total_user}>"
          	>
          	<div><{$item.total_user}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.total_user ==0}>
            	0
            <{else}>
            	<{$item.total_user/$max.total_user}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
  
  
  


  <tr>
    <td width="18" height="30" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
  <{foreach key=data item=item from=$result}>
    <{if $item.weekend}>
    <td height="30" bgcolor="#DD2020" align="center"><{$item.date}><br>周日<br>开服第<{$item.server}>天</td>
    <{else}>
    <td height="30" bgcolor="#C0C0C0" align="center"><{$item.date}><br>开服第<{$item.server}>天</td>
    <{/if}>
  <{/foreach}>
  </tr>
</table>

<span style="text-align:center; margin-left:25px;">
	日期一栏，分2行显示，第一行显示月日，第二行显示开服第几天。如果是星期天则背景红色显示。
</span>
</div>






<div style='margin:10px; padding:2px; border: 1px solid #CCCCCC;'>
	<b>活跃用户</b>：最近7天总在线时间不低于7小时的用户。并且最近三天有登录
	<br/>
	<b>忠诚用户</b>：最近7天(不是周区间)最少有3次登录，每天登录多次只算1次，并且玩家级别大于等于20级。
	<br/>
	<b>平均在线</b>：某一天的 09:00:00--23:59:59 期间，游戏实际在线数的平均数值。

	（不是24小时平均，因为0点到8点，半夜，人数太少，没有实际统计意义）
</div>