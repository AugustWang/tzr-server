<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<title>流失统计汇总</title>
<script type="text/javascript">
</script>
</head>

<body>
<table cellspacing="1" cellpadding="5" border="0" class='table_list' >
    <tr class='table_list_head' align='center'><td colspan="9" align="center"><{$intervalHour}>小时人数统计</td></tr>
    <tr align='center'>
        <td>角色总量</td>
        <td>开服时间</td>
        <td>0级玩家</td>
        <td>1级玩家</td>
        <td>2级玩家</td>
        <td>3级玩家</td>
        <td><=10级玩家</td>
        <td><=20级玩家</td>
        <td><=30级玩家</td>
    </tr>
    <tr align='center'>
        <td><{$numOfAll}></td>
        <td><{$server_online_date}></td>
        <td><{$numOfLevelZero}></td>		
        <td><{$numOfLevelOne}></td>
        <td><{$numOfLevelSecond}></td>
        <td><{$numOfLevelTrd}></td>
        <td><{$numOfLevelTen}></td>
        <td><{$numOfLevelTweenty}></td>
        <td><{$numOfLevelThirty}></td>
    </tr>
</table>
<br />

<table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
    <tr bgcolor="#E5F9FF"> 
        <td colspan="3" background="/admin/static/images/wbg.gif">
            <font color="#666600" class="STYLE2"><b>流失率统计</b></font>
        </td>
    </tr>
    <{if $numOfAll > 0}>
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">0级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelZero y=$numOfAll format="%.2f"}>% </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">1级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelOne y=$numOfAll format="%.2f"}>% </td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">2级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelSecond y=$numOfAll format="%.2f"}>% </td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">3级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelTrd y=$numOfAll format="%.2f"}>% </td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">10级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelTen y=$numOfAll format="%.2f"}>% </td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">20级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelTweenty y=$numOfAll format="%.2f"}>% </td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">30级流失率</td>
      <td width="75%"><{math equation="(( x / y) * 100)" x=$numOfLevelThirty y=$numOfAll format="%.2f"}>% </td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">欢迎窗口流失率</td>
      <td width="75%"><{math equation="(( (y-x) / y) * 100)" x=$numOfAllEnterGame y=$numOfAll format="%.2f"}>%</td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">创建流失率</td>
      <td width="75%"><{math equation="(( (y - x) / y) * 100)" x=$numOfCreate y=$numOfAllAccount format="%.2f"}>%</td>
    </tr>  
    <tr bgcolor="#FFFFFF"> 
      <td width="25%"></td>
      <td width="75%"></td>
    </tr>  
    <{else}>
    <tr bgcolor="#FFFFFF"> 
      <td width="25%">暂无数据</td>
      <td width="75%"></td>
    </tr> 
    <{/if}>
</table>
                     
                     
</body>
</html>