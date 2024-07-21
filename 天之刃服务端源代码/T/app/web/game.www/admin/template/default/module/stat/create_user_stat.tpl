<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>创建角色页流失率统计</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<style type="text/css" media="screen">
	.prompt{
		margin:auto;
		font-size:1.2em;
		text-align:center;
		display:block;
		margin-bottom:20px;
	}
	.divOperation{
		margin:auto;
		width:100%;
	}
</style>
</head>

<body style="margin:10px">
<div>
	<{if $input}>
	<div class="prompt">  统计从 <font colot="red"><{$input.start_time}></font> 到 <font colot="red"><{$input.end_time}></font>时间段内的流失率</div> 
	<{else}>
	<div class="prompt"> 统计全时间段流失率</div>
	<{/if}>
	<h2 class="color:red"> <{$message}></h2>

	<b>重设统计时间</b>
	<div class='divOperation'>
			<form name="myform" method="post" action="<{$URL_SELF}>">
			统计起始时间:<input type='text' name='start_time' id="start_time" size='10' value='<{$input.start_time}>' style="width:150px"/>
			<img onclick="WdatePicker({el:'start_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
			&nbsp;终止时间：<input type='text' name='end_time' id="end_time" size='10' value='<{$input.end_time}>' style="width:150px"/>
			<img onclick="WdatePicker({el:'end_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
			<input type="submit" name="setTime" value="确定">
			</form>	
	</div>	
	</div>

	<table cellspacing="1" cellpadding="5" border="0" class='table_list' >
		<tr class='table_list_head' align='center'><td colspan="8" align="center">人数统计</td></tr>
		<tr align='center'>
			<td >统计开始时间</td>
			<td >统计截止时间</td>
			<td >平台跳转人数</td>
			<td >创建角色人数</td>
			<td>游戏中角色数</td>
			<td >到达欢迎窗口人数</td>
			<td >完成第一个任务人数</td>
		</tr>
		<tr align='center'>
			<td><{$input.start_time}></td>
			<td><{$input.end_time}></td>		
			<td><{$portal}></td>
			<td><{$after}></td>
			<td><{$role}></td>
			<td><{$game}></td>
			<td><{$mission}></td>
		</tr>
	</table>	
</div>

<div>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head' align='center'><td colspan="3" align="center">新流失率统计方式</td></tr>
	</table>
</div>
<div>
	创建页流失率 = ( 平台跳转账号数量 - 已创建角色数) /到达创建角色页的人数<br/>
	游戏用户流失率 = ( 已创建角色数 - 创建成功并进入游戏的人数) /已创建角色数 [该流失率仅供技术参考]<br/>
	欢迎窗口流失率 = ( 已创建角色数 - 到达欢迎窗口人数) / 已创建角色数<br/>
	第一个任务流失率 = ( 到达欢迎窗口人数 - 接第一个任务人数) / <font color="red">到达欢迎窗口人数</font><br/>
	新手流失率 = ( 平台跳转账号数量 - 完成第一个任务人数) / 到达创建角色页的人数<br/>
</div>

<div>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'><td colspan="7" align="center">创建页流失率</td></tr>
		<tr>			
			<td width="15%">平台账号数</td>
			<td width="15%">完成创建页人数</td>
			<td width="15%">创建流失率</td>
			<td width="10%"></td>
			<td width="15%">到达创建页独立IP数量</td>
			<td width="15%">完成创建页独立IP数量</td>
			
		</tr>
		<tr>
			<td><{$portal}></td>						
			<td><{$after}></td>
			<{if $portal == 0}>
				<td>0%</td>
			<{else}>
				<td> <{math equation="((( x - y ) / t) * 100)" x=$portal y=$after z=100 t=$portal format="%.2f"}>% </td>	
			<{/if}>
			<td></td>		
			<td><{$before_ip}></td>
			<td><{$after_ip}></td>
		</tr>
	</table>	
</div>
<div>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'><td colspan="7" align="center">游戏用户流失率(0%)[该流失率仅供技术参考]</td></tr>
		<tr>
					
			<td width="15%">完成角色创建的人数</td>			
			<td width="15%">游戏中的角色数</td>			
			<td width="15%">游戏用户流失率</td>
			<td width="10%"></td>
			<td width="15%">完成角色创建独立IP数</td>
			<td width="15%">游戏中角色独立IP数</td>
		</tr>
		<tr>		
			<td><{$after}></td>					
			<td><{$role}></td>
			<{if $after == 0}>
			<td>0</td>
			<{else}>
			<td><{math equation="((( x - y ) / t ) * 100)" x=$after y=$role t=$after  z=100 format="%.2f"}>% </td>
			<{/if}>
			<td></td>
			<td><{$after_ip}></td>
			<td><{$role_ip}></td>
		</tr>
	</table>	
</div>

<div>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'><td colspan="7" align="center">欢迎窗口流失率</td></tr>
		<tr>
			<td width="15%">游戏中角色数</td>			
			<td width="15%">到达欢迎窗口人数</td>			
			<td width="15%">欢迎窗口流失率</td>
			<td width="10%"></td>
			<td width="15%">游戏角色独立IP数</td>
			<td width="15%">到达欢迎窗口独立IP数量</td>
		</tr>
		<tr>		
			<td><{$role}></td>					
			<td><{$game}></td>
			<{if $role == 0}>
			<td>0</td>
			<{else}>
			<td><{math equation="((( x - y ) / t ) * 100)" x=$role y=$game t=$role  z=100 format="%.2f"}>% </td>
			<{/if}>
			<td></td>
			<td><{$role_ip}></td>
			<td><{$game_ip}></td>
		</tr>
	</table>	
</div>

<div>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'><td colspan="7" align="center">第一个任务流失率</td></tr>
		<tr>
			<td width="15%">欢迎窗口的人数</td>	
			<td width="15%">完成首次任务的人数</td>			
		
			<td width="15%">首次任务流失率</td>
			<td width="10%"></td>
			<td width="15%">完成首次任务的IP数</td>
			<td width="15%">欢迎窗口的IP数</td>

		</tr>
		<tr>	
                 	<td><{$game}></td>	
			<td><{$mission}></td>					
		
			
			<{if $role == 0}>
			<td>0</td>
			<{else}>
			<td><{math equation="((( x - y ) / t ) * 100)" x=$game y=$mission t=$game  z=100 format="%.2f"}>% </td>
			<{/if}>
			
			<td></td>
			<td><{$mission_ip}></td>
			<td><{$game_ip}></td>

			
		</tr>
	</table>	
</div>

<div> 
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'><td colspan="7" align="center">新手流失率</td></tr>
		<tr>
			<td width="15%">平台跳转人数</td>			
			<td width="15%">完成第一个任务人数</td>			
			<td width="15%">第一个任务流失率</td>
			<td width="10%"></td>
			<td width="15%">到达创建角色页独立IP数量</td>
			<td width="15%">第一个任务独立IP数量</td>
		</tr>
		<tr>		
			<td><{$portal}></td>					
			<td><{$mission}></td>
			<td><{math equation="((( x - y ) / t ) * 100)" x=$portal y=$mission z=100 t=$portal format="%.2f"}>%</td>
			<td></td>
			<td><{$before_ip}></td>
			<td><{$mission_ip}></td>
		</tr>
	</table>	
</div>

<div id="create_form">
</div>
</body>
</html>

