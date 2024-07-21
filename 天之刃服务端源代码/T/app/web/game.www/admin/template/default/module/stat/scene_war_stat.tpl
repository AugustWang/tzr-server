<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>场景副本统计</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
    $(document).ready(function(){
        $("#showType").change(function(){
            $("#frm").submit();
        });
    });
</script>
</head>

<body>
    场景副本统计：
    <form action="#" method="POST" id="frm">
    <table style="margin:5px;">
        <tr>
        <td colspan="4">
        选择副本类型：       
            <select name="fb_sel" id="fb_sel">
                <{html_options options=$fb_list  selected=$fb_type}>
            </select>
        统计起始时间: <input type='text' name='start' id='start' size='10' value='<{$start}>' />
        <img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        终止时间: <input type='text' name='end' id='end' size='10' value='<{$end}>' />
        <img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        </td>
        <td>
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    <div style="width:200px;float:left; margin-right:10px; ">
    <div>进入次数的人数分布</div>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>次数</th>
            <th>人数</th>
        </tr>
    <{foreach key=key item=item from=$PeopleTimes}>
        <tr>
            <td><{$item.times}></td>
            <td><{$item.num}></td>
        </tr>
    <{/foreach}>
    </table>
    </div>
    <div style="width:200px;float:left; margin-right:10px; ">
    <div>队伍人数的次数分布</div>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>人数</th>
            <th>次数</th>
        </tr>
        <tr>
            <td><{$SingleTimes.out_number}></td>
            <td><{$SingleTimes.num}></td>
        </tr>
    <{foreach key=key item=item from=$TeamTimes}>
        <tr>
            <td><{$item.out_number}></td>
            <td><{$item.num}></td>
        </tr>
    <{/foreach}>
    </table>
    </div>
    
    
        <div style="width:200px;float:left; margin-right:10px; ">
    <div>按持续时间的人次分布</div>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>持续时间(分)</th>
            <th>人次数</th>
        </tr>
    <{foreach key=key item=item from=$ContinueTime}>
        <tr>
            <td><{$item.contime}></td>
            <td><{$item.num}></td>
        </tr>
    <{/foreach}>
    </table>
    </div>
    
    <div style="width:200px;float:left; margin-right:10px; ">
    <div>玩家(当时)等级的人次分布</div>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>等级</th>
            <th>人次数</th>
        </tr>
    <{foreach key=key item=item from=$GamerLevel}>
        <tr>
            <td><{$item.level}></td>
            <td><{$item.num}></td>
        </tr>
    <{/foreach}>
    </table>
    </div>
    

    <div style="width:200px;float:left; margin-right:10px; ">
    <div>进入时间的分布</div>
    <table class="DataGrid" cellspacing="0" style="margin:5px;">
        <tr>
            <th>进入时间（h）</th>
            <th>人次数</th>
        </tr>
    <{foreach key=key item=item from=$StartTime}>
        <tr>
            <td><{$item.start_from}>点以后</td>
            <td><{$item.num}></td>
        </tr>
    <{/foreach}>
    </table>
    </div>
</body>
</html>