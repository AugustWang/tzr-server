package modules.pet {
	import com.components.cooling.CoolingManager;
	import com.managers.Dispatch;
	import com.scene.sceneUnit.baseUnit.things.heartbeat.ThingFrameFrequency;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.ModuleCommand;
	import modules.navigation.NavigationModule;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;
	import modules.skill.vo.SkillVO;
	
	import proto.common.p_map_pet;
	import proto.common.p_pet;
	import proto.common.p_pet_id_name;
	import proto.common.p_pet_skill;
	import proto.common.p_pet_training_info;
	import proto.common.p_role_pet_bag;
	import proto.line.m_pet_info_toc;
	import proto.line.m_pet_training_request_toc;

	public class PetDataManager {
		//pet_skill_type  1为群攻，6普通外功，7普通内功，11为单体攻击，12给主人增加的BUFF，13给自身增加的BUFF
		//type ID在10以上有概率学习成功，10以下100%学习成功
		public static var _petBag:p_role_pet_bag;
		private static var _petList:Array=[];
		private static var _bagContent:int=0;
		public static var isBattle:Boolean; //场景中是否有自己的宠物
		public static var thePet:p_pet; //放出来战斗的那一只的ID
		public static var petInfos:Dictionary=new Dictionary;
		public static var selectedPet:p_pet; //在列表中选择中的那只
		public static var theAttackType:int; //放出来战斗的那一只的内外功
		public static var attackAble:Boolean; //自己的宠物能否攻击
		public static var ownSkills:Array=[];
		public static var useTroopHit:Boolean; //使用群攻
		public static var petTroopOut:int=8; //宠物外攻技能类型
		public static var petTroopIn:int=9; //宠物内攻技能类型
		/////////////////////
		private static var huiTianID:int=63127001;
		private static var yiQiID:int=63127002;
		public static var selectedSkillID:int; //手动选中的技能

		public function PetDataManager() {
		}

		public static function set petBag(bag:p_role_pet_bag):void {
			_petBag=bag;
			if (bag) {
				_petList=bag.pets;
				_bagContent=bag.content;
				Dispatch.dispatch(ModuleCommand.PET_LIST_CHANGED);
			}
		}

		public static function get petBag():p_role_pet_bag {
			return _petBag;
		}

		public static function get petList():Array {
			return _petList;
		}
		
		public static function get bagContent():int{
			return _bagContent;
		}
		
		public static function get currentPetInfo():p_pet{
			return _currentPetInfo;
		}
		
		private static var _currentPetInfo:p_pet;
		public static function set currentPetInfo(value:p_pet):void{
			_currentPetInfo = value;
			Dispatch.dispatch(ModuleCommand.PET_CURRENT_INFO_CHANGE);
		}
		
		private static var _petTrainingInfoDic:Dictionary = new Dictionary();
		private static var _petTrainingInfo:Array = [];
		public static function set petTrainingInfo(value:Array):void{
			_petTrainingInfoDic = new Dictionary();
			_petTrainingInfo = value;
			for(var i:int=0; i < value.length; i++){
				var item:p_pet_training_info = value[i];  
				_petTrainingInfoDic[item.pet_id] = item;
			}
			Dispatch.dispatch(ModuleCommand.PET_TRAINING_INFO_UPDATE);
		}
		
		public static function get petTrainingInfo():Array{
			return _petTrainingInfo
		}
		
		public static function get petTrainingInfoDic():Dictionary{
			return _petTrainingInfoDic;
		}
		
		private static var _trainingRoom:int;
		public static function set trainingRoom(value:int):void{
			_trainingRoom = value;
		}
		
		public static function get trainingRoom():int{
			return _trainingRoom;
		}

		public static function makeOwnSkills(arr:Array):Array {
			ownSkills=[];
			var hotSkills:Array=[];
			for (var i:int=0; i < arr.length; i++) {
				var ps:p_pet_skill=arr[i];
				var skill:SkillVO=SkillDataManager.getSkill(ps.skill_id);
				skill.level=ps.skill_level;
				var petSkill:PetSkillVO=new PetSkillVO(skill, ps.skill_type)
				ownSkills.push(petSkill);
				if (petSkill.skill_type == 1) { //把群攻技能放到技能栏里里面
					skillToNavigation(skill);
				}
				if ((petSkill.skill_type < 10 || petSkill.skill_type > 100) && petSkill.skill.attack_type == SkillConstant.ATTACK_TYPE_INITIATIVE) { //把群攻技能放到技能栏里里面,>100是神技
					hotSkills.push(skill);
				}
			}
			return hotSkills;
		}

		//自动把群攻技能放到技能栏里面
		private static function skillToNavigation(skill:SkillVO):void {
			var items:Array=NavigationModule.getInstance().getItems();
			for (var i:int=0; i < items.length; i++) { //清空技能栏里面的宠物群攻技能
				if (items[i].type == 1) { //type==1表示那个栏里面放的是技能
					var sk:SkillVO=SkillDataManager.getSkill(items[i].id);
					if (sk.category == petTroopOut || sk.category == petTroopIn) {
						NavigationModule.getInstance().clearItemAt(i);
					}
				}
			}
			//把新学习的第一个技能设置成自动施放
			for (var j:int=items.length - 1; j >= 10; j--) {
				if (items[j].type == 0) {
					NavigationModule.getInstance().addItemAt(skill, j);
					break;
				}
			}
		}

		public static function checkIsHuiTian(skillID:int):Boolean {
			return skillID == huiTianID;
		}

		public static function checkHuiTianReady():int {
			var sk:PetSkillVO;
			var isCooling:Boolean;
			for (var i:int=0; i < ownSkills.length; i++) {
				sk=ownSkills[i];
				if (checkIsHuiTian(sk.skill.sid) == true) { //回天技能
					isCooling=CoolingManager.getInstance().isCoolingByName(sk.skill.typeId);
					if (isCooling == false) {
						return sk.skill.sid;
					}
				}
			}
			return 0;
		}

		public static function checkIsYiQi(skillID:int):Boolean {
			return skillID == yiQiID;
		}

		public static function checkYiQiReady():int {
			var sk:PetSkillVO;
			var isCooling:Boolean;
			for (var i:int=0; i < ownSkills.length; i++) {
				sk=ownSkills[i];
				if (checkIsYiQi(sk.skill.sid) == true) {
					isCooling=CoolingManager.getInstance().isCoolingByName(sk.skill.typeId);
					if (isCooling == false) {
						return sk.skill.sid;
					}
				}
			}
			return 0;
		}

		public static function checkIsAutoTrick(skillID:int):Boolean {
			if (checkIsHuiTian(skillID) == true || checkIsYiQi(skillID) == true) {
				return true;
			}
			return false;
		}

		//自动选一种技能去放，1为群攻，6普通外功，7普通内功，11为单体攻击，12给主人增加的BUFF，13给自身增加的BUFF	
		//优先顺序是  手动触发的技能———>群攻———>普通单体攻击
		//skill_type<10代表群攻，skill_type>100是神技，其它是普通技能,这里排除回天和益气两个神技
		public static function selectSkill():int {
			var t:int=getTimer();
			var useSkill:int;
			var isCooling:Boolean=true;
			var index:int;
			var sk:PetSkillVO;
			var findAutoTrick:Boolean; //找到自动释放类神技
			var findTroop:Boolean; //找到群攻
			for (var i:int=0; i < ownSkills.length; i++) {
				sk=ownSkills[i];
				if (selectedSkillID > 0 && sk.skill.sid == selectedSkillID) { //手动触发的技能
					if (checkIsAutoTrick(selectedSkillID) == true) { //回天和益气不手动发，如果手动点了，就致0
						selectedSkillID=0;
						continue;
					}
					isCooling=CoolingManager.getInstance().isCoolingByName(sk.skill.typeId);
					if (isCooling == false) {
						useSkill=sk.skill.sid;
						break;
					}
				}
				if (findTroop == false) {
					if (sk.skill_type == 1) { //群攻类技能
						if (useTroopHit == true) { //技能栏那里点了群攻，这个值就为true
							useTroopHit=false;
							isCooling=CoolingManager.getInstance().isCoolingByName(sk.skill.typeId);
							if (isCooling == false) { //找到群攻的直接 break用群攻
								useSkill=sk.skill.sid;
								findTroop=true;
								return useSkill;
							}
						}
					}
				}
				if (sk.skill.attack_type == SkillConstant.ATTACK_TYPE_PASSIVITY) { //排除被动技能
					continue;
				}
				if (sk.skill_type == 11) { //普通单体攻击
					isCooling=CoolingManager.getInstance().isCoolingByName(sk.skill.typeId);
					if (isCooling == false) { //找到群攻的直接 break用群攻
						useSkill=sk.skill.sid; //找到单体攻击的continue继续找，排除群攻的可能性
					}
				}
			}
			if (useSkill == 0) { //没有技能
				useSkill=theAttackType == 1 ? 6 : 7;
			}
//			trace("选中宠物技能时间：", getTimer() - t);
			return useSkill;
		}

		public static function getStandSpeed(skinid:int):int {
			var speed:int=ThingFrameFrequency.STAND;
			if (skinid == 10086 || skinid == 10089 || skinid == 10090 || skinid == 10092 || skinid == 10108) { //蝴蝶和鸟
				speed=4;
			}
			return speed;
		}

		public static function getWalkSpeed(skinid:int):int {
			return 2;
		}

		public static function createP_map_pet(vo:p_pet):p_map_pet {
			var p:p_map_pet=new p_map_pet;
			p.pet_id=vo.pet_id;
			p.type_id=vo.type_id;
			p.pet_name=vo.pet_name;
			p.state=vo.state;
			p.hp=vo.hp;
			p.attack_speed=vo.attack_speed;
			p.max_hp=vo.max_hp;
			p.level=vo.level;
			p.role_id=vo.role_id;
			p.state_buffs=vo.buffs;
			p.title=vo.title;
			p.color=vo.color;
			return p;
		}
		
		public static function updatePetInfo(petInfo:p_pet):void{
			if(currentPetInfo && currentPetInfo.pet_id == petInfo.pet_id){
				copyValues(currentPetInfo,petInfo);
				Dispatch.dispatch(ModuleCommand.PET_INFO_UPDATE,currentPetInfo);
			}
		}
		
		public static function updatePetSkills(petId:int,skills:Array):void{
			if(currentPetInfo && petId == currentPetInfo.pet_id){
				currentPetInfo.skills = skills;
				Dispatch.dispatch(ModuleCommand.PET_SKILLS_UPDATE,currentPetInfo);
			}	
		}
		
		private static function copyValues(cur:p_pet,dest:p_pet):void{
			cur.pet_id = dest.pet_id;
			cur.type_id = dest.type_id;
			cur.role_id = dest.role_id;
			cur.role_name = dest.role_name;
			cur.hp = dest.hp;
			cur.max_hp = dest.max_hp;
			cur.pet_name = dest.pet_name;
			cur.color = dest.color;
			cur.understanding = dest.understanding;
			cur.sex = dest.sex;
			cur.pk_mode = dest.pk_mode;
			cur.bind = dest.bind;
			cur.mate_id = dest.mate_id;
			cur.mate_name = dest.mate_name;
			cur.level = dest.level;
			cur.exp = dest.exp;
			cur.life = dest.life;
			cur.generated = dest.generated;
			cur.buffs = dest.buffs;
			cur.str = dest.str;
			cur.int2 = dest.int2;
			cur.con = dest.con;
			cur.dex = dest.dex;
			cur.men = dest.men;
			cur.base_str = dest.base_str;
			cur.base_int2 = dest.base_int2;
			cur.base_con = dest.base_con;
			cur.base_dex = dest.base_dex;
			cur.base_men = dest.base_men;
			cur.remain_attr_points = dest.remain_attr_points;
			cur.phy_defence = dest.phy_defence;
			cur.magic_defence = dest.magic_defence;
			cur.phy_attack = dest.phy_attack;
			cur.magic_attack = dest.magic_attack;
			cur.double_attack = dest.double_attack;
			cur.hit_rate = dest.hit_rate;
			cur.miss = dest.miss;
			cur.attack_speed = dest.attack_speed;
			cur.equip_score = dest.equip_score;
			cur.spec_score_one = dest.spec_score_one;
			cur.spec_score_two = dest.spec_score_two;
			cur.attack_type = dest.attack_type;
			cur.period = dest.period;
			cur.skills = dest.skills;
			cur.title = dest.title;
			cur.max_hp_aptitude = dest.max_hp_aptitude;
			cur.phy_defence_aptitude = dest.phy_defence_aptitude;
			cur.magic_defence_aptitude = dest.magic_defence_aptitude;
			cur.phy_attack_aptitude = dest.phy_attack_aptitude;
			cur.magic_attack_aptitude = dest.magic_attack_aptitude;
			cur.double_attack_aptitude = dest.double_attack_aptitude;
			cur.get_tick = dest.get_tick;
			cur.next_level_exp = dest.next_level_exp;
			cur.state = dest.state;
			cur.max_hp_grow_add = dest.max_hp_grow_add;
			cur.phy_defence_grow_add = dest.phy_defence_grow_add;
			cur.magic_defence_grow_add = dest.magic_defence_grow_add;
			cur.phy_attack_grow_add = dest.phy_attack_grow_add;
			cur.magic_attack_grow_add = dest.magic_attack_grow_add;
			cur.max_skill_grid = dest.max_skill_grid;
		}
	}
}
