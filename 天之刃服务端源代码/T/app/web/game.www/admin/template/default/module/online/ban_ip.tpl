<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#btnAdd").click(function(){
			var flag = true;
			if("" == $.trim( $("#ip").val() )){
				alert("请输入IP");
				flag = false;
			}
			if("" == $.trim( $("#ban_reason").val() )){
				alert("请输入封禁原因");
				flag = false;
			}
			if(flag){
				yes = confirm("确定要封禁此IP？");
				if(yes){
					$("#frmBan").submit();
				}
			}
		});
		$("#btnClear").click(function(){
			window.location.href = "?action=clear";
		});
		$("#btnChkOnline").click(function(){
			if("" == $.trim( $("#ip").val() )){
				alert("请输入IP");
				flag = false;
			}else{
				$.ajax({
				   type: "POST",
				   url: "?action=chkOnline",
				   data: "ip="+$("#ip").val(),
				   success: function(cnt){
				     $("#msg").text("IP："+$("#ip").val()+" 当前在线人数有 "+cnt+" 人。");
				   }
				}); 
			}
		});
		
	});
	function doRemove(ip){
		if(ip){
			window.location.href = "?action=remove&ip="+ip;
		}
	}
	function rebuild(){
		window.location.href = "?action=rebuild";
	}
</script>
<title>玩家管理：封禁IP</title>
</head>

<body>
<div><b>玩家管理：封禁IP</b></div><br>

<table border="0" width="900">
	<tr>
		<td>
		<span>封禁IP须注意：封禁前最好先检查一下此IP在线数，在线数过多，有可能是平台的IP。<br />千万别把游戏平台的IP给封了，否则所有玩家都登录不了。</span><br/>
		<span id="msg" style="color:red;"></span>
		<{if $strErr}>
		<font color="Red"><{$strErr}></font>
		<{/if}>
		</td>
		<td valign="bottom" align="right"><span style="border:2px solid #945EA2; margin-left:20px;"><input type="button" name="BtnRebuild" value="重新生成缓存" onclick="rebuild();"><font color="Red">注意！只在缓存文件补误删时使用</font></span></td>
	</tr>
</table>
<table width="900" class="SumDataGrid">
  <tr>
    <th>IP</th>
    <th>解禁时间</th>
    <th>原因</th>
    <th>操作</th>
    <th>操作者</th>
  </tr>
  
<form action="<{$URL_SELF}>?action=add" method="POST" id="frmBan">
  <tr align="center">
    <td><input type="text" name="ip"  id="ip" /></td>
    <td>
		<select name="ban_time">
    		<{html_options options=$arrBanTime}>
    	</select>
	</td>
    <td><input class="ban_reason" type="text" size="30" name="ban_reason" id="ban_reason" /></td>
    <td>
	<input type="button" name="btnChkOnline" id="btnChkOnline" value="检查此IP在线数" />
	<input type="button" name="btnAdd" id="btnAdd" value="封禁" />
	</td>
	<td>
	<input type="button" name="btnClear" id="btnClear" value="清除过期的IP" />
	</td>
  </tr>
</form>
 <{foreach from=$arrBanIPs item=row key=key}>
	<{if $key % 2 == 0}>
  <tr class='odd'>
	<{else}>
  <tr>
	<{/if}>
    <td><{$row.ip}></td>
    <td><{$row.end_time_str}></td>
    <td><{$row.ban_reason}></td>
    <td align="center"><input type="button" name="btnRemove" value="移除" onclick="doRemove('<{$row.ip}>');" /></td>
    <td align="center"><{$row.admin_name}></td>
  </tr>
 <{/foreach}>
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
