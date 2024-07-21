<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
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
</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
</script>
</head>

<body>
<div id="all">
<div id="main">
<!--start 查找玩家-->
<b>玩家：玩家升级日志查询</b><br>
<form action="?action=search" style="margin:20px;" method="POST">
	<span style='margin-right:20px;'>角色ID: <input type='text' id='role_id' name='role_id' size='11' value='<{ $role.role_id }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_name').value ='';" /></span>
	<span style='margin-right:20px;'>登录帐号: <input type='text' id='account_name' name='account_name' size='12' value='<{ $role.account_name }>' onkeydown="document.getElementById('role_name').value =''; document.getElementById('role_id').value ='';" /></span>
	<span style='margin-right:20px;'>角色名: <input type='text' id='role_name' name='role_name' size='12' value='<{ $role.role_name }>' onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';" /></span>
	<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
</form>
<!--end 查找玩家-->

<{ if $role.role_id }>
<table class="DataGrid" cellspacing="0">
    <tr align="center">
        <th rowspan="2">账号信息</th>
        <th>帐号</th> 
        <th>角色名</th>
        <th>角色ID</th>    
        <th>创建时间</th>
        <th>最近登录时间</th>    
    </tr>
    <tr align="center">
        <td><{ $role.account_name       }>&nbsp;</td>
        <td><{ $role.role_name          }>&nbsp;</td>
        <td><{ $role.role_id            }>&nbsp;</td>
        <td><{ $role.create_time|date_format:"%Y-%m-%d %H:%M:%S"        }>&nbsp;</td>
        <td><{ $ext.last_login_time|date_format:"%Y-%m-%d %H:%M:%S"     }>&nbsp;</td>
    </tr>
</table>
<br />
<br />

<table class="DataGrid">
  <tr class='table_list_head'>
    <th>国家</th>
    <th>玩家级别</th>
    <th>时间</th>
    <th>离2级的时间间隔(秒)</th>
    <th>离创建账户的时间间隔(秒)</th>
  </tr>
 <{section name=i loop=$result}>
   <{if $smarty.section.i.rownum % 2 == 0}>
	   <tr class='odd'>
		<{else}>
	   <tr>
   <{/if}>
    <td><{$result[i].faction_name}></td>
    <td><{$result[i].level}></td>
    <td><{$result[i].log_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
    <td><{$result[i].elapsed_lv2}></td>
    <td><{$result[i].elapsed_lv1}></td>
  </tr>
  <{sectionelse}>
	<tr>
 		<td colspan="6">无数据</td>
 	</tr>
<{/section}>
 	
</table>
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
</body>
</html>
