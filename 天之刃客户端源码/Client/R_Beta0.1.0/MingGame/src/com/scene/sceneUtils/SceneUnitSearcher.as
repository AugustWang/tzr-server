package com.scene.sceneUtils {
	import com.common.GlobalObjectManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.tile.Pt;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import modules.factionsWar.FactionWarDataManager;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.managers.PackManager;
	import modules.roleStateG.RoleStateDateManager;
	import modules.scene.SceneDataManager;
	import modules.system.SystemConfig;

	import proto.common.p_map_dropthing;

	public class SceneUnitSearcher {
		public static var selectedKeys:Array=new Array;
		public static var pickFailed:int;

		public function SceneUnitSearcher() {
		}

		public static function seachDropThing(pos:Pt):DropThing {
			var acceptTypes:Array=[SystemConfig.autoPickEquip, SystemConfig.autoPickmedicine, SystemConfig.autoPickStone, SystemConfig.autoPickother];
			var acceptColors:Array=makeAcceptColors(SystemConfig.pickEquipColors);
			var otherColors:Array=makeAcceptColors(SystemConfig.pickOtherColors);
			var tar:DropThing;
			var tid:int=-1;
			var d:Number=-1;
			var dict:Dictionary=SceneUnitManager.myDropThing;
			for (var s:String in dict) {
				var a:DropThing=dict[s] as DropThing;
				var pvo:p_map_dropthing=a.pvo;
				var isWant:Boolean=checkIsWant(pvo, acceptTypes, acceptColors, otherColors);
				if (isWant == true && a.id != pickFailed) { //想要的东西，并且没捡失败过
					if (pvo.roles.length == 0 || typeInArray(GlobalObjectManager.getInstance().user.base.role_id, pvo.roles) == true) { //东西所属有我的份
						var isBagFull:Boolean; //是否有空间可以放
						if (pvo.ismoney == true) {
							isBagFull=false;
						} else {
							isBagFull=PackManager.getInstance().isBagFull();
						}
						if (isBagFull == false) {
							//距离判断
							var dd:int=checkInDistance(pos, a.index)
							if (dd <= 10) {
								if (d == -1 || dd < d) {
									d=dd;
									tar=a;
								}
							}
						}
					}
				}
			}
			return tar;
		}

		/**
		 *
		 * @param vo
		 * @param acceptTypes [装备][药品][灵石][其他]
		 * @param acceptColors
		 * @return
		 *
		 */
		private static function checkIsWant(vo:p_map_dropthing, acceptTypes:Array, acceptColors:Array, otherColors:Array):Boolean { //1道具 ，2 宝石 ， 3 装备
			var want:Boolean;
			if (vo.ismoney == true) {
				want=true;
			} else {
				var equit:Boolean=acceptTypes[0];
				var drug:Boolean=acceptTypes[1];
				var stone:Boolean=acceptTypes[2];
				var other:Boolean=acceptTypes[3];
				if (vo.goodstype == 3 && equit == true) {
					if (typeInArray(vo.drop_property.colour, acceptColors) == true) {
						want=true;
					}
				} else if (vo.goodstype == 2 && stone == true) {
					want=true;
				} else if (vo.goodstype == 1) { //goodstype==1有可能是药，也有可能是其他
					if (ItemLocator.getInstance().getObject(vo.goodstypeid).kind == 2) {
						if (drug == true) {
							want=true;
						}
					} else {
						if (other == true && typeInArray(vo.drop_property.colour, otherColors) == true) {
							want=true;
						}
					}
				}
			}
			return want;
		}

		public static function makeAcceptTypes(equit:Boolean, drug:Boolean, stone:Boolean, other:Boolean):Array {
			var arr:Array=[];
			if (equit)
				arr.push(3);
			if (drug)
				arr.push(1);
			if (stone)
				arr.push(2);
			if (other)
				arr.push(1);
			return arr;
		}

		public static function makeAcceptColors(colors:Array):Array {
			var arr:Array=[];
			if (colors[0])
				arr.push(1);
			if (colors[1])
				arr.push(2);
			if (colors[2])
				arr.push(3);
			if (colors[3])
				arr.push(4);
			if (colors[4])
				arr.push(5);
			if (colors[5])
				arr.push(6);
			return arr;
		}

		private static function typeInArray(type:int, arr:Array):Boolean {
			for (var i:int=0; i < arr.length; i++) {
				if (type == arr[i]) {
					return true;
				}
			}
			return false;
		}

		private static function checkInDistance(pos:Pt, goodPt:Pt):int {
			var d1:int=Math.abs(pos.x - goodPt.x);
			var d2:int=Math.abs(pos.z - goodPt.z);
			var d3:int=d1 >= d2 ? d1 : d2;
			return d3;
		}

		//找附近掉落物
		public static function searchNearItem(pt:Pt):DropThing {
			var tar:DropThing;
			var dict:Dictionary=SceneUnitManager.dropthingHash;
			for (var s:String in dict) {
				var a:DropThing=dict[s];
				var pvo:p_map_dropthing=DropThing(a).pvo;
				if (pvo.id != pickFailed) {
					var dd:int=checkInDistance(pt, a.index)
					if (dd <= 5) {
						tar=a;
						break;
					}
				}
			}
			return tar;
		}

		//找可攻击目标
		public static function SearchEmeny():MutualAvatar {
			var tar:MutualAvatar;
			var dic:Dictionary=SceneUnitManager.unitHash;
			var rect:Rectangle=new Rectangle(0, 0, 1002, 545);
			var offsetX:int=SceneDataManager.mapData.offsetX;
			var offsetY:int=SceneDataManager.mapData.offsetY;
			for (var s:String in dic) {
				var a:DisplayObject=dic[s] as DisplayObject;
				if (a is MutualAvatar == false || MutualAvatar(a).isDead == true || MutualAvatar(a).isConceal == true) {
					continue;
				}
				if (SceneCheckers.checkIsEnemy(a as MutualAvatar) == true) {
					if (selectedKeys.indexOf(s) == -1) {
						if (RoleStateDateManager.seletedUnit == null || RoleStateDateManager.seletedUnit.key != s) {
							var p:Point=a.localToGlobal(new Point());
							if (rect.contains(p.x, p.y) == true) {
								tar=a as MutualAvatar;
								selectedKeys.push(s);
								break;
							}
						}
					}
				}
			}
			if (tar == null) {
				selectedKeys.length=0;
			}
			return tar;
		}

		/**
		 * 通过目的地怪物
		 * @param matchPos
		 * @return
		 */
		public static function searchMonsterByType(matchPos:Pt, monsterType:int):Monster {
			var monsters:Dictionary=SceneUnitManager.monsterHash;
			var monster:Monster;
			var monsterTemp:Monster;
			var dis:int=-1;
			for (var s:String in monsters) {
				monsterTemp=monsters[s];
				if (monsterTemp.isDead)
					continue;
				if (monsterType == monsterTemp.pvo.typeid) {
					var d:int=checkInDistance(matchPos, monsterTemp.index);
					if (dis == -1 || d < dis) {
						dis=d;
						if (monsterTemp.pvo != null) {
							monster=monsterTemp;
						}
					}
				}
			}
			return monster;
		}

		public static function searchCollectionByType(matchPos:Pt, collectType:int):Collection {
			var units:Dictionary=SceneUnitManager.unitHash;
			var collection:Collection;
			var collectionTemp:Collection;
			var unit:IMutualUnit;
			var dis:int=-1;
			for (var s:String in units) {
				unit=units[s];
				if (unit.sceneType == SceneUnitType.COLLECT_TYPE) {
					collectionTemp=Collection(unit);
				} else {
					continue;
				}
				if (collectType == collectionTemp.pvo.typeid) {
					var d:int=checkInDistance(matchPos, collectionTemp.index);
					if (dis == -1 || d < dis) {
						dis=d;
						if (collectionTemp.pvo != null) {
							collection=collectionTemp;
						}
					}
				}
			}
			return collection;
		}

		/**
		 * 挂机找怪函数
		 * @param myPos
		 * @return
		 *
		 */
		public static function searchHugEnemy(myPos:Pt):MutualAvatar {
			var weapon_type:int=GlobalObjectManager.getInstance().user.base.weapon_type;
			var dic:Dictionary=SceneUnitManager.unitHash;
			var target:MutualAvatar;

			var dis:int=-1;
			for (var s:String in dic) {
				var a:DisplayObject=dic[s] as DisplayObject;
				if (a is MutualAvatar == false || MutualAvatar(a).isDead == true || MutualAvatar(a).isConceal == true) { //排除不是avatar类的，还有死了的
					continue;
				}
				if (a is Monster) {
					var hits:Dictionary=SystemConfig.hitMonsters;
					if (hits[Monster(a).pvo.typeid] == null) { //排除不是打怪列表里面的
						continue;
					}
					var d:int=checkInDistance(myPos, MutualAvatar(a).index);
					if (weapon_type == 101 || weapon_type == 0) { //近程攻击的
						if (dis == -1 || d < dis) {
							dis=d;
							target=a as MutualAvatar;
						}
					} else {
						//可以远程攻击的
						if (d <= 7) { //10格内随便找一个
							target=a as MutualAvatar;
							break;
						} else { //如果10格内没有，就找最近的
							if (dis == -1 || d < dis) {
								dis=d;
								target=a as MutualAvatar;
							}
						}
					}
				} else if (a is Role) { //是敌国玩家
					if (Role(a).pvo != null && Role(a).pvo.faction_id != GlobalObjectManager.getInstance().user.base.faction_id && SystemConfig.otherFaction == true) {
						if (FactionWarDataManager.isInWarTimeAndPlace() == false) { //国战期间，平江，边城，京城不让挂外国人
							var d2:int=checkInDistance(myPos, MutualAvatar(a).index);
							if (d2 <= 10) {
								target=a as MutualAvatar;
								break;
							}
						}
					}
				}
			}
			return target;
		}
	}
}