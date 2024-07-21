package modules.skill
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	
	import flash.utils.Dictionary;
	
	import modules.buff.BuffModule;
	import modules.pet.PetDataManager;
	import modules.skill.vo.BuffVO;
	import modules.skill.vo.ConditionVO;
	import modules.skill.vo.SkillEffectActionVO;
	import modules.skill.vo.SkillEffectItemVO;
	import modules.skill.vo.SkillEffectVO;
	import modules.skill.vo.SkillLevelVO;
	import modules.skill.vo.SkillVO;

	public class SkillDataManager
	{
		private static var skills:Dictionary;
		private static var skillsArray:Array;
		private static var categorys:Dictionary;
		private static var buffShow:Dictionary;
		public static var skillBooks:Dictionary;
		public static var bookID:Dictionary;
		
		
		//选中技能
		public static var currentSkill:SkillVO;
		//选中技能目标
		public static var currentSkillTraget:MutualAvatar;
		//自动技能
		public static var autoSkill:SkillVO;
		
		public static var chooseSkill:SkillVO;
		
		//获取技能数组
		public static function getSkills():Array{
			return skillsArray;
		}
		
		//获取技能
		public static function getSkill(id:int):SkillVO{
			return skills[id] as SkillVO;
		}
		
		//获取技能的某一等级
		public static function getSkillItem(id:int,level:int=0):SkillLevelVO{
			var skillVO:SkillVO = skills[id];
			return skillVO.levels[level - 1] as SkillLevelVO
		}
		
		//获取各系技能
		public static function getCategory(name:int):Array{
			return categorys[name] as Array;
		}
		
		public static var warriorPoint:int = 0;
		public static var archerPoint:int = 0;
		public static var rangerPoint:int = 0;
		public static var priestPoint:int = 0;
		
		/**
		 *更新各系投入点数 
		 */		
		public static function updataCategoryPoint():void{
			warriorPoint = getPoint(SkillConstant.CATEGORY_WARRIOR);
			archerPoint = getPoint(SkillConstant.CATEGORY_ARCHER);
			rangerPoint = getPoint(SkillConstant.CATEGORY_RANGER);
			priestPoint = getPoint(SkillConstant.CATEGORY_PRIEST);
			function getPoint(catagory:int):int{
				var skillArr:Array = getCategory(catagory);
				var count:uint = 0
				if(skillArr !=null){
					var l:uint = skillArr.length
					for(var i:int = 0; i < l; i++){
						count += skillArr[i].level;
					}
				}
				return count;
			}
		}
		
		//获取一系投入的技能点
		public static function getCategoryPoint(catagory:int):uint{
			switch( catagory ){
				case SkillConstant.CATEGORY_WARRIOR:return warriorPoint;
				case SkillConstant.CATEGORY_ARCHER:return archerPoint;
				case SkillConstant.CATEGORY_RANGER:return rangerPoint;
				case SkillConstant.CATEGORY_PRIEST:return priestPoint;
			}
			return 0;
		}
		
		//获取投入技能点最多的系
		public static function getMaxCategory():uint{
			var warrior:uint = getCategoryPoint(SkillConstant.CATEGORY_WARRIOR);
			var archer:uint = getCategoryPoint(SkillConstant.CATEGORY_ARCHER);
			var ranger:uint = getCategoryPoint(SkillConstant.CATEGORY_RANGER);
			var priest:uint = getCategoryPoint(SkillConstant.CATEGORY_PRIEST);
			var points:Array = [warrior,archer,ranger,priest];
			points.sort(Array.NUMERIC | Array.DESCENDING);
			if(points[0] == 0){
				if(GlobalObjectManager.getInstance().user.attr.category != 0){
					return GlobalObjectManager.getInstance().user.attr.category;
				}
				return SkillConstant.CATEGORY_WARRIOR;
			}
			if(warrior == points[0]){
				return SkillConstant.CATEGORY_WARRIOR;
			}
			if(archer == points[0]){
				return SkillConstant.CATEGORY_ARCHER;
			}
			if(ranger == points[0]){
				return SkillConstant.CATEGORY_RANGER;
			}
			if(priest == points[0]){
				return SkillConstant.CATEGORY_PRIEST;
			}
			if(GlobalObjectManager.getInstance().user.attr.category != 0){
				return GlobalObjectManager.getInstance().user.attr.category;
			}
			return SkillConstant.CATEGORY_WARRIOR;
		}
		
		/**
		 * 生成技能栏的Tooltip
		 * @param $skill
		 * @return
		 *
		 */
		public static function createHotKeyTooltip($skill:SkillVO):String
		{
			var s:String='';
			s=s.concat("<font color='#FFFFFF'size='14'><b>" + $skill.name + "</b></font>\n");
			if($skill.category!=PetDataManager.petTroopIn&&$skill.category!=PetDataManager.petTroopOut){
				s=s.concat("<font color='#FFFFFF'>等级:" + $skill.level + "/" + $skill.max_level + "</font>\n");
			}
			if($skill.category == SkillConstant.CATEGORY_LIFE){
				s = s.concat("<font color='#f2c802'>"+$skill.levels[$skill.level - 1].discription+"</font>\n\n");
				return s;
			}
			switch ($skill.category){
				case 1:
					if (GlobalObjectManager.getInstance().user.base.weapon_type == 101){
						s=s.concat("<font color='#FFFFFF'>需要装备武器:刀</font>\n");
					}else{
						s=s.concat("<font color='#FF0000'>需要装备武器:刀</font>\n");
					}
					break;
				case 2:
					if (GlobalObjectManager.getInstance().user.base.weapon_type == 102){
						s=s.concat("<font color='#FFFFFF'>需要装备武器:弓</font>\n");
					}else{
						s=s.concat("<font color='#FF0000'>需要装备武器:弓</font>\n");
					}
					break;
				case 3:
					if (GlobalObjectManager.getInstance().user.base.weapon_type == 104){
						s=s.concat("<font color='#FFFFFF'>需要装备武器:扇</font>\n");
					}else{
						s=s.concat("<font color='#FF0000'>需要装备武器:扇</font>\n");
					}
					break;
				case 4:
					if (GlobalObjectManager.getInstance().user.base.weapon_type == 103){
						s=s.concat("<font color='#FFFFFF'>需要装备武器:杖</font>\n");
					}else{
						s=s.concat("<font color='#FF0000'>需要装备武器:杖</font>\n");
					}
					break;
				case 5:
					if (GlobalObjectManager.getInstance().user.base.weapon_type == 5){
						s=s.concat("<font color='#FFFFFF'>需要装备武器:特殊</font>\n");
					}else{
						s=s.concat("<font color='#FF0000'>需要装备武器:特殊</font>\n");
					}
					break;
			}
			if ($skill.level > 0){
				s=s.concat("<font color='#FFFFFF'>冷却时间:" + $skill.levels[$skill.level - 1].cooldown * 0.001 + "秒</font>\n");
				if($skill.category!=PetDataManager.petTroopIn&&$skill.category!=PetDataManager.petTroopOut){
					s=s.concat("<font color='#FFFFFF'>消耗内力:" + $skill.levels[$skill.level - 1].consume_mp + "点</font>\n");
				}
				s=s.concat("<font color='#f2c802'>" + $skill.levels[$skill.level - 1].discription + "</font>\n");
			}
			return s;
		}
		
		public static function getBookID(skillid:int):int{
			return int(bookID[skillid.toString()]);
		}
		
		public static function init():void{
			skills = new Dictionary();
			skillsArray = [];
			categorys = new Dictionary();
			skillBooks = new Dictionary();
			bookID = new Dictionary();
			var skillXML:XML = CommonLocator.getXML(CommonLocator.SKILL_XML_PATH);;
			xmlToSkillVO(skillXML);
			var effectXML:XML = CommonLocator.getXML(CommonLocator.SKILL_EFFECT);
			xmlToSkillEffect(effectXML);
		}
		
		private static function xmlToSkillVO(xml:XML):void{
			var skilList:XMLList = xml.skill;
			for(var i:int = 0; i < skilList.length(); i++){
				var skill:SkillVO = createSkillVO(skilList[i]);
				skills[skill.sid] = skill
				skillsArray.push(skill);
				if(categorys.hasOwnProperty(skill.category)){
					var arr:Array = categorys[skill.category] as Array;
					arr.push(skill);
				}else{
					categorys[skill.category] = [];
					categorys[skill.category].push(skill)
				}
			}
			var positionList:XMLList = xml.position;
			for(var j:int = 0; j < positionList.length(); j++){
				if(skills[int(positionList[j].@id)]){
					skills[int(positionList[j].@id)].tree_x = positionList[j].@x;
					skills[int(positionList[j].@id)].tree_y = positionList[j].@y;
				}
			}
			var priorityList:XMLList = xml.priority;
			for(var k:int =0; k < priorityList.length(); k++){
				if(skills[int(priorityList[k].@id)]){
					skills[int(priorityList[k].@id)].priority = priorityList[k].@data;
				}
			}
			var actionTypeList:XMLList = xml.actionType;
			for(var l:int = 0; l < actionTypeList.length(); l++){
				if(skills[int(actionTypeList[l].@id)]){
					skills[int(actionTypeList[l].@id)].actionType = actionTypeList[l].@data;
				}
			}
			var books:XMLList = xml.book;
			for(var m:int = 0; m < books.length(); m++){
				skillBooks[books[m].@id.toString()] = books[m].@sid.toString();
				bookID[books[m].@sid.toString()] = books[m].@id.toString();
			}
			var useMethods:XMLList = xml.useMethod;
			for(var n:int = 0; n < useMethods.length(); n++){
				if(skills[int(useMethods[n].@id)]){
					skills[int(useMethods[n].@id)].useMethod = useMethods[n].@data.toString();
				}
			}
			var bookTips:XMLList = xml.bookTip;
			for(var o:int = 0; o < bookTips.length(); o++){
				if(skills[int(bookTips[o].@id)]){
					skills[int(bookTips[o].@id)].bookTip = true;
				}
			}
		}
		
		private static function xmlToSkillEffect(xml:XML):void{
			var effects:XMLList = xml.effect;
			for(var p:int = 0; p < effects.length(); p++){
				var skillVO:SkillVO = skills[int(effects[p].@id)];
				if(skillVO){
					skillVO.effect = createSkillEffectVO(effects[p]);
				}
			}
		}
		
		public static function createSkillVO(xml:XML):SkillVO{
			var skillVO:SkillVO = new SkillVO;
			skillVO.sid = xml.@id;
			skillVO.name = xml.@name;
			skillVO.kind = xml.@kind;
			skillVO.max_level = xml.@max_level;
			skillVO.need_equip_types = xml.@need_equip_types;
			skillVO.is_common_phy = xml.@contain_common_phy;
			skillVO.cast_time = xml.@cast_time;
			skillVO.category = xml.@category;
			skillVO.distance = xml.@distance;
			skillVO.attack_type = xml.@attack_type;
			skillVO.effect_type = xml.@effect_type;
			skillVO.target_type = xml.@target_type;
			skillVO.typeId = 'skill' + skillVO.sid;
			skillVO.path = GameConfig.ROOT_URL + 'com/assets/skills/'.concat(skillVO.sid).concat('.png');
			skillVO.levels = [];
			var xmllist:XMLList = xml.level;
			for(var i:int = 0; i < xmllist.length(); i++)
			{
				var xmlItem:XML = xmllist[i];
				var skillItem:SkillLevelVO = new SkillLevelVO();
				skillItem.level = xmlItem.@level;
				skillItem.discription = xmlItem.@discription;
				while(skillItem.discription.indexOf('\r') != -1 || skillItem.discription.indexOf('\n') != -1){
					skillItem.discription = skillItem.discription.replace('\r','');
					skillItem.discription = skillItem.discription.replace('\n','');
				}
				skillItem.cooldown = xmlItem.@cooldown;
				skillItem.consume_mp = xmlItem.@consume_mp;
				var buffXML:String = xmlItem.@buff.toString();
				var buffs:Array = buffXML.split(',');
				for(var k:int = 0; k < buffs.length; k=k+2){
					var buff:BuffVO = new BuffVO();
					buff.buff_id = int(buffs[k]);
					buff.type = int(buffs[k+1]);
					skillItem.buff.push(buff);
				}
				var debuffXML:String = xmlItem.@debuff.toString();
				var debuffs:Array = debuffXML.split(',');
				for(var l:int = 0; l < debuffs.length; l=l+2){
					var debuff:BuffVO = new BuffVO();
					debuff.buff_id = int(debuffs[l]);
					debuff.type = int(debuffs[l+1]);
					skillItem.debuff.push(debuff);
				}
				var conditionXML:XMLList = xmlItem.condition
				for(var j:int = 0; j < conditionXML.length(); j++)
				{
					var conditionXMLItem:XML = conditionXML[j]
					var c:ConditionVO = new ConditionVO()
					c.name = conditionXMLItem.@name;
					c.data = conditionXMLItem.@data;
					skillItem.conditions.push(c);
				}
				skillVO.levels.push(skillItem);
			}
			return skillVO;
		}
		
		public var effectType:int;
		public var srcActionType:int;
		public var destActionType:int;
		public var destActionDelay:int;
		public var hasArrow:int;
		public var effects:Array = [];
		public var arrowEndEffects:Array = [];
		public static function createSkillEffectVO(xml:XML):SkillEffectVO{
			var effectVO:SkillEffectVO = new SkillEffectVO();
			effectVO.isNormal = xml.isNormal;
			effectVO.hasDamage = xml.hasDamage;
			effectVO.damageStart = xml.damageStart;
			effectVO.damageDelay = xml.damageDelay;
			var i:int = 0;
			var action:SkillEffectActionVO;
			var effect:SkillEffectItemVO;
			for( i = 0; i < xml.actions.item.length(); i++ ){
				action = new SkillEffectActionVO();
				action.type = xml.actions.item[i].type;
				action.target = xml.actions.item[i].target;
				action.delay = xml.actions.item[i].delay;
				effectVO.actions.push( action );
			}
			for( i = 0; i < xml.arrowEndActions.item.length(); i++ ){
				action = new SkillEffectActionVO();
				action.type = xml.arrowEndActions.item[i].type;
				action.target = xml.arrowEndActions.item[i].target;
				action.delay = xml.arrowEndActions.item[i].delay;
				effectVO.arrowEndActions.push( action );
			}
			for( i = 0; i < xml.effects.item.length(); i++ ){
				effect = new SkillEffectItemVO();
				effect.id = xml.effects.item[i].id;
				effect.type = xml.effects.item[i].type;
				effect.target = xml.effects.item[i].target;
				effect.delay = xml.effects.item[i].delay;
				effect.hasDir = xml.effects.item[i].hasDir;
				effect.hasRotation = xml.effects.item[i].hasRotation;
				effect.layerType = xml.effects.item[i].layerType;
				effect.posType = xml.effects.item[i].posType;
				effect.speed = xml.effects.item[i].speed;
				effectVO.effects.push(effect);
			}
			for( i = 0; i < xml.arrowEndEffects.item.length(); i++ ){
				effect = new SkillEffectItemVO();
				effect.id = xml.arrowEndEffects.item[i].id;
				effect.type = xml.arrowEndEffects.item[i].type;
				effect.target = xml.arrowEndEffects.item[i].target;
				effect.delay = xml.arrowEndEffects.item[i].delay;
				effect.hasDir = xml.arrowEndEffects.item[i].hasDir;
				effect.hasRotation = xml.arrowEndEffects.item[i].hasRotation;
				effect.layerType = xml.arrowEndEffects.item[i].layerType;
				effect.posType = xml.arrowEndEffects.item[i].posType;
				effect.speed = xml.arrowEndEffects.item[i].speed;
				effectVO.arrowEndEffects.push(effect);
			}
			return effectVO;
		}
		
		public function SkillDataManager(){}
	}
}