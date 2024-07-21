<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script src="/admin/static/js/jquery.min.js" type="text/javascript" charset="utf-8"></script>
<script language="javascript">
	function doSubmit(type){
		$("#frm").attr("action","?type="+type);
		$("#frm").submit();
	}
</script>
<style type="text/css">
	.current{
		background-color:#D6AAFF;
	}
	

.itemlist {
	background-color: #CCC;
	display: none;
	height: 255px;
	height: 255px;
	left: 254px;
	margin: 0px;
	max-height: 260px;
	overflow: hidden;
	padding: 0px;
	position: absolute;
	top: 0px;
	width: 200px;
}
.itemlist ul li:hover {color: #FF00FF}
</style>
</head>

<body>
<b>数据统计：道具消耗统计</b>

<form action="<{$URL_SELF}>" method="POST" id="frm">
<table>
	<tr>
		<td>
		统计起始日期：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})" size="12" name="startDate" value="<{$startDate}>" />&nbsp;结束时间：<input type="text" class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"  size="12" name="endDate" value="<{$endDate}>" />&nbsp; 
		道具：<input type="hidden" name="itemid" id="itemid" value="<{$itemid}>" /><input type="text" name="itemname" id="itemname" value="<{$itemname}>" onKeyUp="searchItem()" onMouseUp="searchItem();" />
		<!--autocomplete 道具列表-->
		<div style="position:relative;">                
		<div id="itemlist" class="itemlist" ></div>          
		</div>                                                                                  
		<script language="javascript" >                                
			var itemArray = new Array();  
				<{foreach item=idata from=$itemlist}>       
					itemArray[<{$idata.typeid}>] = "<{$idata.typeid}> | <{$idata.item_name}> ";                                        
				<{/foreach}>                                                                  
		function selectItem(iid){                                                       
			document.getElementById('itemid').value = iid;                            
			document.getElementById('itemname').value = itemArray[iid];             
			document.getElementById('itemlist').style.display="none";               
		}                                                                               
		
		function searchItem(){                                                          
			document.getElementById('itemlist').style.display="block";              
			var keyword = document.getElementById('itemname').value ;               
			var onArray = new Array();                                              
			for(kid in itemArray) {                                                 
				if(itemArray[kid].indexOf(keyword) !=-1 ){                      
					onArray[kid] = itemArray[kid]; 
				}                                                               
			}                                                                       
			var str='<ul><li style="text-align:right;"><a href="javascript:;" onclick="hiddenlist();">关闭</a></li>';                                                       
			for(iid in onArray) {                                                   
				str += '<li style="cursor:pointer;" onclick="selectItem('+iid+');">'+onArray[iid]+'</li>';                                                                                      
			}                                                                       
			str += '</ul>';                                                         
			document.getElementById('itemlist').innerHTML = str ;                   
		}                                                                               
		function hiddenlist(){                                                          
			document.getElementById('itemlist').style.display="none";               
		}                                                                               
		</script>   
		<!--autocomplete 道具列表-->
		
		</td>
	</tr>
	<tr>
		<td>
		<input type="button" name="btnGet" value="全 部" onclick="doSubmit(0)" <{if !$type}>class="current"<{/if}> />
		<{foreach from=$arrConsumTypes key=key item=typeName}>
		&nbsp;<input type="button" name="btnGet" value="<{$typeName}>" onclick="doSubmit(<{$key}>)" <{if $key==$type}>class="current"<{/if}> />
		<{/foreach}>
		</td>
	</tr>
</table>
</form>
<br />
<table class="SumDataGrid">
	<tr align="center">
		<th valign="middle" colspan="<{$headerCol}>"><{$headerTip}></th>
	</tr>
	<tr align="center" valign="bottom" height="150">
		<th valign="middle">消耗量</th>
		<{foreach from=$arrResult item=row}>
		<td><{$row.amount}>
			<hr class="<{if $row.amount>$maxAmount*0.75}>hr_red<{else}>hr_green<{/if}>" style=" height:<{if $maxAmount>0}><{$row.amount*120/$maxAmount|round}><{else}>0<{/if}>px;" />
		</td>
		<{/foreach}>
	</tr>
	<tr align="center">
		<th>日期</th>
		<{foreach from=$arrResult item=row}>
		<td>
			<{if 0==$row.week}><span style="color:red;"><{$row.date}><br />周日<br /></span><{else}><{$row.date}><br /><{/if}>
		</td>	
		<{/foreach}>
	</tr>
</table>

</body>
</html>
