<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<title>查看地图列表</title>
</head>

<body>

<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' style="width:300px;" >
    <tr>
        <th>ID</th>
        <th>名称</th>
    </tr>
<{section name=loop loop=$rsData}>
    <{if $smarty.section.loop.rownum % 2 == 0}>
        <tr class='odd'>
    <{else}>
        <tr>
    <{/if}>
        <td>
            <{$rsData[loop].map_id}>
        </td><td>
            <{$rsData[loop].map_name}>
        </td>
    </tr>
<{sectionelse}>

<{/section}>
</table>

<br />
</body>
</html>
