<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/js/jquery.min.js"></script>
<title>直接创建GM角色</title>
</head>

<body style="margin:10px">

<form action="?action=do&type=gold" method="post">
<table width="100%" border="0" cellpadding="4" cellspacing="1"
    bgcolor="#A5D0F1">
    <tr bgcolor="#E5F9FF">
        <td colspan="2" background="/admin/static/images/wbg.gif"><font
            color="#666600" class="STYLE2"><b>::直接创建GM角色</b></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="25%">GM账号名：</td>
        <td width="75%"><input type="text" name="accname" value="" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="25%">GM角色名：</td>
        <td width="75%"><input type="text" name="rolename" value="" /></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="25%">国家：</td>
        <td><select id="faction" name="faction">
            <option value="1">云州</option>
            <option value="2">沧州</option>
            <option value="3">幽州</option>
        </select></td>
    </tr>
    <tr bgcolor="#FFFFFF">
        <td width="25%">性别：</td>
        <td><select id="sex" name="sex">
            <option value="2">女</option>
            <option value="1">男</option>
        </select></td>
    </tr>
    
    <tr bgcolor="#FFFFFF">
        <td width="25%">
        <input type='hidden' name='action' value='create' />
        </td>
        <td width="75%">
        <input type="submit" name="submit" value="创建" />
        <input type="reset" name="reset" value="重置" /></td>
    </tr>
</table>
</form>



<br/><br/><br/>
<font color='red'>请谨慎操作</font>

<br/><br/><br/>
<hr>
<br>


<br/><br/><br/>


</body>
</html>