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
</head>

<body>
<b>消息管理：批量发信</b>
<br />
<a href="<{$URL_SELF}>?action=byRoleName" style="color: red;"><b>指定玩家名</b></a>
<a href="<{$URL_SELF}>?action=byCondition" style="color: blue; text-decoration: underline;"><b>按条件</b></a>
<a href="<{$URL_SELF}>?action=history" style="color: blue; text-decoration: underline;"><b>已发出信件</b></a>
<br /><br />
<div id="main" style="border:1px solid #999999;padding-left:10px;">
	<div id="divByRoleName">
	
		<span style="color:red;"><b>
		<{$errByRoleName}>
		<{$ok}>
		</b>
		</span>
		<form action="?action=byRoleName" method="POST">
			请输入玩家角色名列表，以 ， (全角逗号)隔开：<br />
			<textarea name="role_names" cols="60" rows="3"><{$strRoleNames}></textarea><br /><br />
			信件标题：<input size="60" type="text" name="email_title" value="<{$email_title}>"><br/>
			请输入信件内容:<br/>
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
									
			
			
			
			<textarea style="display:none;" name="email_content" id="email_content" cols="60" rows="5" ><{$email_content}></textarea>
			<input type="submit" value="发 送"  />
		</form>	
	</div>
	<br />
</div>
</body>
</html>
