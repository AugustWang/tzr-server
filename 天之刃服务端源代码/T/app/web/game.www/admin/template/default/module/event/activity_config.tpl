<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<title>
	查看活动配置
</title>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>

<body style="margin:0">
<div><b>活动：查看活动配置</b></div>
<b>

<style>
	.hiddenData{
		display:none;
	}
	.table_list_head{
		font-size:1.2em;	
	}

	tr.tnice{
		font-weight:normal;	
		font-size:16px;
	}
</style>
<br/>
<{foreach from=$lastMsg item=eachItem key=k}>	

<h3><{$keyList.$k}></h3>

<table class="DataGrid">
		<tr class="table_list_head">
			<td>开始时间</td>
			<td>结束时间</td>
			<td>是否开启</td>
			<td>参数配置</td>
		</tr>
		<{foreach from=$eachItem item=i}>
			<tr class="table_list_body tnice" style="color: <{$i.color}> ">
				<td> <{$i.start_time}> </td>
				<td><{$i.end_time}></td>
				<td><{$i.is_open}></td>
				<td>[查看...]</td>
			</tr>	
			
			<tr class="css hiddenData tnice">
				<td colspan="4">
					<{foreach item=itr from=$i.rec}>
						<{$itr}> <br/>
					<{/foreach}>
				</td>
			</tr>
		<{/foreach}>

</table>


<br/><br/><br/>

<{/foreach}>	






<script>
$('.table_list_body').click(function(idx,val){
	$(this).next('.css').toggleClass('hiddenData');
})


</script>
