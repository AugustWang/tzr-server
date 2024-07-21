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
<a href="<{$URL_SELF}>?action=pyh" style="color:blue; text-decoration: underline;"><b></b>鄱阳湖副本</a>
<a href="<{$URL_SELF}>?action=dtfd" style="color: red;"><b>洞天福地副本</b></a>
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
        <input type="hidden" name="action" value="dtfd" />
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    <div style="float:left;margin:10px;width:800px;" >进入副本的人数、次数统计
    <table class="DataGrid" cellspacing="0" width="400px" >
        <tr>
            <td>进入副本总人数</td>
            <td><{$all_num}></td>
            <td>进入副本总人次</td>
            <td><{$all_times}></td>
        </tr>
    </table>
    <br/>
    <table class="DataGrid" cellspacing="0" width="100%" >
        <tr>
            <th rowspan =2 >统计时间</th>
            <th colspan = 3>进入副本人数</th>
            <th colspan = 3>进入副本人次</th>
            <th rowspan=2 style="width:200px;" >35级以上当日登陆玩家数</th>
        </tr>
        <tr>
            <th>35级</th>
            <th>45级</th>
            <th>55级</th>
            <th>35级</th>
            <th>45级</th>
            <th>55级</th>
        </tr>
        <{if $list}>
                        <{foreach from=$list item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$row.day}></td>
                            <td><{$row.num1}></td>
                            <td><{$row.num2}></td>
                            <td><{$row.num3}></td>
                            <td><{$row.times1}></td>
                            <td><{$row.times2}></td>
                            <td><{$row.times3}></td>
                            <td><{$row.login_num}></td>
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