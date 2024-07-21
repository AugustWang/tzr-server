<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>系统顶级配置项</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
</head>

<body style="margin:10px">

<div>
	<h4>修改系统全局变量配置</h4>
	<font color=red>警告：如果你不清楚这里的内容，请勿进行任何操作。</font>
</div>
<div style='float:left;'>
	<table cellspacing="1" cellpadding="3" border="1" class='table_list' style='width:auto;margin-right:10px;'>
		<tr><td colspan=2>可用变量</td></tr>
		<tr><td>变量名</td><td>值</td></tr>
<{foreach key=pname item=pval from=$params}>
		<tr><td><{$pname}></td><td><{$pval}></td></tr>
<{/foreach}>
	</table>
</div>
<div style='float:left;'>
		<form name="myform" method="post" action="<{$URL_SELF}>">
			<input type='hidden' name='ac' value='modify' />
			<table cellspacing="1" cellpadding="3" border="0" class='table_list' style='width:auto;'>
				<tr class='table_list_head'>
					<td>KEYNAME</td>
					<td>说明</td>
					<td>当前设置值</td>
					<td>参考取值</td>
				</tr>
<{section name=loop loop=$data}>
	<{if $smarty.section.loop.rownum % 2 == 0}>
				<tr class='trEven'>
	<{else}>
				<tr class='trOdd'>
	<{/if}>
					<td><{$data[loop].ckey}></td>
					<td><{$data[loop].memo}></td>
					<td>
	<{if $data[loop].readonly}><{$data[loop].cvalue|escape:"html"}><{else}>
		<{if $data[loop].ctype == 'string' || $data[loop].ctype == 'int' || $data[loop].ctype == 'float'}>
						<input type='input' name='<{$data[loop].ckey}>' id='<{$data[loop].ckey}>' style='width:400px;' value="<{$data[loop].cvalue|escape:"html"}>" />
		<{/if}>
		<{if $data[loop].ctype == 'text'}>
						<textarea name='<{$data[loop].ckey}>' id='<{$data[loop].ckey}>' style='width:400px;height:80px;' ><{$data[loop].cvalue|escape:"html"}></textarea>
		<{/if}>
		<{if $data[loop].ctype == 'boolean'}>
						<input type='checkbox' name='<{$data[loop].ckey}>' id='<{$data[loop].ckey}>' <{if $data[loop].cvalue == 'true'}>checked<{/if}> />
						打上勾，表示“是”。不打勾，表示“否”
		<{/if}>
	<{/if}>
					</td>
					<td><{$data[loop].example|escape:"html"}></td>
				</tr>
<{sectionelse}>
<{/section}>
				<tr><td colspan='4'>
					<div style='text-align:center;'>
						<input type="submit" name='save' class="input2" value='立即保存修改' />
					</div>
				</td>
			</tr>
		</table>
	</form>
</div>

</body>
</html>
