package modules.system {
	import com.managers.Dispatch;
	import com.ming.managers.SoundManager;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	import modules.ModuleCommand;
	import modules.mypackage.managers.PackManager;
	import modules.skill.SkillDataManager;
	import modules.skill.SkillModule;
	import modules.skill.vo.SkillVO;
	
	import proto.line.p_sys_config;

	/**
	 * 系统设置配置
	 * @author Administrator
	 *
	 */
	public class SystemConfig extends EventDispatcher {
		public static var serverTime:int;

		public static var MUSIC_URL:String="com/sounds/shanshui.mp3";
		/**
		 * 音频
		 */
		public static var openBackSound:Boolean=false; //是否开启背景音效
		public static var openGameSound:Boolean=false; //是否开启游戏音效
		public static var sceneVolume:int=50; //背景音乐
		public static var gameVolume:int=50; //游戏音效
		public static var imageQuality:int=2; //画面质量
		/**
		 * 显示
		 */
		public static var privateChat:Boolean=true; //开启私聊频道：不勾选，则收不到私聊频道信息
		public static var nationChat:Boolean=true; //开启国家频道：不勾选，则收不到国家频道信息
		public static var familyChat:Boolean=true; //开启门派频道：不勾选，则收不到门派频道信息
		public static var worldChat:Boolean=true; //开启综合频道：不勾选，则收不到综合频道信息
		public static var teamChat:Boolean=true; //开启队伍频道：不勾选，则收不到队伍频道信息
		public static var centerBroadcast:Boolean=true; //开启中央广播：不勾选，则收不到中央广播信息，如战神、国王登陆信息、送花广播

		public static var acceptFriendrequest:Boolean=true; //接受好友请求
		//public static var openEffect:Boolean = true;//开启所有效过
		public static var showClothing:Boolean=true; //是否显示衣服
		public static var byFind:Boolean=true; //被视察时显示。
		public static var showDropGoodsName:Boolean=true; //显示掉落物名称
		public static var showEquipCompare:Boolean=true; //显示装备对比

		public static var showRoleInfo:Boolean=true; //显示角色信息
		public static var showFmaily:Boolean=true; //玩家门派
		public static var showFactionName:Boolean=true; //玩家官职
		public static var showName:Boolean=false;

		/**
		 * 开启效果,技能特效控制写在核心端,所以先这样写
		 */
		public static var _openEffect:Boolean=true; //显示消失
		public static function set openEffect(value:Boolean):void {
			_openEffect=value;
		}

		public static function get openEffect():Boolean {
			return _openEffect;
		}
		
		//是否启动自动打怪
		public static var open:Boolean=false;

		//补血相关常量
		public static var autoUseHP:Boolean=false; //是否自动用生命药
		public static var hp:Number=0.5; //当血值低于多少时补血
		public static var hpUseBitToBig:Boolean = false;

		public static var autoUseMP:Boolean=false; //是否自动用内力药
		public static var mp:Number=0.5; //当内力值低于多少时内力药
		public static var mpUseBitToBig:Boolean = false;

		public static var autoUsePet:Boolean=false; //是否自动用宠物药
		public static var pet:Number=0.5; //当宠物血低于多少时宠物药
		public static var petUseBitToBig:Boolean = false;

		public static var autobuyMP:Boolean=false; //自动买药,包括内力药，名名有误
		public static var buyHPTypeId:int=10200003; //自动购买生命药的类型ID
		public static var buyMPTypeId:int=10200007; //自动购买内力药的类型ID
		public static var buyPetDrugTypeId:int=12300101; //自动购买内力药的类型ID
		public static var autobuyHC:Boolean=false; //自动买回城卷

		//拾取物品设置
		public static var autoPickEquip:Boolean=true; //自动捡装备
		public static var autoPickStone:Boolean=true; //自动捡石头
		public static var autoPickmedicine:Boolean=true; //自动捡药品
		public static var autoPickother:Boolean=true; //自动捡其它

		public static var pickEquipColors:Array=[true, true, true, true, true]; //拾取装备的颜色
		public static var pickOtherColors:Array=[true, true, true, true, true]; //拾取其它物品的颜色

		//技能设置
		private static var _autoSkill:Boolean=true; //自动技能
		public static var autoPetSkill:Boolean=true;

		public static function set autoSkill(value:Boolean):void {
			if (_autoSkill != value) {
				_autoSkill=value;
			}
		}

		public static function get autoSkill():Boolean {
			return _autoSkill;
		}

		private static var _skills:Array=[null, null, null, null, null]; //释放技能的类型

		public static function set skills(value:Array):void {
			_skills=value;
		}

		public static function get skills():Array {
			return _skills;
		}

		public static var findMonster:Boolean=false; //自动找怪
		public static var hitMonsters:Dictionary=new Dictionary(); //攻击怪物列表

		//挂机时间设置
		public static var otherFaction:Boolean=true; //将外国人纳入挂机目标
		public static var _autoTeam:Boolean = false; //是否自动组队
		public static function set autoTeam(value:Boolean):void{
			_autoTeam=value; //自动处理组队
			Dispatch.dispatch(ModuleCommand.SYSTEM_CONFIG_AUTO_TEAM_CHANGE);
		}
		
		public static function get autoTeam():Boolean{
			return _autoTeam;
		}
		public static var autoAcceptTeam:Boolean=true; //是否自动接受组队

		/**
		 * 安全锁
		 *
		 */
		public static function init(sys:p_sys_config):void {
			openBackSound=sys.back_sound;
			openGameSound=sys.game_sound;
			sceneVolume=sys.scence_vol; //场景音乐
			gameVolume=sys.game_vol; //游戏音乐
			imageQuality=sys.image_quality; //画面质量

			privateChat=true;//sys.private_chat; //开启私聊频道
			nationChat=true;//sys.nation_chat; //国家频道
			familyChat=true;//sys.family_chat; //门派频道
			worldChat=true;//sys.world_chat; //综合频道
			teamChat=true;//sys.team_chat;
			centerBroadcast=sys.center_broadcast;

			acceptFriendrequest=sys.accept_friend_request;
			openEffect=sys.skill_effect;
			showClothing=sys.show_cloth;
			byFind=sys.by_find;
			showDropGoodsName=sys.show_dropgoods_name;
			showEquipCompare=sys.show_equip_compare;

			showRoleInfo=sys.show_title; //玩家称号
			showFmaily=sys.show_family; //玩家门派
			showFactionName=sys.show_faction; //玩家官职


			autoUseHP=sys.auto_use_hp; //自动补红
			hp=sys.hp_below / 100; //血量低于多少时使用
			hpUseBitToBig = sys.use_hp_item_type == 1 ? true : false;
			autoUseMP=sys.auto_use_mp; //自动补蓝
			mp=sys.mp_below / 100; //内力低于多少时使用
			mpUseBitToBig = sys.use_mp_item_type == 1 ? true : false;
			autoUsePet=sys.pet_auto_use_hp; //宠物自动补红
			pet=sys.pet_hp_below / 100; //宠物血多少时使用
			petUseBitToBig = sys.use_pet_item_type == 1 ? true : false;
			
			autobuyMP=sys.auto_buy; //自动购买药品
			buyHPTypeId=sys.by_hp_typeid; //购买生命药类型ID
			buyMPTypeId=sys.by_mp_typeid; //购买内力药类型ID
			buyPetDrugTypeId=sys.pet_by_hp_typeid; //宠物药ID
			autobuyHC=sys.auto_return_home; //自动回城

			autoPickEquip=sys.auto_pick_equip; //自动拾取装备
			autoPickStone=sys.auto_pick_stone; //自动拾取宝石
			autoPickmedicine=sys.auto_pick_drug; //自动拾取药品
			autoPickother=sys.auto_pick_other; //自动拾取其它

			pickEquipColors=sys.pick_equip_color; //拾取装备颜色
			pickOtherColors=sys.pick_other_color; //拾取其它颜色

			autoSkill=sys.auto_use_skill; //自动使用技能
			autoPetSkill=sys.pet_auto_use_skill; //自动宠物技能
			var useskills:Array=[];
			for (var i:int=0; i < sys.skill_list.length; i++) {
				var skillId:int=sys.skill_list[i];
				useskills[i]=SkillDataManager.getSkill(skillId);
			}
			skills=useskills; //技能列表
			findMonster=sys.auto_search; //自动寻怪

			otherFaction=sys.other_faction; //将外国人纳入挂机目标
			autoTeam=sys.auto_team; //自动处理组队
			autoAcceptTeam=sys.auto_accept; //是否接受组队邀请
		}

		public static function save():void {
			var sys:p_sys_config=new p_sys_config();
			sys.back_sound=openBackSound;
			sys.game_sound=openGameSound;
			sys.scence_vol=sceneVolume; //场景音乐
			sys.game_vol=gameVolume; //游戏音乐
			sys.image_quality=imageQuality; //画面质量

			sys.private_chat=privateChat; //开启私聊频道
			sys.nation_chat=nationChat; //国家频道
			sys.family_chat=familyChat; //门派频道
			sys.world_chat=worldChat; //综合频道
			sys.team_chat=teamChat;
			sys.center_broadcast=centerBroadcast;

			sys.accept_friend_request=acceptFriendrequest;
			sys.skill_effect=openEffect;
			sys.show_cloth=showClothing;
			sys.by_find=byFind;
			sys.show_dropgoods_name=showDropGoodsName;
			sys.show_equip_compare=showEquipCompare;

			sys.show_title=showRoleInfo; //玩家称号
			sys.show_family=showFmaily; //玩家门派
			sys.show_faction=showFactionName; //玩家官职


			sys.auto_use_hp=autoUseHP; //自动补红
			sys.hp_below=hp * 100; //血量低于多少时使用
			sys.use_hp_item_type = hpUseBitToBig ? 1 : 2;
			sys.auto_use_mp=autoUseMP; //自动补蓝
			sys.mp_below=mp * 100; //内力低于多少时使用
			sys.use_mp_item_type = mpUseBitToBig ? 1 : 2;
			sys.auto_buy=autobuyMP; //自动购买药品
			sys.pet_auto_use_hp=autoUsePet; //
			sys.use_pet_item_type = petUseBitToBig ? 1 : 2; 
			sys.pet_hp_below=pet * 100;
			sys.auto_return_home=autobuyHC; //自动回城
			sys.by_hp_typeid=buyHPTypeId; //购买生命药类型ID
			sys.by_mp_typeid=buyMPTypeId; //购买内力药类型ID
			sys.pet_by_hp_typeid=buyPetDrugTypeId; //购买宠物药ID

			sys.auto_pick_equip=autoPickEquip; //自动拾取装备
			sys.auto_pick_stone=autoPickStone; //自动拾取宝石
			sys.auto_pick_drug=autoPickmedicine; //自动拾取药品
			sys.auto_pick_other=autoPickother; //自动拾取其它

			sys.pick_equip_color=pickEquipColors; //拾取装备颜色
			sys.pick_other_color=pickOtherColors; //拾取其它颜色

			sys.auto_use_skill=autoSkill; //自动使用技能
			sys.pet_auto_use_skill=autoPetSkill; //自动宠物技能
			var useskills:Array=[];
			for (var i:int=0; i < skills.length; i++) {
				var skillVO:SkillVO=skills[i];
				if (skillVO) {
					useskills[i]=skillVO.sid;
				} else {
					useskills[i]=0;
				}
			}
			sys.skill_list=useskills; //技能列表
			sys.auto_search=findMonster; //自动寻怪

			sys.other_faction=otherFaction; //将外国人纳入挂机目标
			sys.auto_team=autoTeam; //自动处理组队
			sys.auto_accept=autoAcceptTeam; //是否接受组队邀请

			SystemModule.getInstance().saveConfig(sys);
		}

		/**
		 * 重置设置面板
		 */
		public static function resetSetting():void {
			openBackSound=true; //是否开启背景音效
			openGameSound=true; //是否开启游戏音效
			sceneVolume=50; //背景音乐
			gameVolume=50; //游戏音效
			imageQuality=2; //画面质量

			privateChat=true; //开启私聊频道：不勾选，则收不到私聊频道信息
			nationChat=true; //开启国家频道：不勾选，则收不到国家频道信息
			familyChat=true; //开启门派频道：不勾选，则收不到门派频道信息
			worldChat=true; //开启综合频道：不勾选，则收不到综合频道信息
			teamChat=true; //开启队伍频道：不勾选，则收不到队伍频道信息

			centerBroadcast=true; //开启中央广播：不勾选，则收不到中央广播信息，如战神、国王登陆信息、送花广播
			acceptFriendrequest=true;
			openEffect=true; //开启技能效过
			showClothing=true; //是否显示衣服
			byFind=true; //被视察时显示。
			showDropGoodsName=true; //是否显示掉落物名称

			showRoleInfo=true; //玩家称号
			showFmaily=true; //玩家门派
			showFactionName=true; //玩家官职
		}

		/**
		 * 重置打怪面板
		 */
		public static function resetAutoSetting():void {
			autoUseHP=true; //是否自动用生命药
			hp=0.5; //当血值低于多少时补血

			autoUseMP=true; //是否自动用内力药
			mp=0.5; //当内力值低于多少时内力药

			autoUsePet=true;
			pet=0.5;
			autobuyMP=false; //自动买药
			autobuyHC=false; //自动买回城卷
			buyHPTypeId=10200003; //自动购买生命药的类型ID
			buyMPTypeId=10200007; //自动购买内力药的类型ID
			buyPetDrugTypeId=12300101;
			hpUseBitToBig = false;
			mpUseBitToBig = false;
			petUseBitToBig = false;

			autoPickEquip=true; //自动捡装备
			autoPickStone=true; //自动捡石头
			autoPickmedicine=true; //自动捡药品
			autoPickother=true; //自动捡其它

			pickEquipColors=[true, true, true, true, true]; //拾取装备的颜色
			pickOtherColors=[true, true, true, true, true]; //拾取其它物品的颜色

			autoSkill=true; //自动技能
			autoPetSkill=true; //宠物技能
			skills=[null, null, null, null, null]; //释放技能的类型
			findMonster=true; //自动找怪

			otherFaction=true; //将外国人纳入挂机目标
			autoTeam=false;
			autoAcceptTeam=false; //是否自动接受组队
		}

		public static function initSound(scene:Sprite):void {
			SoundManager.registerScene(scene);
			SoundManager.getInstance().sceneVolume=sceneVolume;
			SoundManager.getInstance().soundVolume=gameVolume;
		}
	}
}