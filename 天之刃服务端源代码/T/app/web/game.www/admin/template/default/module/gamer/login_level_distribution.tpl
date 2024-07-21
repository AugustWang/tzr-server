<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>登录用户等级详情</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
</head>

<body>
<b>登录统计：登录用户等级详情</b>
	<form action="#" method="POST">
	<table style="margin:5px;">
		<tr>
			<td>开始日期：<input type="text" size="10" name="start" id="start" value="<{$start}>"><img onclick="WdatePicker({el:'start'})" 
			src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			
			<td>结束日期：<input type="text" size="10" name="end" id="end" value="<{ $end}>"><img onclick="WdatePicker({el:'end'})" 
			src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle"></td>
			<td><input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  /></td>
			<td><input type='button' value="前一天" id="prev"></input></td>
			<td><input type="button" value="后一天" id="succ"></input></td>
		</tr>
	</table>
	</form>
	<br/><br/>
		
		




<div class="tScroll frm" id="all" >
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">

<tr>
<td width="70" height="120" align="center" bgcolor="#EBF9FC"><b>登录人数</b></td>
    <{foreach item=level from=$result}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="等级：<{$level.level}>  总量：<{$level.nid}>">
          	<div><{$level.nid}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max == 0}>
	            0
            <{else}>
            	<{$level.nid/$max}>
            <{/if}>
 	       px"/>            
		  </td>
        </tr>
      </table>
	</td>
    <{/foreach}>
</tr>



<tr>
	<td width="22" height="50px" align="center" bgcolor="#EBF9FC"><b>等级</b></td>
    <{foreach item=level from=$result}>
    <td width="22" bgcolor="#FFFFFF">
    	<{$level.label}>
  	</td>
    <{/foreach}>
 </tr>

<tr>
</tr>
</table>
<br/><br/>





	
<script>
	$('#prev').click(function(){
		window.location = 'login_level_distribution.php?start=<{$pre}>&end=<{$pre}>';		
	});
	
	$('#succ').click(function(){
		window.location = 'login_level_distribution.php?start=<{$next}>&end=<{$next}>';
	});

</script>
		

	
</body>
</html>