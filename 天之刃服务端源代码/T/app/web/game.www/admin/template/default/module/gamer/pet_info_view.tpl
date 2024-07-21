<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<title>查看宠物详细信息</title>
</head>

<body>
<b>玩家管理：宠物详细信息查询</b>
<div id='input_panel' class='divOperation'>
	<form name="myform" method="post" action="/admin/module/gamer/pet_info_view.php">
		<input type="hidden" name='ac' value='search' />
		<span style='margin-right:20px;'>宠物ID: <input type='text' id='uid' name='uid' size='11' value='<{ $pet.pet_id }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('nickname').value ='';" /></span>
		<input type="hidden" name="isPost" value="1" />
		<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
	</form>
</div>
<br>

<{if $pet.pet_id}>
<table class="DataGrid" cellspacing="0">
	<tr><th colspan="8">宠物基本信息</th></tr>
    <tr>
        <td align="right">宠物名称：</td>                  <td><{ $pet.pet_name }>&nbsp;</td>
        <td align="right">宠物类型ID：</td>                <td><{ $pet.type_id        }>&nbsp;</td>
        <td align="right">性别：</td>              <td><{ $pet.sex         }>&nbsp;</td>
    </tr>
    <tr class="odd">
       <td align="right">配偶ID：</td>                <td><{ $pet.mate_id          }>&nbsp;</td>
       <td align="right">悟性：</td>                  <td><{ $pet.understanding}>&nbsp;</td>
       <td align="right">颜色：</td>                <td><{$pet.color}>&nbsp;</td>
    </tr>
    <tr>
       <td align="right">称号：</td>               <td><{ $pet.title        }>&nbsp;</td>
       <td align="right">等级：</td>           <td><{$pet.level}>&nbsp;</td>
       <td align="right">生命值：</td>             <td><{$pet.hp}>/<{$pet.max_hp}></td>
    </tr>
    <tr>
       <td align="right">寿命：</td>  			<td><{$pet.life}>&nbsp;</td>
       <td align="right">经验：</td>           <td><{ $pet.exp   }>&nbsp;</td> 
    </tr>
     <tr>
       <td align="right">力量：</td>               <td><{ $pet.str        }>&nbsp;</td>
       <td align="right">智力：</td>           <td><{$pet.int2}>&nbsp;</td>
       <td align="right">体质：</td>             <td><{$pet.con}>&nbsp;</td>
    </tr>
     <tr>
       <td align="right">精神：</td>               <td><{ $pet.dex        }>&nbsp;</td>
       <td align="right">敏捷：</td>           <td><{$pet.men}>&nbsp;</td>
       <td align="right">潜能：</td>             <td><{$pet.remain_attr_points}>&nbsp;</td>
    </tr>
     <tr>
       <td align="right">法攻资质：</td>               <td><{ $pet.phy_attack_aptitude        }>&nbsp;</td>
       <td align="right">法力资质：</td>           <td><{ $pet.magic_attack_aptitude        }>&nbsp;</td>
       <td align="right">外防资质：</td>             <td><{ $pet.phy_defence_aptitude        }>&nbsp;</td>
    </tr>
     <tr>
       <td align="right">内防资质：</td>                <td><{ $pet.magic_defence_aptitude        }>&nbsp;</td>
       <td align="right">生命值资质：</td>            <td><{ $pet.max_hp_aptitude        }>&nbsp;</td>
       <td align="right">重击率资质：</td>             <td><{ $pet.double_attack_aptitude        }>&nbsp;</td>
    </tr>
     <tr>
       <td align="right">物理攻击：</td>                <td><{ $pet.phy_attack        }>&nbsp;</td>
       <td align="right">法力攻击：</td>           <td><{ $pet.magic_attack        }>&nbsp;</td>
       <td align="right">物理防御：</td>              <td><{ $pet.phy_defence        }>&nbsp;</td>
    </tr>
    	<td align="right">法力防御：</td>            <td><{ $pet.magic_defence        }>&nbsp;</td>
       <td align="right">重击率：</td>            <td><{ $pet.double_attack        }>&nbsp;</td>
       <td align="right">攻击类型：</td>            <td><{ $pet.attack_type        }>&nbsp;</td>
</table>
<br />


<{ /if }>
<{if $isPost&&!$pet.role_id}>
没有此宠物
<{/if}>
</body>
</html>