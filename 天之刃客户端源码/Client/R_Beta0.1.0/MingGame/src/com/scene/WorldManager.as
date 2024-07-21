package com.scene {
	import com.globals.GameConfig;
	import com.loaders.CommonLocator;
	import com.loaders.ResourcePool;
	import com.scene.sceneData.CityVo;
	import com.scene.sceneData.MacroPathVo;
	import com.scene.sceneData.MapDataVo;
	import com.scene.sceneData.MapEncode;
	import com.scene.sceneData.MapTransferVo;
	import com.scene.tile.Pt;
	import com.scene.tile.gameAstar.MCAstar;
	import com.scene.tile.gameAstar.WorldMapGrid;
	import com.zip.ZipEntry;
	import com.zip.ZipFile;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import modules.scene.SceneDataManager;

	public class WorldManager {
		public static const KAI_FENG:int=10200;
		public static const DA_MO:int=10201;
		public static const AN_NAN:int=10202;
		public static const TU_MU_BAO:int=10203;
		public static const QUAN_ZHOU:int=10204;
		public static const ZONG_ZU:int=10300;
		public static const TAO_FA_DI_YING:int=10400;
		public static const DA_MING_BAO_ZANG:int=10500;
		public static const SHI_TU_FU_BEN:int=10600;
		public static const JIAN_YU:int=10700;
		public static const CHENG_SHI_ZHENG_DUO:int=10301;
		public static const SHEN_NONG_JIA:int=10210;
		public static const FU_BEN_1:int=10801;
		public static const FU_BEN_2:int=10802;
		public static const FIRST_MISSION_FB:int=10302;

		private static var allMapsDict:Dictionary;
		private static var mapsXML:XML;
		private static var worldMapData:MapDataVo;
		private static var citys:Dictionary;
		private static var worldGrid:WorldMapGrid;
		private static var astar:MCAstar;


		public static function setup():void {
			parseXML();
//			parseMCM();
		}

		//解析一个地图包，通常是一个国家的或中立区的
		public static function parseMcmBag(mapBag:ByteArray):void {
			if (allMapsDict == null) {
				allMapsDict=new Dictionary;
			}
			var mcms:ZipFile=new ZipFile(mapBag);
			var t:int=getTimer();
			for (var i:int=0; i < mcms.entries.length; i++) {
				var entry:ZipEntry=mcms.entries[i];
				var data:ByteArray=mcms.getInput(entry);
				if (entry.name.indexOf(".mcm") != -1) {
					var key:String=entry.name.substr(0, 5);
					if (allMapsDict[key] == null) {
						allMapsDict[key]=data;
						if (key == "world") {
							parseMCM();
						}
					}
				}
			}
		}

		//获取一个地图数据
		public static function getMapDataVo(mapID:int):MapDataVo {
			var obj:Object=allMapsDict[mapID.toString()];
			if (obj) {
				if (obj is ByteArray) {
					allMapsDict[mapID]=MapEncode.encodeByteArray(obj as ByteArray);
					return allMapsDict[mapID];
				} else if (obj is MapDataVo) {
					return obj as MapDataVo;
				}
			}
			return null;
		}

		private static function parseMCM():void {
			var bytes:ByteArray=allMapsDict["world"];
			worldMapData=MapEncode.encodeByteArray(bytes);

			worldGrid=new WorldMapGrid(worldMapData);
			astar=new MCAstar(worldGrid);
		}

		private static function parseXML():void {
			citys=new Dictionary;
			var data:XML=CommonLocator.getXML(CommonLocator.WORLD_URL);
			if (data) {
				mapsXML=data;
				var _xml_:XMLList=mapsXML.child('country')
				var len:int=_xml_.length();
				var vo_:MacroPathVo;
				var xml:XML;
				var xml_:XML;
				for (var i_:int=0; i_ < len; i_++) {
					var countrys:XMLList=_xml_[i_].child('map');
					var len_:int=countrys.length();
					for (var i:int=0; i < len_; i++) {
						xml_=countrys[i];
						var vo:CityVo=new CityVo();
						vo.init();
						vo.id=int(xml_.@id);
						vo.name=xml_.@name;
						vo.url=xml_.@url;
						vo.posx=int(String(xml_.@pos).split('|')[0]);

						vo.posy=int(String(xml_.@pos).split('|')[1]);
						vo.scale=Number(xml_.@scale);
						vo.music=String(xml_.@music);
						vo.turn_map_abled=int(xml_.@turn_map_abled);
						vo.level=int(xml_.@index);
						vo.countryId=int(vo.id.toString().substr(0, 2));
						var children:XMLList=xml_.child('children')[0].child('point');
						var len_j:int=children.length();
						for (var j:int=0; j < len_j; j++) {
							xml=children[j];
							vo_=new MacroPathVo(int(xml.@tar_map), new Pt(int(xml.@x), 0, int(xml.@y)));
							if (vo.children[vo_.mapid.toString()] == null)
								vo.children[vo_.mapid.toString()]=vo_;
						}

						var parents:XMLList=xml_.child('prents')[0].child('point');
						var len_k:int=parents.length();
						for (var k:int=0; k < len_k; k++) {
							xml=parents[k];
							vo_=new MacroPathVo(int(xml.@tar_map), new Pt(int(xml.@x), 0, int(xml.@y)));
							if (vo.parents[vo_.mapid.toString()] == null)
								vo.parents[vo_.mapid.toString()]=vo_;
						}

						var renascences:XMLList=xml_.child('renascence')[0].child('map');
						var len_r:int=renascences.length();
						for (var r:int=0; r < len_r; r++) {
							xml=renascences[r];
							vo_=new MacroPathVo(int(xml.@tar_map), null);
							vo.renascence.push(vo_);
						}

						var livePoints:XMLList=xml_.child('livePoints')[0].child('point');
						var len_n:int=livePoints.length();
						for (var n:int=0; n < len_n; n++) {
							xml=livePoints[n];
							vo_=new MacroPathVo(int(xml.@tar_map), new Pt(int(xml.@x), 0, int(xml.@y)));
							vo.livePoints.push(vo_);
						}
						if (citys[vo.id] == null)
							citys[vo.id]=vo;
					}
				}
			}
		}

		public static function getCityVo(mapid:int):CityVo {
			if (citys[mapid + ""] == null) {
				throw new Error("找不到地图ID为：" + mapid + "的配置");
				return null;
			}
			return citys[mapid + ""] as CityVo;
		}

		public static function getCurrentCity():CityVo {
			var mapid:int=SceneDataManager.mapData.map_id;
			return citys[mapid + ""] as CityVo;
		}

		public static function getMapName(mapid:int):String {
			var name:String="";
			var vo:CityVo=getCityVo(mapid);
			if (vo != null) {
				name=vo.name;
			}
			return name;
		}

		public static function getWorldPath(startMap:MacroPathVo, endMap:MacroPathVo):Array {
			if (startMap.mapid == endMap.mapid) { //本地图寻路
				return [endMap];
			}
			var startCity:CityVo=getCityVo(startMap.mapid);
			var endCity:CityVo=getCityVo(endMap.mapid);
			var startPt:Pt=mapToPt(startMap.mapid);
			var endPt:Pt=mapToPt(endMap.mapid);
			if (startPt == null || endPt == null) {
				return null;
			}
			//跨地图寻路
			var fullPath:Array=astar.findPath(startPt, endPt);
			var mapPath:Array=[];
			for (var i:int=0; i < fullPath.length; i++) { //清除不是地图的格子
				var pt:Pt=fullPath[i];
				var trans:MapTransferVo=ptHasMap(pt);
				if (trans != null) {
					mapPath.push(trans);
				}
			}
			var result:Array=[];
			var dic:Dictionary=new Dictionary;
			for (i=0; i < mapPath.length - 1; i++) {
				var ep1:MapTransferVo=mapPath[i];
				var vo1:CityVo=getCityVo(ep1.id);

				var ep2:MapTransferVo=mapPath[i + 1];
				var vo2:CityVo=getCityVo(ep2.id);
				var mac:MacroPathVo=getJumpVo(vo1, vo2);
				if (mac) {
					if (dic[mac.mapid.toString()] == null) {
						result.push(mac);
						dic[mac.mapid.toString()]=mac.mapid.toString();
					}
				}
			}
			result.push(endMap);
			return result;
		}

		private static function mapToPt(map_id:int):Pt {
			for (var i:int=0; i < worldMapData.transfers.length; i++) {
				var ep:MapTransferVo=worldMapData.transfers[i] as MapTransferVo;
				if (map_id == ep.id) {
					return new Pt(ep.tx, 0, ep.ty)
					break;
				}
			}
			return null;
		}

		private static function ptHasMap(pt:Pt):MapTransferVo {
			for (var i:int=0; i < worldMapData.transfers.length; i++) {
				var ep:MapTransferVo=worldMapData.transfers[i] as MapTransferVo
				if (ep.tx == pt.x && ep.ty == pt.z) {
					return ep;
				}
			}
			return null;
		}

		//得到一个MacroPathVo，mapid本地图的，pt是本地图的跳转点位置
		private static function getJumpVo(vo1:CityVo, vo2:CityVo):MacroPathVo {
			var child:MacroPathVo;
			var vo:MacroPathVo;
			for (var i:String in vo1.children) {
				vo=vo1.children[i];
				if (vo.mapid == vo2.id) {
					child=vo;
					break;
				}
			}
			var parent:MacroPathVo;
			for (var j:String in vo1.parents) {
				vo=vo1.parents[j];
				if (vo.mapid == vo2.id) {
					parent=vo;
					break;
				}
			}
			var vo_:MacroPathVo=new MacroPathVo(vo1.id, new Pt);
			if (child && parent) {
				vo_.pt.x=child.pt.x;
				vo_.pt.z=child.pt.z;
				return vo_;
			} else if (child) {
				vo_.pt.x=child.pt.x;
				vo_.pt.z=child.pt.z;
				return vo_;
			} else if (parent) {
				vo_.pt.x=parent.pt.x;
				vo_.pt.z=parent.pt.z;
				return vo_;
			}
			return null;
		}
	}
}