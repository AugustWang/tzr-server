<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>vip信息统计</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
function change_fb_type()
{
    jQuery.getJSON("<{$URL_SELF}>", { action: "change_fb", fb_type: jQuery("#fb_type").val() },
    function(json){
        document.getElementById('fb_level').options.length = 0;
         for(var i = 0; i < json.length; i++)
             {
                var varItem = new Option(json[i].map_name, json[i].map_id);      
                document.getElementById('fb_level').options.add(varItem);   
             }
    }); 

}
</script>
</head>

<body>
    副本掉落物品统计统计：
    <form method="POST" id="frm"  action="<{$URL_SELF}>" >
    <table style="margin:5px;">
        <tr>
        <td>
            副本类型选择
            <select name="fb_type" id="fb_type" onchange='change_fb_type();'  >
                <{html_options options=$fb_type_list selected=$fb_type }>
            </select>
        </td>
        <td>
            副本等级
           <select name="fb_level" id="fb_level" >
                <{html_options options=$fb_level_list selected=$fb_level  }>
            </select>
        </td>
        <td colspan="4">
        统计起始时间: <input type='text' name='start' id='start' size='10' value='<{$start}>' />
        <img onclick="WdatePicker({el:'start',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        终止时间: <input type='text' name='end' id='end' size='10' value='<{$end}>' />
        <img onclick="WdatePicker({el:'end',dateFmt:'yyyy-MM-dd'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle">
        </td>
        <td>
        <input type="hidden" name="action" value="search" />
        <input type="image" name='search' src="/admin/static/images/search.gif" class="input2" align="absmiddle"  />
        </td>
        </tr>
    </table>
    </form>
    
    <table class="DataGrid" cellspacing="0" style="margin:10px; width:500px;float:left;">
        <tr>
            <th>道具类型ID</th>
            <th>道具名</th>
            <th>掉落时间</th>
            <th>地图名</th>
        </tr>
    <{foreach key=key item=item from=$log_list}>
        <tr>
            <td><{$item.type_id}></td>
            <td><{$item.item_name}></td>
            <td><{$item.drop_time}></td>
            <td><{$item.map_name}></td>
        </tr>
    <{/foreach}>
    </table>
    
    <table class="DataGrid" cellspacing="0" style="margin:10px;width:500px;float:left;">
        <tr>
            <th>道具类型ID</th>
            <th>道具名</th>
            <th>掉落总数</th>
        </tr>
    <{foreach key=key item=item from=$stat_list}>
        <tr>
            <td><{$item.type_id}></td>
            <td><{$item.item_name}></td>
            <td><{$item.count}></td>
        </tr>
    <{/foreach}>
    </table>
    
</body>
</html>