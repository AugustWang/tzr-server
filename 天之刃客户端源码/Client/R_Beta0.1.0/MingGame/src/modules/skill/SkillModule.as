package modules.skill {
	import com.common.GlobalObjectManager;
	import com.common.cursor.CursorManager;
	import com.common.cursor.CursorName;
	import com.components.cooling.CoolingManager;
	import com.ming.managers.ToolTipManager;
	import com.scene.GameScene;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Animal;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.SceneCheckers;
	import com.scene.sceneUtils.SceneUnitType;
	import com.utils.HtmlUtil;
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.buff.BuffModule;
	import modules.mypackage.PackageModule;
	import modules.navigation.NavigationModule;
	import modules.pet.PetDataManager;
	import modules.roleStateG.RoleStateDateManager;
	import modules.scene.SceneModule;
	import modules.scene.cases.FightCase;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;
	import modules.skillTree.views.items.SkillTooltip;
	import modules.system.SystemConfig;
	import modules.team.TeamModule;
	
	import mx.core.mx_internal;
	
	import proto.common.p_actor_buf;
	import proto.common.p_role;
	import proto.line.p_team_role;

	public class SkillModule extends BaseModule {

		private var onHookIndex:int;
		private var user:p_role;

		public function SkillModule() {
			init();
		}

		private static var instance:SkillModule;

		public static function getInstance():SkillModule {
			if (instance == null) {
				instance=new SkillModule();
			}
			return instance;
		}

		private function init():void {
			ToolTipManager.registerToolTip(SkillConstant.SKILL_TREE_TIP, SkillTooltip);
		}

		override protected function initListeners():void {
			addMessageListener("SKILL_BUFF_ANTI_STEALTH", antiStealth);
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
		}

		private function onEnterGame():void {
			user=GlobalObjectManager.getInstance().user;
		}

		/**
		 * 反隐形
		 * @param value
		 */
		public function antiStealth(value:Boolean):void {
			RoleStateDateManager.isAntiStealth=value;
			for (var i:String in SceneUnitManager.roleHash) {
				if (SceneUnitManager.roleHash[i] is MyRole)
					continue;
				if (SceneUnitManager.roleHash[i] is Role) {
					SceneUnitManager.roleHash[i].conceal(SceneUnitManager.roleHash[i].isConceal, value);
				}
			}
		}

		public function showError(value:int, skill:SkillVO=null):void {
			var s:String;
			switch (value) {
				case SkillConstant.SKILL_NO_CD:
					s='技能未冷却，无法使用技能！';
					break;
				case SkillConstant.SKILL_NO_MP:
					s='内力值不足，无法使用技能！';
					break;
				case SkillConstant.SKILL_NO_TARGET:
					s='目标无法使用该技能';
					break;
				case SkillConstant.SKILL_NO_WEAPON:
					if (skill.category == 1)
						s="需要装备武器:<font color='#FF0000'>刀</font>";
					if (skill.category == 2)
						s="需要装备武器:<font color='#FF0000'>弓</font>";
					if (skill.category == 3)
						s="需要装备武器:<font color='#FF0000'>扇</font>";
					if (skill.category == 4)
						s="需要装备武器:<font color='#FF0000'>杖</font>";
					break;
			}
			BroadcastSelf.getInstance().appendMsg(s);
		}

		/**
		 * 自动挂机技能
		 * 返回一个目标，一个技能。target==""就是当前目标,target==自己role_id就是自己。
		 * @return
		 *
		 */

		public function onHookSkill(target:MutualAvatar):Object {
			var myUnitKey:String = SceneUnitType.ROLE_TYPE + "_" +GlobalObjectManager.getInstance().user.attr.role_id;
			var skills:Array=SystemConfig.skills;
			if (skills[0] == null && skills[1] == null && skills[2] == null && skills[3] == null && skills[4] == null) {
				return null;
			}
			var index:int=onHookIndex
			for (var loop:int=0; loop < 5; loop++) {
				index++;
				if (index > 4)
					index=0;
				var skillVO:SkillVO=skills[index] as SkillVO;
				if (skillVO == null || SkillMethods.checkSkill(skillVO) != SkillConstant.SKILL_OK) {
					continue;
				}
				if (skillVO.category == SkillConstant.CATEGORY_LIFE || skillVO.category == SkillConstant.CATEGORY_FAMILY) { //忽略生活技能
					continue;
				}
				//如果物理攻击则直接对所选目标使用
				if (skillVO.is_common_phy == 1 || skillVO.sid == 31104002 || skillVO.sid == 31104003) { //点穴和内力的特殊处理
					if (SkillMethods.checkTarget(skillVO, target)) {
						onHookIndex=index;
						return {targetKey: target.unitKey, skillVO: skillVO}
					}
					continue;
				}
				//如果不是物理攻击的
				var skillItem:SkillLevelVO=skillVO.levels[skillVO.level - 1] as SkillLevelVO;
				if (skillItem.buff.length > 0) {
					var buffID:int=skillItem.buff[0].buff_id;
					var buffs:Array=user.base.buffs;
					var hp:Number=user.fight.hp / user.base.max_hp;
					//检测自己的BUFF和血
					if (skillVO.sid == 41102001) {
						if (SystemConfig.hp + 0.05 > hp) {
							onHookIndex=index;
							return {targetKey: myUnitKey, skillVO: skillVO};
						}
					} else {
						if (!BuffModule.checkHasBuff(buffID, buffs)) {
							onHookIndex=index;
							return {targetKey: myUnitKey, skillVO: skillVO};
						}
					}
					var members:Array=TeamModule.getInstance().members;
					var l:int=members.length;
					if(skillVO.effect_type == SkillConstant.EFFECT_TYPE_FRIEND_ROLE || skillVO.effect_type == SkillConstant.EFFECT_TYPE_FRIEND){
						for (var i:int=0; i < l; i++) {
							var ptr:p_team_role=members[i] as p_team_role;
							var member:IRole=SceneUnitManager.getUnit(ptr.role_id) as IRole;
							if (member != null) {
								buffs=member.pvo.state_buffs;
								hp=member.pvo.hp / member.pvo.max_hp;
								if (skillVO.sid == 41108001){
									if(Animal(member).isDead){
										return {targetKey: SceneUnitManager.getUnit(ptr.role_id).unitKey, skillVO: skillVO};
									}
								}
								if (skillVO.sid == 41102001) {
									if (SystemConfig.hp + 0.05 > hp) {
										onHookIndex=index;
										return {targetKey: SceneUnitManager.getUnit(ptr.role_id).unitKey, skillVO: skillVO};
									}
								} else {
									if (!BuffModule.checkHasBuff(buffID, buffs)) {
										onHookIndex=index;
										return {targetKey: SceneUnitManager.getUnit(ptr.role_id).unitKey, skillVO: skillVO};
									}
								}
							}
						}
					}
				} else { //不带物理攻击切不带BUFF的技能
					return null;
				}
			}
			return null;
		}

		public function skillToTarget($target:IMutualUnit):void {
			if (SkillDataManager.chooseSkill) {
				SkillDataManager.currentSkill=SkillDataManager.chooseSkill;
				SkillDataManager.currentSkillTraget=MutualAvatar($target);
				SkillDataManager.chooseSkill=null;
			}
			var obj:Object=filterSkill($target);
			if (obj != null) {
				var skillVO:SkillVO=obj.skillVO;
				var targetKey:String=obj.targetKey;
				var point:Point=obj.point;
				if (skillVO.kind == SkillConstant.KIND_NEGATIVE && skillVO.target_type != SkillConstant.TARGET_TYPE_SELF && skillVO.target_type != SkillConstant.TARGET_TYPE_SELF_AROUND) {
					FightCase.getInstance().attackTargetKey=targetKey;
				}
				SceneUnitManager.getSelf().runAndHit(targetKey, skillVO, point);
			}
		}
		
		private var coolTimeKey:int;
		public function filterSkill($target:IMutualUnit):Object {
			var target:MutualAvatar=MutualAvatar($target);
			if (SkillDataManager.currentSkill != null && (SkillDataManager.currentSkillTraget != null || SkillDataManager.
				currentSkill.target_type == SkillConstant.TARGET_TYPE_AREA_MAP)) {
				if (SkillMethods.checkSkill(SkillDataManager.currentSkill) == SkillConstant.SKILL_OK) {
					if (SkillDataManager.currentSkill.target_type == SkillConstant.TARGET_TYPE_AREA_MAP) {
						return {targetKey: "", skillVO: SkillDataManager.currentSkill, point: new Point(GameScene.getInstance().
									midLayer.mouseX, GameScene.getInstance().midLayer.mouseY)};
					}
					if (SkillMethods.checkTarget(SkillDataManager.currentSkill, SkillDataManager.currentSkillTraget)) {
						return {targetKey: SkillDataManager.currentSkillTraget.unitKey, skillVO: SkillDataManager.currentSkill};
					}
					if (!SceneCheckers.checkIsEnemy(SkillDataManager.currentSkillTraget)) {
						return null;
					}
				}
			}
			//自动技能，在攻击怪物的时候，自动切换技能
			if(SystemConfig.autoSkill){
				var obj:Object=onHookSkill(MutualAvatar($target));
				if (obj != null)
					return obj;
			}
//			if (SystemConfig.open && SystemConfig.autoSkill) {
//				var obj:Object=onHookSkill(MutualAvatar($target));
//				if (obj != null)
//					return obj;
//			}
			if (SkillDataManager.autoSkill != null) {
				if (SkillMethods.checkSkill(SkillDataManager.autoSkill) == SkillConstant.SKILL_OK && SkillMethods.checkTarget(SkillDataManager.
					autoSkill, target)) {
					return {targetKey: $target.unitKey, skillVO: SkillDataManager.autoSkill};
				}
			}
			if (!SkillMethods.isCooling(SkillModule.getInstance().getNormalSkill())){
				return {targetKey: $target.unitKey, skillVO:SkillModule.getInstance().getNormalSkill() };
			}else{
				if(SystemConfig.open){
				}else{
					FightCase.getInstance().attackTargetKey=$target.unitKey;
					return null;
				}
			}
			return null;
		}

		public function useSkillFormNavbar(sid:int, type:String):void {
			var skillVO:SkillVO=SkillDataManager.getSkill(sid);
			if (skillVO.category == PetDataManager.petTroopIn || skillVO.category == PetDataManager.petTroopOut) {
				//如果是宠物技能
				PetDataManager.useTroopHit=true;
				return;
			}
			if (skillVO.category == SkillConstant.CATEGORY_LIFE) {
				useLifeSkill(skillVO.sid);
				return;
			}
			var skillItem:SkillLevelVO=skillVO.levels[skillVO.level - 1] as SkillLevelVO;
			if (skillItem.cooldown > 2000) {
				useSkill(skillVO);
				return;
			}
			if (RoleStateDateManager.seletedUnit) {
				if (type == 'mouse' && SkillDataManager.autoSkill) {
					if (skillVO.sid == SkillDataManager.autoSkill.sid) {
						autoSkill=null;
						useSkill(getNormalSkill());
						return;
					}
				}
				autoSkill=skillVO;
				useSkill(skillVO);
			} else {
				if (skillVO.isSelectAuto) {
					autoSkill=null;
				} else {
					autoSkill=skillVO;
				}
			}
		}

		/**
		 * 使用技能
		 * @param id
		 */
		public function useSkill(skillVO:SkillVO):void {
			var skillItem:SkillLevelVO=skillVO.levels[skillVO.level - 1] as SkillLevelVO;
			var status:int=SkillMethods.checkSkill(skillVO);
			if (status == SkillConstant.SKILL_OK) {
				if (skillVO.effect_type == SkillConstant.EFFECT_TYPE_SELF || skillVO.target_type == SkillConstant.TARGET_TYPE_SELF_AROUND) {
					SkillDataManager.currentSkill=skillVO;
					SkillDataManager.currentSkillTraget=SceneUnitManager.getSelf();
					skillToTarget(SkillDataManager.currentSkillTraget);
					return;
				}
				if (skillVO.target_type == SkillConstant.TARGET_TYPE_AREA_MAP) {
					selectTarget(skillVO);
					return;
				}
				if (RoleStateDateManager.seletedUnit == null) {
					if (skillItem.cooldown > 2000) {
						selectTarget(skillVO);
					}
				} else {
					var target:MutualAvatar=MutualAvatar(SceneUnitManager.getUnitByKey(RoleStateDateManager.seletedUnit.
						key));
					if (SkillMethods.checkTarget(skillVO, target)) {
						SkillDataManager.currentSkill=skillVO;
						SkillDataManager.currentSkillTraget=target;
						skillToTarget(target);
					} else {
						if (skillItem.cooldown > 2000)
							selectTarget(skillVO);
					}
				}
			} else {
				showError(status, skillVO);
			}
		}

		public function useLifeSkill(id:int):void {
			switch (id) {
				case SkillConstant.LIFE_SKILL_MOUNT:
					PackageModule.getInstance().mountFromHotKey();
					break;
				case SkillConstant.LIFE_SKILL_AUTO:
					SceneModule.getInstance().toAutoHitMonster();
					break;
			}
		}

		/**
		 * 设置自动技能
		 * @param skill
		 */
		public function set autoSkill(skill:SkillVO):void {
			if (SkillDataManager.autoSkill) {
				if (skill != null && SkillDataManager.autoSkill.sid != skill.sid && skill.name != null) {
					BroadcastSelf.getInstance().appendMsg("你当前使用 " + HtmlUtil.font(skill.name, "#3be450") + " 作为默认技能，使用鼠标左键单击停止释放。");
				}
			}
			if (SkillDataManager.autoSkill != null) {
				SkillDataManager.autoSkill.isSelectAuto=false;
			}
			if (skill != null) {
				skill.isSelectAuto=true;
			}
			SkillDataManager.autoSkill=skill;
			NavigationModule.getInstance().updateHotBar();
			//更新自动技能
			if (NavigationModule.getInstance().navBar != null) {
				NavigationModule.getInstance().navBar.upgoodsBox.updataSkillAutoStatus();
				NavigationModule.getInstance().navBar.downgoodsBox.updataSkillAutoStatus();
			}
		}

		/**
		 * 取各系普通攻击
		 */
		public function getNormalSkill():SkillVO {
			switch (GlobalObjectManager.getInstance().user.base.weapon_type) {
				case SkillConstant.NO_EQUIP:
				case SkillConstant.WARRIOR_EQUIP:
					return SkillDataManager.getSkill(1);
					break;
				case SkillConstant.RANGER_EQUIP:
				case SkillConstant.PRIEST_EQUIP:
					return SkillDataManager.getSkill(5);
					break;
				case SkillConstant.ARCHER_EQUIP:
					return SkillDataManager.getSkill(2);
					break;
				default:
					return SkillDataManager.getSkill(1);
					break;
			}
		}

		/**
		 * 开始CD
		 * @param data
		 *
		 */
		public function coolDownStart(id:int):void {
			var skillvo:SkillVO=SkillDataManager.getSkill(id);
			if (skillvo) {
				var skillItem:SkillLevelVO=skillvo.levels[skillvo.level - 1] as SkillLevelVO;
				if (skillItem){
					var cooldown:int;
					if (skillItem.cooldown < 2000) {
						cooldown=skillItem.cooldown / (GlobalObjectManager.getInstance().user.base.attack_speed * 0.001)
					} else {
						cooldown=skillItem.cooldown;
					}
					CoolingManager.getInstance().startCooling(skillvo.typeId, cooldown);
				}
			}
		}

		/**
		 * 推荐自动挂机技能
		 * @return
		 *
		 */
		public function getRecommend():Array {
			var prioritys:Array=[];
			var skills:Array=SkillDataManager.getSkills();
			for (var i:int; i < skills.length; i++) {
				var skill:SkillVO=skills[i] as SkillVO;
				if (skill.level > 0 && skill.priority != 0) {
					prioritys.push(skill);
				}
			}
			prioritys.sort(prioritysSortFun);
			prioritys.reverse();
			if (prioritys.length > 5) {
				var prioritysTemp:Array=prioritys.slice(prioritys.length - 5, prioritys.length); //挑选出来的5个技能
				var priority_one:Array=[]; //单体攻击
				var proority_notOne:Array=[];
				while (prioritysTemp.length != 0) {
					skill=SkillVO(prioritysTemp.pop());
					if (skill.is_common_phy == 1 && skill.effect_type == 3 && skill.target_type == 4) {
						priority_one.push(skill);
					} else {
						proority_notOne.push(skill);
					}
				}

				if (priority_one.length == 0) { //在其他技能里面选一个单体攻击技能
					for (var j:int=0; j < prioritys.length - 5; j++) {
						skill=SkillVO(prioritys[j]);
						if (skill.is_common_phy == 1 && skill.effect_type == 3 && skill.target_type == 4) {
							proority_notOne.pop();
							proority_notOne.push(skill);
							break;
						}
					}
				}
				if (priority_one.length > 1) {
					proority_notOne.push(priority_one[0]);
				}
				proority_notOne.reverse();
				return proority_notOne;
			}
			if (prioritys.length < 5) {
				while (prioritys.length > 4) {
					prioritys.push(null);
				}
				return prioritys;
			}
			return prioritys;
		}

		/**
		 * 推荐自动挂机技能等级
		 */
		private function prioritysSortFun(valueA:SkillVO, valueB:SkillVO):int {
			if (valueA.priority < valueB.priority) {
				return 1;
			} else if (valueA.priority > valueB.priority) {
				return -1;
			} else if (valueA.category < valueB.category) {
				return -1;
			} else if (valueA.category > valueB.category) {
				return 1;
			} else {
				return 0;
			}
		}

		public function selectTarget(skillVO:SkillVO):void {
			SkillDataManager.chooseSkill=skillVO;
			CursorManager.getInstance().setCursor(CursorName.SELECT_TARGET);
			CursorManager.getInstance().enabledCursor=false;
		}
	}
}