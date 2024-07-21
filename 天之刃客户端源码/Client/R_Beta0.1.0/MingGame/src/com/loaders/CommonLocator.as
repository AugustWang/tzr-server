package com.loaders {
	import com.globals.GameConfig;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class CommonLocator {
		public static const SERVER_MAP:String="server_map.xml";
		public static const SKILL_XML_PATH:String="skillTree.xml";
		public static const SKILL_EFFECT:String="skillEffect.xml";
		public static const EQUIP_URL:String="equips.xml";
		public static const ITEM_URL:String="generals.xml";
		public static const STONE_URL:String="stones.xml";
		public static const WORLD_URL:String="maps.xml";
		public static const MONSTER_URL:String="monster.xml";
		public static const BUFF_XML_PATH:String="buff.xml";
		public static const SERVER_NPC_URL:String="server_npc.xml";
		public static const FCM:String="fcm.xml";
		public static const COLLECT:String="collect.xml";
		public static const FAMILY_YBC:String="familyYBC.xml";
		public static const SAY_XML_PATH:String="say.xml";
		public static const TITLE:String="title.xml";
		public static const TASKS:String="tasks.xml";
		public static const DEAL:String="deal.xml";
		public static const MATERIAL:String="material.xml";
		public static const TREASURY:String="treasury.xml";
		public static const FLOWERS:String="flowers.xml";
		public static const PRINCE:String="prince.xml";
		public static const CITY:String="city.xml";
		public static const DRIVERS:String="drivers.xml";
		public static const TRADING:String="trading_item.xml";
		public static const PRESENT:String="present.xml";
		public static const PET_URL:String="pet.xml";
		public static const PET_SAY_URL:String="petSay.xml";
		public static const PET_TRICK_SKILL:String="petTrickSkills.xml";
		public static const ACT_AWARD:String="act_award.xml";
		public static const ACT_TODAY:String="act_today.xml";
		public static const FML_SKILL_XML:String="familySkillResearch.xml";
		public static const ACHIEVEMENT:String="achievement.xml";
		public static const MOUNT_UPGRADE:String="mountUpgrade.xml";
		public static const MATERIALID:String="compose.xml";
		public static const EXPRESION:String="expresion.xml";
		public static const FML_SKILL_BUFF:String="FMLskillBuff.xml";
		public static const VIP:String="vip.xml";
		public static const ITEMLINK:String="itemLink.xml";
		public static const CANTBUYITEM:String="cantBuyItem.xml";
		public static const ACT_GIFT:String="act_gift.xml";
		public static const SCENE_WAR_FB:String="scene_war_npc.xml";
		public static const PERSONAL_FB:String="personalFB.xml";
		public static const HERO_FB:String="hero_fb.xml";
		public static const HORTATION:String="hortation.xml";
		public static const YBC_PERSON_COST:String="ybc_person_cost.xml";
		public static const MONSTER_POS:String="monsterPos.xml";
		public static const HELP:String="help.xml";
		public static const EXPACK:String="ex_pack.xml";
		public static const GOAL_XML_PATH:String = "goal.xml";
		public static const ACTIVITY_FOLLOW:String = "activityFollow.xml";
		private static var map:Dictionary;

		public function CommonLocator() {
		}

		public static function parseXMLFile():void {
			var bytes:ByteArray=ResourcePool.remove(GameConfig.XML_LIB_URL);
			if (bytes) {
				bytes.uncompress();
				map=new Dictionary();
				while (bytes.bytesAvailable != 0) {
					var name:String=bytes.readUTF();
					var size:int=bytes.readInt();
					var xmlData:ByteArray=new ByteArray();
					bytes.readBytes(xmlData, 0, size);
					map[name]=xmlData;
				}
			}
		}

		public static function getXML(fileName:String):XML {
			return new XML(map[fileName]);
		}

		public static function getXMLList(fileName:String):XMLList {
			return new XMLList(map[fileName]);
		}

		public static function getData(fileName:String):* {
			return map[fileName];
		}
	}
}