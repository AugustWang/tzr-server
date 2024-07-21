<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>vip信息查询</title>
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
    VIP信息查询：
    <form action="#" method="POST" id="frm">
    <table style="margin:5px;">
        <tr>
        <td colspan="4">
        <input type="hidden" name='ac' value='search' />
        <span style='margin-right:20px;'>角色ID: <input type='text' id='uid' name='uid' size='11' value='<{ $base.role_id }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('nickname').value ='';" /></span>
        <span style='margin-right:20px;'>帐号: <input type='text' id='acname' name='acname' size='12' value='<{ $base.account_name }>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('uid').value ='';" /></span>
        <span style='margin-right:20px;'>角色名: <input type='text' id='nickname' name='nickname' size='12' value='<{ $base.role_name }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('uid').value ='';" /></span>
        </td>
        <td>
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>角色ID</th>
            <th>账号</th>
            <th>角色名</th>
            <th>VIP总时长</th>
            <th>VIP星级</th>
            <th>VIP结束时间</th>
        </tr>

        <tr>
            <td><{$role_id}></td>
            <td><{$account_name}></td>
            <td><{$role_name}></td>
            <td><{$vip_time}></td>
            <td><{$vip_level}></td>
            <td><{$vip_end_time}></td>
        </tr>

    </table>
    
</body>
</html>