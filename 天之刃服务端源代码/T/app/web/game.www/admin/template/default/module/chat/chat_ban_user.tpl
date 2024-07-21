<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<title>
	设置玩家禁言
</title>
</head>



<body style="margin:10px">
	
<b>消息管理：设置玩家禁言</b>
<br/>
<form id="form1" name="form1" method="post" action="<{$URL_SELF}>">
玩家角色名：　
<input type='text' name='nickname' size='16' value='' />  (同一角色，如果设置多次，只有最后一次有效)
<br/>
禁言多少分钟：<input type='text' name='interval' size='10' value='<{$minuteInterval}>' />
&nbsp;(建议禁言30分钟就可以了。)
<br/>
系统提示信息内容 (将提示信息内容框清空，即可禁言某人，但不发系统通知)<br/>
<textarea name='content' id='content' cols=60 rows=5>玩家{USERNAME}因发布不文明信息，被系统禁言{MINUTE}分钟。</textarea>

&nbsp;&nbsp;
					<input type="submit" name='ok' value='设置' class="input2"  />
</form>			

<form id="form2" name="form2" method="post" action="<{$URL_SELF}>">		
<br/><br/>
<input type="submit" name='clear_old' value='清除已到期的数据' class="input2"  />		
</form>


<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
<!-- SECTION  START -------------------------->
<form id="form3" name="form3" method="post" action="">
<{section name=loop loop=$keywordlist}>	
	<{if $smarty.section.loop.rownum % 20 == 1}> 
	<tr class='table_list_head'>
		<td></td>
		<td>角色ID</td>
		<td>角色名</td>
		<td >开始禁言时间</td><td >禁言结束时间</td><td >禁言多少分钟</td><td >系统提示信息</td>
		
	</tr>
	<{/if}> 

	<{if $smarty.section.loop.rownum % 2 == 0}> 
	<tr class='trEven'>
	<{else}> 
	<tr class='trOdd'>
	<{/if}> 
		<td>	
			<a href='?del=<{$keywordlist[loop].role_id}>'>删除</a>		
		</td><td>		
		<{$keywordlist[loop].role_id}>			
		</td><td>		
		<{$keywordlist[loop].role_name}>
		</td><td>					
		<{$keywordlist[loop].time_start|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>		
		<{$keywordlist[loop].time_end|date_format:"%Y-%m-%d %H:%M:%S"}>
		</td><td>		
		<{$keywordlist[loop].duration}>
		</td><td>								
		<{$keywordlist[loop].reason}>
		</td>
	</tr>
<{sectionelse}>
<br/>还没有设置玩家禁言
<{/section}>	
<!-- SECTION  END -------------------------->		

</form>
</table>

    <!-- 查找用户快捷栏  START -------------------------->
    <br><br><br><br><br>
    <hr/>
    <h3>查找用户快捷栏</h3>
        <form  method="GET">
             角色名:
            <input id="rolename_a" type="text" style='width:100px;' value='<{$keyword}>' />
            &nbsp;&nbsp;&nbsp;&nbsp;
             账户名:
            <input id="accountname_a" type="text" style='width:100px;' value='<{$keyword}>' />
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
             玩家ID
            <input id="role_id_a" type="text" style='width:100px;' value='<{$keyword}>' />
            <br/>
            <input type="button" src="/admin/static/images/search.gif" class="input2" id="user_check" value="搜索"/>
        </form>
        <div id="appender"></div>
    <!-- 查找用户快捷栏  END -------------------------->

</body>

<script type="text/javascript">
$(function(){
    $("#user_check").bind('click',function(){
        $.ajax({
            'type':'GET',
            'url':'<{$URL_SELF}>',
            'data':{'search':'true','rolename':$("#rolename_a").val(),'roleid':$("#role_id_a").val(),'accountname':$("#accountname_a").val()},
            'success':function(data){
                $("#appender").html(data);
            }
        })
    })
    
    
    
})

$(function(){
    $("#new_update").click(function(){
        $.get('<{$URL_SELF}>',{'update':'true','rolename':$("#rolename").val(),'deadline':$("#deadline").val()},function(data){
            history.go(0);
        });     
    });
});
</script>

</html>