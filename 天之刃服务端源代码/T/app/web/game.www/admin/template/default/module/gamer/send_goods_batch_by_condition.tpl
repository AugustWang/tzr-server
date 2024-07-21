<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>无标题文档</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
	        
        <!-- start 支持as3 的富文本编辑器	-->
        <link rel="stylesheet" type="text/css" href="/admin/static/richTextEditor/richTextEditor.css" />
        <script type="text/javascript" src="/admin/static/richTextEditor/history/history.js"></script>
        <script type="text/javascript" src="/admin/static/richTextEditor/swfobject.js"></script>
        <script type="text/javascript">
            var swfVersionStr = "10.0.0";
            var xiSwfUrlStr = "/admin/static/richTextEditor/playerProductInstall.swf";
            var flashvars = {};
            var params = {};
            params.quality = "high";
            params.bgcolor = "#ffffff";
            params.allowscriptaccess = "sameDomain";
            params.allowfullscreen = "true";
            var attributes = {};
            attributes.id = "richTextEditor";
            attributes.name = "richTextEditor";
            attributes.align = "middle";
            swfobject.embedSWF(
                "/admin/static/richTextEditor/richTextEditor.swf", "flashContent", 
                "100%", "100%", 
                swfVersionStr, xiSwfUrlStr, 
                flashvars, params, attributes);
			swfobject.createCSS("#flashContent", "display:block;text-align:left;");
			
			
			function setHtmlToEditor(){
				var str = '<{$email_content}>';
				return str;
			}
			
			function getHtmlFromEditor(strHtml){
				document.getElementById("email_content").value = strHtml;
			}
        </script>
        <!-- end 支持as3 的富文本编辑器	-->
        

<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<script language="javascript">
	$(document).ready(function() {
    	$("#selectedCompare").change(function(){
    		if('0'==$(this).val()){
    			$("#endLevel").hide();
    		}else{
    			$("#endLevel").show();
    		}
    		if('between'==$(this).val()){
    			$("#startLevel").show();
    		}else{
    			$("#startLevel").hide();
    		}
    	});
    	$("#getReceiverCnt").click(function(){
    		$.ajax({
    			   type: "POST",
				   url: "<{$URL_SELF}>?action=receiverCnt",
				   data: $("#frm").serialize(),
				   success: function(msg){
				    $("#receiverCnt").text(msg);;
				   }
    		});
    	});
    	
	});
</script>
<script type="text/javascript" src="/admin/static/js/My97DatePicker/WdatePicker.js"></script>
</head>

<body>
<b>消息管理：批量发道具</b>
<br />
<a href="<{$URL_SELF}>?action=byRoleName" style="color: blue; text-decoration: underline;"><b>指定玩家名</b></a>
<a href="<{$URL_SELF}>?action=byCondition" style="color: red;"><b>按条件</b></a>
<a href="<{$URL_SELF}>?action=byAll" style="color:blue; text-decoration: underline;"><b>全部发送</b></a>
<a href="<{$URL_SELF}>?action=history" style="color: blue; text-decoration: underline;"><b>已发出信件</b></a>
<br /><br />

		<form id="frm" action="?action=byCondition" method="POST">
			<{if $err}>
				<font color="Red"><b>错误：<{$err}></b></font>
			<{/if}>
			<{if $ok}>
				<font color="Red" size = "5"><b><{$ok}></b></font>
			<{/if}>
			<table class="SumDataGrid">
            	<tr>
					<td >信件标题：</td>
					<td><input size="60" type="text" name="email_title" value="<{$email_title}>"></td>
				</tr>
				<tr>
					<td width="15%">等级：</td>
					<td valign="middle">
					<input type="text" value="<{$startLevel}>" name="startLevel" id="startLevel" size="5" style="display:<{$displayStartLevel}>;"/>
					<select name="selectedCompare" id="selectedCompare"><{ html_options options=$arrCompare selected=$selectedCompare }></select>
					<input type="text" value="<{$endLevel}>" name="endLevel" id="endLevel" size="5" style="display:<{$displayEndLevel}>;" />
					</td>
				</tr>	
				<tr>
				    <td>距离上次登录时间：</td>
				    <td><input type="text" value="<{$lastDays}>"  name = "lastDays" id="lastDays" style="width:30px;" />&nbsp;天之内</td>
				</tr>
				<tr>
					<td>性别：</td>
					<td>
					<select name="selectedSex"><{ html_options options=$arrSex selected=$selectedSex }></select>
					</td>
				</tr>
				<tr>
					<td>国家：</td>
					<td>
					<select name="selectedFaction"><{ html_options options=$arrFaction selected=$selectedFaction }></select>
					</td>
				</tr>
				<tr>
					<td>门派名：</td>
					<td><input type="text" name="family_name" id="family_name" value="<{$family_name}>"></td>
				</tr>
				<tr>
					<td>物品ID：</td>
					<td><input type="text" name="typeid" value="<{ $typeid }>" />
					<a style="border-bottom: 1px solid red;" target="_BLANK" href="gamer_item_list.php"><font color="red"><b>查看道具列表</b></font></a>
					</td>
				</tr>
				<tr>
					<td>赠送数量：(装备最多1件，其他最多50个)</td>
					<td><input type="text" name="number" value="<{ $number }>" /> <input type="checkbox" name="bind" value="1" checked="checked" />是否绑定[勾上表示绑定]
					</td>
				</tr>
				<tr>
					<td width="25%">品质：</td>
					<td><select id="type" name="quality">
						<{html_options options=$dictQualityType selected=$quality }>
					</select></td>
				</tr>
				<tr>
					<td>颜色：</td>
					<td><select id="type" name="color">
							<{html_options options=$dictColor selected=$color }>
						</select>
					</td>
				</tr>
	           
	           <tr>
<td >有效时间</td>
<td>
<select id="time_state" name="time_state" onchange="change_time_state(this.options[this.options.selectedIndex].value)">

<option value =0 >无限制</option>
<option value =1>绝对时间</option>
</select>
<div id="time_range" style="display:none;">
开始时间：<input type="text" name="start_time" id="start_time" value="0" /> 
<img onclick="WdatePicker({el:'start_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
结束时间：<input type="text" name="end_time" id="end_time" value="0"  />
<img onclick="WdatePicker({el:'end_time',dateFmt:'yyyy-MM-dd HH:mm:00'})" src="/admin/static/js/My97DatePicker/skin/datePicker.gif" width="16" height="22" align="absmiddle" />
</td>
</div>
</tr>

<script language="javascript" > 
function change_time_state(s) 
{ 
    if(s==0)
    {
        document.getElementById("time_range").style.display="none";
        document.getElementById("start_time").value="0";
        document.getElementById("end_time").value="0";
    }
    else if(s==1)
    {
        document.getElementById("start_time").value="0";
        document.getElementById("end_time").value="0";
        document.getElementById("time_range").style.display="inline-block";
    }

　　//选择后,让第一项被选中,这样,就有Change啦.
　　document.all.time_state.options[s].selected=true;
} 
</script>
	           
	           
					<td colspan="2">
					<textarea style="display:none;" name="email_content" id="email_content" cols="60" rows="5" ><{$email_content}></textarea>
						附信内容：<br />
			(编辑器背景色、内容区域宽度与游戏中信箱一致，<font color="Red">URL必须有“http://”前缀！</font>)：<br />
						
		<!-- start 支持as3 的富文本编辑器	-->
		<div id="richTextEditorDiv" style="width:300px; height:340px;">
        <!-- start 若版本不支持 打印提示	-->
        <div id="flashContent">
        	<p>
	        	To view this page ensure that Adobe Flash Player version 
				10.0.0 or greater is installed. 
			</p>
			<script type="text/javascript"> 
				var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://"); 
				document.write("<a href='http://www.adobe.com/go/getflashplayer'><img src='" 
								+ pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>" ); 
			</script> 
        </div>
	   	 <!-- end  若版本不支持 打印提示	-->
	   	 
       	<noscript>
            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="100%" height="100%" id="richTextEditor">
                <param name="movie" value="richTextEditor.swf" />
                <param name="quality" value="high" />
                <param name="bgcolor" value="#ffffff" />
                <param name="allowScriptAccess" value="sameDomain" />
                <param name="allowFullScreen" value="true" />
                <!--[if !IE]>-->
                <object type="application/x-shockwave-flash" data="/admin/static/richTextEditor/richTextEditor.swf" width="100%" height="100%">
                    <param name="quality" value="high" />
                    <param name="bgcolor" value="#ffffff" />
                    <param name="allowScriptAccess" value="sameDomain" />
                    <param name="allowFullScreen" value="true" />
                <!--<![endif]-->
                <!--[if gte IE 6]>-->
                	<p> 
                		Either scripts and active content are not permitted to run or Adobe Flash Player version
                		10.0.0 or greater is not installed.
                	</p>
                <!--<![endif]-->
                    <a href="http://www.adobe.com/go/getflashplayer">
                        <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash Player" />
                    </a>
                <!--[if !IE]>-->
                </object>
                <!--<![endif]-->
            </object>
	    </noscript>	
		</div>
		<!-- end 支持as3 的富文本编辑器	-->
						
						
					</td>
				</tr>
				<tr>
					<td colspan="2" style="padding-left:100px;">
					预计收信人数：<span style="color:red;" id="receiverCnt"></span>
					&nbsp;&nbsp;&nbsp;&nbsp;<input type="button" id="getReceiverCnt" value="点击测算">
						<input type="submit" value="发 送"  />
					</td>
				</tr>
			</table>
		</form>	

</body>
</html>
