<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style type="text/css">
	.more{
		display:none;
		width:250px;
		word-break:break-all;
	}
</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function() {
    	$(".showLess").click(function(){
    		$(this).parent().find(".less").show();
    		$(this).parent().find(".more").hide();
    		$(this).hide();
    		$(this).parent().find(".showMore").show();
    	});
    	$(".showMore").click(function(){
    		$(this).parent().find(".less").hide();
    		$(this).parent().find(".more").show();
    		$(this).hide();
    		$(this).parent().find(".showLess").show();
    	});
	});
</script>
</head>

<body>
<b>消息管理：批量发道具</b>
<br />
<a href="<{$URL_SELF}>?action=byRoleName" style="color: blue; text-decoration: underline;"><b>指定玩家名</b></a>
<a href="<{$URL_SELF}>?action=byCondition" style="color: blue; text-decoration: underline;"><b>按条件</b></a>
<a href="<{$URL_SELF}>?action=history" style="color: red;"><b>已发出信件</b></a>
<br /><br />
	<table class="SumDataGrid"  width="1200">
		<tr>
			<th width="20">ID</th>
			<th width="80">创建时间</th>
			<th width="250">收件角色列表</th>
			<th width="200">收信条件</th>
			<th width="200">信件标题</th>
			<th width="300">信件内容</th>
			<th width="30">操作者</th>
		</tr>
		
<{section name=i loop=$rsEmail}>
    <{if $smarty.section.i.rownum % 2 == 0}>
        <tr class='odd'>
    <{else}>
        <tr>
    <{/if}>
			<td>&nbsp;<{$rsEmail[i].id}></td>
			<td>&nbsp;<{$rsEmail[i].create_time}></td>
			<td style="word-break : break-all;"><div class="less"><{$rsEmail[i].role_names|truncate:60:"...":true}></div><div class="more"><{$rsEmail[i].role_names}></div><a style="color:blue;" class="showMore" href="javascript:void(0);">显示全部</a><a class="showLess" style="display:none;color:blue;" href="javascript:void(0);">关闭</a></td>
			<td>&nbsp;<{$rsEmail[i].conditions}></td>
			<td>&nbsp;<{$rsEmail[i].email_title}></td>
			<td style="background-color:#223A3D;">&nbsp;<{$rsEmail[i].email_content}></td>
			<td>&nbsp;<{$rsEmail[i].admin_name}></td>
   	 </tr>
<{sectionelse}>
	<tr>
	<td colspan="5" align="center">暂无记录</td>
	</tr>
<{/section}>
	</table>

</body>
</html>
