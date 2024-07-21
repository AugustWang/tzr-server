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
<a href="<{$URL_SELF}>?action=dmyx" style="color: red;"><b>大明英雄副本</b></a>
<a href="<{$URL_SELF}>?action=pyh" style="color: blue; text-decoration: underline;"><b>鄱阳湖副本</b></a>
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
        <input type="hidden" name="action" value="dmyx" />
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>        
    <div style="width:500px; float:left;margin:10px;">
        参与人数统计
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
    <div style="width:200px;float:left;margin:10px;" >每关进入次数统计
    
    <table class="DataGrid" cellspacing="0" >
    
        <tr>
            <th>关数</th>
            <th>进入次数</th>
        </tr>
        <{if $inlist}>
                        <{foreach from=$inlist item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$row.level}></td>
                            <td><{$row.times}></td>
                        </tr>
                        <{/foreach}>
                    <{else}>
                    <tr>
                        <td colspan="6" align="center">没数据</td>
                    </tr>
                    <{/if}>
    </table></div>
    <div style="width:200px;float:left;margin:10px;" >元宝消耗购买次数统计
   
    <table class="DataGrid" cellspacing="0" >
        <tr>
            <th>元宝价格</th>
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
                            <td><{$row.gold}></td>
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
    <div style="width:200px;float:left;margin:10px;" >玩家打副本次数
   
    <table class="DataGrid" cellspacing="0" >
        <tr>
            <th>副本次数</th>
            <th>副本人数</th>
        </tr>
        <{if $timeslist}>
                        <{foreach from=$timeslist item=row key=key}>
                        <{if $key%2 == 0}>
                        <tr class='odd'>
                        <{else}>
                        <tr>
                        <{/if}>
                            <td><{$row.count}></td>
                            <td><{$row.times_num}></td>
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