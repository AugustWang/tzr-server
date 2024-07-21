<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<title>密码修改</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
</HEAD>

<body>

<div class="main">


  <div id="centerm"><div id="content">
  
  <form name='password' id='password' action='' method='post' onsubmit=''>
<input type='hidden' name='action' id='action' value='update' />
  
<table cellspacing="1" cellpadding="3" border="0" style="border-color:SkyBlue;border-width:1px;border-style:solid;width:auto;">
	<tr style="color:#232323;background-color:#D7E4F5;font-weight:bold;">
<td colspan='2' class='title' align="middle">密码修改: <{$username}></td></tr>

<tr style="background-color:#EDF2F7;"><td align="right">原密码</td><td>
<input type='password' class='text' name='oldpass' id='oldpass' size='25' maxlength='60' value='' />
</td></tr>
<tr style="background-color:#EDF2F7;"><td align="right">新密码</td><td>
<input type='password' class='text' name='newpass1' id='newpass1' size='25' maxlength='60' value='' />
</td></tr>
<tr style="background-color:#EDF2F7;"><td align="right">再次输入新密码</td><td>
<input type='password' class='text' name='newpass2' id='newpass2' size='25' maxlength='60' value='' />
</td></tr>

<tr style="color:#232323;background-color:#D7E4F5;font-weight:bold;"><td align="right" colspan=2>
<input type='submit' class='button' name='submit'  id='submit' value='保 存' />
&nbsp;&nbsp;
<font color=red><{$message}></font>
</td></tr>

</table></form>

</div></div>
</div>

</body>
</html>