<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<title>查看玩家的宠物背包和宠物操作日志</title>
</head>

<body>
<b>玩家管理：宠物状态查询</b>
<div id='input_panel' class='divOperation'>
	<form name="myform" method="post" action="/admin/module/gamer/gamer_pet_info.php">
		<input type="hidden" name='ac' value='search' />
		<span style='margin-right:20px;'>角色ID: <input type='text' id='uid' name='uid' size='11' value='<{ $base.role_id }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('nickname').value ='';" /></span>
		<span style='margin-right:20px;'>帐号: <input type='text' id='acname' name='acname' size='12' value='<{ $base.account_name }>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('uid').value ='';" /></span>
		<span style='margin-right:20px;'>角色名: <input type='text' id='nickname' name='nickname' size='12' value='<{ $base.role_name }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('uid').value ='';" /></span>
		<input type="hidden" name="isPost" value="1" />
		<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
	</form>
</div>
<br>

<{if $base.role_id}>
<table class="DataGrid" cellspacing="0">
	<tr align="center">
		<th >玩家宠物背包信息</th>
		<th>角色名</th>
        <th>角色ID</th>    
        <th>宠物背包容量</th>
        <th>携带宠物ID</th>
        <th>宠物名称</th>        
    </tr>
    <{ if $pets }>
    <{section name=i loop=$pets}>
    <tr align="center" <{ if 0==$smarty.section.i.index %2 }> class="odd"<{ /if }>>
    	<td><{ $smarty.section.i.index+1        }>&nbsp;</td>
    	<td><{ $base.role_name          		}>&nbsp;</td>
    	<td><{ $base.role_id            		}>&nbsp;</td>
    	<td><{ $petBag.content          		}>&nbsp;</td>
    	<td><{ $pets[i].pet_id          		}>&nbsp;</td>
    	<td><{ $pets[i].name            		}>&nbsp;</td>
    </tr>
    <{/section}>
    <{ else }>
    <tr><td colspan="11">无</td></tr>
    <{ /if }>
</table>
<br />


<{ /if }>
<{if $isPost&&!$base.role_id}>
没有此玩家
<{/if}>
</body>
</html>