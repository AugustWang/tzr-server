<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<title>玩家：玩家称号</title>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
function delGamerTitle(id,role_id){
	if (confirm("确认删除该玩家的此称号?")){
		window.location.href = '?action=del&id='+id+'&role_id='+role_id;
	}
}
$(document).ready(function(){
	$(".btnGetRole").click(function(){
		$("#frm").attr("action","?action=searchUser");
		$("#frm").submit();
	});
	$("#btnSet").click(function(){
		var msg = "";
		if("" == $("#title").val()){
			msg+="称号不能为空！\n";
		}
		pattern = /^\#?[0-9a-fA-F]{6}$/;
		var color = $("#color").val();
		if(!color.match(pattern)){
			msg += "颜色值错误" 
		}
		if(""!=msg){
			alert(msg);
		}else{
			$("#frm").attr("action","?action=set");
			$("#frm").submit();
		}
	});
	$("#send_letter").click(function(){
		if($(this).attr("checked")){
			$("#tr_letter_content").show();
		}else{
			$("#tr_letter_content").hide();
		}
	});
	
});
</script>
</head>
<body>
<div align="left"><b>玩家：玩家称号</b></div>
<div style="border:2px solid #CCC;">
<table width="800">
  <tr valign="bottom">
    <td>
    <form id="frm" action="<{$URL_SELF}>?action=set" method="post">
      <table class="DataGrid">
        <tr>
          <th colspan="2">玩家称号设置</th>
        </tr>
        <tr>
          <td align="right">玩家角色ID：</td>
          <td><input type="text" name="role[role_id]" id="role_id" size="16" value="<{$role.role_id}>"  onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_name').value ='';" /></td>
        </tr>
        <tr>
          <td align="right">玩家角色名：</td>
          <td><input type="text" name="role[role_name]" id="role_name" size="16" value="<{$role.role_name}>" onkeydown="document.getElementById('account_name').value =''; document.getElementById('role_id').value ='';"  />&nbsp;<input type="button" class="btnGetRole" value="查找" /></td>
        </tr>
        <tr>
          <td align="right">玩家帐号名：</td>
          <td><input type="text" name="role[account_name]" id="account_name" size="16" value="<{$role.account_name}>"  onkeydown="document.getElementById('role_name').value =''; document.getElementById('role_id').value ='';" />&nbsp;<input type="button" class="btnGetRole" value="查找" /></td>
        </tr>
        <{if $role.role_id}>
        <tr>
          <td align="right">称号名称：</td>
          <td><input type="text" name="title" id="title" size="16" maxlength="10" value="<{$title}>"/>(最长10个汉字)</td>
        </tr>
        <td align="right">称号颜色：</td>
          <td><input type="text" name="color" id="color" size="16" maxlength="7"  value="<{$color}>" /></td>
        <tr>
          <td align="right">有效时间至：</td>
          <td><{*input type="text" name="start_time" size="22" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'})" />
            至*}>
            <input type="text" name="end_time" size="22" class="Wdate" value="<{$end_time}>" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd HH:mm:ss'})" />(留空则不限)
        </tr>
        <tr>
          <td colspan="2"><input type="checkbox" name="show_in_chat"  <{$showInChatChk}>  value="1"  />
            显示在聊天频道中 &nbsp;&nbsp;&nbsp;&nbsp;
            <input type="checkbox" name="show_in_sence" <{$showInSenceChk}>  value="1"  />
            显示在场景中&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="checkbox" name="send_letter" id="send_letter" value="1" />信件通知玩家
 			</td>
        </tr>
        
        <tr id="tr_letter_content" style="display:none;">
          <td colspan="2"><textarea name="letter_content" rows="3" cols="60"></textarea> </td>
        </tr>
        
        <tr>
          <td colspan="2" align="center"><input type="button" id="btnSet" value=" 设 置 " /></td>
        </tr>
        <tr>
          <td colspan="2">提示：增加称号，得过30秒左右，才能完全写入到数据库，请30秒后刷新列表，查看是否加成功。
          <{if $err}><font color="Red"><b><{$err}></b></font><{/if}></td>
        </tr>
        
        <{/if}>
      </table>
    </form>
    </td>
	
    <td>
	<table class="DataGrid">
        <tr>
          <th colspan="2">常用色值列表</th>
        </tr>
        <tr>
          <td><font color="#00FFFF">门派自定义称号</font></td>
          <td>色值代码 #00FFFF</td>
        </tr>
        <tr></tr>
        <tr>
          <td>日常设置参考值</td>
          <td>&nbsp;</td>
        </tr>
      </table>
	  </td>
  </tr>
</table><br>

<div>
<form id="frm" action="<{$URL_SELF}>?action=searchUser" method="post">
	角色名:<input type="text" name="role[role_name]" value="<{$role.role_name}>" /> <input type="submit" value="搜 索" />
	<a style="color:blue;text-decoration:underline;" href="/admin/module/gamer/gamer_title.php?<{$urlListSuffix}>">刷新列表</a>
</form>
提示：若删除某个玩家的某称号，得过约30秒才能彻底从数据库中删除，请不要重复点击删除。
</div>
<table class="DataGrid">
  <tr id="header">
    <th>玩家角色名</th>
    <th>称号ID</th>
    <th>称号名称</th>
    <th>称号颜色</th>
    <th>过期时间</th>
    <th>是否显示在聊天频道中</th>
    <th>是否显示在场景中</th>
    <th>操作</th>
  </tr>
  <{foreach from=$allGamerTitles item=title}>
  <tr>
    <td><{$title.role_name}></td>
    <td><{$title.id}></td>
    <td align="center"><b><font color="#<{$title.color}>"><{$title.name}></font></b></td>
    <td><{$title.color}></td>
    <td><{$title.timeout_time}></td>
    <td><{$title.show_in_chat}></td>
    <td><{$title.show_in_sence}></td>
    <td align="center"><{*<a href="?action=update&id=<{$title.id}>">编辑</a>*}> <a href="javascript:delGamerTitle(<{$title.id}>,<{$title.role_id}>);">删除</a> </td>
  </tr>
  <{/foreach}>
  <{if !$allGamerTitles}>
 	<tr>
 		<td colspan="7">无数据</td>
 	</tr>
  <{/if}>
</table>
</div>
</body>
</html>
