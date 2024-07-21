<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<title>
	用户登录历史查询
</title>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<!---script type="text/javascript" language="javascript" src="../js/searchSelect.js"></script-->
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>

<body style="margin:0">
<div><b>玩家：登录历史查询</b></div>
<b>
<div class='divOperation'>
<form name="myform" method="post" action="gamer_login_check.php">
请输入玩家登录帐号
<input type='text'   id="account" name='account' size='10' value='<{$roleInfo.account_name}>' "/>
&nbsp;或者角色名：
<input type='text'  id="role_name" name='role_name' size='10' value='<{$roleInfo.role_name}>' "/>
或者角色ID
&nbsp;：
<input type='text'   id="role_id" name='role_id' size='10' value='<{$roleInfo.role_id}>'/>

起始时间：
<input type='text'  id="start" name='start' size='12' value='<{$start}>'  />
<img onclick="WdatePicker({el:'start'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
终止时间：
<input type='text' id="end" name='end' size='12' value='<{$end}>'   />
<img onclick="WdatePicker({el:'end'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"/>
</form>
</div>

<font color=red><{$error}></font>
<{$pager}>
<table cellspacing="1" class='DataGrid' >
<tr class="table_list_head">
	<td>角色名</td>
	<td>登录时间</td>
	<td>登录IP</td>
	<td>IP所在地</td>
</tr>
<{foreach from=$loginInfo item=item key=key}>
<tr class="main">
	<td><{$roleInfo.role_name}></td>
	<td><{$item.log_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
	<td><{$item.login_ip}>   </td>
	<td><a href="http://www.ip138.com/ips.asp?ip=<{$item.login_ip}>&action=2">来源</a></td>
</tr>
<{/foreach}>
</table>



<script>

jQuery.extend({
	minus:function(ary,ele){
		var ret = new Array()
		$.each(ary,function(idx,val){
			if(ele != val){
				ret.push(val);
			}	
		});
		return ret;
	}
});



$('.main').addClass('trOdd');
$('.main:odd').removeClass('trOdd').addClass('trEven');


var ary = ['account','role_name','role_id'];
$(function(){
	$.each(ary,function(idx,val){
		$("#"+val).keydown(function(){
			var remain = jQuery.minus(ary,val);
			$.each(remain,function(idx,val){
				$('#'+val).val('');
			})
		})
	})
})

</script>


</body>
</html>