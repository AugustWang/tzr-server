<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>查看错误日志</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
</head>

<body style="background-color:#B4E097;">

<form action="admin_error_log_view.php" type="post">
	显示行数:<input id="line" name="line" id="line" value="<{$line}>">
	<input type="submit" value="确定">
</form>
<button id="refresh">刷新</button>

<{if $ary}>
<ul>
<{foreach from=$ary item=item}>
<li class="dir">
<a href="admin_error_log_view.php?file=<{$item}>&line=<{$line}>"><{$item}></a>
</li>
<{/foreach}>

</ul>


<{/if}>

<{if $content}>
<span>
	<span class="filename"> <{$file}></span>
	<span clsaa="ret"> <a href="admin_error_log_view.php?line=<{$Line}>">--->  返回目录</a></span>
</span>
<br/>
<hr/>
<pre>
<{$content}>
</pre>
<{/if}>
<style>
li a{
	display:block;
	color:#090909;

}


li{
	list-style-type:circle;
	margin-bottom:5px;
}

ul{
	margin-left:50px;
}
.filename{
	width:50%;
	float:left;
	text-align:center;
	color:red;
	text-align:left;
	font-size:15px;
	
}
.ret{
	float:right;
	width:100%;
	text-align:right;
}

</style>
<script>


$("#refresh").click(function(){
window.location = "admin_error_log_view.php?file=<{$file}>&line="+$("#line").val();
})

/*
document.getElementById('btn').click = function(e){
	var line = document.getElementsById("line").value;
	window.location="admin_error_log_view.php?file=<{$file}>&line="+line;
	e.preventDefault();
	return false;
}*/

</script>
</body>
</html>
