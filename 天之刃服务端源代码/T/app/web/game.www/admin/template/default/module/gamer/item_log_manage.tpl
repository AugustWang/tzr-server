<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<style type="text/css">
	.actionTypes li{
		width:200px;
		float:left;
	}

.itemlist {
background-color: #CCC;
display: none;
height: 255px;
height: 255px;
left: 710px;
margin: 0px;
max-height: 260px;
overflow: hidden;
padding: 0px;
position: absolute;
top: 0px;
width: 200px;
}

.itemhelp{
width:180px;
}
.hidtr{
display:none;
}
</style>
<title>
	道具跟踪查询
</title>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function(){
		$("#chkAll").click(function(){
			$("#actionTypes>li :checkbox").attr("checked",$(this).attr("checked"));
		});
		$("#actionTypes>li :checkbox").click(function(){

			chk = true;
			$("#actionTypes>li :checkbox").each(function(){
				if(!$(this).attr("checked")){
					chk = false;
				}
			});
			$("#chkAll").attr("checked",chk);
		});
		chk = true;
		$("#actionTypes>li :checkbox").each(function(){
			if(!$(this).attr("checked")){
				chk = false;
			}
		});
		$("#chkAll").attr("checked",chk);
	});
</script>
</head>

<body style="margin-left:10px;">
<div><b>玩家：道具跟踪查询</b></div>
<b>注:</b>查询以起始时间为准，终止时间如果与起始时间不在同一个星期内，则自动校正到同一星期。同一星期内查询，起始时间和终止时间可以随意输入</br>
<b>注:</b>(使用失去、拾取获得的日志类型需要六小时才能看到)</br>
<div class='divOperation'>

<form name="myform" method="post" action="<{$URL_SELF}>">

请输入玩家登录帐号：<input type='text' id="acname" name='acname' size='10' value='<{$search_keyword1}>' onkeydown="document.getElementById('nickname').value=''"/>

&nbsp;或者角色名：<input type='text' id="nickname" name='nickname' size='10' value='<{$search_keyword2}>' onkeydown="document.getElementById('acname').value=''"/>
起始时间：<input type='text' name='date1' size='12' value='<{$date1}>' class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"  />
&nbsp;终止时间：<input type='text' name='date2' size='12' value='<{$date2}>' class="Wdate" onfocus="WdatePicker({dateFmt:'yyyy-MM-dd'})"  />
&nbsp;道具

<input type="text" name="itemname" id="itemname" value="<{$itemname}>" onKeyUp="searchItem()" onMouseUp="searchItem();" class="itemhelp" />
<input type="image" name='search' src="/admin/static/images/search.gif"  align="absmiddle"/>
<input type="hidden" name="item_id" id = "item_id" value="<{$item_id}>" />
<div style="position:relative;">
<div id="itemlist" class="itemlist" ></div>
</div>
<script language="javascript" >
	var itemArray = new Array();
		<{foreach item=idata from=$itemlist}>
			itemArray[<{$idata.typeid}>] = "<{$idata.typeid}> | <{$idata.item_name}> ";
		<{/foreach}>
function selectItem(iid){
	document.getElementById('item_id').value = iid;
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
		str += '<li onclick="selectItem('+iid+');">'+onArray[iid]+'</li>';
	}
	str += '</ul>';
	document.getElementById('itemlist').innerHTML = str ;
}
function hiddenlist(){
	document.getElementById('itemlist').style.display="none";
}
</script>


<div>
<input type="checkbox" name="chkAll" <{ if $chkAll }> checked="checked" <{ /if }> id="chkAll" value="1">全选<br />
<ul class="actionTypes" id="actionTypes">
	<{foreach from=$arrActionType item=action}>
	<li><input type="checkbox" name="actions[]" value="<{$action.key}>" <{ $action.checked }> ><{$action.text}></li>
	<{/foreach}>
</ul>
</div>

</form>
</div>
<font color=red><{$word}></font>
<table width="100%"  border="0" cellspacing="0" cellpadding="0" class='table_page_num'>
  <tr>
    <td height="30" class="even">

 <{foreach key=key item=item from=$page_list}>
 <a href="<{$URL_SELF}>?acname=<{$search_keyword1|escape:"url"}>&amp;nickname=<{$search_keyword2|escape:"url"}>&amp;date1=<{$date1}>&amp;date2=<{$date2}>&amp;item_id=<{$item_id}>&amp;<{$urlActions}>&amp;page=<{$item}>"><{$key}></a><span style="width:5px;"></span>
 <{/foreach}>
<{if $page_count > 0}>

&nbsp;总共<{$record_count}>个记录&nbsp;总页数(<{$page_count}>)
<{*if $page_count > 5}>
	<input name="acname" type="hidden" value="<{$search_keyword1}>">
	<input name="nickname" type="hidden" value="<{$search_keyword2}>">
	<input name="date1" type="hidden" value="<{$date1}>">
	<input name="date2" type="hidden" value="<{$date2}>">
	<input name="item_id" type="hidden" value="<{$item_id}>">
  <input name="page" type="text" class="text" size="3" maxlength="6">&nbsp;
  <input type="submit" class="button" name="Submit" value="GO">
<{/if*}>
<{/if}>
</form>
    </td>
  </tr>
</table>

<table cellspacing="1" class='DataGrid' >
<!-- SECTION  START -------------------------->
<{section name=loop loop=$keywordlist}>
	<{if $smarty.section.loop.rownum % 20 == 1}>
	<tr>
		<th >角色ID</th><th >角色等级</th>
		<!--<th>道具ID</th>--><th>道具</th>
		<th>个数</th><th>类型</th><th>时间</th>
		<th>颜色</th><th>品质</th><th>绑定</th>
		<th>详细</th>
	</tr>
	<{/if}>

	<{if $smarty.section.loop.rownum % 2 == 0}>
	<tr class='odd'>
	<{else}>
	<tr>
	<{/if}>
		<td>
		<{$keywordlist[loop].userid}>
		</td>
		<td>
        <{$keywordlist[loop].userlevel}>
        </td><td>
		<{$keywordlist[loop].item_name}>
		</td>
		<td><{$keywordlist[loop].amount}></td>
		<td>
		<{$keywordlist[loop].action_desc}>
		</td><td>
		<{$keywordlist[loop].start_time|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td>
		<td>
        <{$keywordlist[loop].color_name}>
        </td>
        <td>
        <{$keywordlist[loop].fineness_name}>
        </td>
        <td>
        <{$keywordlist[loop].bind_desc}>
        </td>
        <td id = "td_<{$keywordlist[loop].super_unique_id}>" >
        <{if $keywordlist[loop].super_unique_id ==0 }>
        <{else}>
        <a href =javascript:void(0); onclick = getdetail(<{$keywordlist[loop].super_unique_id}>) >..打开/关闭</a>
        <{/if}>
        </td>
	</tr>
	<tr id="detail_<{$keywordlist[loop].super_unique_id}>" class="hidtr"  >
    <td colspan = "10" bgcolor="#FFFFFF"></td>
    </tr>
<{sectionelse}>
找不到符合条件的数据
<{/section}>
<br />
<{if $errMsg }><font color="Red"><{ $errMsg }></font><{/if}>
<!-- SECTION  END -------------------------->

<script>

function getdetail(uniqueid){
    if(uniqueid!=0)
    {
        if($("#detail_"+uniqueid).attr("class"))
        {
            $.get("gamer_item_use_view.php", { unique_id: uniqueid,action:"getdetail" },
            function(data){
                if(data=="")
                    data="没有数据";
                $("#detail_"+uniqueid).children().text(data);
            });
            $("#detail_"+uniqueid).removeAttr("class");
        }
        else
        {
            $("#detail_"+uniqueid).addClass("hidtr"); ;
        }
    }
}


</script>
</body>
</html>