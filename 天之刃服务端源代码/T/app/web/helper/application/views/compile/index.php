<h1>与君共勉</h1>
<p>
<ol>
    <li>简单的事情重复做，重复的事情细心做</li>
    <li>先做完再做好(否则可能没有机会做好)</li>
</ol>
</p>
<h4>构建参数设定</h4>
<select id="version">
<?php foreach($versions as $key => $version):?>
<option value="<?php echo $key;?>"><?php echo $version;?></option>
<?php endforeach;?>
</select>
&nbsp;
<select id="rebuild">
<option value="true">完全编译(rebuild)</option>
<option value="false">差异编译(make)</option>
</select>
&nbsp;
服务器：<input type="text" value="auto" id="server"/>
&nbsp;
<input type="text"  id="svn" value="svn帐号" />
&nbsp;
<input type="password" id="svnPass" value="svn密码" />
<br />
<input type="button" id="startCompile" value="开始构建" />
<!--  <input type="button" id="publicVersion" value="构建完毕-发布版本" />-->
<input type="button" id="stopTrace" value="停止刷新日志" />
<input type="button" id="startTrace" value="刷新日志" />
<h4>日志</h4>
<div id="log" style="height:500px;overflow-y:scroll;overflow-x:hidden;">

</div>
<script type="text/javascript">
var _trace = true;
$(document).ready(function(){
	$('#startCompile').click(function(){
		$.post(
			'?compile/start_compile',
			{'vid':$('#version').val(),
			 'svn':$('#svn').val(),
			 'svnPass':$('#svnPass').val(),
			 'rebuild':$('#rebuild').val(),
			 'server':$('#server').val()});
		
	});
	$('#publicVersion').click(function(){
		$.get('?compile/public_version');
	});
	$('#stopTrace').click(function(){
		_trace=false;
	});
	$('#startTrace').click(function(){
		_trace=true;
		get_log_trace();
	});
});
function get_log_trace(){
	$.get('?compile/get_log_trace',function(data){
		$('#log').html(data).animate({scrollTop: $('#log')[0].scrollHeight});
		$(this).oneTime(3000, 'one', function(){
			if(!_trace)return;
			get_log_trace();
		});
	});
}
get_log_trace();
</script>