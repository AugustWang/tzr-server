<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<title>道具列表</title>
</head>

<body>

<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">
    <form method="post" action="?">
        <input type="hidden" name="action" value="search" size="10"/>道具名：
        <input type="text" name="item_name" value="<{$item_name}>" size="10"/>
        <input type="submit" value="搜索" />
    </form> 
    </td>
  </tr>
</table>

<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' style="width:300px;" >
    <tr>
        <th>ID</th>
        <th>类型</th>
        <th>名称</th>
    </tr>
<{section name=loop loop=$rsData}>
    <{if $smarty.section.loop.rownum % 2 == 0}>
        <tr class='odd'>
    <{else}>
        <tr>
    <{/if}>
        <td>
            <{$rsData[loop].typeid}>
        </td><td>
            <{$rsData[loop].type}>
        </td><td>
            <{$rsData[loop].item_name}>
        </td>
    </tr>
<{sectionelse}>

<{/section}>
</table>

<br />
</body>
</html>
