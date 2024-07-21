package com.scene.sceneUnit.configs {
	import com.loaders.CommonLocator;
	import com.scene.tile.Pt;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;


	public class MonsterConfig {
		public static var hash:Dictionary=new Dictionary;
		public static var nameHash:Dictionary=new Dictionary;
		private static var serverHash:Dictionary=new Dictionary();
		public static var MONSTER_URL:String;
		public static var SERVER_NPC_URL:String;
		private static var serverNPCXML:XML;
		private static var sayXML:XML;
		private static var _posHash:Dictionary=new Dictionary();
		private static var typePosHash:Dictionary=new Dictionary(); //一类怪物的位置，与上面是同个功能的另一种做法

		public function MonsterConfig() {
		}

		public static function init():void {
			var data:XML=CommonLocator.getXML(CommonLocator.MONSTER_URL);
			for each (var t:XML in data.children()) {
				var vo:MonsterType=new MonsterType;
				vo.icon=t.@entIcon;
				vo.level=t.@level;
				vo.monstername=t.@monstername;
				vo.skinid=int(t.@skinid);
				vo.type=t.@typeid;
				vo.rarity=t.@rarity;
				vo.say=t.@dialogIds;
				hash[int(t.@typeid)]=vo;
				if (nameHash[vo.monstername] == null) { //一个怪物名可能
					nameHash[vo.monstername]=new Array;
				}
				(nameHash[vo.monstername] as Array).push(vo);
			}
			var pos:XML=CommonLocator.getXML(CommonLocator.MONSTER_POS);
			for each (var p:XML in pos.children()) {
				var mapID:int=int(p.@id);
				if (typePosHash[mapID] == null) {
					typePosHash[mapID]=new Dictionary;
				}
				var children:XMLList=p.child('monster');
				var len:int=children.length();
				var xml:XML;
				for (var j:int=0; j < len; j++) {
					xml=children[j];
					typePosHash[mapID][String(xml.@typeid)]=new Pt(xml.@x, 0, xml.@y);
				}
			}
		}

		public static function getMonsterByName(monster_name:String):Array {
			var arr:Array=MonsterConfig.nameHash[monster_name];
			return arr;
		}

		public static function getServerNPCByType(typeId:int):Object {
			if (serverNPCXML == null) {
				serverNPCXML=CommonLocator.getXML(CommonLocator.SERVER_NPC_URL);
			}
			if (serverHash[typeId]) {
				return serverHash[typeId];
			}
			var result:XMLList=serverNPCXML.servernpc.(@typeid == typeId);
			if (result.length() == 0) {
				throw new Error("不存在typeId为" + typeId + "的战斗NPC.");
			}
			var xml:XML=result[0];
			var serverNPC:Object={typeid: typeId, skinid: String(xml.@skinid), path: String(xml.@path), level: int(xml.@level)};
			serverHash[typeId]=serverNPC;
			return serverNPC;
		}

		public static function getSayById($id:int):String {
			if (sayXML == null) {
				sayXML=CommonLocator.getXML(CommonLocator.SAY_XML_PATH);
			}
			return sayXML.item.(@id == $id).@data;
		}

		/**
		 * 设置某只怪物的坐标
		 */
		static public function setPos(monsterTypeID:int, mapID:int, tx:int, ty:int):void {
			if (!MonsterConfig._posHash[mapID]) {
				MonsterConfig._posHash[mapID]=new Dictionary();
			}
			MonsterConfig._posHash[mapID][monsterTypeID]=[tx, ty];
		}

		/**
		 * 获取某只怪物的坐标
		 * @return [tx, ty]
		 */
		static public function getPos(mapdID:*, monsterTypeID:*):Array {
			return MonsterConfig._posHash[mapdID][monsterTypeID];
		}

		/**
		 * 替换上面的方法
		 */
		public static function getMonsterPos(mapID:int, monsterTypeID:*):Pt {
			if (typePosHash[mapID] && typePosHash[mapID][monsterTypeID]) {
				return typePosHash[mapID][monsterTypeID];
			}
			return null;
		}
		
		public static function getMonsterPosByMap(mapID:int):Dictionary{
			if(typePosHash[mapID]){
				return typePosHash[mapID]
			}
			return null;
		}
	}
}