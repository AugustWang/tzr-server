<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<title>
	宠物信息查询
</title>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<!---script type="text/javascript" language="javascript" src="../admin/js/searchSelect.js"></script-->
<script type="text/javascript" src="../admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#showType").change(function(){
			$("#frm").submit();
		});
	});
</script>
<body style="margin:0">
<div class='divOperation'>
<form name="myform" method="get" action="">
请输入宠物ID
<input type='text'   id="pet_id" name='pet_id' size='10' value='<{$pet_id}>' />
&nbsp;或者角色ID：
<input type='text'  id="role_id" name='role_id' size='10' value='<{$role_id}>' />
或操作类型:
<select name= "option" id="option">
	<{html_options options=$pet_option_log selected=$key}>
</select>
<script language="javascript">
				$(document).ready(function(){
					$("#option").change(function(){
						var option = $(this).val();
					});
				});
</script>

<br>
统计起始时间：

<input type='text' id="dateStart" name='dateStart' size='10' value='<{$start}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;终止时间：<input type='text' name='dateEnd' id='dateEnd' size='10' value='<{$end}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
<input type='submit' value="查询">
</form>
</div>

<font color=red><{$error}></font>
<{$pager}>
<table cellspacing="1" class='DataGrid' >
<tr class="table_list_head">
	<th>宠物ID</th>
	<th>宠物名</th>
	<th>角色ID</th>
	<th>宠物类型</th>
	<th>宠物操作</th>
	<th>操作详细</th>
	<th>操作时间</th>
</tr>
<{foreach from=$pet_info item=info }>
<tr class="main">
	<td><{$info.pet_id}></td>
	<td><{$info.pet_name}></td>
	<td><{$info.role_id}></td>
	<td><{$info.pet_type_str}></td>
	<td><{$info.action_str}></td>
	<td><{$info.action_detail_str}></td>
	<td><{$info.time}></td>
</tr>
<{/foreach}>
</table>

	<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
<form method="get" action="">
 <{foreach key=key item=item from=$pagelist}>
 <a href="<{$URL_SELF}>?sort_1=<{$search_sort_1}>&amp;dateStart=<{$start}>&amp;dateEnd=<{$end}>&amp;sort_2=<{$search_sort_2}>&amp;page=<{$page}>&amp;role_id=<{$role_id}>&amp;pet_id=<{$pet_id}>&amp;option=<{$option}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
总页数(<{$page_count}>)
	<input name="sort_1" type="hidden" value="<{$search_sort_1}>">
	<input name="sort_2" type="hidden" value="<{$search_sort_2}>">
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;<input type="submit" class="button" name="Submit" value="GO">
</form>
    </td>
  </tr>
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


var ary = ['account','pet_name','pet_id'];
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