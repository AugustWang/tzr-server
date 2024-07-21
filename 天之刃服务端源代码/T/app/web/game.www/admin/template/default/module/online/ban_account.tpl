<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		
	});
	
	function doBanOne(role_id){
		if($.trim( $("#ban_"+role_id+"_ban_reason").val() ) == "" ){
			alert("请填写封禁此号的原因");
		}else{
			yes = confirm("确定要封禁此号？");
			if(yes){
				$("#banRoleID").val(role_id);
				$("#frmBan").submit();
			}
		}
	}
	
	function doUnBan(role_id,role_name){
		if(role_id){
			window.location.href = "?action=doUnBan&role_id="+role_id+"&role_name="+role_name;
		}
	}
	function rebuild(){
		window.location.href = "?action=rebuild";
	}


	function kickStall(role_id,role_name){
		$.ajax({
			type:'POST',
			url:'ban_account.php',
			data:{action:'ajaxKickStall',role_id:role_id,role_name:role_name},
			success:function(res){
				alert(res);
			}
		});
	}

	
</script>

<title>封禁帐号</title>
</head>

<body>
<b>玩家管理：封禁帐号</b><br />
<div style="padding:5px;">
说明：
"封号"只是让玩家不能再次登录，并没有踢他下线。<br>
"踢下线"会使玩家立刻离线，但是要<font color="Red">5分钟后</font>才能显示为离线状态。
</div>
<form action="<{$URL_SELF}>?action=search" method="POST" id="frmSearch">
<div>输入IP 或 角色名：<input type="text" name="keyWord" value="<{$keyWord}>">&nbsp;<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle" />
<span style="border:2px solid #945EA2; margin-left:20px;"><input type="button" name="BtnRebuild" value="重新生成缓存" onclick="rebuild();"><font color="Red">注意！只在缓存文件补误删时使用</font></span>
</div>
</form>
<{if $arrSearchResult}>
<form action="<{$URL_SELF}>?action=doBan" method="POST" id="frmBan">
<table class="DataGrid">
  <tr>
    <th>角色ID</th>
    <th>角色名</th>
    <th>帐号名</th>
    <th>IP地址</th>
    <th>等级</th>
    <th>充值总额</th>
    <th>状态</th>
    <th>封禁时长</th>
    <th>封禁原因</th>
    <th>操作</th>
  </tr>
  <{ foreach from=$arrSearchResult item=row key=key }>
	<{if $key % 2 == 0}>
  <tr align="center" class='odd'>
	<{else}>
  <tr align="center">
	<{/if}>
    <td><input type="hidden" name="ban[<{$row.role_id}>][role_id]" value="<{$row.role_id}>"><{$row.role_id}></td>
    <td><input type="hidden" name="ban[<{$row.role_id}>][role_name]" value="<{$row.role_name}>"><{$row.role_name}></td>
    <td><input type="hidden" name="ban[<{$row.role_id}>][account_name]" value="<{$row.account_name}>"><{$row.account_name}></td>
    <td><{$row.last_login_ip}></td>
    <td><{$row.level}></td>
    <td><{$row.total_pay}></td>
    <td>
    	<{if 1==$row.online}>
    	<font color="green"><b>在线</b></font>
    	<{*&nbsp;<input type="checkbox" checked="checked" value="1" name="ban[<{$row.role_id}>][kick]">踢下线*}>
    	<{else}>
    	<font color="gray"><b>离线</b></font>
    	<{/if}>
    </td>
    <td>
    	<select name="ban[<{$row.role_id}>][ban_time]">
    		<{html_options options=$arrBanTime}>
    	</select>
    </td>
    <td><input class="ban_reason" type="text" name="ban[<{$row.role_id}>][ban_reason]" id="ban_<{$row.role_id}>_ban_reason" size="40"></td>
    <td><input type="button" name="btnBan" onclick="doBanOne(<{$row.role_id}>);" value="封禁"></td>
  </tr>
  <{/foreach}>
</table>
<input type="hidden" name="banRoleID" id="banRoleID" value="" />
 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?action=search&amp;keyWord=<{$keyWord}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
</form>
<br>
<{/if}>

<table class="DataGrid">
  <tr>
    <th>角色ID</th>
    <th>角色名</th>
    <th>帐号名</th>
    <th>IP地址</th>
    <th>等级</th>
    <th>充值总额</th>
    <th>状态</th>
    <th>解封时间</th>
    <th>封禁原因</th>
    <th>操作</th>
    <th>操作者</th>
  </tr>
  <{if $arrBanRoles}>
  <{ foreach from=$arrBanRoles item=row key=key }>
	<{if $key % 2 == 0}>
  <tr align="center" class='odd'>
	<{else}>
  <tr align="center">
	<{/if}>
    <td><{$row.role_id}></td>
    <td><{$row.role_name}></td>
    <td><{$row.account_name}></td>
    <td><{$row.last_login_ip}></td>
    <td><{$row.level}></td>
    <td><{$row.total_pay}></td>
    <td>
    	<{if 1==$row.online}>
    	<font color="green"><b>在线</b></font>&nbsp;
    	<a style="color:blue;text-decoration:underline;" href="<{$URL_SELF}>?action=kick&role_id=<{$row.role_id}>&role_name=<{$row.role_name}>">踢下线</a>
    	<{else}>
    	<font color="gray"><b>离线</b></font>
    	<{/if}>
    </td>
    <td><{$row.end_time_str}></td>
    <td><{$row.ban_reason}></td>
    <td>
    <input type="button" name="btnUnBan" value="解封" onclick="doUnBan(<{$row.role_id}>,'<{$row.role_name}>');" />
    <input type="button" name="btnKickStall" id="btnKickStall" value="踢摊位下线" onclick="kickStall(<{$row.role_id}>,'<{$row.role_name}>');" />
    </td>
    
    
    
    <td><{$row.admin_name}></td>
  </tr>
  <{/foreach}>
  <{/if}>
</table>
<style type="text/css">
	#ulBandReason{
		width:300px;
		margin:0px;
		padding:0px;
		list-style:none;
		background-color:#D9D9D9;
		border:2px solid blue;
		position:absolute;
		display:none;
	}
	#ulBandReason li{
		height:20px;
		border:1px solid #CCC;
	}
	#closeReason{
		text-align:right;
		text-decoration:underline;
	}	
</style>
<ul id="ulBandReason">
	<li id="closeReason"><a href="javascript:void(0);">关闭</a></li>
	<{foreach from=$arrBandReason item=reason}>
	<li class="reasonItem"><a href="javascript:void(0);"><{$reason}></a></li>
	<{/foreach}>
</ul>
<script language="javascript">
	$(document).ready(function(){
		window.fromInput = null;
		$(".ban_reason").click(function(){
			var offset = $(this).offset();
			window.fromInput = $(this);
			$("#ulBandReason").css("top",offset.top+20).css("left",offset.left);
			$("#ulBandReason").show();
		});
		$("#closeReason").click(function(){
			$("#ulBandReason").hide();
		});
		$(".reasonItem").click(function(){
			window.fromInput.val($(this).find("a").text());
			$("#ulBandReason").hide();
			event.stopPropagation();
		});
	});
</script>
</body>
</html>
