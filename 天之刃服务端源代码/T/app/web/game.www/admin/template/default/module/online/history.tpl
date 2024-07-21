<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style type="text/css">

#all {text-align:left;margin-left:4px; line-height:1;}
#nodes {width:100%; float:left;border:1px #ccc solid;}
#result {width: 100%; height:100%; clear:both; border:1px #ccc solid;}

</style>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript">
</script>
</head>

<body>
	<div id="all">	
    	<div><{$errorMsg}></div>
        <div id="main">
            <div class="box">
                <div id="nodes">
                	<table>
                    	<tr>
                        	<{foreach from=$pageHTML key=page_name item=page_id}>
                        	<td><a href="?pid=<{$page_id}>"><{$page_name}></a></td>
                            <{/foreach}>
                        </tr>
                    </table>
                	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
	
                        <tr class='trRollup'>	
                            <td colspan=9>当前系统时间：<{$smarty.now|date_format:"%Y-%m-%d %H:%M:%S"}></td>
                        </tr>
                    </table>
                	<table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
                        <tr bgcolor="#E5F9FF"> 
                            <td colspan="3" background="/admin/static/images/wbg.gif">
                            	<font color="#666600" class="STYLE2"><b>在线信息统计，每30秒统计一次</b></font>
                            </td>
                        </tr>
                        
                        
                        <tr bgcolor="#FFFFFF"> 
                          <td width="25%">最高在线: <{$high}></td>
                          <td width="25%">最低在线: <{$low}></td>
                          <td width="50%">平均在线: <{$aver}></td>
                        </tr>
                        
                        
                        <tr bgcolor="#FFFFFF"> 
                          <td width="25%">统计时间</td>
                          <td width="25%"><label style="color:red; font-weight:bold;">实时</label>在线人数</td>
                          <td width="50%"></td>
                        </tr>
                        <{foreach from=$onlines item=online}>
                    	<tr bgcolor="#FFFFFF"> 
                          <td width="25%"><{$online.dateline|date_format:"%Y-%m-%d %H:%M:%S"}></td>
                          <td width="25%"><{$online.online}></td>
                          <td width="50%"><img src="/admin/static/images/green.gif" height="5" width="<{$online.weight}>" /></td>
                        </tr>
                        <{foreachelse}>
                       	<tr bgcolor="#FFFFFF"> 
                          <td colspan="3"><font color="#FF0000">暂无在线纪录(请检查游戏服是否正常开启了)</font></td>
                        </tr>
                        <{/foreach}>
                        
                     </table>

                </div>
            </div>
        </div>
	</div>
</body>
</html>
