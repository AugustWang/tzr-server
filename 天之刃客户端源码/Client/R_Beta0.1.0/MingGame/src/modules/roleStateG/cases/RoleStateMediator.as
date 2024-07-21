package modules.roleStateG.cases {
	import com.common.GlobalObjectManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.baseUnit.things.effect.DamageEffect;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.PathUtil;
	
	import flash.geom.Point;
	
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.friend.views.part.ChatWindowManager;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.EquipVO;
	import modules.npc.NPCConstant;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.views.details.MyDetailView;
	import modules.roleStateG.views.states.RoleBuffView;
	import modules.vip.VipModule;
	
	import proto.common.p_goods;
	import proto.common.p_role;
	import proto.line.m_map_update_actor_mapinfo_toc;
	import proto.line.m_role2_attr_change_toc;
	import proto.line.m_role2_exp_full_toc;
	import proto.line.m_role2_five_ele_attr_toc;
	import proto.line.m_role2_getroleattr_toc;
	import proto.line.m_role2_hair_toc;
	import proto.line.m_role2_head_toc;
	import proto.line.m_role2_levelup_toc;
	import proto.line.m_role2_pkmodemodify_toc;
	import proto.line.m_role2_pkpoint_left_toc;
	import proto.line.m_role2_pointassign_toc;
	import proto.line.m_role2_relive_toc;
	import proto.line.m_role2_sex_toc;
	import proto.line.m_title_change_cur_title_toc;
	import proto.line.m_title_get_role_titles_toc;
	import proto.line.p_equip_endurance_info;
	import proto.line.p_role_attr_change;

	public class RoleStateMediator {
		public var stateCase:RoleStateCase;
		public var myDetailCase:RoleMyDetailCase;
		public var otherDetailCase:RoleOtherDetailCase;
		public var changeSexCase:ChangeSexCase;
		public var changeHairCase:ChangeHairCase;

		public function RoleStateMediator() {
			initClasses();
		}

		public function setup():void {
			initClasses();
			stateCase.initView()
		}

		private function initClasses():void {
			if ( !_isInitClasses ) {
				stateCase=new RoleStateCase();
				myDetailCase=new RoleMyDetailCase();
				otherDetailCase=new RoleOtherDetailCase();
				changeSexCase=new ChangeSexCase();
				changeHairCase=new ChangeHairCase();

				_isInitClasses=true;
			}
		}		
		

		public function onOpenMyDetail(index:int=0):void {
			myDetailCase.show(index);
		}

		public function onOpenCloseMyDetail():void {
			myDetailCase.showClose();
		}

		public function onOpenOtherDetail(vo:m_role2_getroleattr_toc):void {
			if (vo.succ == true) {
				if (ChatWindowManager.getInstance().isOenByChat) {
					ChatWindowManager.getInstance().isOenByChat=false;
					if (ChatWindowManager.getInstance().panel) {
						ChatWindowManager.getInstance().panel.showFriendInfo(vo);
					}
				} else {
					otherDetailCase.show(vo);
				}
			}
		}

		public function updateMine():void {
			stateCase.update();
			myDetailCase.update();
		}

		/**
		 * 更新坐骑面版信息
		 */
		public function updateMount():void {
			myDetailCase.updateMount();
		}

		public function updateMyTitles(vo:m_title_get_role_titles_toc):void {
			myDetailCase.updateMyTitles(vo);
		}

		public function onCurrentTitle(vo:m_title_change_cur_title_toc):void {
			if (vo.succ == true) {
				RoleStateDateManager.cur_title_id=vo.id;
				if (vo.color == "")
					vo.color="ffffff";
				GlobalObjectManager.getInstance().user.base.cur_title_color=vo.color;
			} else {
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			}
		}

		public function onAddRoleProperty(vo:m_role2_pointassign_toc):void {
			if (vo.succ=false) {
				BroadcastSelf.getInstance().appendMsg(vo.reason);
			} else {

			}
		}

		public function onEnduraceChanged(vo:p_equip_endurance_info):void {
			var arr:Array=GlobalObjectManager.getInstance().user.attr.equips;
			for each (var p:p_goods in arr) {
				if (p.id == vo.equip_id) {
					p.current_endurance=vo.num;
					p.endurance=vo.max_num;
				}
			}
			myDetailCase.update();
		}

		public function onPKModeChange(vo:m_role2_pkmodemodify_toc):void {
			stateCase.updateAttackMode(vo);
		}

		public function onLevelUp(vo:m_role2_levelup_toc):void {
			stateCase.onLevelUp(vo);
			updateMine();
//			sendToModel([ModelConstant.FAMILY_MODEL, ModelConstant.NAVIGATION_MODEL,ModelConstant.EDUCATE_MODEL], RoleStateMap_M.ROLE_LEVEL_UP);
		}

		public function updateActor(vo:m_map_update_actor_mapinfo_toc):void {
			if (GlobalObjectManager.getInstance().user.base.role_id == vo.actor_id && vo.actor_type == SceneUnitType.ROLE_TYPE) { //自己的PKpoint
				GlobalObjectManager.getInstance().user.base.pk_points=vo.role_info.pk_point;
				updateMine();
			}
			stateCase.onUpdateSelected(vo);
		}

		public function onFiveEveChange(vo:m_role2_five_ele_attr_toc):void {
			if (vo.succ) {
				if (GlobalObjectManager.getInstance().user.attr.five_ele_attr == 0) {
					BroadcastSelf.getInstance().appendMsg("恭喜你，获得五行属性！");
				} else {
					BroadcastSelf.getInstance().appendMsg("恭喜你，重洗五行属性成功！");
				}
				GlobalObjectManager.getInstance().user.attr.five_ele_attr=vo.five_ele_attr;
//				sendToModel([ModelConstant.TEAM_MODEL], TeamActionType.UPDATE_FIVE + "", null);
			} else {
				BroadcastSelf.getInstance().appendMsg(vo.reason)
			}
		}

		public function onPKPointLeft(vo:m_role2_pkpoint_left_toc):void {
			myDetailCase.onPKPointLeft(vo);
		}

		public function onMoneyChange(silverNum:int):void {
			GlobalObjectManager.getInstance().user.attr.silver=silverNum;
//			sendToModel([ModelConstant.PACKAGE_MODEL], RoleStateMap_M.PACKAGE_MONEY_CHANGE + "");
		}

		public function onRelive(vo:m_role2_relive_toc):void {
			if (vo.succ == true) {
				if (vo.return_self == true) {
					GlobalObjectManager.getInstance().user.base=vo.role_base;
					GlobalObjectManager.getInstance().user.fight=vo.role_fight;
					GlobalObjectManager.getInstance().user.pos=vo.role_pos;
					updateMine();
				}
			}
		}

		public function showSelectedRole(obj:Object):void {
			stateCase.showSelected(obj);
		}

		public function onDeadOrLive(isAlive:Boolean):void {
			stateCase.onDeadAlive(isAlive);
		}

		public function onAttrChange(vo:m_role2_attr_change_toc):void {
			var pvo:p_role=GlobalObjectManager.getInstance().user;
			for (var i:int=0; i < vo.changes.length; i++) {
				var cvo:p_role_attr_change=vo.changes[i] as p_role_attr_change;
				switch (cvo.change_type) {
					case 1:
						pvo.fight.hp=cvo.new_value;
						break;
					case 2:
						pvo.fight.mp=cvo.new_value;
						break;
					case 3: //剩余技能点
						pvo.attr.remain_skill_points=cvo.new_value;
						sendToSkillTree(); //告诉技能模块
						break;
					case 4: //剩余属性点
						pvo.base.remain_attr_points=cvo.new_value;
						break;
					case 5: //经验值
						if (pvo.base.status == RoleActState.ON_HOOK) {
							if (cvo.new_value - pvo.attr.exp > 0) {
//								Tips.getInstance().addTipsMsg("获得经验 " + (cvo.new_value - pvo.attr.exp));
							}
						}
						if (cvo.new_value - pvo.attr.exp > 0) {
							DamageEffect.getEffect().showExp(SceneUnitManager.getSelf().topEffectLayer, new Point(0, -85), cvo.new_value - pvo.attr.exp, 30);
//							BroadcastSelf.getInstance().appendMsg("获得" + (cvo.new_value - pvo.attr.exp) + "经验。");
						}
						pvo.attr.exp=cvo.new_value;
//						sendToModel([ModelConstant.NAVIGATION_MODEL], RoleStateMap_M.EXP_CHAGNGE.toString());
						break;
					case 6: //银子
						pvo.attr.silver=cvo.new_value;
//						sendToModel([ModelConstant.PACKAGE_MODEL], RoleStateMap_M.PACKAGE_MONEY_CHANGE + "");
						//告诉背包sengToPackage
						break;
					case 7: //绑定银子
						pvo.attr.silver_bind=cvo.new_value;
//						sendToModel([ModelConstant.PACKAGE_MODEL], RoleStateMap_M.PACKAGE_MONEY_CHANGE + "");
						//告诉背包sengToPackage
						break;
					case 8: //改变元宝
						pvo.attr.gold=cvo.new_value;
//						sendToModel([ModelConstant.PACKAGE_MODEL], RoleStateMap_M.PACKAGE_MONEY_CHANGE + "");
						//告诉背包sengToPackage
						break;
					case 9: //绑定元宝
						pvo.attr.gold_bind=cvo.new_value;
//						sendToModel([ModelConstant.PACKAGE_MODEL], RoleStateMap_M.PACKAGE_MONEY_CHANGE + "");
						break;
					case 10: //精力值
						pvo.fight.energy=cvo.new_value;
						break;
					case 11: //功勋
						if (cvo.new_value - pvo.attr.gongxun > 0) {
							DamageEffect.getEffect().showZhangong(SceneUnitManager.getSelf().topEffectLayer, new Point(0, -85), cvo.new_value - pvo.attr.gongxun, 30);
							BroadcastSelf.getInstance().appendMsg("获得" + (cvo.new_value - pvo.attr.gongxun) + "战功。");
						}
						pvo.attr.gongxun=cvo.new_value;
						break;
					case 12: //门派贡献度
						pvo.attr.family_contribute=cvo.new_value;
						break;
					case 13: //门派id
						pvo.base.family_id=cvo.new_value;
						break;
					case 14: //魅力值得
						pvo.attr.charm=cvo.new_value;
						break;
					case 15:
						pvo.attr.active_points=cvo.new_value;
//						ActivityModel.getInstance().actpointChange(cvo.new_value);
//						sendToModel([ModelConstant.ACTIVITY_MODEL],RoleStateMap_M.ROLE_ACT_POINT_CHANGE)
						break;
					case 17://玩家总声望
						pvo.attr.sum_prestige = cvo.new_value;
						//BroadcastSelf.getInstance().appendMsg("玩家总声望：" + (cvo.new_value));
						break;
					case 18://玩家当前声望
						pvo.attr.cur_prestige = cvo.new_value;
						//BroadcastSelf.getInstance().appendMsg("玩家当前声望" + (cvo.new_value));
						break;
					default:
						break;
				}
			}
			updateMine();
		}

		public function toChangeAttackMode(mode:int):void {
			stateCase.toChangeAttackMode(mode);
		}

		public function onEquipUnload(equip_id:int):void {
			var equip:EquipVO=RoleStateDateManager.getEquipById(equip_id);
			RoleStateDateManager.unLoadEquip(equip_id); //从attr里去掉这个装备的数据
			myDetailCase.update();
		}

		public function showPutEquipTask(index:int):void {
			onOpenMyDetail();
			myDetailCase.flashEquipItem(4);
		}

		public function showPropretyTask():void {
			onOpenMyDetail(1);
			myDetailCase.flashProprety();
		}

		public function getMyDetailView():MyDetailView {
			return myDetailCase.theView
		}

		public function getBuffBox():RoleBuffView {
			return stateCase.buffBox;
		}

		public function sendToSkillTree():void {
//			var getter:Vector.<int>=new Vector.<int>
//			getter.push(ModelConstant.SKILL_TREE_MODEL);
//			var m:IMessage=_model.createMessage(MessageConstant.MODEL_TO_MODEL, MessageConstant.CALL, getter, null);
//			m.name=SkillTreeActionType.ROLE_ARR_CHANGE.toString();
//			_model.send(m);
		}


		public function openChangeSex():void {
			changeSexCase.show();
		}

		public function changeSexResult(vo:m_role2_sex_toc):void {
			changeSexCase.changeSexResult(vo);
		}


		public function openChangeHair():void {
			changeHairCase.show();
		}

		public function changeHairResult(vo:m_role2_hair_toc):void {
			changeHairCase.onChangeHair(vo);
		}

		public function onChangeFace(vo:m_role2_head_toc):void {
			changeHairCase.onChangeFace(vo);
		}

		public function updatePKPoint():void {
			myDetailCase.update();
		}

		public function onExpFull(vo:m_role2_exp_full_toc):void {

		}


		//add by handing @2011.4.21 14:15
		private var isPlaySet:String=null;
		private var _isInitClasses:Boolean;

		public function get playSet():String {
			return isPlaySet;
		}

		public function set playSet(data:String):void {
			isPlaySet=data;
		}

		/**
		 * 检测耐久度
		 *
		 * author: handing
		 * updateTime:2011.4.21 -  11.40
		 */
		public function checkEndurance(array:Array):void {
			//GlobalObjectManager.getInstance().addObject(
			//先看看用户有没有设置过不再提示
			//如果为null则表示没有设置过，玩家刚开始游戏，no表示没有设置，yes表示设置了
			if (isPlaySet == null) {
				var data:Object=GlobalObjectManager.getInstance().getObject("checkEndurance");
				//先检查设置过没有
				var isPlaySetting:String=data as String;
				//为null表示没有这事
				if (isPlaySetting == null) {
					isPlaySet="no";
					gotoTraverseArray(array);
				}
			} else if (isPlaySet == "no") {
				gotoTraverseArray(array);
			}
		}

		//遍历装备数组，检测是否有耐久度为0的
		private function gotoTraverseArray(array:Array):void {
			var equipsArray:Array=array;
			var equipsArray_length:int=equipsArray.length;
			for (var i:int=0; i < equipsArray_length; i++) {
				var equips_good:p_goods=equipsArray[i];
				if (equips_good.current_endurance == 0) {
					//如果有武器的耐久度为0的，就提示
					var vipLevel:int = VipModule.getInstance().getRoleVipLevel();
					var str:String = "您装备:" + equips_good.name + "耐久度为0";
					var linkStr:String = "修理全部装备";
					if (vipLevel < 4) {
						str += "\n\n<font color='#ff0000'>VIP4可远程修理全部装备</font>    <a href='event:openVip'><font color='#00ff00'><u>成为VIP4</u></font></a>";
						linkStr = "前往铁匠铺修理";
					}
					BroadcastModule.getInstance().popup(str, linkStr, gotoFix, null, 0);
					break;
				}
			}
		}

		private function gotoFix():void {
			if (VipModule.getInstance().getRoleVipLevel() >= 3) {
				PackageModule.getInstance().fixEquip(0, false);
				return;
			}
			
			var roleFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var tieJiangNPCID:int=NPCConstant.NPC_JING_CHENG_TIE_JIANG_ID[roleFaction];
			PathUtil.findNpcAndOpen(tieJiangNPCID);
		}
	}
}