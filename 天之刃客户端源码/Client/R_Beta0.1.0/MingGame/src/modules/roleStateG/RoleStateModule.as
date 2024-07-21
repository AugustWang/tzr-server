package modules.roleStateG {
	import com.Message;
	import com.common.GlobalObjectManager;
	import com.components.MessageIconManager;
	import com.net.SocketCommand;
	import com.scene.sceneManager.UnitPool;
	import com.scene.sceneUnit.baseUnit.things.effect.DamageEffect;
	import com.scene.sceneUtils.RoleActState;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadcastModule;
	import modules.broadcast.views.BroadcastSelf;
	import modules.family.FamilySkillModule;
	import modules.friend.views.part.ChatWindowManager;
	import modules.mypackage.vo.EquipVO;
	import modules.npc.NPCActionType;
	import modules.npc.vo.NpcLinkVO;
	import modules.playerGuide.GuideConstant;
	import modules.roleStateG.cases.RoleStateMediator;
	import modules.roleStateG.views.details.MyDetailView;
	import modules.roleStateG.views.states.RoleBuffView;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_goods;
	import proto.common.p_role;
	import proto.line.m_map_update_actor_mapinfo_toc;
	import proto.line.m_role2_add_energy_toc;
	import proto.line.m_role2_attr_change_toc;
	import proto.line.m_role2_attr_reload_toc;
	import proto.line.m_role2_base_reload_toc;
	import proto.line.m_role2_exp_full_toc;
	import proto.line.m_role2_five_ele_attr_toc;
	import proto.line.m_role2_five_ele_attr_tos;
	import proto.line.m_role2_getroleattr_toc;
	import proto.line.m_role2_getroleattr_tos;
	import proto.line.m_role2_hair_toc;
	import proto.line.m_role2_hair_tos;
	import proto.line.m_role2_head_toc;
	import proto.line.m_role2_head_tos;
	import proto.line.m_role2_levelup_toc;
	import proto.line.m_role2_pkmodemodify_toc;
	import proto.line.m_role2_pkpoint_left_toc;
	import proto.line.m_role2_pointassign_toc;
	import proto.line.m_role2_relive_toc;
	import proto.line.m_role2_reload_toc;
	import proto.line.m_role2_sex_toc;
	import proto.line.m_role2_sex_tos;
	import proto.line.m_role2_show_cloth_toc;
	import proto.line.m_role2_show_equip_ring_toc;
	import proto.line.m_title_change_cur_title_toc;
	import proto.line.m_title_get_role_titles_toc;
	import proto.line.p_equip_endurance_info;
	import proto.line.p_role_attr_change;

	public class RoleStateModule extends BaseModule {
		private static var _instance:RoleStateModule;
		private var inited:Boolean;
		public var mediator:RoleStateMediator;

		public function RoleStateModule() {
			mediator=new RoleStateMediator();
			if (_instance != null) {
				throw new Error("RoleStateModule只能存在一个实例。");
			}
		}

		private function initView():void {
			if (inited == false) {
				if (mediator == null) {
					mediator=new RoleStateMediator();
				}
				mediator.setup();
				inited=true;
			}
		}

		public function onOpenMyDetail(index:int=0):void {
			mediator.myDetailCase.show(index);
		}

		public function openRoleAttrPanel():void {
			mediator.myDetailCase.show(1);
		}

		public function onOpenCloseMyDetail():void {
			mediator.myDetailCase.showClose();
		}

		public function onOpenOtherDetail(vo:m_role2_getroleattr_toc):void {
			if (vo.succ == true) {
				if (ChatWindowManager.getInstance().isOenByChat) {
					ChatWindowManager.getInstance().isOenByChat=false;
					if (ChatWindowManager.getInstance().panel) {
						ChatWindowManager.getInstance().panel.showFriendInfo(vo);
					}
				} else {
					mediator.otherDetailCase.show(vo);
				}
			}
		}

		public function updateMine(param:*=null):void {
			if (inited) {
				mediator.stateCase.update();
				mediator.myDetailCase.update();
			}
		}

		/**
		 * 更新坐骑面版信息
		 */
		public function updateMount():void {
			mediator.myDetailCase.updateMount();
		}

		public function updateMyTitles(vo:m_title_get_role_titles_toc):void {
			if (mediator) {
				mediator.myDetailCase.updateMyTitles(vo);
			}
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
			mediator.myDetailCase.update();
		}

		private function setEquipItem(equip:p_goods):void {
			//由于在穿装备时，背包模块消息先到，角色模块身上数据后到，就导致背包窗口的提示出现问题，所以在此处强制更新人物身上数据
			RoleStateDateManager.setEquipItem(equip);
		}

		public function onPKModeChange(vo:m_role2_pkmodemodify_toc):void {
			mediator.stateCase.updateAttackMode(vo);
		}

		public function onLevelUp(vo:m_role2_levelup_toc):void {
			mediator.stateCase.onLevelUp(vo);
			updateMine();
			dispatch(ModuleCommand.ROLE_LEVEL_UP);
		}

		public function updateActor(vo:m_map_update_actor_mapinfo_toc):void {
			if (GlobalObjectManager.getInstance().user.base.role_id == vo.actor_id && vo.actor_type == SceneUnitType.ROLE_TYPE) { //自己的PKpoint
				GlobalObjectManager.getInstance().user.base.pk_points=vo.role_info.pk_point;
				updateMine();
			}
			if (mediator) {
				mediator.stateCase.onUpdateSelected(vo);
			}
		}

		private function onFiveEveChangeTos(npcLinkVO:NpcLinkVO):void {
			var vo:m_role2_five_ele_attr_tos=new m_role2_five_ele_attr_tos;
			vo.type=1;
			this.sendSocketMessage(vo);

		}

		public function lookDetail(roleId:int):void
		{
			var vo:m_role2_getroleattr_tos=new m_role2_getroleattr_tos;
			vo.role_id=roleId;
			send(vo);
		}
		
		public function onFiveEveChange(vo:m_role2_five_ele_attr_toc):void {
			if (vo.succ) {
				if (GlobalObjectManager.getInstance().user.attr.five_ele_attr == 0) {
					BroadcastSelf.getInstance().appendMsg("恭喜你，获得五行属性！");
				} else {
					BroadcastSelf.getInstance().appendMsg("恭喜你，重洗五行属性成功！");
				}
				GlobalObjectManager.getInstance().user.attr.five_ele_attr=vo.five_ele_attr;
				dispatch(ModuleCommand.UPDATE_FIVE);
			} else {
				BroadcastSelf.getInstance().appendMsg(vo.reason)
			}
		}

		public function onPKPointLeft(vo:m_role2_pkpoint_left_toc):void {
			mediator.myDetailCase.onPKPointLeft(vo);
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
			mediator.stateCase.showSelected(obj);
		}

		public function onDeadOrLive(isAlive:Boolean):void {
			mediator.stateCase.onDeadAlive(isAlive);
		}

		public function onAttrChange(vo:m_role2_attr_change_toc):void {
			var pvo:p_role=GlobalObjectManager.getInstance().user;
			for (var i:int=0; i < vo.changes.length; i++) {
				var cvo:p_role_attr_change=vo.changes[i] as p_role_attr_change;
				switch (cvo.change_type) {
					case 1:
						pvo.fight.hp=cvo.new_value;
						if (pvo.attr.level < 25) { //隐藏膏药
							if (pvo.fight.hp / pvo.base.max_hp > 0.5) {
								dispatch(GuideConstant.HP_DOWN_TIP_HIDE);
							}
						}
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
								this.dispatch(ModuleCommand.BROADCAST, "获得经验 " + (cvo.new_value - pvo.attr.exp));
//								Tips.getInstance().addTipsMsg("获得经验 " + (cvo.new_value - pvo.attr.exp));
							}
						}
						if (cvo.new_value - pvo.attr.exp > 0) {
							var c:Sprite=UnitPool.getMyRole().topEffectLayer;
							if (c) {
								DamageEffect.getEffect().showExp(c, new Point(0, -85), cvo.new_value - pvo.attr.exp, 30);
							}
							//this.dispatch(ModuleCommand.BROADCAST, "获得 " + (cvo.new_value - pvo.attr.exp) + "经验。");
							BroadcastSelf.getInstance().appendMsg("获得" + (cvo.new_value - pvo.attr.exp) + "经验。");
						}
						pvo.attr.exp=cvo.new_value;
						dispatch(ModuleCommand.EXP_CHAGNGE);
						break;
					case 6: //银子
						pvo.attr.silver=cvo.new_value;
						dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
						//告诉背包sengToPackage
						break;
					case 7: //绑定银子
						pvo.attr.silver_bind=cvo.new_value;
						dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
						//告诉背包sengToPackage
						break;
					case 8: //改变元宝
						pvo.attr.gold=cvo.new_value;
						dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
						//告诉背包sengToPackage
						break;
					case 9: //绑定元宝
						pvo.attr.gold_bind=cvo.new_value;
						dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
						break;
					case 10: //精力值
						pvo.fight.energy=cvo.new_value;

						if (cvo.new_value <= 0) {
							BroadcastModule.getInstance().popup("你今天的精力值已经用完，继续打怪只能获得1经验。", HtmlUtil.font("补充精力值", "#00ff00"), mediator.myDetailCase.openAddEnergy, null, 0);
						}
						break;
					case 11: //战功
						if (cvo.new_value - pvo.attr.gongxun > 0) {
							var sp:Sprite=UnitPool.getMyRole().topEffectLayer;
							if (sp) {
								DamageEffect.getEffect().showZhangong(sp, new Point(0, -85), cvo.new_value - pvo.attr.gongxun, 30);
							}
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
						//ActivityModel.getInstance().actpointChange(cvo.new_value);
						//						sendToModel([ModelConstant.ACTIVITY_MODEL],RoleStateMap_M.ROLE_ACT_POINT_CHANGE)
						break;
					// 昨天精力值剩余
					case 16:
						pvo.fight.energy_remain=cvo.new_value;
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
			mediator.stateCase.toChangeAttackMode(mode);
		}

		public function onEquipUnload(equip_id:int):void {
			var equip:EquipVO=RoleStateDateManager.getEquipById(equip_id);
			RoleStateDateManager.unLoadEquip(equip_id); //从attr里去掉这个装备的数据
			mediator.myDetailCase.update();
		}

		public function showPutEquipTask(index:int):void {
			onOpenMyDetail();
			mediator.myDetailCase.flashEquipItem(4);
		}

		public function showPropretyTask():void {
			onOpenMyDetail(1);
			mediator.myDetailCase.flashProprety();
		}

		public function getMyDetailView():MyDetailView {
			return mediator.myDetailCase.theView
		}

		public function getBuffBox():RoleBuffView {
			return mediator.stateCase.buffBox;
		}

		public function sendToSkillTree():void {
			this.dispatch(ModuleCommand.ROLE_REMAIN_POINT_CHANGE);
		}

		public function openChangeSex(link:NpcLinkVO=null):void {
			mediator.changeSexCase.show();
		}

		public function changeSexResult(vo:m_role2_sex_toc):void {
			mediator.changeSexCase.changeSexResult(vo);
		}


		public function openChangeHair(link:NpcLinkVO=null):void {
			mediator.changeHairCase.show();
		}

		public function changeHairResult(vo:m_role2_hair_toc):void {
			mediator.changeHairCase.onChangeHair(vo);
		}

		public function onChangeFace(vo:m_role2_head_toc):void {
			mediator.changeHairCase.onChangeFace(vo);
		}

		public function updatePKPoint():void {
			mediator.myDetailCase.update();
		}


		public function changeHairRequest(vo:m_role2_hair_tos):void {
			this.sendSocketMessage(vo);
		}

		public function changeFaceRequest(vo:m_role2_head_tos):void {
			this.sendSocketMessage(vo);
		}

		public function changeSexRequest(vo:m_role2_sex_tos):void {
			this.sendSocketMessage(vo);
		}

		private function onRoleAttrReload(vo:m_role2_attr_reload_toc):void {
			GlobalObjectManager.getInstance().user.attr=vo.role_attr;
			mediator.updateMine();
			mediator.sendToSkillTree();
			FamilySkillModule.getInstance().familyInfoUpdata();
			this.dispatch(ModuleCommand.PACKAGE_MONEY_CHANGE);
			this.dispatch(ModuleCommand.EXP_CHAGNGE);
		}

		private function onRoleBaseReload(vo:m_role2_base_reload_toc):void {
			GlobalObjectManager.getInstance().user.base=vo.role_base;
			mediator.updateMine();
		}

		private function onRoleReload(vo:m_role2_reload_toc):void {
			GlobalObjectManager.getInstance().user.base=vo.role_base;
			GlobalObjectManager.getInstance().user.attr=vo.role_attr;
			mediator.updateMine();
			mediator.checkEndurance(vo.role_attr.equips);
			mediator.sendToSkillTree();
		}

		// add by handing @2011.4.21 - 11.28
		private function checkEndurance():void {
			//检测武器的耐久度
			mediator.checkEndurance(GlobalObjectManager.getInstance().user.attr.equips);
		}

		private function onShowCloth(vo:Message):void {
			GlobalObjectManager.getInstance().user.attr.show_cloth=m_role2_show_cloth_toc(vo).show_cloth;
		}

		private function onShowEquipRing(vo:m_role2_show_equip_ring_toc):void {
			GlobalObjectManager.getInstance().user.attr.show_equip_ring=(vo.succ && vo.show_equip_ring);
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.ENTER_GAME, initView);
			addMessageListener(ModuleCommand.OPEN_OR_CLOSE_MY_DETAIL, onOpenCloseMyDetail);
			addMessageListener(ModuleCommand.ROLE_OPEN_MY_DETAIL, onOpenMyDetail);
			addMessageListener(ModuleCommand.OPEN_OTHER_DETAIL, onOpenOtherDetail);
			addMessageListener(ModuleCommand.UPDATE_BLOOD, updateMine);
			addMessageListener(ModuleCommand.SHOW_SELECTED_ONE, showSelectedRole);
			addMessageListener(ModuleCommand.MORAL_VALUE_CHANGED, updateMine);
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, changeAttackModeWhenMapEnter);
			addMessageListener(ModuleCommand.ROLE_CHANGE_ATTACK_MODE, toChangeAttackMode);
			addMessageListener(ModuleCommand.FAMILY_CHANGED, updateMine);
			addMessageListener(ModuleCommand.OPEN_ROLE_ATTR_PANEL, openRoleAttrPanel);
			//add by handing @2011.4.21 - 11.25
//			addMessageListener(ModuleCommand.ENTER_GAME, checkEndurance);
			addMessageListener(ModuleCommand.EQUIP_CHECK_ENDURANCE, checkEndurance);
			//装备耐久度更新
			addMessageListener(ModuleCommand.EQUIP_ENDURACE_CHANGED, onEnduraceChanged);
			addMessageListener(ModuleCommand.EQUIP_CHANGED, setEquipItem);
			addMessageListener(ModuleCommand.ROLE_DEAD_ALIVE, onDeadOrLive);
			addMessageListener(NPCActionType.NA_56, openChangeSex);
			addMessageListener(NPCActionType.NA_56, openChangeSex);
			addMessageListener(ModuleCommand.ROLE_UPDATE_SEX, updateMine);
			addMessageListener(NPCActionType.NA_77, openChangeHair);
			addMessageListener(NPCActionType.NA_77, openChangeHair);
			addMessageListener(ModuleCommand.ROLE_PKPOINT_CHANGE, updatePKPoint);
			addMessageListener(ModuleCommand.ROLE_MONUT_PERIOD_CHANGE, updateMount);
			addMessageListener(NPCActionType.NA_57, onFiveEveChangeTos); //人物五行属性
			addMessageListener(ModuleCommand.PRESTIGE_CHANGED,onPresitgeChanged);

			addSocketListener(SocketCommand.ROLE2_ATTR_CHANGE, onAttrChange);
			addSocketListener(SocketCommand.MAP_ENTER, updateMine);



			addSocketListener(SocketCommand.ROLE2_ATTR_RELOAD, onRoleAttrReload);
			addSocketListener(SocketCommand.ROLE2_BASE_RELOAD, onRoleBaseReload);
			addSocketListener(SocketCommand.ROLE2_RELOAD, onRoleReload);
			addSocketListener(SocketCommand.ROLE2_POINTASSIGN, onAddRoleProperty);
			addSocketListener(SocketCommand.ROLE2_GETROLEATTR, onOpenOtherDetail);
			addSocketListener(SocketCommand.ROLE2_PKMODEMODIFY, onPKModeChange);
			addSocketListener(SocketCommand.ROLE2_LEVELUP, onLevelUp);
			addSocketListener(SocketCommand.MAP_UPDATE_ACTOR_MAPINFO, updateActor);
			addSocketListener(SocketCommand.ROLE2_FIVE_ELE_ATTR, onFiveEveChange); //人物五行属性
			addSocketListener(SocketCommand.ROLE2_SHOW_CLOTH, onShowCloth);
			addSocketListener(SocketCommand.ROLE2_SHOW_EQUIP_RING, onShowEquipRing);
			addSocketListener(SocketCommand.ROLE2_PKPOINT_LEFT, onPKPointLeft);
			addSocketListener(SocketCommand.ROLE2_RELIVE, onRelive);
			addSocketListener(SocketCommand.TITLE_GET_ROLE_TITLES, updateMyTitles);

			addSocketListener(SocketCommand.TITLE_CHANGE_CUR_TITLE, onCurrentTitle);
			addSocketListener(SocketCommand.ROLE2_EXP_FULL, MessageIconManager.getInstance().showExpFullIcon);
			addSocketListener(SocketCommand.ROLE2_HAIR, changeHairResult);
			addSocketListener(SocketCommand.ROLE2_HEAD, onChangeFace);
			addSocketListener(SocketCommand.ROLE2_SEX, changeSexResult);
			addSocketListener(SocketCommand.ROLE2_EXP_FULL, onExpFull);
			addSocketListener(SocketCommand.ROLE2_ADD_ENERGY, onAddEnergy);

		}

		private function onPresitgeChanged():void{
			mediator.myDetailCase.theView.updatePrestige();	
		}
		
		private function onAddEnergy(vo:m_role2_add_energy_toc):void {
			mediator.myDetailCase.onAddEnergyRtn(vo);
		}

		private function onExpFull(vo:m_role2_exp_full_toc):void {
			mediator.onExpFull(vo);
		}

		private function changeAttackModeWhenMapEnter():void {
			if (SceneDataManager.isRobKingMap == true) {
				toChangeAttackMode(3);
			}
			showSelectedRole({see: false}); //切地图去掉头像
		}

		public function showPutEquipTaskBounds(index:int=3):void {
			showPutEquipTask(index);
		}

		public function showTaskBounds():void {
			showPropretyTask();
		}

		public function send(vo:Message):void {
			sendSocketMessage(vo);
		}

		public function get myDetailView():MyDetailView {
			return getMyDetailView();
		}

		public function get buffBox():RoleBuffView {
			return getBuffBox();
		}

		public function showExtDetail():void {
			mediator.onOpenMyDetail(1);
		}

		public static function getInstance():RoleStateModule {
			if (_instance == null) {
				_instance=new RoleStateModule();
			}
			return _instance;
		}
	}
}