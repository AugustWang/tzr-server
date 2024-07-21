<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style type="text/css">
#all {
	text-align: left;
	margin-left: 4px;
	line-height: 1;
}

#nodes {
width: 100%;
float: left;
border: 1px #ccc solid;
}

#result {
width: 100%;
height: 100%;
clear: both;
border: 1px #ccc solid;
}

.itemlist {
background-color: #CCC;
display: none;
height: 255px;
height: 255px;
left: 254px;
margin: 0px;
max-height: 260px;
overflow: hidden;
padding: 0px;
position: absolute;
top: 0px;
width: 200px;
}

</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
</script>
</head>

<body>
<div><b>道具管理：<{ $pageTitle }></b></div>
<div id="all">
<div id="main">
<div class="box">
<div id="nodes">
<!--start 查找玩家-->
<form action="?action=search" style="margin:20px;" method="POST">
<span style='margin-right:20px;'>角色ID: <input type='text' id='role_id' name='role_id' size='11' value='<{ $role.role_id }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_name').value ='';" /></span>
<span style='margin-right:20px;'>登录帐号: <input type='text' id='account_name' name='account_name' size='12' value='<{ $role.account_name }>' onkeydown="document.getElementById('role_name').value =''; document.getElementById('role_id').value ='';" /></span>
<span style='margin-right:20px;'>角色名: <input type='text' id='role_name' name='role_name' size='12' value='<{ $role.role_name }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';" /></span>
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
</form>
<!--end 查找玩家-->

<{ if $role.role_id }>
<form action="?action=do&type=gold" method="post">
<table width="100%" border="0" cellpadding="4" cellspacing="1"
bgcolor="#A5D0F1">
<tr bgcolor="#E5F9FF">
<td colspan="2" background="/admin/static/images/wbg.gif"><font
color="#666600" class="STYLE2"><b>::赠送道具</b></font></td>
</tr>
<tr>
<td bgcolor="#FFFFFF" colspan="2">
在下面输入ID直接送道具或可以搜索道具：<input type="text" name="itemname" id="itemname" value="" onKeyUp="searchItem()" onMouseUp="searchItem();" />
<div style="position:relative;">                
<div id="itemlist" class="itemlist" ></div>          
</div>                                                                                  
<script language="javascript" >                                
	var itemArray = new Array();  
		<{foreach item=idata from=$itemlist}>       
			itemArray[<{$idata.typeid}>] = "<{$idata.typeid}> | <{$idata.item_name}> ";                                        
		<{/foreach}>                                                                  
function selectItem(iid){                                                       
	document.getElementById('typeid').value = iid;                            
	document.getElementById('itemname').value = itemArray[iid];             
	document.getElementById('itemlist').style.display="none";               
}                                                                               

function searchItem(){                                                          
	document.getElementById('itemlist').style.display="block";              
	var keyword = document.getElementById('itemname').value ;               
	var onArray = new Array();                                              
	for(kid in itemArray) {                                                 
		if(itemArray[kid].indexOf(keyword) !=-1 ){                      
			onArray[kid] = itemArray[kid];                          
		}                                                               
	}                                                                       
	var str='<ul><li style="text-align:right;"><a href="javascript:;" onclick="hiddenlist();">关闭</a></li>';                                                       
	for(iid in onArray) {                                                   
		str += '<li onclick="selectItem('+iid+');">'+onArray[iid]+'</li>';                                                                                      
	}                                                                       
	str += '</ul>';                                                         
	document.getElementById('itemlist').innerHTML = str ;                   
}                                                                               
function hiddenlist(){                                                          
	document.getElementById('itemlist').style.display="none";               
}                                                                               
</script>                                                                               

</td>

</tr>
<tr bgcolor="#FFFFFF">
<td width="25%" colspan="2">
<a href="gamer_item_list.php" target="_BLANK" style="border-bottom:1px solid red;"><font  color='red'><b>查看道具列表</b></font></a>
</td>
</tr>
<tr bgcolor="#FFFFFF">
<td width="25%">物品ID：</td>
<td width="75%"><input type="text" name="typeid" id="typeid"  value="<{ $typeid }>" /></td>
</tr>
<tr bgcolor="#FFFFFF">
<td width="25%">赠送数量：(装备最多1件，其他最多50个)</td>
<td width="75%"><input type="text" name="number" value="<{ $number }>" /> <input
type="checkbox" name="bind" value="1" <{ if $bind }>checked="checked"<{ /if }> />是否绑定[勾上表示绑定]
</td>
</tr>
<tr bgcolor="#FFFFFF">
<td width="25%">品质：</td>
<td><select id="type" name="quality">
<{html_options options=$dictQualityType selected=$quality }>
</select></td>
</tr>
<tr bgcolor="#FFFFFF">
<td width="25%">颜色：</td>
<td><select id="type" name="color">
<{html_options options=$dictColor selected=$color }>
</select>
</td>
</tr>
<tr bgcolor="#FFFFFF">
<td width="25%">有效时间</td>
<td>
<select id="time_state" name="time_state" onchange="change_time_state(this.options[this.options.selectedIndex].value)">

<option value =0 >无限制</option>
<option value =1>绝对时间</option>
</select>
<div id="time_range" style="display:none;">
开始时间：<input type="text" name="start_time" id="start_time" value="0" /> 
<img onclick="WdatePicker({el:'start_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
结束时间：<input type="text" name="end_time" id="end_time" value="0"  />
<img onclick="WdatePicker({el:'end_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
(都为0表示无限制)
</div></td>
</tr>

<script language="javascript" > 
function change_time_state(s) 
{ 
    if(s==0)
    {
        document.getElementById("time_range").style.display="none";
        document.getElementById("start_time").value="0";
        document.getElementById("end_time").value="0";
    }
    else if(s==1)
    {
        document.getElementById("start_time").value="0";
        document.getElementById("end_time").value="0";
        document.getElementById("time_range").style.display="inline-block";
    }

　　//选择后,让第一项被选中,这样,就有Change啦.
　　document.all.time_state.options[s].selected=true;
} 
</script>
<tr bgcolor="#FFFFFF">
<td width="25%"></td>
<input type="hidden" name="role[role_id]" value="<{ $role.role_id }>" />
<input type="hidden" name="role[role_name]" value="<{ $role.role_name }>" />
<input type="hidden" name="role[account_name]" value="<{ $role.account_name }>" />
<td width="75%"><input type="submit" name="submit" value="确认赠送" />
<input type="reset" name="reset" value="重置" /></td>
</tr>
</table>
</form>
<{ /if }>
<{ if $err }>
<table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
<tr bgcolor="#FFFFFF"> 
<td align="center">
<font color="red"><b><{ $err }></b></font>
</td>
</tr>
</table>
<{ /if }>

</div>
</div>
</div>
</div>
</body>
</html>
