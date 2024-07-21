<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="/admin/static/css/base.css" type="text/css">
<link rel="stylesheet" href="/admin/static/css/style.css" type="text/css">
<script type="text/javascript" src="/admin/static/js/jquery.min.js"></script>
<title>查看玩家的状态</title>
<script type="text/javascript">
setConloginDay = function() {
	if (confirm("确定要手工设置玩家的连续登录天数？")) {
		window.location.href='?gamer_action=setConlogin&uid=<{$base.role_id}>&day=' + $('#conlogin_day').val();
	}
}

function setActivePoint(){
    var ap= $('#active_point').val();
    if(parseInt(ap)!=ap)
    {
        alert("请输入整数");
        return false;
    }
    if(ap>28)
    {
        alert("活跃度不能大于28");
        return false;   
    }
    window.location.href='/admin/module/gamer/gamer_status_view.php?gamer_action=setActivePoint&uid=<{$base.role_id}>&ap=' + $('#active_point').val();
}

doClearYbc = function(roleID) {
	if (confirm("确定清理该玩家的个人拉镖状态？")) {
		window.location.href='?gamer_action=clearPersonYbc&uid=<{$base.role_id}>';
	}
}

function doGamerAction(gamerAction,gamerUID){
    document.getElementById('gamer_action').value = gamerAction;
    document.getElementById('gamer_uid').value = gamerUID;
	
	myform.submit();
}

//通过防沉迷
function doPassFcm() {
	if (confirm("你确定手工设置该玩家通过防沉迷吗？")) {
		window.location.href='?gamer_action=passFcm&uid=<{$base.role_id}>';
	}
}
</script>
</head>

<body>
<b>玩家：玩家状态</b>
<div id='input_panel' class='divOperation'>
	<form name="myform" id="myform" method="post" action="/admin/module/gamer/gamer_status_view.php">
		<input type="hidden" name='ac' value='search' />
		<span style='margin-right:20px;'>角色ID: <input type='text' id='uid' name='uid' size='11' value='<{ $base.role_id }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('nickname').value ='';" /></span>
		<span style='margin-right:20px;'>帐号: <input type='text' id='acname' name='acname' size='12' value='<{ $base.account_name }>' onkeydown="document.getElementById('nickname').value =''; document.getElementById('uid').value ='';" /></span>
		<span style='margin-right:20px;'>角色名: <input type='text' id='nickname' name='nickname' size='12' value='<{ $base.role_name }>' onkeydown="document.getElementById('acname').value =''; document.getElementById('uid').value ='';" /></span>
		<input type="hidden" name="isPost" value="1" />
		<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
        <input type="hidden" id="gamer_action" name="gamer_action" />
        <input type="hidden" id="gamer_uid" name="gamer_uid" />
	</form>
</div>
<br>

<{if $base.role_id}>
<table class="DataGrid" cellspacing="0">
	<{if $msg}>
    <tr>
    	<td colspan="5" align="center" style="color:red;"><b><{$msg}></b></td>
    </tr>
    <{/if}>
	<tr>
		<td style="width:200px;"><input type="button" name="btnSendReturnHome" id="btnSendReturnHome" value="送回新手村" 
		  onclick="doGamerAction('sendReturnHome',<{$base.role_id}>)"/></td>   
		<td style="width:200px;"><input type="button" name="btnKick" id="btnKick" value="踢下线"  
		  onclick="doGamerAction('kick',<{$base.role_id}>)" /></td>    
		<td style="width:200px;"><input type="button" name="btnKickStall" id="btnKickStall" value="踢摊位下线"  
		  onclick="doGamerAction('kickStall',<{$base.role_id}>)" /></td>   
		<td style="width:200px;"><input type="button" name="btnResetEnergy" id="btnResetEnergy" value="重置精力值" 
		  onclick="doGamerAction('resetEnergy',<{$base.role_id}>)" /></td>    
        <td style="width:200px;"><input type="button" name="btn" id="btnTidyRoleGoods" value="整理玩家背包异常数据" 
          onclick="doGamerAction('tidyRoleGoods',<{$base.role_id}>)" /></td>  
    </tr>
    <tr>
        <td style="width:200px;"><input type="button" name="btnUpdateRoleMission" id="btnUpdateRoleMission" value="刷新玩家任务数据" 
          onclick="doGamerAction('updateRoleMission',<{$base.role_id}>)"/></td>   
        <td style="width:200px;"><input type="button" name="btnReturnExp" id="btnReturnExp" value="技能返还经验"
		  onclick="doGamerAction('skillReturnExp',<{$base.role_id}>)"/></td>
        <td style="width:200px;"><input type="button" name="" value="通过防沉迷" onclick="doPassFcm();" /></td>    
        <td style="width:200px;"><input type="button" name="" value="清理个人拉镖异常" onclick="doClearYbc('<{$base.role_id}>');" /></td>    
        <td style="width:200px;">&nbsp;</td>    
    </tr>
    <tr>
        <td style="width:200px;"><input type="button" name="" value="处理道具摆摊状态异常" onclick="doGamerAction('clearItemStallState',<{$base.role_id}>)" /></td>
        <td style="width:200px;"><input type="button" name="" value="清除交易状态" onclick="doGamerAction('clearExchangeState',<{$base.role_id}>)" /></td>
    </tr>
    <tr>
    	<td colspan=3 >设置连续登录天数: <input type="text" id="conlogin_day" style="width:32px;" name="conlogin_day" value="<{$day}>" /> <input type="button" name="setConlogin" value="设置" onclick="setConloginDay();"  /></td>       
        <td> 设置玩家活跃度: <input type="text" id="active_point" style="width:32px;" name="active_point" value="<{$ap}>" /> <input type="button" name="setActPt" value="设置" onclick="setActivePoint();"/><font color="red" >只能设置在线玩家的活跃度</font> </td>

    </tr>
    
</table>
<br />

<table class="DataGrid" cellspacing="0">
    <tr>
        <td><b>是否vip:</b></td>
        <td><{$isVip}></td>   
        <td><b>vip等级:</b></td>    
        <td><{$vipLevel}></td>  
        <td><b>防沉迷验证:</b></td>
        <td><{$strFcm}></td>   
        <td>&nbsp;</td>    
    </tr>
    <tr>
	    <td><b>自动摆摊</b></td>  <td><{$s.stall_auto}></td>
	    <td><b>亲自摆摊:</b></td>  <td><{$s.stall_self}></td>
	    <td><b>战斗:</b></td>  <td><{$s.fight}></td>
	    <td><b>打坐:</b></td>  <td><{$s.sitdown}></td>
	    <td><b>兑换:</b></td>  <td><{$s.exchange}></td>
	    <td><b>拉镖:</b></td>  <td><{$s.ybc}></td>
	    <td><b>贸易:</b></td>  <td><{$s.trading}></td>
    </tr>
</table>
<br />

<table class="DataGrid" cellspacing="0">
	
</table>
<br />

<table class="DataGrid" cellspacing="0">
	<tr align="center">
		<th rowspan="2">账号信息</th>
		<th>帐号</th> 
		<th>角色名</th>
        <th>角色ID</th>    
        <th>创建时间</th>
        <th>最近登录时间</th>
        <th>最近登陆的IP：</th>     
        <th>最近登陆地点：</th>     
    </tr>
    <tr align="center">
    	<td><{ $base.account_name       }>&nbsp;</td>
    	<td><{ $base.role_name          }>&nbsp;</td>
    	<td><{ $base.role_id            }>&nbsp;</td>
    	<td><{ $base.create_time|date_format:"%Y-%m-%d %H:%M:%S"        }>&nbsp;</td>
    	<td><{ $ext.last_login_time|date_format:"%Y-%m-%d %H:%M:%S"     }>&nbsp;</td>
    	<td><{ $attr.last_login_ip       }>&nbsp;</td>
    	<td><{ $attr.last_login_location }>&nbsp;</td>
    </tr>
</table>
<br />


<table class="DataGrid" cellspacing="0">
	<tr align="center">
		<th rowspan="2">在线情况<br/><{if $isNowOnline==1}><font color="Red"><b>(当前在线)</b></font><{/if}><{if $isNowOnline==-1}><font color="Gray"><b>(当前离线)</b></font><{/if}></th>
		<th>活跃情况</th> 
		<th>总在线时长</th>
        <th>最近7天平均在线时长</th>    
        <th>前1天在线时长</th>
        <th>前2天在线时长</th>
        <th>前3天在线时长</th>
        <th>前4天在线时长</th>
        <th>前5天在线时长</th>
        <th>前6天在线时长</th>
    </tr>
    <{if $online}>
    <tr align="center">
    	<td><{ $online.user_status      }>&nbsp;</td>
    	<td><{ $online.total_live_time    }>&nbsp;</td>
    	<td><{ $online.avg_online_time    }>&nbsp;</td>
    	<td><{ $online.total_live_time_1    }>&nbsp;</td>
    	<td><{ $online.total_live_time_2    }>&nbsp;</td>
    	<td><{ $online.total_live_time_3    }>&nbsp;</td>
    	<td><{ $online.total_live_time_4    }>&nbsp;</td>
    	<td><{ $online.total_live_time_5    }>&nbsp;</td>
    	<td><{ $online.total_live_time_6    }>&nbsp;</td>
    </tr>
    <{else}>
    	<tr><td colspan="9" align="center">无记录</td></tr>
    <{/if}>
</table>
<br />

<table class="DataGrid" cellspacing="0">
	<tr align="center">
		<th rowspan="2">货币情况</th>
		<th>总充值金额</th> 
		<th>总充值元宝</th>
        <th>元宝</th>    
        <th>绑定元宝</th>
        <th>银子</th>
        <th>绑定银子</th>
    </tr>
    <{if $pay}>
    <tr align="center">
    	<td><{ $pay.total_pay      }>&nbsp;</td>
    	<td><{ $pay.total_gold    }>&nbsp;</td>
    	<td><{ $attr.gold    }>&nbsp;</td>
    	<td><{ $attr.gold_bind    }>&nbsp;</td>
    	<td><{ $attr.silver    }>&nbsp;</td>
    	<td><{ $attr.silver_bind    }>&nbsp;</td>
    </tr>
    <{else}>
    	<tr><td colspan="6" align="center">无记录</td></tr>
    <{/if}>
</table>
<br />

<table class="DataGrid" cellspacing="0">
	<tr><th colspan="8">角色基本信息</th></tr>
    <tr>
        <td align="right">角色名：</td>                <td><{ $base.role_name          }>&nbsp;</td>
        <td align="right">性别：</td>                  <td><{ $base.sex                }>&nbsp;</td>
        <td align="right">国家：</td>                <td><{ $base._faction_name        }>&nbsp;</td>
        <td align="right">门派：</td>              <td><{ $base.family_name         }>&nbsp;</td>
    </tr>
    <tr class="odd">
       <td align="right">等级：</td>                <td><{ $attr.level          }>&nbsp;</td>
       <td align="right">经验：</td>                  <td><{ $attr.exp}>/<{ $attr.next_level_exp}></td>
       <td align="right">五行：</td>                <td><{$attr._five_ele_attr_name}>&nbsp;</td>
       <td align="right">官职：</td>             <td><{ $attr.office_name         }>&nbsp;</td>
    </tr>
    <tr>
       <td align="right">师德值：</td>               <td><{ $attr.moral_values        }>&nbsp;</td>
       <td align="right">技能点：</td>           <td><{$cur_skill_point}>/<{$cur_skill_point+$attr.remain_skill_points}></td>
       <td align="right">精力值：</td>             <td><{$fight.energy}>/4000</td>
       <td align="right">当前状态：</td>             <td><{ $base.status         }>&nbsp;</td>
    </tr>
    <tr>
       <td align="right">当前所在地点：</td>  <td><{if $pos.map_id}><{$pos.map_name}>(<{$pos.pos.tx}>,<{$pos.pos.ty}>)<{/if}></td>
       <td align="right">玩家活跃度：</td>           <td><{ $attr.active_points   }>&nbsp;</td> 
       <td align="right">魅力值</td>           <td><{ $attr.charm   }></td>
       <td align="right">战功值</td>           <td><{ $attr.gongxun   }></td>
    </tr>
    <tr>
       <td align="right">通过防沉迷：</td>  <td>
            <{if $isFcmPassed}>通过<{else}>未通过<{/if}>&nbsp;
       </td>
       <td align="right">&nbsp;</td>   <td>&nbsp;</td> 
       <td align="right">&nbsp;</td>       <td>&nbsp;</td>
       <td align="right">&nbsp;</td>       <td>&nbsp;</td>
    </tr>
</table>
    <br />
    
    
<table class="DataGrid" cellspacing="0">
	<tr><th colspan="8">角色信息</th></tr>
    <tr>
        <td align="right">生命值：</td>                <td><{if $fight.hp}><{$fight.hp}><{else}>0<{/if}>/<{$base.max_hp}>&nbsp;</td>
        <td align="right">生命恢复速度：</td>           <td><{ $base.hp_recover_speed }>&nbsp;</td>
        <td align="right">法力值：</td>                <td><{if $fight.mp}><{$fight.mp}><{else}>0<{/if}>/<{$base.max_mp}>&nbsp;</td>
        <td align="right">法力恢复速度：</td>           <td><{ $base.mp_recover_speed }>&nbsp;</td>
    </tr>
    <tr class="odd">        
        <td align="right">剩余属性点：</td>             <td><{ $base.remain_attr_points }>&nbsp;</td>
        <td align="right">力量：</td>              <td><{$base.base_str}>+<{$base.str-$base.base_str}>&nbsp;</td>
        <td align="right">智力：</td>              <td><{$base.base_int}>+<{$base.int2-$base.base_int}>&nbsp;</td>
        <td align="right">体质：</td>              <td><{$base.base_con}>+<{$base.con-$base.base_con}>&nbsp;</td>
    </tr>
    <tr>        
        <td align="right">敏捷：</td>              <td><{$base.base_dex}>+<{$base.dex-$base.base_dex}>&nbsp;</td>
        <td align="right">精神：</td>              <td><{$base.base_men}>+<{$base.men-$base.base_men}>&nbsp;</td>
        <td align="right">物攻击力：</td>          <td><{ $base.min_phy_attack }>—<{ $base.max_phy_attack     }>&nbsp;</td>
        <td align="right">外防：</td>              <td><{ $base.phy_defence        }>&nbsp;</td>
    </tr>
    <tr class="odd">        
        <td align="right">法攻击力：</td>          <td><{ $base.min_magic_attack   }>—<{ $base.max_magic_attack   }>&nbsp;</td>
        <td align="right">内防：</td>              <td><{ $base.magic_defence      }>&nbsp;</td>
        <td align="right">幸运值：</td>                <td><{ $base.luck               }>&nbsp;</td>
        <td align="right">移动速度：</td>              <td><{ $base.move_speed         }>&nbsp;</td>
    </tr>
    <tr>        
        <td align="right">攻击速度：</td>              <td><{ $base.attack_speed       }>&nbsp;</td>       
        <td align="right">暴击率(万分比)：</td>                <td><{ $base.erupt_attack_rate  }>&nbsp;</td>
        <td align="right">破甲(万分比)：</td>                  <td><{ $base.no_defence         }>&nbsp;</td>
        <td align="right">闪避(万分比)：</td>                  <td><{ $base.miss               }>&nbsp;</td>   
    </tr>
    <tr class="odd">        
        <td align="right">暴击：</td>                  <td><{ $base.double_attack      }>&nbsp;</td>
        <td align="right">法攻伤抗绝对值数值(万分比)：</td> <td><{ $base.phy_anti           }>&nbsp;</td>
        <td align="right">物攻伤抗绝对值数值(万分比)：</td> <td><{ $base.magic_anti         }>&nbsp;</td>  
         <td align="right">击晕(万分比)：</td>               <td><{ $base.dizzy              }>&nbsp;</td>
    </tr>
    <tr>         
        <td align="right">中毒(万分比)：</td>               <td><{ $base.poisoning          }>&nbsp;</td>
        <td align="right">冰冻(万分比)：</td>               <td><{ $base.freeze             }>&nbsp;</td>
        <td align="right">伤害(万分比)：</td>               <td><{ $base.hurt               }>&nbsp;</td>
        <td align="right">中毒抗性(万分比)：</td>           <td><{ $base.poisoning_resist   }>&nbsp;</td>
    </tr>
    <tr class="odd">        
        <td align="right">击晕抗性(万分比)：</td>           <td><{ $base.dizzy_resist       }>&nbsp;</td>
        <td align="right">冰冻抗性(万分比)：</td>           <td><{ $base.freeze_resist      }>&nbsp;</td>
        <td align="right">伤害反射：</td>              <td><{ $base.hurt_rebound       }>&nbsp;</td>
        <td align="right">&nbsp;</td>              <td>&nbsp;</td>
    </tr>
</table>
    <br />    
   
 

<table class="DataGrid" cellspacing="0">
	<{if $base.family_id}>
    <tr>
    	<th rowspan="2">门派信息</th>
        <th>门派名称</th>
        <th>门派贡献度</th>
        <th>门派称号</th>
        <th>最近退出门派时间</th>
    </tr>
    <tr align="center">
       <td><{$base.family_name}>&nbsp;</td>
       <td><{if !$attr.family_contribute}>0<{else}><{$attr.family_contribute}><{/if}>&nbsp;</td>
       <td><{$family_title}>&nbsp;</td>
       <td><{$ext.family_last_op_time|date_format:"%Y-%m-%d %H:%M:%S" }>&nbsp;&nbsp;</td>
    </tr>
    <{else}>
    <tr>
    	<th>门派信息</th>
    	<td colspan="3">未加入门派<td>
    </tr>
    <{/if}>
</table>
    <br />


<table class="DataGrid" cellspacing="0">
	<tr>
		<th rowspan="2">角色造型</th>
		<th>外形</th>     
		<th>发型</th>      
		<th>发型颜色</th>  
		<th>武器</th>      
		<th>衣服</th>
		<th>骑宠</th>
		<th>副手装备</th>
	</tr>
	
	<tr class="odd" align="center">
		<td><{ $skin.skinid       }>&nbsp;</td> 
		<td><{ $skin.hair_type    }>&nbsp;</td>
		<td><{ $skin.hair_color   }>&nbsp;</td> 
		<td><{ $skin.weapon_name       }>&nbsp;</td> 
		<td><{ $skin.clothes_name      }>&nbsp;</td> 
		<td><{ $skin.mounts       }>&nbsp;</td> 
		<td><{ $skin.assis_weapon_name }>&nbsp;</td> 
	</tr>
</table>
<br />

<table class="DataGrid" cellspacing="0">
    <tr>
    	<th rowspan="2">PK情况</th>
        <th>PK模式</th>
        <th>PK值</th>
        <th>红名情况</th>
        <th>灰名情况</th>
        <th>上次灰名时间</th>
    </tr>
    <tr align="center">
       <td><{$base.pk_mode_name}>&nbsp;</td>
       <td><{$base.pk_points}>&nbsp;</td>
       <td><{if $base.pk_points >=18 }>红名<{else}>无<{/if}></td>
       <td><{if $base.if_gray_name}>灰名<{else}>无<{/if}></td>
       <td><{if $base.last_gray_name>0}><{$base.last_gray_name|date_format:"%Y-%m-%d %H:%M:%S"}><{/if}>&nbsp;</td>
    </tr>
</table>
<br />



<table class="DataGrid" cellspacing="0">
	<tr><th colspan="11"><b>buff</b></th></tr>
	<{ if $buffs }>
	<tr>
		<th>Buff ID</th>
		<th>Buff 名称</th>
		<th>Buff 值</th>
		<th>Buff 持续时间(秒)</th>
		<th>开始时间</th>
		<th>结束时间</th>
	</tr>
	<{section name=i loop=$buffs}>
	<tr align="center" <{ if 0==$smarty.section.i.index %2 }> class="odd"<{ /if }>>
		<td><{ $buffs[i].buff_id                }>&nbsp;</td>
		<td><{ $buffs[i].buff_name              }>&nbsp;</td>
		<td><{ $buffs[i].value             }>&nbsp;</td>
		<td><{ $buffs[i].remain_time       }>&nbsp;</td>
		<td><{ $buffs[i].start_time            }>&nbsp;</td>
		<td><{ $buffs[i].end_time            }>&nbsp;</td>
	</tr>
	<{ /section }>
	<{ else }>
    <tr><td colspan="11">无</td></tr>
    <{ /if }>
</table>
<br />


<table class="DataGrid" cellspacing="0">
	<tr><th colspan="12">装备列表</th></tr>
	<{ if $equips }>
	<tr>
		<th>ID</th>
		<th>装备名称</th>
		<th>装备所在位置</th>
		<th>是否绑定</th>
		<th>时间</th>
		<th>颜色</th>
		<th>耐久度</th>
		<th>强化结果</th>
		<th>精炼系数</th>
		<th>宝石数/孔数</th>
		<th>宝石</th>
		<th>签名角色Id</th>
	</tr>
	<{section name=i loop=$equips}>
	<tr<{ if 0==$smarty.section.i.index %2 }> class="odd"<{ /if }>>
		<td><{ $equips[i].id                }>&nbsp;</td>
		<td><{ $equips[i].name              }>&nbsp;</td>
		<td><{ $equips[i]._bagid_name             }>&nbsp;</td>
		<td><{ $equips[i].bind              }>&nbsp;</td>
		<td><{ $equips[i]._period            }>&nbsp;</td>
		<td><{ $equips[i]._current_colour_name    }>&nbsp;</td>
		<td><{ $equips[i].current_endurance }>&nbsp;</td>
		<td><{ $equips[i].reinforce_result  }>&nbsp;</td>
		<td><{ $equips[i].refining_index  }>&nbsp;</td>
		<td><{ $equips[i].stone_num }>/<{ $equips[i].punch_num }>&nbsp;</td>
		<td><{ $equips[i].stones            }>&nbsp;</td>
		<td><{ $equips[i].sign_role_id      }>&nbsp;</td>
	</tr>
	<{ /section }>
	<{ else }>
    <tr><td colspan="11">无</td></tr>
    <{ /if }>
</table>
<br />

<table class="DataGrid" cellspacing="0">
	<tr><th colspan="7">宝石列表</th></tr>
	<{ if $stones }>
	<tr>
		<th>ID</th>
		<th>物品名称</th>
		<th>数量</th>
		<th>所在位置</th>
		<th>是否绑定</th>
		<th>时间</th>
		<th>颜色</th>
		<th>签名角色Id</th>
	</tr>
	<{section name=i loop=$stones}>
	<tr<{ if 0==$smarty.section.i.index %2 }> class="odd"<{ /if }>>
		<td><{ $stones[i].id                }>&nbsp;</td>
		<td><{ $stones[i].name              }>&nbsp;</td>
		<td><{ $stones[i].current_num       }>&nbsp;</td>
		<td><{ $stones[i]._bagid_name             }>&nbsp;</td>
		<td><{ $stones[i].bind              }>&nbsp;</td>
		<td><{ $stones[i]._period            }>&nbsp;</td>
		<td><{ $stones[i]._current_colour_name    }>&nbsp;</td>
		<td><{ $stones[i].sign_role_id      }>&nbsp;</td>
	</tr>
	<{ /section }>
	<{ else }>
    <tr><td colspan="7">无</td></tr>
    <{ /if }>
</table>
<br />

<table class="DataGrid" cellspacing="0">
	<tr><th colspan="7">普通物品列表</th></tr>
	<{ if $general }>
	<tr>
		<th>ID</th>
		<th>物品名称</th>
		<th>数量</th>
		<th>所在位置</th>
		<th>是否绑定</th>
		<th>时间</th>
		<th>颜色</th>
		<th>签名角色Id</th>
	</tr>
	<{section name=i loop=$general}>
	<tr<{ if 0==$smarty.section.i.index %2 }> class="odd"<{ /if }>>
		<td><{ $general[i].id                }>&nbsp;</td>
		<td><{ $general[i].name              }>&nbsp;</td>
		<td><{ $general[i].current_num       }>&nbsp;</td>
		<td><{ $general[i]._bagid_name             }>&nbsp;</td>
		<td><{ $general[i].bind              }>&nbsp;</td>
		<td><{ $general[i]._period            }>&nbsp;</td>
		<td><{ $general[i]._current_colour_name    }>&nbsp;</td>
		<td><{ $general[i].sign_role_id      }>&nbsp;</td>
	</tr>
	<{ /section }>
	<{ else }>
    <tr><td colspan="7">无</td></tr>
    <{ /if }>
</table>
<{ /if }>
<{if $isPost&&!$base.role_id}>
没有此玩家
<{/if}>
</body>
</html>