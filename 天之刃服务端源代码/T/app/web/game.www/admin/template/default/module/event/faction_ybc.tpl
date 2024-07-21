<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
</head>

<body>
	<form action="<{$URL_SELF}>" method="POST">
	<table class="SumDataGrid" width="400">
        <tr bgcolor="#E5F9FF"> 
        	<td align="center" background="/admin/static/images/wbg.gif"><font color="#666600"><b>◆开启国运</b></font></td>
        </tr>
        <tr align="center"> 
       		 <td>
        	国家：<select name="factionId" id="factionId"><{html_options options=$dictFaction selected=$factionId}></select>
            时间--时：<input type="text" value="00" name="startH" id="startH" style="width:40px" />：
            分：<input type="text" value="00" name="startM" id="startM" style="width:40px" />
           <input type="submit" name="submit"  onclick="return chkStart();" value="开启"/>
           </td>
        </tr>
    </table>
    </form>
    <script language="javascript">
		function chkStart(){
			startH =  $("#startH").val();
			startM =  $("#startM").val();
			strTime = startH + ':'+ startM;
			factionName = $("#factionId").find("option:selected").text();
			return confirm('你将于'+strTime+'开启<{$AGENT_NAME}> <{$SERVER_NAME}>服【' +factionName+ '】的国运，确定要开启吗？');
		}
    </script>
</body>
</html>
