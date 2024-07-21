<meta http-equiv="Content-Type" content="text/html"; charset="UTF-8" />
<title>
        查看门派
</title>
<link href="/admin/static/css/style.css" rel="stylesheet" type="text/css" />
<style>
.fa_title{width:80px;}
td{word-break:break-all}
</style>
</head>

<body style="margin:10px">
<font color='red'><{$errmsg}></font>

<div align="left"><b>综合：门派信息</b></div>
<div class='divOperation'>
        <form name="myform" method="post" action="<{$URL_SELF}>">
                请输入门派名:
                <input type='text' name='fname' id='fname' size='10' value='<{$fname}>' onkeydown="document.getElementById('fid').value ='';" />
                或门派ID:
                <input type='text' name='fid' id='fid' size='10' value='<{$fid}>' onkeydown="document.getElementById('fname').value ='';"  />
		<input type='hidden' name='action' value='search' />
<input type="image" name='search' src="/admin/static/images/search.gif" class="input2"  />
        </form>
</div>

<div class='tbl_user_msg_list'>
        <table cellspacing="1" cellpadding="3" border="0" class='table_list' style="width:900px">
            <{if $familyinfo}>
                <tr >
                        <td class='table_list_head' style="width:80px" >ID</td>
                        <td class='trOdd'><{$familyinfo.family_id}></td>
                        <td  class='table_list_head'  width="80">门派名称</td>
                        <td class='trOdd'><{$familyinfo.family_name}></td>
                        <td  class='table_list_head'  >门派等级</td>
                        <td class='trOdd'><{$familyinfo.level}></td>
                        <td  class='table_list_head' >所在国家</td>
                        <td class='trOdd'>
							<{if $familyinfo.faction_id==1}>
								云州
							<{elseif $familyinfo.faction_id==2}>
								沧州
							<{elseif $familyinfo.faction_id==3}>
								幽州
							<{/if}>
						</td>

                </tr>
                <tr >
                        <td  class='table_list_head' >创始人</td>
                        <td class='trOdd'><{$familyinfo.create_role_name}></td>
                        <td  class='table_list_head'  >掌门</td>
                        <td class='trOdd'><{$familyinfo.owner_role_name}></td>
                        <td  class='table_list_head'  >长老</td>
                        <td class='trOdd'><{$familyinfo.second_owners}></td>
                        <td  class='table_list_head'  >创立时间</td>
                        <td class='trOdd'><{$familyinfo.creator_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
                </tr>
                <tr >

                        <td  class='table_list_head'  >门派人数</td>
                        <td class='trOdd'><{$familyinfo.cur_members}></td>
                        <td  class='table_list_head'  >繁荣度</td>
                        <td class='trOdd'><{$familyinfo.active_points}></td>
                        <td  class='table_list_head'  >门派资金</td>
                        <td class='trOdd'><{$familyinfo.money}></td>
                        <td  class='table_list_head'  >门派总战功</td>
                        <td class='trOdd'><{$familyinfo.gongxun}></td>
                </tr>
                <tr >
                        <td  class='table_list_head'>重设掌门</td>
                        <td>角色名:</td>
                        <td colspan="2">
                                <form name="resetform" method="post" action="<{$URL_SELF}>">
										<input type="hidden" name="action" value="change_owner"/>
                                        <input type="hidden" name='fname' value='<{$familyinfo.family_name}>' />
                                        <input type='text' name='reset_owner_name' size='14' value='<{$familyinfo.owner_role_name}>' />
                                        <!--<input type="submit" name='reset_owner' value='重设' class="input2" style='color:darkred'/>-->
                                </form>
                        </td>
                        <td colspan="2">注：慎重操作</td>
						<td class='table_list_head' >门派地图是否开启</td>
						<td class='trOdd'>
							<{if $familyinfo.ernable_map==0}>
							否
							<{elseif $familyinfo.ernable_map==1}>
							是
							<{/if}>
						</td>
                </tr>
		<!-- <tr >                                                          
         		<td  class='table_list_head'  >门派地图是否开启</td>           
         		<td class='trOdd'><{$familyinfo.enable_map}></td>     
         		<td  class='table_list_head'  >是否已经杀死升级boss</td> 
         		<td class='trOdd'><{$familyinfo.active_points}></td>   
         		<td  class='table_list_head'  >是否已经召唤了门派升级boss</td>
         		<td class='trOdd'><{$familyinfo.money}></td>           
 		</tr> -->                                                         

                <tr >
                        <td  class='table_list_head'  >门派成员</td>
                        <td colspan="7" class='trOdd' ><{$familyinfo.members}></td>
                </tr>
		<tr>
			<td  class='table_list_head'  >申请入族列表</td>           
			<td colspan="7" class='trOdd' ><{$familyinfo.request_list}></td>
		</tr>
                <tr >
                        <td  class='table_list_head'  >邀请入族列表</td>
                        <td colspan="7" class='trOdd' ><{$familyinfo.invite_list}></td>
                </tr>

		<tr >                                                                  
	         	<td  class='table_list_head'  >对外公告</td>               
         		<td colspan="7" class='trOdd' ><{$familyinfo.public_notice}></td>
		</tr>                                                                  
		<tr >                                                                  
         		<td  class='table_list_head'  >对内公告</td>               
         		<td colspan="7" class='trOdd' ><{$familyinfo.private_notice}></td>
 		</tr>                                                                  
                <!--<tr >
                        <td colspan="8" class='table_list_head'  >门派事件</td>
                </tr>

                <{foreach key=key  item=event from=$eventData}>
                <tr >
                <td colspan="8" class='trOdd'>
                        <{$event.time}> <{$event.html}></td>
                </tr>
                <{/foreach}>-->
	
        <{/if}>
		<{if $familyextinfo}>
			<tr>
				<td class='table_list_head' >上次变更掌门时间</td>
				<td class='trOdd'><{$familyextinfo.last_set_owner_time|date_format:"%Y-%m-%d %H:%M:%S"}></td>
				<td class='table_list_head' >是否召唤普通boss</td>
				<td class='trOdd'>
					<{if $familyextinfo.common_boss_called==false}>
					否
					<{else}>
					是
					<{/if}>
				</td>
				<td class='table_list_head' >是否杀死普通boss</td>
				<td class='trOdd'>
					<{if $familyextinfo.common_boss_killed==false}>
					否
					<{else}>
					是
					<{/if}>
				</td>
				<td class='table_list_head' >普通boss召唤日期</td>
				<td class='trOdd'>
				<{if $familyextinfo.common_boss_call_time==0}>
					未召唤
				<{else}>
					<{$familyextinfo.common_boss_call_time}>
				<{/if}>
				</td>
			</tr>
			<tr>
				<td class='table_list_head' >上次镖车结束日期</td>
				<td class='trOdd'>
					<{$familyextinfo.last_ybc_finish_date}>
				</td>
				<td class='table_list_head' >上次接镖开始时间</td>
				<td class='trOdd'>
					<{if $familyextinfo.last_ybc_begin_time==0}>
						无
					<{else}>
						<{$familyextinfo.last_ybc_begin_time|date_format:"%Y-%m-%d %H:%M:%S"}>
					<{/if}>
					</td>
				<td class='table_list_head' >上次接镖的结果</td>
				<td class='trOdd'>
					<{if $familyextinfo.last_ybc_result==none}>
					无
					<{else}>
					<{$familyextinfo.last_ybc_result}>
					<{/if}>
				</td>
				<td class='table_list_head' >上次扣除地图费用时间</td>
				<td class='trOdd'>
					<{if $familyextinfo.last_resume_time==0}>
					 无
					 <{else}>
					 	<{$familyextinfo.last_resume_time|date_format:"%Y-%m-%d %H:%M:%S"}>
					 <{/if}>
					
				</td>
			</tr>
			<tr>
				<td class='table_list_head' >上次门派令使用数量</td>
				<td class='trOdd'><{$familyextinfo.last_card_use_count}></td>
				<td class='table_list_head' >上次门派令使用日期</td>
				<td class='trOdd'><{$familyextinfo.last_card_use_day}></td>
				<td class='table_list_head' >今日普通boss召唤次数</td>
				<td class='trOdd'><{$familyextinfo.common_boss_call_count}></td>
				<td class='table_list_head' ></td>
				<td class='trOdd'></td>
			</tr>
		<{/if}>	
        </table>
</div>

</body>
</html>
