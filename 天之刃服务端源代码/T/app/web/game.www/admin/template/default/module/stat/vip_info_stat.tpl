<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>vip信息统计</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
    $(document).ready(function(){
        $("#showType").change(function(){
            $("#frm").submit();
        });
    });
</script>
</head>

<body>
    VIP信息统计：
    <form action="#" method="POST" id="frm">
    <table style="margin:5px;">
        <tr>
        <td colspan="4">
        统计起始时间: <input type='text' name='start' id='start' size='10' value='<{$start}>' />
        <img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        终止时间: <input type='text' name='end' id='end' size='10' value='<{$end}>' />
        <img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        </td>
        <td>
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <td style="width:100px;">VIP总人数</td>
            <td><{$vip_all_count}></td>
            <td style="width:100px;">VIP过期人数</td>
            <td><{$vip_over_time_count}></td>
        </tr>
    </table>
    
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>角色ID</th>
            <th>账号</th>
            <th>角色名</th>
            <th>VIP开始时间</th>
            <th>VIP开通方式</th>
            <th>续期</th>
            <th>VIP总时长</th>
            <th>VIP星级</th>
            <th>VIP结束时间</th>
        </tr>
    <{foreach key=key item=item from=$datalist}>
        <tr>
            <td><{$key}></td>
            <td><{$item.account_name}></td>
            <td><{$item.role_name}></td>
            <td><{$item.start_time}></td>
            <td><{$item.open_type}></td>
            <td><{$item.add_time}></td>
            <td><{$item.total_time}></td>
            <td><{$item.vip_level}></td>
            <td>
            <{if $item.is_over_time==true}>
            <font color = "#f53f3c" ><{$item.vip_end_time}></font>
            <{else}>
            <{$item.vip_end_time}>
            <{/if}>
            </td>
        </tr>
    <{/foreach}>
    </table>
    
</body>
</html>