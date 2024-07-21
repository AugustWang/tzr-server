package modules.pet.config {
	import com.loaders.CommonLocator;

	import flash.utils.Dictionary;

	public class PetConfig {
		public static var hash:Dictionary=new Dictionary; //所有宠物配置
		public static var says:Dictionary=new Dictionary;
		public static var trickSkill:Dictionary=new Dictionary;

		public function PetConfig() {
		}

		public static function init():void {
			var data:XML=CommonLocator.getXML(CommonLocator.PET_URL);
			for each (var t:XML in data.children()) {
				var vo:PetType=new PetType(t.@typeid, t.@skinid, t.@takeLevel, t.@msg, t.@maxAptitude, t.@attackType);
				hash[int(t.@typeid)]=vo;
			}
			var sayData:XML=CommonLocator.getXML(CommonLocator.PET_SAY_URL);
			for each (var say:XML in sayData.children()) {
				if (says[String(say.name().localName)] == null) {
					says[String(say.name().localName)]=new Array;
				}
				for each (var word:XML in say.children()) {
					says[String(say.name().localName)].push({'id': String(word.@id), 'data': String(word.@data), 'addName': String(word.@addName)});
				}
			}
			var trickSkillData:XML=CommonLocator.getXML(CommonLocator.PET_TRICK_SKILL);
			for each (var trick:XML in trickSkillData.children()) {
				if (trickSkill[String(trick.@level)] == null) {
					trickSkill[String(trick.@level)]=new Array;
				}
				for each (var skills:XML in trick.children()) {
					var skill:Object={'id': String(skills.@id), 'name': String(skills.@name)};
					var levels:XML=skills.levels[0];
					for each (var level:XML in levels.children()) {
						var levelIndex:String=String(level.@value);
						skill[levelIndex]=String(level.@desc);
					}
					trickSkill[String(trick.@level)].push(skill);
				}
			}
		}

		public static function getPetSkin(typeid:int):int {
			var skinid:int;
			var vo:PetType=hash[typeid];
			if (vo != null) {
				skinid=vo.skinId;
			} else {
				throw new Error("找不到typeid为：" + typeid + "的宠物");
				return;
			}
			return skinid;
		}

		public static function getPetTakeLevel(typeid:int):int {
			var takeLevel:int;
			var vo:PetType=hash[typeid];
			if (vo != null) {
				takeLevel=vo.takeLevel;
			}
			return takeLevel;
		}

		public static function getPetAttackType(typeid:int):String {
			var vo:PetType=hash[typeid];
			if (vo != null) {
				return vo.attackType;
			}
			return null;
		}

		public static function getPetMsg(typeid:int):String {
			var msg:String;
			var vo:PetType=hash[typeid];
			if (vo != null) {
				msg=vo.msg;
			}
			return msg;
		}

		public static function getMaxAptitude(typeid:int):int {
			var aptitude:int;
			var vo:PetType=hash[typeid];
			if (vo != null) {
				aptitude=vo.maxAptitude;
			}
			return aptitude;
		}

		public static function getPetConfig(typeid:int):PetType {
			var vo:PetType=hash[typeid];
			return vo;
		}

		public static function getSayWordByAction(action:String):Object {
			if (says[action]) {
				var index:int=int(Math.random() * (says[action] as Array).length);
				return says[action][index];
			}
			return null;
		}

		//获取领悟技能
		public static function getTrickSkillByLevel(level:int):Array {
			if (trickSkill[level.toString()]) {
				return trickSkill[level.toString()];
			}
			return null;
		}
	}
}