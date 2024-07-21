<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>每日元宝留存量与消耗量统计
</title>
<link href="/admin/static/css/style.css" rel="stylesheet" type="text/css" />
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>


<script>
$(function(){
	$('.btn').click(function(){
		$('.frm').addClass('hide');
		$('#'+$(this).attr('content')).removeClass('hide');
	})
	$('.btn')[0].click();	
})
</script>

<style>
	td {text-align:center;}
	.hide{
		display:none;
	}
</style>


</head>
<body style="margin:0">
<b>数据分析：元宝存量与消耗</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">
<tr>统计起始时间：<input type='text' name='date1' id="date1" size='10' value='<{$date1}>' />
<img onclick="WdatePicker({el:'date1'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
</tr><tr>&nbsp;终止时间：<input type='text' name='date2' id="date2" size='10' value='<{$date2}>' />
<img onclick="WdatePicker({el:'date2'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

</tr>
&nbsp;&nbsp;&nbsp;选择分等级明细类型
	<select name="level" id="level">
		<{foreach from=$levels item=item key=key}>
		<{if $key == $level }>
		<option value="<{$key}>" selected="selected"><{$item}></option>
		<{else}>
		<option value="<{$key}>"><{$item}></option>
		<{/if}>
		<{/foreach}>
	</select>


<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>
</div>

<br/>



<input type="button" class="btn" content="all" value="总共">
<input type="button" class="btn" content="bind" value="绑定">
<input type="button" class="btn" content="unbind" value="不绑定">


<table  cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr><td bgcolor="#FFFFFF">
</table>

<!-- total gold -->

<table  cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr><td bgcolor="#FFFFFF">
</table>

<div class="tScroll frm" id="all" >
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>总元宝消耗量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}> <{$item.day}>  总元宝消耗量：<{$item.consume_gold}>"
          	>
          	<div><{$item.consume_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.consume_gold == 0 }>
				0  	
            <{else}>
            	<{$item.consume_gold/$max.consume_gold}>
            <{/if}>
             "  />
		  </td>
        </tr>
      </table>
  </td>
    <{/foreach}>
  </tr>



<tr>
	
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>总元宝留存量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  总元宝留存量：<{$item.save_gold}>"
          	>
          	<div><{$item.save_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.save_gold == 0}>
	            0
            <{else}>
            	<{$item.save_gold/$max.save_gold}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>


<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>总元宝新增量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}> 总元宝新增量：<{$item.new_gold}>"
          	>
          	<div><{$item.new_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.new_gold == 0 }>
            	0
            <{else}>
            	<{$item.new_gold/$max.new_gold}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
  
  
  
  
  
  
  
  
<tr>
	
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>流通元宝消耗</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  流通元宝消耗：<{$item.cur_gold_added}>"
          	>
          	<div><{$item.cur_gold_added}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.cur_gold_added == 0}>
            		0
            	<{else}>
            		<{$item.cur_gold_added/$max.cur_gold_added}>
            	<{/if}>
            
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>


<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>流通元宝新增</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  流通银子新增：<{$item.cur_gold_consume}>"
          	>
          	<div><{$item.cur_gold_consume}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.cur_gold_consume == 0}>
            		0
            	<{else}>
            		<{$item.cur_gold_consume/$max.cur_gold_consume}>
            	<{/if}>
            
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

  
  
  
  
  <tr>
    <td width="23" height="30" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
  <{foreach key=data item=item from=$datalist}>
    <{if $item.week == 0}>
    <td height="30" bgcolor="#DD2020" align="center"><{$item.month}>.<{$item.day}><br>周日</td>
    <{else}>
    <td height="30" bgcolor="#C0C0C0" align="center"><{$item.month}>.<{$item.day}></td>
    <{/if}>
  <{/foreach}>
  </tr>
</table>

<span style="text-align:center; margin-left:25px;">
	日期一栏，分2行显示，第一行显示月日，第二行显示开服第几天。如果是星期天则背景红色显示。
</span>
</div>









<table  cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr><td bgcolor="#FFFFFF">
</table>

<!-- unbind gold -->
<div class="tScroll frm hide"  id="unbind">
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>元宝消耗量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}> <{$item.day}>  元宝消耗量：<{$item.consume_unbind_gold}>"
          	>
          	<div><{$item.consume_unbind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.consume_unbind_gold == 0 }>
				0  	
            <{else}>
            	<{$item.consume_unbind_gold/$max.consume_unbind_gold}>
            <{/if}>
             "  />
		  </td>
        </tr>
      </table>
  </td>
    <{/foreach}>
  </tr>



<tr>
	
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>元宝留存量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  元宝留存量：<{$item.save_unbind_gold}>"
          	>
          	<div><{$item.save_unbind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			<{if $max.save_unbind_gold == 0}>
	            0
            <{else}>
            	<{$item.save_unbind_gold/$max.save_unbind_gold}>
            <{/if}>
 	       "/>            
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>
<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>元宝新增量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}> 元宝新增量：<{$item.new_unbind_gold}>"
          	>
          	<div><{$item.new_unbind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.new_unbind_gold == 0 }>
            	0
            <{else}>
            	<{$item.new_unbind_gold/$max.new_unbind_gold}>
            <{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>




<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>流通元宝新增</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  不流通银子新增：<{$item.cur_unbind_gold_added}>"
          	>
          	<div><{$item.cur_unbind_gold_added}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.cur_unbind_gold_added == 0}>
            		0
            	<{else}>
            		<{$item.cur_unbind_gold_added/$max.cur_unbind_gold_added}>
            	<{/if}>
            
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>流通元宝消耗</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>  流通银子消耗：<{$item.cur_unbind_gold_consume}>"
          	>
          	<div><{$item.cur_unbind_gold_consume}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            	<{if $max.cur_unbind_gold_consume == 0}>
            		0
            	<{else}>
            		<{$item.cur_unbind_gold_consume/$max.cur_unbind_gold_consume}>
            	<{/if}>
            "  />
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>




  <tr>
    <td width="23" height="30" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
  <{foreach key=data item=item from=$datalist}>
    <{if $item.week == 0}>
    <td height="30" bgcolor="#DD2020" align="center"><{$item.month}>.<{$item.day}><br>周日</td>
    <{else}>
    <td height="30" bgcolor="#C0C0C0" align="center"><{$item.month}>.<{$item.day}></td>
    <{/if}>
  <{/foreach}>
  </tr>
</table>

<span style="text-align:center; margin-left:25px;">
	日期一栏，分2行显示，第一行显示月日，第二行显示开服第几天。如果是星期天则背景红色显示。
</span>
</div>


<!--bind gold-->










<table  cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr><td bgcolor="#FFFFFF">
</table>

<div class="tScroll frm hide" id="bind" >
<table height="167" cellspacing="1" cellpadding="1" border="0" bgcolor="#CCCCCC" class="paystat">
<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>绑定元宝消耗量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}> <{$item.day}>  绑定元宝消耗量：<{$item.consume_bind_gold}>"
          	>
          	<div><{$item.consume_bind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="            
            <{if $max.consume_bind_gold == 0}>
            	0
            <{else}>
            	<{$item.consume_bind_gold/$max.consume_bind_gold}>
            <{/if}>"/>
		  </td>
        </tr>
      </table>
  </td>
    <{/foreach}>
</tr>



<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>绑定元宝留存量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>" 绑定元宝留存量：<{$item.save_bind_gold}>" >
          	<div><{$item.save_bind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
            <{if $max.save_bind_gold ==0}>
            	0
            <{else}>
            	<{$item.save_bind_gold/$max.save_bind_gold}>
            <{/if}>
            "/>
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
  </tr>

<tr>
<td width="22" height="120" align="center" bgcolor="#EBF9FC"><b>绑定元宝新增量</b></td>
    <{foreach key=key item=item from=$datalist}>
    <td width="23" bgcolor="#FFFFFF" align="center" valign="bottom">
      <table width="23" border="0" cellpadding="0" cellspacing="0">
        <tr>
          <td align="center" valign="bottom" style="text-align:center"
          	title="日期：<{$item.month}>-<{$item.day}>" 绑定元宝新增量：<{$item.new_bind_gold}>"
          	>
          	<div><{$item.new_bind_gold}></div>
            <img src="/admin/static/images/<{if $data_one.red}>red<{else}>green<{/if}>.gif" width="10" height="
			    <{if  $max.new_bind_gold == 0}>
							0         	
				<{else}>
			            <{$item.new_bind_gold/$max.new_bind_gold}>			          
			    <{/if}>
             "/>
		  </td>
        </tr>
      </table></td>
    <{/foreach}>
 </tr>
 
 
 
 

 <tr>
    <td width="23" height="30" align="center" bgcolor="#EBF9FC"><b>日期</b></td>
  <{foreach key=data item=item from=$datalist}>
    <{if $item.week == 0}>
    <td height="30" bgcolor="#DD2020" align="center"><{$item.month}>.<{$item.day}><br>周日</td>
    <{else}>
    <td height="30" bgcolor="#C0C0C0" align="center"><{$item.month}>.<{$item.day}></td>
    <{/if}>
  <{/foreach}>
  </tr>
</table>

<span style="text-align:center; margin-left:25px;">
	日期一栏，分2行显示，第一行显示月日，第二行显示开服第几天。如果是星期天则背景红色显示。
</span>
</div>

 

<!--silver_unbind-->





</body>
</html>