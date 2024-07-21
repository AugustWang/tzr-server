package com.scene.sceneUtils {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.scene.sceneData.BinaryMath;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.tile.Pt;
	import com.utils.HtmlUtil;
	
	import modules.ModuleCommand;
	import modules.roleStateG.AttackModeContant;
	import modules.scene.SceneDataManager;
	
	import proto.common.p_map_role;
	import proto.common.p_map_ybc;
	import proto.common.p_role_base;

	public class SceneCheckers {

		//特殊地图的跳转点设置
		private static var turnKaiFeng:Object={11105: 1, 12105: 2, 13105: 3};
		private static var turnShenNongJia:Object={11000: 1, 12000: 2, 13000: 3};
		private static var turnFamily:Object={11100: 1, 12100: 2, 13100: 3};
		private static var turnFirstMissionFb:Object={11000: 1, 12000: 2, 13000: 3};
		private static var dictSpecialMap:Object={10200: turnKaiFeng, //开封
				10210: turnShenNongJia, //神农架
				10300: turnFamily, //门派地图
				10302: turnFirstMissionFb //第一个任务副本地图
			};

		public function SceneCheckers() {
		}

		/**
		 * 判断一个单位是不是敌人
		 * @param tar
		 * @return
		 *
		 */
		public static function checkIsEnemy(tar:MutualAvatar):Boolean {
			var isEnemy:Boolean;
			var base:p_role_base=GlobalObjectManager.getInstance().user.base;
			var pkMode:int=base.pk_mode;
			if (tar is Monster) {
				isEnemy=true;
			} else if (tar is Role && tar is MyRole == false && Role(tar).pvo != null) {
				var pvo:p_map_role=Role(tar).pvo;
				switch (pkMode) {
					case AttackModeContant.PEACE:
						isEnemy=false;
						break;
					case AttackModeContant.ALL:
						isEnemy=true;
						break;
					case AttackModeContant.TEAM:
						if (base.team_id == 0 || base.team_id != pvo.team_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FAMILY:
						if (base.family_id == 0 || base.family_id != pvo.family_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FACTION:
						if (base.faction_id != pvo.faction_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.KINDEVIL:
						if (pvo.gray_name == true || pvo.pk_point > 18) {
							isEnemy=true;
						}
						break;
				}
			} else if (tar is YBC) {
				var yvo:p_map_ybc=YBC(tar).pvo;
				switch (pkMode) {
					case AttackModeContant.PEACE:
						isEnemy=false;
						break;
					case AttackModeContant.ALL:
						if (yvo.group_type == 1 && yvo.creator_id == GlobalObjectManager.getInstance().user.attr.role_id) {
							isEnemy=false;
						} else {
							isEnemy=true;
						}
						break;
					case AttackModeContant.TEAM:
						if (yvo.group_type == 3 && base.team_id == yvo.group_id) {
							isEnemy=false;
						} else {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FAMILY:
						if (yvo.group_type == 2 && base.family_id == yvo.group_id) {
							isEnemy=false;
						} else {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FACTION:
						if (base.faction_id != yvo.faction_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.KINDEVIL:
						isEnemy=false;
						break;
				}
			} else if (tar is ServerNPC) {
				if (ServerNPC(tar).isDialogNPC()) {
					isEnemy=false;
				} else {
					switch (pkMode) {
						case AttackModeContant.PEACE:
							isEnemy=false;
							break;
						case AttackModeContant.ALL:
							isEnemy=true;
							break;
						case AttackModeContant.TEAM:
							isEnemy=true;
							break;
						case AttackModeContant.FAMILY:
							isEnemy=true;
							break;
						case AttackModeContant.FACTION:
							if (ServerNPC(tar).pvo.npc_country != base.faction_id) {
								isEnemy=true;
							}
							break;
						case AttackModeContant.KINDEVIL:
							isEnemy=false;
							break;
					}
				}
			} else if (tar is Pet && Pet(tar).pvo != null) {
				var mas:Role=SceneUnitManager.getUnit(Pet(tar).pvo.role_id) as Role;
				if (mas == null)
					return false;
				var rolevo:p_map_role=mas.pvo;
				switch (pkMode) {
					case AttackModeContant.PEACE:
						isEnemy=false;
						break;
					case AttackModeContant.ALL:
						isEnemy=true;
						break;
					case AttackModeContant.TEAM:
						if (base.team_id == 0 || base.team_id != rolevo.team_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FAMILY:
						if (base.family_id == 0 || base.family_id != rolevo.family_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.FACTION:
						if (base.faction_id != rolevo.faction_id) {
							isEnemy=true;
						}
						break;
					case AttackModeContant.KINDEVIL:
						if (rolevo.gray_name == true || rolevo.pk_point > 18) {
							isEnemy=true;
						}
						break;
				}
			}
			return isEnemy;
		}

		/**
		 * 检查跨不同区域
		 * @param pastPt
		 * @param newPt
		 *
		 */
		public static function checkArea(pastPt:Pt, newPt:Pt):void {
			var pastCell:int=SceneDataManager.getCell(pastPt.x, pastPt.z);
			var newCell:int=SceneDataManager.getCell(newPt.x, newPt.z);
			if (BinaryMath.isExist(pastCell) == false || BinaryMath.isExist(newCell) == false)
				return;
			var msg:String;
			if (BinaryMath.isArena(pastCell) != BinaryMath.isArena(newCell)) {
				msg=BinaryMath.isArena(newCell) == true ? "你已进入竞技区！" : "你已离开竞技区！";
				Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
				Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(msg, "#ff0000"));
			}
			if (BinaryMath.isSell(pastCell) != BinaryMath.isSell(newCell)) {
				msg=BinaryMath.isSell(newCell) == true ? "你已进入摆摊区！" : "你已离开摆摊区！";
				Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
				Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(msg, "#ff0000"));
			}
			if (BinaryMath.isSafe(pastCell) != BinaryMath.isSafe(newCell)) {
				if (GlobalObjectManager.getInstance().user.attr.level >= 10) {
					if (BinaryMath.isSafe(newCell) == true && BinaryMath.isAllSafe(newCell) == false) {
						if (ScenePtMath.isInNation == true) { //在国内
							msg="你已进入安全区！"; //相对
							Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
							Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(msg, "#ff0000"));
						}
					} else if (BinaryMath.isSafe(newCell) == true && BinaryMath.isAllSafe(newCell) == true) {
						msg="你已进入安全区！"; //绝对
						Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
						Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(msg, "#ff0000"));
					} else {
						if (BinaryMath.isSafe(pastCell) == true || ScenePtMath.isInNation == true) {
							msg="你已离开安全区！";
							Dispatch.dispatch(ModuleCommand.BROADCAST, msg);
							Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(msg, "#ff0000"));
						}
					}
				}
			}
		}

		public static function checkTurnPoint(pt:Pt):MacroPathVo {
			var turnArr:Vector.<MapTransferVo>=SceneDataManager.mapData.transfers;
			var mapid:int=SceneDataManager.mapData.map_id;
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			var myFaction:int=GlobalObjectManager.getInstance().user.base.faction_id;
			var jump:Boolean;
			var targetMap:MacroPathVo;
			for each (var i:MapTransferVo in turnArr) {
				if (i.tx == pt.x && i.ty == pt.z) {
					if (level < i.minLevel) {
						//i.minLevel + "级以上玩家才能跳转"
						Dispatch.dispatch(ModuleCommand.BROADCAST_SELF, HtmlUtil.font(i.minLevel + "级以上玩家才能跳转", "#ff0000"));
						continue;
					}

					if (mapid != i.tar_Map && i.tar_Map != 0) { //不是目的地不是本地图，
						var turnSpecialMap:Object=dictSpecialMap[mapid];
						if (turnSpecialMap) {
							if (turnSpecialMap[i.tar_Map] == null) {
								jump=true;
							} else {
								jump=turnSpecialMap[i.tar_Map] == myFaction;
							}
						} else {
							jump=true;
						}
					}

					if (jump == true) {
						targetMap=new MacroPathVo(i.tar_Map, new Pt(i.tar_tx, 0, i.tar_ty));
						return targetMap;
					}
				}
			}
			return null;
		}
	}
}