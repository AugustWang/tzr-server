<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>每日登录详情</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>



<body>
<b>登录统计：每日登录统计</b>
<pre>
1、每日流失付费用户数：当天为该付费数最后登录时间的人数；
2、三日内付费用户登录数：近三天有登录的付费用户数。
</pre>



	<form action="#" method="post">
	<table style="margin:5px;">
		<tr>
			<td>开始日期：<input type="text" size="10" name="start" id="start" value="<{$start}>"><img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td>结束日期：<input type="text" size="10" name="end" id="end" value="<{ $end}>"><img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
		</tr>
	</table>
	</form>
	<br/><br/>
		
		
<table  cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" >
<tr><td bgcolor="#FFFFFF">
</table>

<div class="tScroll frm" id="all" >
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>每日登录次数</b></td>
    <{foreach key=key item=item from=$data}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
         <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  总量：<{$item.cid}>"
          	>
          	<div><{$item.cid}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.cid == 0 }>
				0  	
            <{else}>
            	<{$item.cid/$max.cid}>
            <{/if}>
             "  />
		  </td>
        </tr>
      </table>
  </td>
    <{/foreach}>
 </tr>



<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>每日登录角色数</b></td>
    <{foreach key=key item=item from=$data}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  总量：<{$item.crid}>"
          	>
          	<div><{$item.crid}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.crid == 0}>
	            0
            <{else}>
            	<{$item.crid/$max.crid}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>
		
		
		
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>每日登录IP</b></td>
    <{foreach key=key item=item from=$data}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  总量：<{$item.cip}>"
          	>
          	<div><{$item.cip}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.cip == 0}>
	            0
            <{else}>
            	<{$item.cip/$max.cip}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>
		
		
		
		
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>每日流失付费用户数</b></td>
    <{foreach key=key item=item from=$data}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  总量：<{$item.loss}>"
          	>
          	<div><{$item.loss}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.loss == 0}>
	            0
            <{else}>
            	<{$item.loss/$max.loss}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>
		
		
		


<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>三日内付费用户登录数</b></td>
    <{foreach key=key item=item from=$data}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.date}>  总量：<{$item.login}>"
          	>
          	<div><{$item.login}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.login == 0}>
	            0
            <{else}>
            	<{$item.login/$max.login}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>
		
		
		
		

		
 <tr>
    <td width="23" height="30" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
  <{foreach key=data item=item from=$data}>
    <{if $item.weekend}>
    <td height="30" bgcolor="#DD2020" align="center"><{$item.date}><br>周日</td>
    <{else}>
    <td height="30" bgcolor="#C0C0C0" align="center"><{$item.date}></td>
    <{/if}>
  <{/foreach}>
  </tr>
		
	
</body>
</html>