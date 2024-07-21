package modules.roleStateG {
	import com.common.GlobalObjectManager;
	import com.scene.sceneKit.SelectedStyle;
	import com.scene.sceneManager.NPCTeamManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.NPC;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.vo.EquipVO;
	import modules.pet.PetDataManager;
	import modules.scene.SceneModule;
	
	import proto.common.p_goods;
	import proto.common.p_title;
	import proto.line.m_title_get_role_titles_toc;

	public class RoleStateDateManager {
		public static var myTitles:Array=[];
		public static var cur_title_id:int;
		private static var activitArr:Array=["极其活跃", "较为活跃", "闲云野鹤", "沉寂无声"];

		public function RoleStateDateManager() {
		}

		public static function getEquipById(itemId:int):EquipVO {
			var tar:EquipVO;
			for each (var item:p_goods in GlobalObjectManager.getInstance().user.attr.equips) {
				if (item.id == itemId) {
					tar=ItemConstant.wrapperItemVO(item) as EquipVO;
				}
			}
			return tar;
		}

		public static function getEquipByPosition(loadposition:int):EquipVO {
			for each (var item:EquipVO in equips) {
				if (item.loadposition == loadposition) {
					return item;
				}
			}
			return null;
		}

		public static function get usePhysic():Boolean {
			var mainEquip:EquipVO=getEquipByPosition(4);
			if (mainEquip) {
				return mainEquip.kind == ItemConstant.KIND_KNIFE || mainEquip.kind == ItemConstant.KIND_FAN ? true : false;
			} else {
				return false;
			}
		}

		public static function setEquipItem(p:p_goods):void {
			var arr:Array=GlobalObjectManager.getInstance().user.attr.equips;
			var index:int;
			for (var i:int=0; i < arr.length; i++) {
				if (p_goods(arr[i]).loadposition == p.loadposition) {
					index=i;
					break;
				}
			}
			arr.splice(index, 1);
			arr.push(p);
		}

		public static function get equips():Array {
			var arr:Array=[];
			for each (var item:p_goods in GlobalObjectManager.getInstance().user.attr.equips) {
				var tar:EquipVO=ItemConstant.wrapperItemVO(item) as EquipVO;
				arr.push(tar);
			}
			return arr;
		}

		public static function unLoadEquip(equip_id:int):void {
			var arr:Array=GlobalObjectManager.getInstance().user.attr.equips;
			var index:int;
			for (var i:int=0; i < arr.length; i++) {
				var p:p_goods=arr[i];
				if (p.id == equip_id) {
					index=i;
					break;
				}
			}
			arr.splice(i, 1);
		}
		
		//是否反隐身
		public static var isAntiStealth:Boolean = false;
		
		public static function isEquipEmpty(pos:int):Boolean {
			var isEmpty:Boolean=true;
			var arr:Array=equips;
			for (var i:int=0; i < arr.length; i++) {
				var p:EquipVO=arr[i];
				if (p.loadposition == pos) {
					isEmpty=false;
				}
			}
			return isEmpty;
		}

		public static function get isMount():Boolean {
			return GlobalObjectManager.getInstance().user.attr.skin.mounts != 0;
		}

		public static function choosePositionToPut(equip:EquipVO):void {
			var poses:Array=ItemConstant.getPostionByPutWhere(equip.putWhere);
			if (poses.length > 1) { //有2个位置
				if (isEquipEmpty(poses[0] + 1) == true) {
					PackageModule.getInstance().useEquip(equip.oid, poses[0] + 1);
					return;
				}
				if (isEquipEmpty(poses[1] + 1) == true) {
					PackageModule.getInstance().useEquip(equip.oid, poses[1] + 1);
					return;
				}
				var results:Array=[getEquipByPosition(poses[0] + 1), getEquipByPosition(poses[1] + 1)];
				results.sort(compareEquip);
				var badEquip:EquipVO=results.pop();
				var pos:int=poses[0] + 1;
				if (badEquip.loadposition == poses[1] + 1) {
					pos=poses[1] + 1;
				}
				PackageModule.getInstance().useEquip(equip.oid, pos);
			} else { //只有一个位置
				PackageModule.getInstance().useEquip(equip.oid, poses[0] + 1);
			}

		}

		public static function compareEquip(equip1:EquipVO, equip2:EquipVO):int {
			var level:int=compare(equip1.minlvl, equip2.minlvl);
			if (level == 0) {
				var color:int=compare(equip1.color, equip2.color);
				if (color == 0) {
					return compare(equip1.refine_index, equip2.refine_index);
				}
				return color;
			}
			return level;
		}
		
		private static function compare(value1:int, value2:int):int {
			if (value1 > value2) {
				return -1;
			} else if (value1 < value2) {
				return 1;
			} else {
				return 0;
			}
		}
		
		public static function setRoleTitles(vo:m_title_get_role_titles_toc):void {
			myTitles=new Array;
			var pt:p_title=new p_title;
			pt.name="天之刃";
			myTitles.push(pt);
			myTitles=myTitles.concat(vo.titles);
		}

		public static function getLevelTitle():String {
			//获得等级称号,恶人104001,等级101001，功勋105001
			var title:String="";
			if (myTitles != null) {
				for (var i:int=0; i < myTitles.length; i++) {
					var p:p_title=myTitles[i];
					if (p.type == 101001) {
						title=p.name;
						break;
					}
				}
			}
			return title;
		}

		public static function getActivityStr(value:int):String {
			var str:String="";
			if (value < 10) {
				str=activitArr[3];
			} else if (value >= 10 && value < 40) {
				str=activitArr[2];
			} else if (value >= 40 && value < 60) {
				str=activitArr[1];
			} else if (value >= 60) {
				str=activitArr[0];
			}


			return str;
		}
		private static var _seletedUnit:SeletedRoleVo;

		public static function get seletedUnit():SeletedRoleVo {
			return _seletedUnit;
		}

		public static function set seletedUnit(value:SeletedRoleVo):void {
			SelectedStyle.instance.reParent(null);
			if (value != null) {
				if (value.unit_type == SceneUnitType.NPC_TYPE) {
					var npc:NPC=NPCTeamManager.getNPC(value.id);
					if (npc != null) {
						SelectedStyle.instance.color=1;
						SelectedStyle.instance.reParent(npc);
					}
				} else {
					var a:MutualAvatar=SceneUnitManager.getUnitByKey(value.key) as MutualAvatar;
					if (a && a is Monster) { //红
						SelectedStyle.instance.color=0;
					} else if (a && a is Role) {
						if (Role(a).pvo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id) { //绿
							SelectedStyle.instance.color=2;
						} else { //红
							SelectedStyle.instance.color=0;
						}
					} else { //黄
						SelectedStyle.instance.color=1;
					}
					//放进去
					SelectedStyle.instance.reParent(a);
				}
			} else {
				PetDataManager.attackAble=false;
			}
			_seletedUnit=value;
		}
	}
}