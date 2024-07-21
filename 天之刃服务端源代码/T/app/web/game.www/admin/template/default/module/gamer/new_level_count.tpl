<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>升级玩家统计</title>
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
    <b>游戏基础数据统计>>升级信息统计：</b>

    <form action="" method="GET" id="frm">
    <table style="margin:5px;" class="DataGrid">
        <tr>
        <td colspan="4">
        统计起始时间: <input type='text' name='start' id='start' size='10' value='<{$start}>' />
        <img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        终止时间: <input type='text' name='end' id='end' size='10' value='<{$end}>' />
        <img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        级数: <input type='text' name='level' id='level' size='4' value='<{$level}>' />

        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>等级</th>
            <th>人数</th>
            <th>总数</th>
            <th>百分比</th>
        </tr>
   	<{$output}>
    </table>

</body>
</html>