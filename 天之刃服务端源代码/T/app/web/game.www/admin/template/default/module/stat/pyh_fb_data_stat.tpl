<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>

</head>

<body>
<b>副本数据统计：大明英雄副本数据统计</b>
<br />
<a href="<{$URL_SELF}>?action=dmyx" style="color: blue; text-decoration: underline;"><b>大明英雄副本</b></a>
<a href="<{$URL_SELF}>?action=pyh" style="color: red;"><b>鄱阳湖副本</b></a>
<a href="<{$URL_SELF}>?action=dtfd" style="color:blue; text-decoration: underline;"><b>洞天福地副本</b></a>
<br /><br />
    <form method="POST" id="frm"  action="<{$URL_SELF}>" >
    <table style="margin:5px;">
        <tr>
        <td colspan="4">
        统计起始时间: <input type='text' name='start' id='start' size='10' value='<{$start}>' />
        <img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        终止时间: <input type='text' name='end' id='end' size='10' value='<{$end}>' />
        <img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        </td>
        <td>
        <input type="hidden" name="action" value="pyh" />
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
 <div style="width:500px; float:left;margin:10px;">
        副本参与率
    <table class="DataGrid" cellspacing="0"  >

        <tr>
            <th>时间</th>
            <th>参与总人数</th>
            <th>≥20级活跃玩家人数</th>
            <th>参与率</th>
        </tr>
        <{if $joinlist}>
                        <{foreach from=$joinlist item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$row.day}></td>
                            <td><{$row.all_count}></td>
                            <td><{$row.active_20}></td>
                            <td><{$row.rate}>%</td>
                        </tr>
                        <{/foreach}>
                    <{else}>
                    <tr>
                        <td colspan="6" align="center">没数据</td>
                    </tr>
                    <{/if}>
    </table>
     </div>

<div style="width:200px;float:left;margin:10px;" >参与次数
    
    <table class="DataGrid" cellspacing="0" >
    
        <tr>
            <th>参与次数</th>
            <th>人次数</th>
        </tr>
        <{if $inlist}>
                        <{foreach from=$inlist item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$row.times}></td>
                            <td><{$row.in_num}></td>
                        </tr>
                        <{/foreach}>
                    <{else}>
                    <tr>
                        <td colspan="6" align="center">没数据</td>
                    </tr>
                    <{/if}>
    </table></div>
    
    <div style="width:200px;float:left;margin:10px;" >副本购买次数
    <table class="DataGrid" cellspacing="0" >
        <tr>
            <th>购买次数</th>
            <th>购买人数</th>
        </tr>
        <{if $paylist}>
                        <{foreach from=$paylist item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$key+1}></td>
                            <td><{$row.pay_num}></td>
                        </tr>
                        <{/foreach}>
                    <{else}>
                    <tr>
                        <td colspan="6" align="center">没数据</td>
                    </tr>
                    <{/if}>
    </table> </div>
</body>
</html>