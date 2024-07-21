package com.globals {

	/**
	 * 管理游戏所有基本配置设置(1，资源文件和配置文件路径，2，以及基本调试配置)
	 */
	public class GameConfig {
		/**
		 * 是否初始化游戏
		 */
		public static var initGame:Boolean=false;
		/**
		 * 资源根目录
		 */
		public static var ROOT_URL:String="";
		/**
		 * 游戏资源路径
		 */
		public static var GAME_URL:String="MingGame.swf";
		public static var CREATE_ROLE_URL:String="createRoleCQ2.swf";
		public static var CONFIG_URL:String="assets/configure.xml";
		public static var XML_LIB_URL:String="com/xmllib/xml.lib";
		public static var WORDFILTER:String="com/data/wordfilter.txt";
		public static var VIEWUI_URL:String="com/assets/viewUI/viewUI.swf";
		public static var FACES_URL:String="com/assets/chat/faceIcons.swf";
		public static var SOUND_URL:String="com/assets/sound/sound.swf";
		public static var ARROW_URL:String="com/assets/arrow.swf";
		public static var WORLDMCM_URL:String="com/maps/world.mcm";
		public static var GOAL_URL:String="com/assets/goal/goal.swf";
		//Avatar 
		public static var DEFLUT_BODY_MAN_URL:String="com/ui/role/man.swf";
		public static var DEFLUT_BODY_WOMEN_URL:String="com/ui/role/woman.swf";
		public static var DEFLUT_MOUNT_MAN_URL:String="com/ui/role/mount/man.swf";
		public static var DEFLUT_MOUNT_WOMAN_URL:String="com/ui/role/mount/woman.swf";

		public static var BODY_PATH:String="com/ui/role/";
		public static var EQUIP_PATH:String="com/ui/role/equips/";
		public static var FASHION_PATH:String="com/ui/role/fashion/"
		public static var HAIR_MAN_PATH:String="com/ui/role/hairMan";
		public static var HAIR_WOMAN_PATH:String="com/ui/role/hairWoman";
		public static var HAIR_MAN_MOUNT_PATH:String="com/ui/role/mount/hairManMount";
		public static var HAIR_WOMAN_MOUNT_PATH:String="com/ui/role/mount/hairWomanMount";
		public static var MOUNT_PATH:String="com/ui/role/mount/";
		public static var NPC_PATH:String="com/ui/npc/";
		public static var NPCS_PATH:String='com/npcs/';
		public static var YBC_PATH:String="com/ui/ybc/";
		public static var COLLECT_PATH:String="com/ui/collect/";
		public static var OTHER_PATH:String="com/ui/other/";
		public static var MOUSE_ICON_PATH:String="com/ui/mouseIcon/";
		public static var DROP_ITEM_ICON:String="com/ui/DropItemIcon/";
		public static var EFFECT_SCENE:String="com/ui/effect_scene/";
		public static var EFFECT_SKILL_PATH:String="com/ui/effect/skill/";
		public static var EFFECT_PATH:String="com/ui/effect/";
		public static var EFFECT_PET_PATH:String="com/ui/effect/pet/";
		public static var FACE_PATH:String="com/ui/face/";
		public static var PLANTING_URL:String="com/ui/planting/planting.swf";
		public static var BUFF_ICON_PATH:String="com/assets/buffIcon/";

		public static var PLAYER_URL:String="com/assets/newPlayer/player.swf";
		public static var DATA_LOADING_URL:String="com/assets/loading/dataloading.swf";
		public static var NPC_DATA_URL:String='com/data/npc_data.txt'; //npc数据
		public static var POS_URL:String="com/data/pos.txt"; //所有地图上物品的位置信息
		
		//游戏新资源，
		public static var T1_UI:String="com/assets/t1UI/T1UI.swf"; 
		public static var T1_VIEWUI:String="com/assets/t1ViewUI/T1ViewUI.swf";
		public static var HERO_FB:String="com/assets/hero_fb/hero_fb.swf";
		public static var MOVIE_UI:String = "com/assets/t1ViewUI/movie.swf";
		public static var SKILL_UI:String = "com/assets/skillUI/skillUI.swf";
		public static var VIP_UI:String = "com/assets/vip/vip.swf";
		public static var SHOP_UI:String = "com/assets/shop/shop.swf";
		public static var STOVE_UI:String = "com/assets/stove/stove.swf";
		public static var BIG_EXPRESION_UI:String = "com/assets/bigExpresion/bigExpresion.swf";
		public static var CREDIT_UI:String = "com/assets/credit/creditUI.swf";
		public static var BOSS_GROUP_XML_URL:String = "com/assets/bossgroup/bossgroup.xml";
		public static var ACHIEVEMENT_UI:String = "com/assets/achievementIcon/achievement.swf";
		public static var BACK_IMAGES:String = "com/assets/backGroundImages/";
		public static var PET_UI:String = "com/assets/pet/pet.swf";
		/**
		 * 战士职业
		 */
		public static const CATEGORY_WARRIOR:int = 1;
		/**
		 * 射手职业
		 */
		public static const CATEGORY_HUNTER:int = 2;
		/**
		 * 侠客职业
		 */
		public static const CATEGORY_RANGER:int = 3;
		/**
		 * 医仙职业
		 */
		public static const CATEGORY_DOCTOR:int = 4;
		
		/**
		 * 缩进字符串定义
		 */
		public static const SUO_JIN_STR:String = '        ';
		
		/**
		 * 换行字符定义
		 */
		public static const N_STR:String = '\n';
		
		/**
		 * 替换缩进
		 */
		static public const S_REG_EXP:RegExp = /\#S\#/g;
		
		/**
		 * 替换换行
		 */
		static public const N_REG_EXP:RegExp = /\#N\#/g;
		
		
		/**
		 * 任务杂项配置 - 进入游戏后加载
		 */
		public static var MISSION_SETTING:String='com/data/mission_setting.txt'; 
		/**
		 * 任务基础数据配置 -- 预加载
		 */
		public static var MISSION_DATA_URL:String='com/data/missions.txt';

		public function GameConfig() {
		}

		public static function wrapperURL():void {
			if (GameParameters.getInstance().localDebug != 'true') {
				GAME_URL=ROOT_URL + GAME_URL;	
				CONFIG_URL=ROOT_URL + CONFIG_URL;
			} else {
				GAME_URL=GAME_URL;
				CONFIG_URL=CONFIG_URL;
			}
			CREATE_ROLE_URL=CREATE_ROLE_URL;
			XML_LIB_URL=ROOT_URL + XML_LIB_URL;
			WORDFILTER=ROOT_URL + WORDFILTER;
			VIEWUI_URL=ROOT_URL + VIEWUI_URL;
			FACES_URL=ROOT_URL + FACES_URL;
			SOUND_URL=ROOT_URL + SOUND_URL;
			ARROW_URL=ROOT_URL + ARROW_URL;

			DEFLUT_BODY_MAN_URL=ROOT_URL + DEFLUT_BODY_MAN_URL;
			DEFLUT_BODY_WOMEN_URL=ROOT_URL + DEFLUT_BODY_WOMEN_URL;
			DEFLUT_MOUNT_MAN_URL=ROOT_URL + DEFLUT_MOUNT_MAN_URL;
			DEFLUT_MOUNT_WOMAN_URL=ROOT_URL + DEFLUT_MOUNT_WOMAN_URL;

			BODY_PATH=ROOT_URL + BODY_PATH;
			EQUIP_PATH = ROOT_URL + EQUIP_PATH;
			FASHION_PATH=ROOT_URL + FASHION_PATH;
			HAIR_MAN_PATH=ROOT_URL + HAIR_MAN_PATH;
			HAIR_WOMAN_PATH=ROOT_URL + HAIR_WOMAN_PATH;
			HAIR_MAN_MOUNT_PATH=ROOT_URL + HAIR_MAN_MOUNT_PATH;
			HAIR_WOMAN_MOUNT_PATH=ROOT_URL + HAIR_WOMAN_MOUNT_PATH;
			MOUNT_PATH=ROOT_URL + MOUNT_PATH;
			NPC_PATH=ROOT_URL + NPC_PATH;
			NPCS_PATH=ROOT_URL + NPCS_PATH;
			YBC_PATH=ROOT_URL + YBC_PATH;
			COLLECT_PATH=ROOT_URL + COLLECT_PATH;
			OTHER_PATH=ROOT_URL + OTHER_PATH;
			MOUSE_ICON_PATH=ROOT_URL + MOUSE_ICON_PATH;
			DROP_ITEM_ICON=ROOT_URL + DROP_ITEM_ICON;
			EFFECT_SCENE=ROOT_URL + EFFECT_SCENE;
			EFFECT_SKILL_PATH=ROOT_URL + EFFECT_SKILL_PATH;
			EFFECT_PATH=ROOT_URL + EFFECT_PATH;
			EFFECT_PET_PATH=ROOT_URL + EFFECT_PET_PATH;
			FACE_PATH=ROOT_URL + FACE_PATH;
			PLANTING_URL=ROOT_URL + PLANTING_URL;
			BUFF_ICON_PATH=ROOT_URL + BUFF_ICON_PATH;
			PLAYER_URL=ROOT_URL + PLAYER_URL;
			WORLDMCM_URL=ROOT_URL + WORLDMCM_URL;
			DATA_LOADING_URL=ROOT_URL + DATA_LOADING_URL;
			MISSION_DATA_URL=ROOT_URL + MISSION_DATA_URL;
			NPC_DATA_URL=ROOT_URL + NPC_DATA_URL;
			POS_URL=ROOT_URL + POS_URL;
			MISSION_SETTING=ROOT_URL + MISSION_SETTING;
			
			T1_UI = ROOT_URL+T1_UI; 
			T1_VIEWUI = ROOT_URL + T1_VIEWUI;
			HERO_FB = ROOT_URL + HERO_FB;
			MOVIE_UI = ROOT_URL + MOVIE_UI;
			SKILL_UI = ROOT_URL + SKILL_UI;
			VIP_UI = ROOT_URL + VIP_UI;
			SHOP_UI = ROOT_URL + SHOP_UI;
			STOVE_UI = ROOT_URL + STOVE_UI;
			BIG_EXPRESION_UI = ROOT_URL + BIG_EXPRESION_UI;
			CREDIT_UI = ROOT_URL+CREDIT_UI;
			BOSS_GROUP_XML_URL = ROOT_URL + BOSS_GROUP_XML_URL;
			ACHIEVEMENT_UI = ROOT_URL+ACHIEVEMENT_UI;
			BACK_IMAGES = ROOT_URL + BACK_IMAGES;
			PET_UI = ROOT_URL + PET_UI;
		}
		
		public static function getBackImage(name:String,type:String=".png"):String{
			return BACK_IMAGES+name+type;
		}
	}
}