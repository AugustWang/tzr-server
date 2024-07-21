<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>版本更新日志</title>
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
    版本更新日志：
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
            <th>ID</th>
            <th>版本号</th>
            <th>记录时间</th>
        </tr>
    <{foreach key=key item=item from=$datalist}>
        <tr>
            <td><{$item.id}></td>
            <td><{$item.version}></td>
            <td><{$item.log_time}></td>
        </tr>
    <{/foreach}>
    </table>
    
</body>
</html>