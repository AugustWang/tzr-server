<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset="UTF-8" />
<title>修改玩家数据</title>
<style>
</style>
<link href="../css/style.css" rel="stylesheet" type="text/css" /></head>

<body style="margin:10px">
<b>玩家：修改玩家数据</b>
<div class='divOperation'>
	<form name="myform" method="post" action="<{$URL_SELF}>">
		请输入玩家登录帐号:
		<input type='text' id="acname" name='acname' size='10' value='<{$search1}>' onkeydown="document.getElementById('nickname').value=''"/>
		或者角色名:
		<input type='text' id="nickname" name='nickname' size='10' value='<{$search2}>' onkeydown="document.getElementById('acname').value=''"/>
		<input type="image" name='search' src="../images/search.gif" class="input2"  />
	</form>
</div>

<{if $userinfo.id>0}>

	<{if $userinfo.status}>
		<div style='margin:5px 0;text-alignt:center;color:red'>不可登陆</div>
	<{/if}>

<div style='margin:5px 0;'>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'>
			<td class='table_list_head' rowspan=2 width=20>
				帐号</td><td>
				帐号名</td><td>
				角色名</td><td width='45px'>
				角色ID</td><td>
				性别</td><td>
				等级(经验)</td><td>
				战绩</td><td>
				国家</td><td>
				门派</td><td>
				注册</td><td>
				最近登陆</td><td>
				最新登陆IP</td>
		</tr>
		<tr class='trEven'>
			<td>
				<{$userinfo.AccountName}></td><td>
				<{$userinfo.nickname}></td><td>
				<{$userinfo.id}></td><{$userinfo.nickname}></td><td>
				<{if $userinfo.sex==0}>男<{else}>女<{/if}></td><td>
				<{$userinfo.level}>(<{$userinfo.exp}>)</td><td>
				<{$userinfo.battle_score}></td><td>
				<{$userinfo.faction}></td><td>
				<{$userinfo.family_name}></td><td>
				<{$userinfo.reg_time|date_format:"%Y-%m-%d %H:%M:%S"}></td><td>
				<{$userinfo.last_login_time|date_format:"%Y-%m-%d %H:%M:%S"}></td><td>
				<{$userinfo.last_login_ip}></td>
		</tr>
	</table>

	<br>
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' >
		<tr class='table_list_head'>
			<td rowspan=6 width=20>
				资源</td>
				<td rowspan=2 width=30>
				</td><td width=100>
				&nbsp;</td><td width=100>
				银两:<{$cinfo.res_S}></td><td width=100>
				铜钱:<{$cinfo.res_C}></td><td width=100>
				木材:<{$cinfo.res_J}></td><td width=100>
				石料:<{$cinfo.res_R}></td><td width=100>
				铁矿:<{$cinfo.res_M}></td><td>
				</td>
		</tr>
		<!--
		<tr class='trEven'>
			<td>
				<{$cinfo.res_S}></td><td>
				<{$cinfo.res_C}></td><td>
				<{$cinfo.res_J}></td><td>
				<{$cinfo.res_R}></td><td>
				<{$cinfo.res_M}></td><td>
				</td>
		</tr>
		-->
		<tr class='trEven'>
			<form name="myform" method="post" action="<{$URL_SELF}>">
			<td class='table_list_head'>增量</td><td>
				<input type='hidden' id='res_action' name='res_action' value='add_res' />
				<input type='hidden' name='userid' value='<{$userinfo.id}>' />
				<input type='hidden' name='acname' size='10' value='<{$userinfo.AccountName}>' />
				<input type='hidden' name='nickname' size='10' value='<{$userinfo.nickname}>' />
				<input type='text' name='res_s' style='width:100px;'value=''/></td><td>
				<input type='text' name='res_c' style='width:100px;'value=''/></td><td>
				<input type='text' name='res_j' style='width:100px;'value=''/></td><td>
				<input type='text' name='res_r' style='width:100px;'value=''/></td><td>
				<input type='text' name='res_m' style='width:100px;'value=''/></td><td>
				<div style='float:left;'>
					<input type="submit" name='inc_btn' value='赠送' class="input2" style='color:darkgreen'/></div>
				<div style='float:left;margin-left:30px;'>
					<input type="submit" name='dec_btn' value='扣除' class="input2" style='color:darkred'/></div>
			</td>
			</form>
		</tr>
		<tr class='table_list_head'>
			<td rowspan=2 width=30>
				</td><td width=100>
				&nbsp;</td><td width=100>
				&nbsp;</td><td width=100>
				铜钱:<{$cinfo.res_C}></td><td width=100>
				木材:<{$cinfo.res_J}></td><td width=100>
				石料:<{$cinfo.res_R}></td><td width=100>
				铁矿:<{$cinfo.res_M}></td><td>
				</td>
		</tr>
		<!--
		<tr class='trEven'>
			<td>
				&nbsp;</td><td>
				<{$cinfo.res_C}></td><td>
				<{$cinfo.res_J}></td><td>
				<{$cinfo.res_R}></td><td>
				<{$cinfo.res_M}></td><td>
				</td>
		</tr>
		-->
		<tr class='trEven'>
			<form name="myform" method="post" action="<{$URL_SELF}>">
			<td class='table_list_head'>改写</td><td>
				<input type='hidden' id='res_action' name='res_action' value='set_res' />
				<input type='hidden' name='userid' value='<{$userinfo.id}>' />
				<input type='hidden' name='acname' size='10' value='<{$userinfo.AccountName}>' />
				<input type='hidden' name='nickname' size='10' value='<{$userinfo.nickname}>' />
				<input type='hidden' name='res_c_original' value='<{$cinfo.res_C}>' />
				<input type='hidden' name='res_j_original' value='<{$cinfo.res_J}>' />
				<input type='hidden' name='res_r_original' value='<{$cinfo.res_R}>' />
				<input type='hidden' name='res_m_original' value='<{$cinfo.res_M}>' />

				</td><td>
				<input type='text' name='res_c' style='width:100px;'value='<{$cinfo.res_C}>' /></td><td>
				<input type='text' name='res_j' style='width:100px;'value='<{$cinfo.res_J}>' /></td><td>
				<input type='text' name='res_r' style='width:100px;'value='<{$cinfo.res_R}>' /></td><td>
				<input type='text' name='res_m' style='width:100px;'value='<{$cinfo.res_M}>' /></td><td>
				<div style='float:left;'>
					<input type="submit" name='update_btn' value='改写' class="input2" style='color:darkblue'/></div>
				<div style='float:left;margin-left:30px;'>
					<input type="submit" name='overwrite_btn' value='覆盖' class="input2" style='color:darkred'/></div>
				</td>
			</form>
		</tr>
	</table>
	<br>
	<div><font color="green">温馨提示</font>：显示的当前剩余闯关次数有可能是不正常的，不处理直接显示是为了让客服能够判断该玩家闯关次数是否真的不正常。</div>
	
	<table cellspacing="1" cellpadding="3" border="0" class='table_list' style="width:450px;text-align:center;">
   		<tr class='table_list_head'>
   			<td width=100>选项</td>
   			<td width=100>当前值 </td>
   			<td width=120 colspan=2>操作</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>已用城池面积：</B></td>
   			<td width=150> <{$cinfo.acreage_use}> / <{$cinfo.acreage_max}>  </td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_acreage_use' />
					<input type="text" name='acreage_use' size="5" value=""/>
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="submit" name='modify' class="input2" value='覆盖' class="input2"  style='color:darkred'/>
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>剩余闯关次数：</B></td>
   			<td width=150><{math equation="x - y" x=4 y=$progress }> <{if $alive_num != ""}>[复活次数：<{$alive_num}>]<{/if}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_cg' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<select name="cg_num">
						<option value="3">1</option>
						<option value="2">2</option>
						<option value="1">3</option>
					</select>
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>婚姻亲密度：</B></td>
   			<td width=150><{$love_point}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_love_point' />
					<input type="text" name='love_point' size="5" value=""/>
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>连续登录天数：</B></td>
   			<td width=150><{$login_days}>/<{$max_login_days}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_love_point' />
					<input type="text" name='love_point' size="5" value=""/>
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>演武场本周积分：</B></td>
   			<td width=150><{$yanwuInfo.week_score}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_yanwu_weekscore' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="week_score" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>演武场胜利次数：</B></td>
   			<td width=150><{$yanwuInfo.win_num}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_yanwu_winnum' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="win_num" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>演武场失败次数：</B></td>
   			<td width=150><{$yanwuInfo.fail_num}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_yanwu_failnum' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="fail_num" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>下西洋海盗积分：</B></td>
   			<td width=150><{$voyageInfo.pirate_score}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_voyage_pirate_score' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="pirate_score" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>下西洋本周完成次数：</B></td>
   			<td width=150><{$voyageInfo.week_tasks}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_voyage_week_tasks' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="week_tasks" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		<tr class='trEven'>
   			<td width=150><B>下西洋总共完成次数：</B></td>
   			<td width=150><{$voyageInfo.total_tasks}></td>
   			<td width=150>
   				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='modify_voyage_total_tasks' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<input type="text" name="total_tasks" value="" size="5">
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
   			</td>
		</tr>
		
	</table>
	<!--
	<br>
   	<table cellspacing="1" cellpadding="3" border="0" class='table_list'>
   		<tr class='table_list_head'>
   			<td width=140>当前桃花阵剩余次数：</td>
   			<td width=50><{$peach_day_times}></td>
   			<td width=160>重置桃花阵剩余次数为：</td>
   			<td>
				<form name="myform" method="post" action="<{$URL_SELF}>">
					<input type="hidden" name='ac' value='clear_peach_day_times' />
					<input type='hidden' name='userid' value='<{$userinfo.id}>' />
					<select name="th_times">
						<{if $peach_day_times eq 3}>
							<option value="3">3</option>
						<{elseif $peach_day_times eq 2}>
							<option value="2">2</option>
							<option value="3">3</option>
						<{elseif $peach_day_times eq 1}>
							<option value="1">1</option>
							<option value="2">2</option>
							<option value="3">3</option>
						<{elseif $peach_day_times eq 0}>
							<option value="1">1</option>
							<option value="2">2</option>
							<option value="3">3</option>
						<{else}>
							<option value="1">1</option>
							<option value="2">2</option>
							<option value="3">3</option>
						<{/if}>
					</select>
					<input type="submit" name='modify' class="input2" value='修改' />
				</form>
			</td>
		</tr>
	</table>
	-->
	
	<br>
	<table>
	<tr><td>
		<font  color='green'>添加道具的功能说明：绿色的选项为勾选道具，道具默认全部都为绑定。</font>
	</td></tr>
	<tr><td>

		<form name="myItemform" method="post" action="<{$URL_SELF}>">
			<input type='hidden' name='acname' size='10' value='<{$search1}>' />
			<input type='hidden' name='nickname' size='10' value='<{$search2}>' />
			<input type='text' name='idItem' size='20' value='<{$idItem}>' />
			<input type="submit" name='submit' value='查找道具' class="input2" />
		</form>
		<font  color='red'><{$msg}></font>

	</td></tr>
	</table>


	<table><tr><td>
<div style="width:1020px;">
	<{foreach name=allname key=key item=item from=$rs}>

			<{if $item.modeIndex == 0}>
				<form name="myItemform" method="post" action="<{$URL_SELF}>">
				<input type='hidden' name='acname' size='10' value='<{$search1}>' />
				<input type='hidden' name='nickname' size='10' value='<{$search2}>' />
			<{/if}>
			<div style="width:305px;float:left;border-bottom:#D7E4F5 solid 18px;border-right:#87CEEB solid 3px;background:#EDF2F7;">
				<div style="width:5px;float:left;">&nbsp;</div>
				<div style="width:18px;float:left;background:green;">
					<input type='checkbox' id='choose' name='choose[]' value='<{$item.itemId}>' style="width:18px;"  />
				</div>
				<div style="width:110px;float:left;">
					<{$item.itemId}>:<{$item.entName}>
				</div>
				<div style="width:165px;float:left;">
					<div style="width:65px;float:left;">数量:<input type='text' id='num' name='num_<{$item.itemId}>' value='1'  style="width:25px;" /></div>
					<div style="width:58px;float:left;">
						<div style="width:20px;float:left;"><input type='checkbox' id='bind' name='bind_<{$item.itemId}>' value='1'  style="width:15px;"  /></div>
						<div style="width:33px;float:left;">不绑</div>
					</div>

					<{if $item.modeIndex == 2 || ($smarty.foreach.allname.last%3 != 2 && $smarty.foreach.allname.last) }>
						<div style="width:10px;float:left;">
							<input type="submit" name='submit' value='赠送' class="input2" style='color:darkblue'/>
						</div>
					<{/if}>
				</div>
			</div>

			<{if $item.modeIndex == 2 || ($smarty.foreach.allname.last%3 != 2 && $smarty.foreach.allname.last) }>
					</form>
			<{/if}>

	<{/foreach}>

</div>

	</td></tr></table>
	
<div style="width:800px;border:1px solid #87CEEB;padding:5px 0 ;">
	<table>
	<tr><td>&nbsp;&nbsp;<font color="red">在下面输入ID直接送道具或可以搜索道具：</font>
	<input type='text' name='itemname' id="itemname" size='20' value='' onKeyUp="searchItem();" onMouseUp="searchItem();" />
	<div style="position:relative;">
<div id="itemlist" class="itemlist" ></div>
</div>
<script language="javascript" >
	var itemArray = new Array();
	<{foreach item=idata from=$ITEMS_LIST}>
		itemArray[<{$idata.item_id}>] = "<{$idata.item_id}> | <{$idata.entName}> | <{$idata.entId}>";
	<{/foreach}>
	function selectItem(iid){
		document.getElementById('iid').value = iid;
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
	</div>
	</td>
	</tr>
	<tr><td>


	<form name="myItemform" method="post" action="<{$URL_SELF}>">
		<input type='hidden' name='acname' size='10' value='<{$search1}>' />
		<input type='hidden' name='nickname' size='10' value='<{$search2}>' />

		<div style="width:455px;float:left;border-bottom:#D7E4F5 solid 18px;border-right:#87CEEB solid 3px;background:#EDF2F7;">
			<div style="width:5px;float:left;">&nbsp;</div>

			<div style="width:160px;float:left;">
				<input type='hidden' id='choose_sec' name='choose_sec' value='1' style="width:18px;"  />
				道具ID：<input type='text' id='iid' name='idItem' size='12' value='<{$idItem}>' />
			</div>
			<div style="width:265px;float:left;">
				<div style="width:75px;float:left;">数量:<input type='text' id='num' name='num' value='1'  style="width:25px;" /></div>

				<div style="width:55px;float:left;">
					<!--	HERE BY NATSUKI -->
					<div style="width:20px;float:left;">

						<select name="finensss" id="finensss"  onchange="" size="1">
							<option value="1">完美</option>
							<option value="2">优良</option>
							<option value="3">普通</option>
							<option value="4">粗糙</option>
							<option value="5">劣质</option>
						</select>
					</div>
					<!-- END -->

				</div>

				<div style="width:58px;float:left;">
					<div style="width:20px;float:left;"><input type='checkbox' id='bind' name='bind' value='1'  style="width:15px;"  /></div>
					<div style="width:33px;float:left;">不绑</div>
				</div>
				<div style="width:10px;float:left;">
					<input type="submit" name='submit' value='赠送' class="input2" style='color:darkblue'/>
				</div>
			</div>
		</div>

	</form>
<div style="width:800px;float:left;"><font  color='red'><{$msg_sec}></font></div>
<div style="width:800px;float:left;">
	<a href="gamer_item_list.php" target="_BLANK" style="border-bottom:1px solid red;"><font  color='red'><b>查看道具列表</b></font></a>
</div>

	</td></tr></table>
</div>


</div>


<div style="width:800px;border:1px solid #87CEEB;padding:5px 0 ;">
	<table>
	<tr><td>&nbsp;&nbsp;<font color="red">在下面输入ID直接送书籍或可以搜索书籍：</font>
	<input type='text' name='bookitemname' id="bookitemname" size='20' value='' onKeyUp="searchBookItem();" onMouseUp="searchBookItem();" />
	<div style="position:relative;">
<div id="bookitemlist" class="itemlist" ></div>
</div>
<script language="javascript" >
	var itemBookArray = new Array();
	<{foreach item=idata from=$BOOK_ITEMS_LIST}>
		itemBookArray[<{$idata.bookId}>] = "<{$idata.bookId}> | <{$idata.bookName}>";
	<{/foreach}>
	function selectBookItem(iid){
		document.getElementById('bookId').value = iid;
		document.getElementById('bookitemname').value = itemBookArray[iid];
		document.getElementById('bookitemlist').style.display="none";
	}

	function searchBookItem(){
		document.getElementById('bookitemlist').style.display="block";
		var keyword = document.getElementById('bookitemname').value ;


		var onArray = new Array();
		for(kid in itemBookArray) {
			if(itemBookArray[kid].indexOf(keyword) !=-1 ){
				onArray[kid] = itemBookArray[kid];
			}
		}
		var strBook='<ul><li style="text-align:right;"><a href="javascript:;" onclick="hiddenbooklist();">关闭</a></li>';
		for(iid in onArray) {
			strBook += '<li onclick="selectBookItem('+iid+');">'+onArray[iid]+'</li>';
		}
		strBook += '</ul>';
		document.getElementById('bookitemlist').innerHTML = strBook ;
	}
	function hiddenbooklist(){
		document.getElementById('bookitemlist').style.display="none";
	}
</script>
	</div>
	</td>
	</tr>
	<tr><td>
	<form name="mybookform" method="post" action="<{$URL_SELF}>">
		<input type='hidden' name='acname' size='10' value='<{$search1}>' />
		<input type='hidden' name='nickname' size='10' value='<{$search2}>' />
		
		<input type="hidden" name='ac' value='give_book' />
		<input type='hidden' name='userid' value='<{$userinfo.id}>' />

		<div style="width:455px;float:left;background:#EDF2F7;">
			<div style="width:5px;float:left;">&nbsp;</div>

			<div style="width:160px;float:left;">
				
				书籍ID：<input type='text' name='bookId' id='bookId' size='12' value='<{$bookId}>' />
			</div>
			<div style="width:265px;float:left;">
				<div style="width:75px;float:left;">数量:<input type='text' id='bookNum' name='bookNum' value='1'  style="width:25px;" /></div>
				<div style="width:58px;float:left;">
					<div style="width:20px;float:left;"><input type='checkbox' id='bind' name='bind' value='1'  style="width:15px;"  /></div>
					<div style="width:33px;float:left;">不绑</div>
				</div>
				<div style="width:10px;float:left;">
					<input type="submit" name='bsubmit' value='赠送' class="input2" style='color:darkblue'/>
				</div>
			</div>
		</div>

	</form>
	<div style="width:800px;float:left;">
	<a href="gamer_book_list.php" target="_BLANK" style="border-bottom:1px solid red;"><font  color='red'><b>查看书籍列表</b></font></a>
	</div>
</div>



	</td></tr></table>



</div>

<{/if}>

</body>
</html>
