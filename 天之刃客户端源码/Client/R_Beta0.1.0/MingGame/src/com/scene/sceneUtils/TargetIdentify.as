package com.scene.sceneUtils
{
	import com.common.GlobalObjectManager;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	
	import modules.roleStateG.AttackModeContant;
	import modules.roleStateG.RoleStateDateManager;
	import modules.roleStateG.SeletedRoleVo;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_map_role;
	import proto.common.p_map_ybc;
	import proto.common.p_role;
	import proto.common.p_role_base;
	
	public class TargetIdentify
	{
		
		public function TargetIdentify():void
		{
			
		}
		
		/**
		 * 判断是否能施放技能
		 * @param tar
		 * @param skill
		 * @return
		 *
		 */
		public static function checkAttack(tar:MutualAvatar, skill:SkillVO):Boolean
		{
			if (skill.target_type == SkillConstant.TARGET_TYPE_SELF_AROUND)
			{
				return true;
			}
			var fire:Boolean;
			var skillTarget:int=skill.effect_type;
			var isEnemy:Boolean;
			var pkMode:int=GlobalObjectManager.getInstance().attackMode;
			if (tar is Monster)
			{
				if (skillTarget == 3 || skillTarget == 5)
				{ //当前技能类型对敌方
					fire=true;
				}
				else
				{
					return false;
				}
				isEnemy=true;
			}
			else if (tar is YBC)
			{
				var base:p_role_base=GlobalObjectManager.getInstance().user.base;
				var yvo:p_map_ybc=YBC(tar).pvo;
				switch (pkMode)
				{
					case AttackModeContant.PEACE:
						isEnemy=false;
						break;
					case AttackModeContant.ALL:
						isEnemy=true;
						break;
					case AttackModeContant.TEAM:
						if (yvo.group_type == 3 && base.team_id == yvo.group_id)
						{
							isEnemy=false;
						}
						else
						{
							isEnemy=true;
						}
						break;
					case AttackModeContant.FAMILY:
						if (yvo.group_type == 2 && base.family_id == yvo.group_id)
						{
							isEnemy=false;
						}
						else
						{
							isEnemy=true;
						}
						break;
					case AttackModeContant.FACTION:
						if (base.faction_id != yvo.faction_id)
						{
							isEnemy=true;
						}
						break;
					case AttackModeContant.KINDEVIL:
						isEnemy=false;
						break;
				}
				if(YBC(tar).pvo.creator_id == GlobalObjectManager.getInstance().user.attr.role_id && YBC( tar ).pvo.group_type == 1){
					isEnemy=false;
				}
			}
			else if (tar is ServerNPC)
			{
				if (ServerNPC(tar).isDialogNPC())
				{
					isEnemy=false;
				}
				else
				{
					switch (pkMode)
					{
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
							if (ServerNPC(tar).pvo.npc_country != GlobalObjectManager.getInstance().user.base.faction_id)
							{
								isEnemy=true;
							}
							break;
						case AttackModeContant.KINDEVIL:
							isEnemy=false;
							break;
					}
				}
			}
			else if (tar is Pet)
			{
				isEnemy=SceneCheckers.checkIsEnemy(tar);
			}
			else if (tar is Role)
			{
				if (skill.effect_type == SkillConstant.EFFECT_TYPE_SELF && tar is MyRole)
				{
					return true;
				}
				var theSeleted:SeletedRoleVo=RoleStateDateManager.seletedUnit;
				var myVo:p_role=GlobalObjectManager.getInstance().user;
				var pvo:p_map_role=Role(tar).pvo;
				var targetKey:String=SceneUnitType.ROLE_TYPE + "_" + pvo.role_id;
				var isSelf:Boolean;
				if (myVo.base.role_id == pvo.role_id)
				{
					isEnemy=false;
					isSelf=true;
				}
				else
				{
					switch (GlobalObjectManager.getInstance().attackMode)
					{
						case AttackModeContant.PEACE: //不处理
							isEnemy=false;
							break;
						case AttackModeContant.ALL:
							isEnemy=true;
							break;
						case AttackModeContant.TEAM:
							if (myVo.base.team_id == 0 || pvo.team_id != myVo.base.team_id)
							{ //敌方
								isEnemy=true;
							}
							break;
						case AttackModeContant.FAMILY:
							if (myVo.base.family_id == 0 || pvo.family_id != myVo.base.family_id)
							{
								isEnemy=true;
							}
							break;
						case AttackModeContant.FACTION:
							if (myVo.base.faction_id == 0 || pvo.faction_id != myVo.base.faction_id)
							{
								isEnemy=true;
							}
							break;
						case AttackModeContant.KINDEVIL:
							if (pvo.gray_name == true || pvo.pk_point > 18)
							{
								isEnemy=true;
							}
							break;
						default:
							break;
					}
				}
			}
			if (isEnemy)
			{ //敌方
				if (skillTarget == 3 || skillTarget == 5)
				{ //当前技能类型对敌方
					fire=true;
				}
			}
			else
			{ //友方
				if ((skillTarget == 1 && isSelf == true) || skillTarget == 2 || skillTarget == 4)
				{ //当前技能类型对自己，友方使用
					fire=true;
				}
				if( skillTarget == 8 ){//镖车
					if( tar is YBC ){
						if(YBC(tar).pvo.creator_id == GlobalObjectManager.getInstance().user.attr.role_id && YBC( tar ).pvo.group_type == 1){
							fire=true;
						}
					}
				}
			}
			return fire;
		}
		
		//武器类型 1:刀,2:弓,3:杖,4:扇,5:特殊;
		public static function checkSkill():SkillVO
		{
			SkillDataManager.getSkill(1).level = 1;
			return SkillDataManager.getSkill(1);
		}
	}
}