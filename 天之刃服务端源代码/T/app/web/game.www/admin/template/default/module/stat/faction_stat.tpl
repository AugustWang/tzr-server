<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>势力对比</title>
<link href="/css/style.css" rel="stylesheet" type="text/css" /></head>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script src="/admin/static/js/jquery.min.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>

<style type="text/css" media="screen">
.em{
	background-color:#eedece;	
}	

</style>

<body style="margin:10px">
<div>
<b>统计：势力统计</b>
</div>

<div>	
<b>活跃用户：最近7天总在线时间不低于7小时的用户</b>
</div>

<div style='width:500px;float:left;'>
	<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' >
		<tr class='table_list_head'>
			<th colspan=4>注册人数</th>
		</tr>
		<tr class='table_list_head'>
			<th width=30>国家</th>
			<th width=50>人数</th>
			<th width=40>比例</th>
			<th></th>
		</tr>
<{foreach key=key item=row from=$faction_reg_count}>
		<tr>
			<td><{$faction[$key].name}></td>
			<td><{$row}></td>
			
			<{if $reg_total == 0}>
			<td>0</td>
			<{else}>
			<td><{math equation="(x/y)*z" x=$row y=$reg_total z=100 format="%.2f"}>%</td>
			<{/if}>
			
			
			<td><div style='background-color:darkgreen;height:18px;width:<{if $max_reg_faction == 0}>0<{else}><{math equation="(( x/y)*z )" x=$row y=$max_reg_faction z=100 }><{/if}>px;'></div></td>
		</tr>
<{/foreach}>
	</table>	
</div>


<div style='width:500px;float:left;'>
	<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' >
		<tr class='table_list_head'>
			<th colspan=4>活跃人数</th>
		</tr>
		<tr class='table_list_head'>
			<th width=30>国家</th>
			<th width=50>人数</th>
			<th width=40>比例</th>
			<th></th>
		</tr>
<{foreach key=key item=row from=$faction_active_count}>
		<tr>
			<td><{$faction[$key].name}></td>
			<td><{$row}></td>
			
			<{if $active_total == 0}>
			<td>0</td>
			<{else}>
			<td><{math equation="(x/y)*z" x=$row y=$active_total z=100 format="%.2f"}>%</td>
			<{/if}>
			
			<td><div style='background-color:darkgreen;height:18px;width:
			<{if $max_active_faction == 0}>0<{else}><{math equation="(( x / y ) * z )" x=$row y=$max_active_faction z=100}><{/if}>px;'
			></div></td>
		</tr>
<{/foreach}>
	</table>	
</div>


<br/><br/><br/><br/><br/><br/><br/><br/><br/>


<b style="float:left">职业对比</b>
<br/>
<div style='width:800px;float:left;'>
	<table cellspacing="1" cellpadding="3" border="0" class='DataGrid' >
		<tr class='table_list_head'>
			<th width="80">等级</th>
			<th width="350">战士</th>
			<th width="350">射手</th>
			<th width="350">侠客</th>
			<th width="350">医仙</th>
			<th width="350">总共</th>
		</tr>
		
		
		<tr >
			<td width="80">全部</td>
			<td width="350">
				<div class="show">云州:<{$all.1.1}>
				<{if $all.1.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.1.1 y=$all.1.5 format="%.2f"}>%)
				<{/if}>
				
				</div>
				<div class="show">沧州:<{$all.1.2}>	
				<{if $all.1.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.1.2 y=$all.1.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$all.1.3}>
				<{if $all.1.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.1.3 y=$all.1.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">总共:<{$all.1.5}></div>
				
			</td>
			<td width="350">
				<div class="show">云州:<{$all.2.1}>
				<{if $all.2.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.2.1 y=$all.2.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">沧州:<{$all.2.2}>
				<{if $all.2.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.2.2 y=$all.2.5 format="%.2f"}>%)
				<{/if}>
				
				</div>
				<div class="show">幽州:<{$all.2.3}>
				<{if $all.2.5 != 0}>												
				( <{math equation="(x/y)*100" x=$all.2.3 y=$all.2.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">总共:<{$all.2.5}></div>
			</td>
			<td width="350">
				<div class="show">云州:<{$all.3.1}>				
				<{if $all.3.5 != 0}>			
				(<{math equation="(x/y)*100" x=$all.3.1 y=$all.3.5 format="%.2f"}>%)
				<{/if}>
				</div>				
				<div class="show">沧州:<{$all.3.2}>
				<{if $all.3.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.3.2 y=$all.3.5 format="%.2f"}>%)
				<{/if}>
				</div>
				
				<div class="show">幽州:<{$all.3.3}>
				<{if $all.3.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.3.3 y=$all.3.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">总共:<{$all.3.5}></div>
			</td>
			<td width="350">
				<div class="show">云州:<{$all.4.1}>
				<{if $all.4.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.4.1 y=$all.4.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">沧州:<{$all.4.2}>
				<{if $all.4.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.4.2 y=$all.4.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$all.4.3}>
				<{if $all.4.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.4.3 y=$all.4.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">总共:<{$all.4.5}></div>
			</td>
			<td width="350">
				<div class="show">云州:<{$all.5.1}>
				<{if $all.5.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.5.1 y=$all.5.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">沧州:<{$all.5.2}>
				<{if $all.5.5 != 0}>		
				(<{math equation="(x/y)*100" x=$all.5.2 y=$all.5.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$all.5.3}>
				<{if $all.5.5 != 0}>
				(<{math equation="(x/y)*100" x=$all.5.3 y=$all.5.5 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">总共:<{$all.5.5}></div>
			</td>
		</tr>
		
		<{foreach item=item from=$occupationAry}>
		<tr >
			<td width=40 >
				<{$item.level}>
			</td>
			<td width='200px'>
				<div class="show">云州:<{$item.1.1}>
					<{if $item.5.1 != 0}>		
					(<{math equation="(x/y)*100" x=$item.1.1 y=$item.5.1 format="%.2f"}>%)
					<{/if}> 
				</div>
				<div class="show">沧州:<{$item.1.2}>
					<{if $item.5.2 != 0}>		
					(<{math equation="(x/y)*100" x=$item.1.2 y=$item.5.2 format="%.2f"}>%)
					<{/if}>
				</div>
				
				<div class="show">幽州:<{$item.1.3}>
					<{if $item.5.3 != 0}>		
					(<{math equation="(x/y)*100" x=$item.1.3 y=$item.5.3 format="%.2f"}>%)
					<{/if}>	
				</div>
			</td>
			<td width='200px'>
				<div class="show">云州:<{$item.2.1}>
					<{if $item.5.1 != 0}>		
					(<{math equation="(x/y)*100" x=$item.2.1 y=$item.5.1 format="%.2f"}>%)
					<{/if}> 			
				
				</div>
				<div class="show">沧州:<{$item.2.2}>
				<{if $item.5.2 != 0}>		
					(<{math equation="(x/y)*100" x=$item.2.2 y=$item.5.2 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$item.2.3}>
				<{if $item.5.3 != 0}>		
					(<{math equation="(x/y)*100" x=$item.2.3 y=$item.5.3 format="%.2f"}>%)
				<{/if}>	
				
				</div>
			</td>
			
			<td width='200px'>
				<div class="show">云州:<{$item.3.1}>
					<{if $item.5.1 != 0}>		
					(<{math equation="(x/y)*100" x=$item.3.1 y=$item.5.1 format="%.2f"}>%)
					<{/if}> 	
				</div>
				<div class="show">沧州:<{$item.3.2}>
				<{if $item.5.2 != 0}>		
					(<{math equation="(x/y)*100" x=$item.3.2 y=$item.5.2 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$item.3.3}>
				<{if $item.5.3 != 0}>		
					(<{math equation="(x/y)*100" x=$item.3.3 y=$item.5.3 format="%.2f"}>%)
				<{/if}>
				
				</div>
			</td>
			
			<td width='200px'>
				<div class="show">云州:<{$item.4.1}>
					<{if $item.5.1 != 0}>		
					(<{math equation="(x/y)*100" x=$item.4.1 y=$item.5.1 format="%.2f"}>%)
					<{/if}> 	
				</div>
				<div class="show">沧州:<{$item.4.2}>
				<{if $item.5.2 != 0}>		
					(<{math equation="(x/y)*100" x=$item.4.2 y=$item.5.2 format="%.2f"}>%)
				<{/if}>
				</div>
				<div class="show">幽州:<{$item.4.3}>
				<{if $item.5.3 != 0}>		
					(<{math equation="(x/y)*100" x=$item.4.3 y=$item.5.3 format="%.2f"}>%)
				<{/if}>
				</div>
			</td>
			
			<td width='200px'>
				<div class="show">云州:<{$item.5.1}>	</div>
				<div class="show">沧州:<{$item.5.2}></div>
				<div class="show">幽州:<{$item.5.3}></div>
			</td>
			
		</tr>
		<{/foreach}>
	</table>
	
	
	
</div>


<script type="text/javascript" charset="utf-8">
	$(function(){
		$("tr.change_color").each(function(idx,val){
			var curLevel =  getLevelOf($(this));
			var nextLevel = getLevelOf($(this).next("tr"));
			if (curLevel != nextLevel) {
				$(this).next("tr").addClass("em");
			};
		}
		)});

	//$("tr.change_color").next("tr").find("td.level").attr("level")
	function getLevelOf ($dom) {
		return $dom.find("td.level").attr('level');	
	}

	$(function(){
		$('.show').each(function(){
				if(   $(this).text().indexOf('总共') == -1 && $(this).text().indexOf('幽州') == -1){
					$(this).append("<hr class='he_sep'></hr>");
				}
			})
		
		})
</script>

<style>
.show{
	border-bottom-width:100%;
	border-bottom-height:2px;
	border-bottom-style:thick double #ff0000;
}

</style>

		
</body>
</html>