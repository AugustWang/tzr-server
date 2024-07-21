<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>导出地图流失率数据</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
useDefaultMapID = function(){
    $('#maps').val("11000,11001,11100,11101,11102,11103,11105");
}
function onlyNum(){
    if (!((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105))) 
        //考虑小键盘上的数字键
        event.returnvalue = false;
}

</script>
</head>

<body>
<form action="" method="post">
	<table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
        <tr bgcolor="#E5F9FF"> 
        	<td colspan="2" background="/admin/static/images/wbg.gif">
        	   <font color="#666600" class="STYLE2"><b>◆导出地图流失率数据</b></font>
        	</td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td colspan="2">
            <div style="width:800px;float:left;">
			    <a href="list_map.php" target="_BLANK" style="border-bottom:1px solid red;">
			         <font  color='red'><b>查看地图列表</b></font></a>
			</div>
          </td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td width="25%">地图ID列表</td>
          <td width="75%" >
          	<div>
            	<input type="text" name="maps" id="maps" value="11001" size="60"  />
	          	<input type="checkbox" id="checkMapID" name="checkMapID"
				onclick="useDefaultMapID()" />默认地图列表（云州的王都、太平村、横涧山等）
            </div> 
          </td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td width="25%">玩家离线的最后相隔时间</td>
          <td width="75%"><input type="text" name="time_gap" id="time_gap" onkeydown="onlyNum()" value="24" size="60" />（单位：小时）</td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td width="25%">玩家的最大级别</td>
          <td width="75%"><input type="text" name="level" onkeydown="onlyNum()"  value="3" size="60" /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
          <td width="25%"></td>
          <td><input type="submit" value="导出数据" /></td>
        </tr>
    </table>
</form>
</body>
</html>
