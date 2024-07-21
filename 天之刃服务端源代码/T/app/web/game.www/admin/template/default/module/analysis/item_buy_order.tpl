<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>
    道具获得统计
</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

</head>

<body style="margin-left:10px;">
<b>数据分析：道具获得排行</b>
<div class='divOperation'>
                <form name="myform" method="post" action="<{$URL_SELF}>">
                    <input type='hidden' name='order' value='<{$order}>' />

统计起始时间：<input type='text' name='dateStart' id="dateStart" size='10' value='<{$search_keyword1}>' />
<img onclick="WdatePicker({el:'dateStart'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">

&nbsp;终止时间：<input type='text' name='dateEnd' id="dateEnd" size='10' value='<{$search_keyword2}>' />
<img onclick="WdatePicker({el:'dateEnd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">


<input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />

&nbsp;&nbsp;&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="今天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrToday}>&dateEnd=<{$dateStrToday}>';">
&nbsp;&nbsp
<input type="button" class="button" name="datePrev" value="前一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrPrev}>&dateEnd=<{$dateStrPrev}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateNext" value="后一天" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=<{$dateStrNext}>&dateEnd=<{$dateStrNext}>';">
&nbsp;&nbsp
<input type="button" class="button" name="dateAll" value="全部" onclick="javascript:location.href='<{$URL_SELF}>?order=<{$order}>&dateStart=ALL&dateEnd=ALL';">

</form>

</div>

<table cellspacing="1" class='DataGrid' style="margin-left:5px;width:600px;">
        <tr>
            <th colspan=3 align="center">
                道具获得统计&nbsp;&nbsp;&nbsp;&nbsp;统计时间范围：<{$search_keyword1}> 0:0:0
        至 <{$search_keyword2}> 23:59:59
            </th>
        </tr>
        <tr>
            <th>道具名称</th>
            <th>购买数量</th>
            <th>当前排名</th>
            <th>排序升降</th>
        </tr>
    <{foreach key=key item=row from=$order_data}>
        <tr class="<{cycle values='trOdd, trEven'}>">
            <td><{$items[$key]}></td>
            <td><{$row}></td>
            <td><{$order[$key].today_order}></td>
            <td><{if $order[$key].up}><font color=red>↑<{$order[$key].up}></font><{elseif $order[$key].down}><font color=green>↓<{$order[$key].down}></font><{/if}></td>
        </tr>
    <{/foreach}>
    </table>
<br>

</body>
</html>