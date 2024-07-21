package modules.skill {
	import com.common.GlobalObjectManager;
	import com.components.cooling.CoolingManager;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.SceneCheckers;
	
	import modules.broadcast.views.BroadcastSelf;
	import modules.broadcast.views.Tips;
	import modules.mypackage.managers.PackManager;
	import modules.skill.vo.ConditionVO;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;


	public class SkillMethods {
		public function SkillMethods() {
		}

		public static function getSkill(target:MutualAvatar):SkillVO {
//			var isEnemy:Boolean = SceneUnitCheckers.checkIsEnemy(MutualAvatar);
//			if( SkillDataManager.currentSkill != null ){
//				if(checkSkill( SkillDataManager.currentSkill ) == SkillConstant.SKILL_OK){
//					if(checkTarget(MutualAvatar)){
//						return SkillDataManager.currentSkill;
//					}else{
//						//目标不适合这样的技能
//					}
//				}else{
//					//技能使用条件不适合
//				}
//			}
//			
//			if( SystemConfig.open && SystemConfig.autoSkill ){
//				var skillVO:SkillVO = SkillModule.getInstance().onHookSkill() as SkillVO;
//				if( skillVO != null){
//					return skillVO;
//				}
//			}
//			
			if (SkillDataManager.autoSkill != null) {
				if (checkSkill(SkillDataManager.autoSkill) == SkillConstant.SKILL_OK && checkTarget(SkillDataManager.autoSkill,
					target)) {
					return SkillDataManager.autoSkill
				}
			}

			return SkillModule.getInstance().getNormalSkill();
		}



		/**
		 * 检验技能是否可用
		 * @param skill
		 * @return
		 * 0 OK
		 * 1 CD未到
		 * 2 蓝不足
		 * 3 武器类型不符合
		 */
		public static function checkSkill(skill:SkillVO):int {
			if (isCooling(skill)) {
				return SkillConstant.SKILL_NO_CD;
			}
			if (!checkMP(skill)) {
				return SkillConstant.SKILL_NO_MP;
			}
			if (!checkWeaponType(skill)) {
				return SkillConstant.SKILL_NO_WEAPON;
			}
			return SkillConstant.SKILL_OK;
		}

		/**
		 * 检测CD
		 */
		public static function isCooling($skill:SkillVO):Boolean {
			return CoolingManager.getInstance().isCoolingByName($skill.typeId);
		}

		/**
		 * 检测武器
		 */
		public static function checkWeaponType($skill:SkillVO):Boolean {
			switch ($skill.category) {
				case 0:
					return true;
				case 1:
					return GlobalObjectManager.getInstance().user.base.weapon_type == SkillConstant.WARRIOR_EQUIP;
				case 2:
					return GlobalObjectManager.getInstance().user.base.weapon_type == SkillConstant.ARCHER_EQUIP;
				case 3:
					return GlobalObjectManager.getInstance().user.base.weapon_type == SkillConstant.RANGER_EQUIP;
				case 4:
					return GlobalObjectManager.getInstance().user.base.weapon_type == SkillConstant.PRIEST_EQUIP;
			}
			return true;
		}

		/**
		 * 检测蓝
		 */
		public static function checkMP($skill:SkillVO):Boolean {
			var skillItem:SkillLevelVO=$skill.levels[$skill.level - 1];
			return skillItem.consume_mp <= GlobalObjectManager.getInstance().user.fight.mp
		}

		/**
		 * 检测目标
		 */
		public static function checkTarget($skill:SkillVO, target:MutualAvatar):Boolean {
			if(target == null)return false;
			var effectType:int=$skill.effect_type;
			var targetType:int=$skill.target_type;
			if (targetType == SkillConstant.TARGET_TYPE_SELF || targetType == SkillConstant.TARGET_TYPE_SELF_AROUND){
				return true;
			}
			if (effectType == SkillConstant.EFFECT_TYPE_SELF || effectType == SkillConstant.EFFECT_TYPE_ALL) {
				return true;
			}
			if (SceneCheckers.checkIsEnemy(target)) { //敌方
				if (effectType == SkillConstant.EFFECT_TYPE_ENEMY || effectType == SkillConstant.EFFECT_TYPE_ENEMY_ROLE) {
					return true;
				}
			} else { //友方
				if (effectType == SkillConstant.EFFECT_TYPE_FRIEND || effectType == SkillConstant.EFFECT_TYPE_FRIEND_ROLE) {
					return true;
				}
				if (effectType == SkillConstant.EFFECT_TYPE_YBC) { //镖车
					if (target is YBC) {
						if (YBC(target).pvo.creator_id == GlobalObjectManager.getInstance().user.attr.role_id && YBC(target).
							pvo.group_type == 1) {
							return true;
						}
					}
				}
			}
			return false;
		}

		/**
		 *检测技能学习状态
		 */
		public static function checkLearnState(sid:int):int {
			var skillVO:SkillVO=SkillDataManager.getSkill(sid);
			if (skillVO.level == skillVO.max_level)
				return SkillConstant.CONDITION_MAXLEVEL;
			var cs:Array=skillVO.levels[skillVO.level].conditions;
			for (var i:int=0; i < cs.length; i++) {
				if (!ckeckCondition(cs[i] as ConditionVO, skillVO)) {
					switch (cs[i].name) {
						case "pre_role_level":
							return SkillConstant.CONDITION_DIS_ROLE_LEVEL;
						case "pre_skill":
							return SkillConstant.CONDITION_DIS_PRE_SKILL;
						case 'need_item':
							return SkillConstant.CONDITION_DIS_NEED_ITEM;
						case 'need_silver':
							return SkillConstant.CONDITION_DIS_NEED_SILVER;
						case 'consume_exp':
							return SkillConstant.CONDITION_DIS_EXP;
					}
				}
			}
			return SkillConstant.CONDITION_ACCORD;
		}

		/**
		 *检测技能的条件
		 */
		public static function ckeckCondition(c:ConditionVO, skillVO:SkillVO):Boolean {
			if (c.data == '' || c.data == "0")
				return true;
			switch (c.name) {
				case 'pre_role_level':
					if (int(c.data) > GlobalObjectManager.getInstance().user.attr.level)
						return false;
					break;
				case 'pre_skill':
					var temp:Array=c.data.split(',');
					for (var i:int=0; i < temp.length; i+=2) {
						if (SkillDataManager.getSkill(temp[i]).level < temp[i + 1])
							return false;
					}
					break;
				case 'need_item':
					if (PackManager.getInstance().getGoodsByType(int(c.data)).length == 0)
						return false;
					break;
				case 'need_silver':
					if (int(c.data) > (GlobalObjectManager.getInstance().user.attr.silver + GlobalObjectManager.getInstance().
						user.attr.silver_bind))
						return false;
					break;
				case 'consume_exp':
					if (Number(c.data) > GlobalObjectManager.getInstance().user.attr.exp)
						return false;
					break;
			}
			return true;
		}

		public static function checkLevel(sid:int):Boolean {
			var skillVO:SkillVO=SkillDataManager.getSkill(sid);
			var cs:Array=skillVO.levels[skillVO.level].conditions;
			var level:int = GlobalObjectManager.getInstance().user.attr.level;
			for (var i:int=0; i < cs.length; i++) {
				if (cs[i].name == 'pre_role_level') {
					if (int(cs[i].data) > level){
						return false;
					}
					return true;
				}
			}
			return true;
		}

		/**
		 *生成技能树的Tooltip
		 */
		public static function createTreeTip(skillVO:SkillVO):String {
			var s:String='';
			s=s.concat("<font color='#FFFFFF'size='14'><b>" + skillVO.name + "</b></font>\n");
			s=s.concat("<font color='#FFFFFF'>等级:" + skillVO.level + "/" + skillVO.max_level + "</font>\n");
			switch (skillVO.category) {
				case 1:
					s=s.concat("<font color='#FFFFFF'>需要装备武器:尺</font>\n");
					break;
				case 2:
					s=s.concat("<font color='#FFFFFF'>需要装备武器:剑</font>\n");
					break;
				case 3:
					s=s.concat("<font color='#FFFFFF'>需要装备武器:杖</font>\n");
					break;
				case 4:
					s=s.concat("<font color='#FFFFFF'>需要装备武器:</font>\n");
					break;
				case 5:
					s=s.concat("<font color='#FFFFFF'>需要装备武器:特殊</font>\n");
					break;
			}
			if (skillVO.is_common_phy == 1) {
				s=s.concat("<font color='#FFFFFF'>攻击距离:" + skillVO.distance + "</font>\n");
			} else {
				if (skillVO.effect_type == 1) {
					s=s.concat("<font color='#FFFFFF'>释放距离:自身</font>\n");
				} else {
					s=s.concat("<font color='#FFFFFF'>释放距离:" + skillVO.distance + "</font>\n");
				}
			}
			if (skillVO.level > 0) {
				if (skillVO.attack_type != 2) {
					s=s.concat("<font color='#FFFFFF'>冷却时间:" + skillVO.levels[skillVO.level - 1].cooldown * 0.001 + "秒</font>\n");
					s=s.concat("<font color='#FFFFFF'>消耗内力:" + skillVO.levels[skillVO.level - 1].consume_mp + "点</font>\n");
				}
				s=s.concat("<font color='#f2c802'>" + skillVO.levels[skillVO.level - 1].discription.toString().replace('\n',
					'') + "</font>\n");
			}
			if (skillVO.level < skillVO.levels.length) {
				s=s.concat("\n<font color='#FFFFFF'>下一等级:</font>\n");
				if (skillVO.attack_type != 2) {
					s=s.concat("<font color='#FFFFFF'>冷却时间:" + skillVO.levels[skillVO.level].cooldown * 0.001 + "秒</font>\n");
					s=s.concat("<font color='#FFFFFF'>消耗内力:" + skillVO.levels[skillVO.level].consume_mp + "点</font>\n");
				}
				s=s.concat("<font color='#f2c802'>" + skillVO.levels[skillVO.level].discription + "</font>\n\n");
			}
			if (skillVO.level != skillVO.max_level) {
				s=s.concat("<font color='#00FF00'>双击技能图标可升级</font>");
			}
			return s;
		}

		/**
		 *
		 */
		public static function createHotKeytip(skillVO:SkillVO):String {
			var s:String='';
			s=s.concat("<font color='#FFFFFF'size='14'><b>" + skillVO.name + "</b></font>\n");
			s=s.concat("<font color='#FFFFFF'>等级:" + skillVO.level + "/" + skillVO.max_level + "</font>\n");
			if (skillVO.category == SkillConstant.CATEGORY_LIFE) {
				s=s.concat("<font color='#f2c802'>" + skillVO.levels[skillVO.level - 1].discription + "</font>\n\n");
				return s;
			}
			switch (skillVO.category) {
				case SkillConstant.CATEGORY_WARRIOR:
					if (checkWeaponType(skillVO)) {
						s=s.concat("<font color='#FFFFFF'>需要装备武器:刀</font>\n");
					} else {
						s=s.concat("<font color='#FF0000'>需要装备武器:刀</font>\n");
					}
					break;
				case SkillConstant.CATEGORY_ARCHER:
					if (checkWeaponType(skillVO)) {
						s=s.concat("<font color='#FFFFFF'>需要装备武器:弓</font>\n");
					} else {
						s=s.concat("<font color='#FF0000'>需要装备武器:弓</font>\n");
					}
					break;
				case SkillConstant.CATEGORY_RANGER:
					if (checkWeaponType(skillVO)) {
						s=s.concat("<font color='#FFFFFF'>需要装备武器:扇</font>\n");
					} else {
						s=s.concat("<font color='#FF0000'>需要装备武器:扇</font>\n");
					}
					break;
				case SkillConstant.CATEGORY_PRIEST:
					if (checkWeaponType(skillVO)) {
						s=s.concat("<font color='#FFFFFF'>需要装备武器:杖</font>\n");
					} else {
						s=s.concat("<font color='#FF0000'>需要装备武器:杖</font>\n");
					}
					break;
			}
			if (skillVO.level > 0) {
				s=s.concat("<font color='#FFFFFF'>冷却时间:" + skillVO.levels[skillVO.level - 1].cooldown * 0.001 + "秒</font>\n");
				s=s.concat("<font color='#FFFFFF'>消耗内力:" + skillVO.levels[skillVO.level - 1].consume_mp + "点</font>\n");
				s=s.concat("<font color='#f2c802'>" + skillVO.levels[skillVO.level - 1].discription + "</font>\n");
			}
			return s;
		}

		public static function showError(msg:String):void {
			Tips.getInstance().addTipsMsg(msg)
			BroadcastSelf.getInstance().appendMsg(msg)
			return;
		}
	}
}