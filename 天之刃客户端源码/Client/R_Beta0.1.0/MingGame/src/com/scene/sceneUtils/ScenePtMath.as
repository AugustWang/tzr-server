package com.scene.sceneUtils {
	import com.common.GlobalObjectManager;
	import com.scene.sceneData.BinaryMath;
	import com.scene.tile.Pt;
	import com.scene.tile.TileUitls;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import modules.scene.SceneDataManager;

	public class ScenePtMath {

		public function ScenePtMath() {
		}

		/**
		 * 判断一个PT点是否有阻碍
		 * @param pt
		 * @return
		 *
		 */
		public static function getPassAbled(pt:Pt):Boolean {
			var isPass:Boolean=true;
			var center:Point=TileUitls.getIsoIndexMidVertex(pt);
			var rectSize:int=100;
			var rect:Rectangle=new Rectangle(center.x - rectSize / 2, center.y - rectSize / 2, rectSize, rectSize)
			return isPass;
		}

		public static function getNearPt(pt:Pt, dis:int, isOutline:Boolean=true, onlyWalkAbled:Boolean=true):Pt {
			var tarpt:Pt;
			var dx:int;
			var dz:int;
			var cell:int;
			while (true) {
				dx=int(Math.random() * (dis * 2 + 1)) - dis;
				dz=int(Math.random() * (dis * 2 + 1)) - dis;
				if (isOutline == true) { //是否只取最外围
					if (Math.abs(dx) == dis || Math.abs(dz) == dis) {
						tarpt=new Pt(pt.x + dx, 0, pt.z + dz);
						if (onlyWalkAbled == true) {
							cell=SceneDataManager.getCell(tarpt.x, tarpt.z)
							if (BinaryMath.isExist(cell) == true) {
								break;
							}
						} else {
							break;
						}
					}
				} else {
					tarpt=new Pt(pt.x + dx, 0, pt.z + dz);
					if (onlyWalkAbled == true) {
						cell=SceneDataManager.getCell(tarpt.x, tarpt.z)
						if (BinaryMath.isExist(cell) == true) {
							break;
						}
					} else {
						break;
					}
				}
			}
			return tarpt;
		}

		/**
		 * 获得前进方向上左边的格子
		 * @param pt 前方的格子
		 * @param enterDir 前进的方向
		 * @return
		 *
		 */
		public static function getLeftPassPt(pt:Pt, enterDir:int):Pt {
			var tarPt:Pt=getDirPt(pt, (enterDir + 2) % 8);
			var cell:int=SceneDataManager.getCell(pt.x, pt.z);
			if (BinaryMath.isExist(cell) == true) {
				return tarPt;
			}
			return null;
		}

		/**
		 * 获得pt的dir方向上的pt
		 * @param pt
		 * @param dir
		 * @return
		 *
		 */
		public static function getDirPt(pt:Pt, dir:int):Pt {
			var dirPt:Pt;
			switch (dir) {
				case 0:
					dirPt=new Pt(pt.x - 1, 0, pt.z - 1);
					break;
				case 1:
					dirPt=new Pt(pt.x, 0, pt.z - 1);
					break;
				case 2:
					dirPt=new Pt(pt.x + 1, 0, pt.z - 1);
					break;
				case 3:
					dirPt=new Pt(pt.x + 1, 0, pt.z);
					break;
				case 4:
					dirPt=new Pt(pt.x + 1, 0, pt.z + 1);
					break;
				case 5:
					dirPt=new Pt(pt.x, 0, pt.z + 1);
					break;
				case 6:
					dirPt=new Pt(pt.x - 1, 0, pt.z + 1);
					break;
				case 7:
					dirPt=new Pt(pt.x - 1, 0, pt.z);
					break;
				default:
					break;
			}
			return dirPt;
		}

		//		public static 
		public static function getFrontPt(pt:Pt, distance:int):Pt {
			var tx:int;
			var ty:int;
			var dir:int=Math.floor(Math.random() * 5);
			switch (dir) {
				case 0: //右
					tx=pt.x + distance;
					ty=pt.z - distance;
					break;
				case 1:
					tx=pt.x + distance;
					ty=pt.z;
					break;
				case 2:
					tx=pt.x + distance;
					ty=pt.z + distance;
					break;
				case 3:
					tx=pt.x;
					ty=pt.z + distance;
					break;
				case 4:
					tx=pt.x - distance;
					ty=pt.z + distance;
					break;
			}
			return new Pt(tx, 0, ty);
		}

		public static function checkDistance(pt1:Pt, pt2:Pt):int {
			var d1:int=Math.abs(pt1.x - pt2.x);
			var d2:int=Math.abs(pt1.z - pt2.z);
			var d:int=d1 >= d2 ? d1 : d2;
			return d;
		}

		public static function get isInNation():Boolean {
			var b:Boolean;
			var myFaction:String="1" + GlobalObjectManager.getInstance().user.base.faction_id;
			var map_id:int=SceneDataManager.mapData.map_id;
			var currentFaction:String=String(map_id).substr(0, 2);
			if (currentFaction == myFaction) {
				b=true;
			}
			return b;
		}

		public static function getNearestPt(myPt:Pt, tarPt:Pt):Pt {
			var dir:int=getDretion(myPt, tarPt);
			dir=(dir + 4) % 8;
			var pt:Pt=getDirPt(tarPt, dir);
			return pt;
		}

		/**
		 * 获得pt点后面2格的pt
		 * @param pt
		 * @param dir
		 * @return
		 *
		 */
		public static function getBackPt(pt:Pt, dir:int):Pt {
			var backDir:int=(dir + 4) % 8;
			var p:Pt=getDirPt(pt, backDir);
			var tarpt:Pt=getDirPt(p, backDir);
			return tarpt;
		}

		/**
		 * 获取某方向上距离为dis的Pt
		 * @param pt
		 * @param dir
		 * @param dis
		 * @return
		 *
		 */
		public static function getDirDisPt(pt:Pt, dir:int, dis:int):Pt {
			var dirPt:Pt;
			switch (dir) {
				case 0:
					dirPt=new Pt(pt.x - dis, 0, pt.z - dis);
					break;
				case 1:
					dirPt=new Pt(pt.x, 0, pt.z - dis);
					break;
				case 2:
					dirPt=new Pt(pt.x + dis, 0, pt.z - dis);
					break;
				case 3:
					dirPt=new Pt(pt.x + dis, 0, pt.z);
					break;
				case 4:
					dirPt=new Pt(pt.x + dis, 0, pt.z + dis);
					break;
				case 5:
					dirPt=new Pt(pt.x, 0, pt.z + dis);
					break;
				case 6:
					dirPt=new Pt(pt.x - dis, 0, pt.z + dis);
					break;
				case 7:
					dirPt=new Pt(pt.x - dis, 0, pt.z);
					break;
				default:
					break;
			}
			return dirPt;
		}

		public static function getDretion(my:Pt, tarPt:Pt):int {
			var myP:Point=TileUitls.getIsoIndexMidVertex(my);
			var tarP:Point=TileUitls.getIsoIndexMidVertex(tarPt);
			var dir:int;
			//dgr范围：-180到180
			var x1:Number=tarP.x - myP.x;
			var y1:Number=tarP.y - myP.y;
			var ang:Number=Math.atan2(y1, x1) * 180 / Math.PI;
			if (ang >= -15 && ang < 15) {
				dir=2;
			} else if (ang >= 15 && ang < 75) {
				dir=3;
			} else if (ang >= 75 && ang < 105) {
				dir=4;
			} else if (ang >= 105 && ang < 170) {
				dir=5;
			} else if (ang >= 170 || ang < -170) {
				dir=6;
			} else if (ang >= -75 && ang < -15) {
				dir=1;
			} else if (ang >= -105 && ang < -75) {
				dir=0;
			} else if (ang >= -170 && ang < -105) {
				dir=7;
			}
			return dir;
		}

		public static function getPetPt(pt:Pt, dir:int, dis:int=1):Pt {
			var pet:Pt;
			switch (dir) {
				case 0:
					pet=new Pt(pt.x + dis, 0, pt.z);
					break;
				case 1:
					pet=new Pt(pt.x + dis, 0, pt.z + dis-2);
					break;
				case 2:
					pet=new Pt(pt.x, 0, pt.z + dis);
					break;
				case 3:
					pet=new Pt(pt.x - (dis - 1), 0, pt.z + (dis - 1));
					break;
				case 4:
					pet=new Pt(pt.x - dis, 0, pt.z);
					break;
				case 5:
					pet=new Pt(pt.x - dis, 0, pt.z - (dis - 2));
					break;
				case 6:
					pet=new Pt(pt.x, 0, pt.z - dis);
					break;
				case 7:
					pet=new Pt(pt.x + (dis - 1), 0, pt.z - (dis - 1));
					break;
				default:
					pet=new Pt(pt.x, 0, pt.z);
					break;
			}
			return pet;
		}
	}
}