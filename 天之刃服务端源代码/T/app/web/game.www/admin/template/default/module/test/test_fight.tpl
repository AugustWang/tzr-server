<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>累积经验</title>
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<style>
.process{}
</style>
</head>

<body>
<form action="" method="post">
    <input type='hidden' value='fight' name='action' />
	<table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
        <tr bgcolor="#E5F9FF"> 
        <td colspan ='2' >角色A</td>
        <td colspan ='2' >角色B</td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
        	<td>最大攻击</td>
        	<td><input type='text' name='a_max_attack' value=<{$role_a.max_attack}> /></td>
        	<td>最大攻击</td>
        	<td><input type='text' name='b_max_attack' value=<{$role_b.max_attack}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
        	<td>最小攻击</td>
        	<td><input type='text' name='a_min_attack' value=<{$role_a.min_attack}> /></td>
        	<td>最小攻击</td>
        	<td><input type='text' name='b_min_attack' value=<{$role_b.min_attack}> /></td>
        </tr>
         <tr bgcolor="#FFFFFF"> 
         	<td>防御</td>
        	<td><input type='text' name='a_defence' value=<{$role_a.defence}>  /></td>
        	<td>防御</td>
        	<td><input type='text' name='b_defence' value=<{$role_b.defence}> /></td>
        </tr>
         <tr bgcolor="#FFFFFF"> 
         	<td>血量</td>
        	<td><input type='text' name='a_hp' value=<{$role_a.hp}> /></td>
        	<td>血量</td>
        	<td><input type='text' name='b_hp' value=<{$role_b.hp}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>命中</td>
        	<td><input type='text' name='a_hit_target' value=<{$role_a.hit_target}> /></td>
        	<td>命中</td>
        	<td><input type='text' name='b_hit_target' value=<{$role_b.hit_target}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>闪避</td>
        	<td><input type='text' name='a_dodge' value=<{$role_a.dodge}> /><font color='red'>注：最高闪避值为10000</font></td>
        	<td>闪避</td>
        	<td><input type='text' name='b_dodge' value=<{$role_b.dodge}> /><font color='red'>注：最高闪避值为10000</font></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>重击</td>
        	<td><input type='text' name='a_double' value=<{$role_a.double}> /></td>
        	<td>重击</td>
        	<td><input type='text' name='b_double' value=<{$role_b.double}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>破甲</td>
        	<td><input type='text' name='a_ignore_defence' value=<{$role_a.ignore_defence}> /></td>
        	<td>破甲</td>
        	<td><input type='text' name='b_ignore_defence' value=<{$role_b.ignore_defence}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>伤害减免</td>
        	<td><input type='text' name='a_reduce_harm' value=<{$role_a.reduce_harm}> /><font color='red'>注：可以为负数</font></td>
        	<td>伤害减免</td>
        	<td><input type='text' name='b_reduce_harm' value=<{$role_b.reduce_harm}> /><font color='red'>注：可以为负数</font></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>幸运</td>
        	<td><input type='text' name='a_lucky' value=<{$role_a.lucky}> /></td>
        	<td>幸运</td>
        	<td><input type='text' name='b_lucky' value=<{$role_b.lucky}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>攻击速度</td>
        	<td><input type='text' name='a_attack_speed' value=<{$role_a.attack_speed}> /></td>
        	<td>攻击速度</td>
        	<td><input type='text' name='b_attack_speed' value=<{$role_b.attack_speed}> /></td>
        </tr>
        <tr bgcolor="#FFFFFF"> 
         	<td>先手</td>
        	<td colspan=3 > <select name=first_hand >
				<option value=0  >角色A</option>
				<option value=1>角色B</option>
				<option value=2 selected >随机</option>
			</select></td>
        </tr>
        <tr bgcolor="#E5F9FF">
        	<td >战斗次数</td>
        	<td ><input type='text' name='fight_times' value=<{$fight_times}> /><font color='red'>建议不要太多次</font></td>
        	<td colspan='2' ><input type='submit' value='点击开始战斗' /> </td>
        </tr>
    </table>
    <br/>
    <table width="100%"  border="0" cellpadding="4" cellspacing="1" bgcolor="#A5D0F1">
    	<tr bgcolor="#FFFFFF">
    		<td>战斗结果</td>
    		<td><{$a_win}>/<{$b_win}></td>
    	</tr>
    	<tr bgcolor="#FFFFFF">
    		<td>实际战斗过程</td>
    		<td>第
    		<select name='fight_num' id= 'fight_num' >
				<{foreach key=key item=item from=$fight_result}>
							<option value="<{$key}>"><{$key+1}></option>
				<{/foreach}>
			</select>次战斗过程
			
			</td>
    	</tr>
    	<tr>
    		<td colspan =2>
    		<{foreach from=$fight_result item=item key=key}>
    		<table id="<{$key}>" class="process" >
    			<{foreach from=$item.record item=item2 key=key2}>
    			<tr><td><{$item2}></td></tr>
    			<{/foreach}>
    		</table>
    		<{/foreach}>
    		</td>
    	</tr>
    </table>
</form> 
</body>
<script language="javascript" > 
jQuery(document).ready(function(){
	changeFightProcess('#fight_num');
	$("#fight_num").change(function(){ //事件發生  
        changeFightProcess(this);
    });  
});
function changeFightProcess(dom){
	var tb_id = $(dom).children('option:selected').val();
    $('.process').css('display','none');
    $('#'+tb_id).css('display','block');
}

</script>
</html>