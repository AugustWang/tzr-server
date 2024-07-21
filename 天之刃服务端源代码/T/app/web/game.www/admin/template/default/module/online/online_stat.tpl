<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
	在线数据统计分析
</title>
<link href="../../css/style.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<body style="margin:0">
<b>在线与注册：在线数据统计</b>
<div class='divOperation'>
				<form name="myform" method="post" action="<{$URL_SELF}>">
统计起始时间：<input type='text' name='date1' id="date1" size='10' value='<{$date1}>' />
<img onclick="WdatePicker({el:'date1'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

&nbsp;终止时间：<input type='text' name='date2' id="date2" size='10' value='<{$date2}>' />
<img onclick="WdatePicker({el:'date2'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
&nbsp;&nbsp;
采样单位：
<select id="viewtype" name="viewtype" >
	<option value="1" <{if $viewtype==1}>selected<{/if}>>小时最大值</option>
	<option value="2" <{if $viewtype==2}>selected<{/if}>>每天平均值</option>
	<option value="3" <{if $viewtype==3}>selected<{/if}>>每分钟在线</option>
	<option value="4" <{if $viewtype==4}>selected<{/if}>>每天最高值</option>
</select>
&nbsp;&nbsp;&nbsp;
<input type="button" class="button" name="datePrev" id="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?date1=<{$dateStrPrev}>&amp;date2=<{$dateStrPrev}>&amp;viewtype=<{$viewtype}>';">
&nbsp;&nbsp;&nbsp;
<input type="button" class="button" name="dateNext" id="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?date1=<{$dateStrNext}>&amp;date2=<{$dateStrNext}>&amp;viewtype=<{$viewtype}>';">

<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
</form>
</div>

<TABLE style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid; BORDER-COLLAPSE: collapse; BACKGROUND-COLOR: white" cellSpacing=0 cellPadding=0 border=0>
              <TBODY>
              <TR>
                <TD style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-WEIGHT: bold; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" align="left" colSpan=33><{$date1}>日~<{$date2}>日<FONT 
                  color=red><{if $viewtype==1}>每小时最高在线<{/if}><{if $viewtype==2}>每天平均在线<{/if}><{if $viewtype==3}>每1分钟最高在线<{/if}></FONT>趋势图(总平均值:<{$avgonline}>&nbsp;&nbsp;&nbsp;&nbsp;最大值：<{$maxonline}>)</TD></TR>
              <TR>           
                <TD style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid" 
                vAlign=bottom align=middle>
                <table cellpadding="0" cellspacing="1"><tr>
                <{section name=loop loop=$datalist}>
                <td valign="bottom">
                  <TABLE cellSpacing=0 cellPadding=0 width=15 border=0 
                        valign="bottom">
                          <TBODY>
                          <TR>
                            <TD height=47></TD></TR>
                          <TR>
                            <TD vAlign=bottom align=middle height=20><FONT 
                              color=red size=1><{$datalist[loop].avgonline}></FONT>
                           </TD></TR>
                          <TR>
                            <TD vAlign=bottom align=middle><IMG 
                              title=在线数：<{$datalist[loop].avgonline}> height=<{$datalist[loop].height}> 
                              src="/admin/static/images/green.gif" 
                          width=10></TD></TR>
				 <tr>
                 <TD style="BORDER-RIGHT: 1px solid; BORDER-TOP: 1px solid; FONT-SIZE: 8pt; BORDER-LEFT: 1px solid; BORDER-BOTTOM: 1px solid; WHITE-SPACE: nowrap; BACKGROUND-COLOR: whitesmoke" align=middle>
				 <{if $viewtype==3}>
                 <{$datalist[loop].hour}>:<{$datalist[loop].min}>
                 
                 <{else}>
                 <{$datalist[loop].hour}>
				  <{if $datalist[loop].minute!=""}>	: <{/if}>
				  <{$datalist[loop].minute}>

				 <{if $datalist[loop].hour!=""}>				 
				 <br/>
				 <{/if}>
				 
				 <{$datalist[loop].month}>/<{$datalist[loop].day}>
                 <{/if}>
                 </TD></tr>
						  </TBODY></TABLE>
			      </td>
			      <{/section}>	
			      </tr>
			      </table>
</TD></TR></TBODY></TABLE>
	
			


</body>
</html>
<script type="text/javascript">
var dt = new Date();
var year = dt.getFullYear();
var month = dt.getMonth()+1;
var dd = dt.getDate();
var date = year+'-0'+month+'-0'+dd;
var date2 = document.getElementById("date2").value;
var viewtype = document.getElementById("viewtype").value;
if(viewtype == 3){
	document.getElementById("date1").disabled = true;
	document.getElementById("date2").disabled = true;
}
if(date == date2){
	document.getElementById("dateNext").disabled = true;
}
</script>