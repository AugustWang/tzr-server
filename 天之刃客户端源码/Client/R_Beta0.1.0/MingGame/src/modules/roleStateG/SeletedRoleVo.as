package modules.roleStateG {
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.scene.sceneData.NPCVo;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.ServerNPC;
	import com.scene.sceneUnit.YBC;
	import com.scene.sceneUnit.configs.MonsterConfig;
	import com.scene.sceneUnit.configs.MonsterType;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.pet.config.PetConfig;
	
	import proto.common.p_map_monster;
	import proto.common.p_map_pet;
	import proto.common.p_map_role;
	import proto.common.p_map_server_npc;
	import proto.common.p_map_ybc;
	import proto.common.p_role;
	import proto.line.p_team_role;

	/**
	 * 场景中被选单位的VO
	 * @author Administrator
	 *
	 */
	public class SeletedRoleVo {
		public var id:int;
		public var name:String;
		public var headId:int;
		public var head_url:String;
		public var unit_type:int;
		public var hp:int;
		public var maxHp:int;
		public var mp:int;
		public var maxMp:int;
		public var level:int;
		public var sex:int;
		public var buf:Array;

		public var faction_id:int
		public var family_id:int;
		public var team_id:int;

		public var isBoss:Boolean=false; //怪物专用

		public function SeletedRoleVo() {
		}

		public function get key():String {
			return unit_type + "_" + id;
		}

		public function setup(tar:IMutualUnit):void {
			if (tar is Role) {
				if (Role(tar).pvo)
					setupRole(Role(tar).pvo);
			} else if (tar is Monster) {
				if (Monster(tar).pvo)
					setupMonster(Monster(tar).pvo);
			} else if (tar is YBC) {
				if (YBC(tar).pvo)
					setupYBC(YBC(tar).pvo);
			} else if (tar is NPC) {
				setupNPC(NPC(tar).pvo);
			} else if (tar is ServerNPC) {
				if (ServerNPC(tar).pvo)
					setupServerNPC(ServerNPC(tar).pvo);
			} else if (tar is Pet) {
				if (Pet(tar).pvo)
					setupPet(Pet(tar).pvo);
			}
		}

		/**
		 * 人物的赋值
		 * @param vo
		 *
		 */
		public function setupRole(vo:p_map_role):void {
			id=vo.role_id;
			name=vo.role_name;
			headId = vo.skin.skinid;
			head_url=GameConstant.getHeadImage(vo.category*10+vo.sex);
			unit_type=SceneUnitType.ROLE_TYPE;
			hp=vo.hp;
			maxHp=vo.max_hp;
			mp=vo.mp;
			maxMp=vo.max_mp;
			level=vo.level;
			buf=vo.state_buffs;
			faction_id=vo.faction_id;
			family_id=vo.family_id;
			team_id=vo.team_id;
			sex=vo.skin.skinid % 2 == 1 ? 1 : 2;
		}

		public function setupMyRole():void {
			var user:p_role=GlobalObjectManager.getInstance().user;
			id=user.base.role_id;
			name=user.base.role_name;
			head_url=GameConstant.getHeadImage(user.base.head);
			headId = user.attr.skin.skinid;
			unit_type=SceneUnitType.ROLE_TYPE;
			hp=user.fight.hp;
			maxHp=user.base.max_hp;
			mp=user.fight.mp;
			maxMp=user.base.max_mp;
			level=user.attr.level;
			buf=user.base.buffs;
			faction_id=user.base.faction_id;
			family_id=user.base.family_id;
			team_id=user.base.team_id;
		}

		/**
		 * 怪物的赋值
		 * @param vo
		 *
		 */
		public function setupMonster(vo:p_map_monster):void {
			var monsterVo:MonsterType=MonsterConfig.hash[vo.typeid] as MonsterType;
			if (monsterVo) {
				id=vo.monsterid;
				name=monsterVo.monstername;
				head_url=GameConfig.ROOT_URL + "com/ui/npc/" + monsterVo.skinid + ".png";
				unit_type=SceneUnitType.MONSTER_TYPE;
				level=monsterVo.level;
				hp=vo.hp;
				maxHp=vo.max_hp;
				mp=vo.mp;
				maxMp=vo.max_mp;
				buf=vo.state_buffs;
				isBoss=monsterVo.rarity > 1;
			} else {
				throw new Error("找不到类型为" + vo.typeid + "的怪物");
			}
		}

		public function setupTeamRole(vo:p_team_role):void {
			id=vo.role_id;
			name=vo.role_name;
			head_url=GameConstant.getHeadImage(vo.category*10+vo.sex);
			unit_type=SceneUnitType.ROLE_TYPE;
			hp=vo.hp;
			maxHp=vo.max_hp;
			mp=vo.mp;
			maxMp=vo.max_mp;
			level=vo.level;
			buf=[];
		}

		public function setupYBC(vo:p_map_ybc):void {
			id=vo.ybc_id;
			name=vo.name;
			head_url=GameConfig.ROOT_URL + "com/ui/ybc/20000.png";
			unit_type=SceneUnitType.YBC_TYPE;
			hp=vo.hp;
			maxHp=vo.max_hp;
			mp=0;
			maxMp=0;
			level=vo.level;
			buf=vo.buffs;
		}

		public function setupNPC(vo:NPCVo):void {
			id=int(vo.id);
			name=vo.name;
			head_url=vo.headImage;
			unit_type=SceneUnitType.NPC_TYPE;
			hp=100;
			maxHp=100;
			mp=100;
			maxMp=100;
			level=200;
			buf=[];
		}

		public function setupServerNPC(vo:p_map_server_npc):void {
			var serverNPCVo:Object=MonsterConfig.getServerNPCByType(vo.type_id);
			id=int(vo.npc_id);
			name=vo.npc_name;
			head_url=GameConfig.ROOT_URL + "com/ui/npc/" + serverNPCVo.skinid + ".png";
			unit_type=SceneUnitType.SERVER_NPC_TYPE;
			hp=vo.hp;
			maxHp=vo.max_hp;
			mp=vo.mp;
			maxMp=vo.max_mp;
			level=serverNPCVo.level;
			buf=vo.state_buffs;
		}

		public function setupPet(vo:p_map_pet):void {
			id=vo.pet_id;
			name=vo.pet_name;
			head_url=GameConfig.ROOT_URL + "com/assets/pet/head/" + PetConfig.getPetSkin(vo.type_id) + ".png";
			unit_type=SceneUnitType.PET_TYPE;
			hp=vo.hp;
			maxHp=vo.max_hp;
			mp=0;
			maxMp=0;
			level=vo.level;
			buf=vo.state_buffs;
		}

		public function selfSeletedVo():void {
			id=GlobalObjectManager.getInstance().user.base.role_id;
			name=GlobalObjectManager.getInstance().user.base.role_name;
			head_url=GameConstant.getHeadImage(GlobalObjectManager.getInstance().user.base.head);
			headId=GlobalObjectManager.getInstance().user.attr.skin.skinid;
			unit_type=SceneUnitType.ROLE_TYPE;
			hp=GlobalObjectManager.getInstance().user.fight.hp;
			maxHp=GlobalObjectManager.getInstance().user.base.max_hp;
			mp=GlobalObjectManager.getInstance().user.fight.mp;
			maxMp=GlobalObjectManager.getInstance().user.base.max_mp;
			level=GlobalObjectManager.getInstance().user.attr.level;
			buf=GlobalObjectManager.getInstance().user.base.buffs;
		}
	}
}