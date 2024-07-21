<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">

</head>

<body>
<b>消息管理：批量发道具</b>
<br />
<a href="<{$URL_SELF}>?action=byRoleName" style="color: blue; text-decoration: underline;"><b>指定玩家名</b></a>
<a href="<{$URL_SELF}>?action=byCondition" style="color: blue; text-decoration: underline;"><b>按条件</b></a>
<a href="<{$URL_SELF}>?action=byAll" style="color:blue; text-decoration: underline;"><b>全部发送</b></a>
<a href="<{$URL_SELF}>?action=history" style="color:blue; text-decoration: underline;"><b>已发出信件</b></a>
<a href="<{$URL_SELF}>?action=sendResult" style="color: red;"><b>发送结果</b></a>

<br /><br />
    <table class="SumDataGrid"  >
        <tr>
            <th width="20">ID</th>
            <th width="300">信件标题</th>
            <th width="200">发送时间</th>
            <th width="80">全部人数</th>
            <th width="80">失败人数</th>
            <th width="100">发送结果</th>
        </tr>
        
<{section name=i loop=$sendResult}>
    <{if $smarty.section.i.rownum % 2 == 0}>
        <tr class='odd'>
    <{else}>
        <tr>
    <{/if}>
            <td>&nbsp;<{$sendResult[i].id}></td>
            <td>&nbsp;<{$sendResult[i].title}></td>
            <td>&nbsp;<{$sendResult[i].log_time}></td>
            <td>&nbsp;<{$sendResult[i].all_count}></td>
            <td>&nbsp;<{$sendResult[i].fail_count}></td>
            <td>&nbsp;<{$sendResult[i].result}></td>
     </tr>
<{sectionelse}>
    <tr>
    <td colspan="5" align="center">暂无记录</td>
    </tr>
<{/section}>
    </table>

</body>
</html>