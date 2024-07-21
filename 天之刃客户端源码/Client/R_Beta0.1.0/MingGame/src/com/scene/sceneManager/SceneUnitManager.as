package com.scene.sceneManager {
	import com.common.GlobalObjectManager;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.IMutualUnit;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.baseUnit.MutualAvatar;
	import com.scene.sceneUtils.SceneUnitType;
	import com.scene.tile.Hash;

	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * 统一记录场景中的物品
	 * @author Administrator
	 *
	 */
	public class SceneUnitManager {
		private static var _unitHash:Dictionary=new Dictionary; //放所有单位
		private static var _monsterHash:Dictionary=new Dictionary; //放怪物
		private static var _roleHash:Dictionary=new Dictionary; //放人
		private static var _petHash:Dictionary=new Dictionary; //放宠物
		private static var _dropthingHash:Dictionary=new Dictionary; //放掉落物
		private static var _snpcHash:Dictionary=new Dictionary; //后台NPC
		private static var _ybcHash:Dictionary=new Dictionary; //ybc
		private static var _waiterHash:Dictionary=new Dictionary; //waiter
		public static var myDropThing:Dictionary=new Dictionary; //我的掉落物,用于自动打怪时的遍历

		/**
		 * 放任意类型可交互单位
		 * @param unit
		 *
		 */
		public static function addUnit(unit:IMutualUnit):void {
			if (_unitHash.hasOwnProperty(unit.unitKey) == false) { //总字典
				_unitHash[unit.unitKey]=unit;
			}
			if (unit.sceneType == SceneUnitType.ROLE_TYPE) { //人物字典
				if (_roleHash.hasOwnProperty(unit.unitKey) == false) {
					_roleHash[unit.unitKey]=unit;
				}
			}
			if (unit.sceneType == SceneUnitType.PET_TYPE) { //宠物字典
				if (_petHash.hasOwnProperty(unit.unitKey) == false) {
					_petHash[unit.unitKey]=unit;
				}
			}
			if (unit.sceneType == SceneUnitType.MONSTER_TYPE) { //怪物字典
				if (_monsterHash.hasOwnProperty(unit.unitKey) == false) {
					_monsterHash[unit.unitKey]=unit;
				}
			}
			if (unit.sceneType == SceneUnitType.DROP_THING_TYPE) { //掉落物字典
				if (_dropthingHash.hasOwnProperty(unit.unitKey) == false) {
					_dropthingHash[unit.unitKey]=unit;
					var roles:Array=DropThing(unit).pvo.roles;
					if (roles.length == 0 || roles.indexOf(GlobalObjectManager.getInstance().user.base.role_id) != -1) {
						if (myDropThing.hasOwnProperty(unit.unitKey) == false) {
							myDropThing[unit.unitKey]=unit;
						}
					}
				}
			}
			if (unit.sceneType == SceneUnitType.SERVER_NPC_TYPE) { //后台NPC
				if (_snpcHash.hasOwnProperty(unit.unitKey) == false) {
					_snpcHash[unit.unitKey]=unit;
				}
			}
			if (unit.sceneType == SceneUnitType.YBC_TYPE) { //镖车
				if (_ybcHash.hasOwnProperty(unit.unitKey) == false) {
					_ybcHash[unit.unitKey]=unit;
				}
			}
			if (unit.sceneType == SceneUnitType.WAITER_TPYE) { //小二
				if (_waiterHash.hasOwnProperty(unit.unitKey) == false) {
					_waiterHash[unit.unitKey]=unit;
				}
			}
		}

		/**
		 * 获取自己
		 * @return
		 *
		 */
		public static function getSelf():MyRole {
			var key:String=SceneUnitType.ROLE_TYPE + "_" + GlobalObjectManager.getInstance().user.base.role_id;
			return getUnitByKey(key) as MyRole;
		}

		/**
		 * 获取单位
		 * @param unit_id
		 * @param type
		 * @return
		 *
		 */
		public static function getUnit(unit_id:int, type:int=SceneUnitType.ROLE_TYPE):IMutualUnit {
			return _unitHash[type + "_" + unit_id];
		}

		public static function getUnitByKey(key:String):IMutualUnit {
			return _unitHash[key];
		}

		/**
		 * 移除单位
		 * @param type
		 * @param unit_id
		 * @return
		 *
		 */
		public static function removeUnit(unit_id:int, type:int=SceneUnitType.ROLE_TYPE):IMutualUnit {
			var key:String=type + "_" + unit_id;
			var tar:IMutualUnit=getUnit(unit_id, type);

			if (_unitHash.hasOwnProperty(key) == true) {
				_unitHash[key]=null;
				delete _unitHash[key];
			}
			if (_roleHash.hasOwnProperty(key) == true) {
				_roleHash[key]=null;
				delete _roleHash[key];
			}
			if (_petHash.hasOwnProperty(key) == true) {
				_petHash[key]=null;
				delete _petHash[key];
			}
			if (_monsterHash.hasOwnProperty(key) == true) {
				_monsterHash[key]=null;
				delete _monsterHash[key];
			}
			if (_dropthingHash.hasOwnProperty(key) == true) {
				_dropthingHash[key]=null;
				delete _dropthingHash[key];
			}
			if (myDropThing.hasOwnProperty(key) == true) {
				myDropThing[key]=null;
				delete myDropThing[key];
			}
			if (_snpcHash.hasOwnProperty(key) == true) {
				_snpcHash[key]=null;
				delete _snpcHash[key];
			}
			if (_ybcHash.hasOwnProperty(key) == true) {
				_ybcHash[key]=null;
				delete _ybcHash[key];
			}
			if (_waiterHash.hasOwnProperty(key) == true) {
				_waiterHash[key]=null;
				delete _waiterHash[key];
			}
			return tar;
		}

		public static function removeUnitByKey(key:String):IMutualUnit {
			var tar:IMutualUnit=getUnitByKey(key);

			if (_unitHash.hasOwnProperty(key) == true) {
				_unitHash[key]=null;
				delete _unitHash[key];
			}
			if (_roleHash.hasOwnProperty(key) == true) {
				_roleHash[key]=null;
				delete _roleHash[key];
			}
			if (_petHash.hasOwnProperty(key) == true) {
				_petHash[key]=null;
				delete _petHash[key];
			}
			if (_monsterHash.hasOwnProperty(key) == true) {
				_monsterHash[key]=null;
				delete _monsterHash[key];
			}
			if (_dropthingHash.hasOwnProperty(key) == true) {
				_dropthingHash[key]=null;
				delete _dropthingHash[key];
			}
			if (myDropThing.hasOwnProperty(key) == true) {
				myDropThing[key]=null;
				delete myDropThing[key];
			}
			if (_snpcHash.hasOwnProperty(key) == true) {
				_snpcHash[key]=null;
				delete _snpcHash[key];
			}
			if (_ybcHash.hasOwnProperty(key) == true) {
				_ybcHash[key]=null;
				delete _ybcHash[key];
			}
			if (_waiterHash.hasOwnProperty(key) == true) {
				_waiterHash[key]=null;
				delete _waiterHash[key];
			}
			return tar;
		}

		/**
		 * 获取总列表
		 * @return
		 *
		 */
		public static function get unitHash():Dictionary {
			return _unitHash;
		}

		/**
		 * 获取怪物列表
		 * @return
		 *
		 */
		public static function get monsterHash():Dictionary {
			return _monsterHash;
		}

		public static function get roleHash():Dictionary {
			return _roleHash;
		}

		public static function get petHash():Dictionary {
			return _petHash;
		}

		public static function get dropthingHash():Dictionary {
			return _dropthingHash;
		}

		public static function get snpcHash():Dictionary {
			return _snpcHash;
		}

		public static function get ybcHash():Dictionary {
			return _ybcHash;
		}

		public static function get waiterHash():Dictionary {
			return _waiterHash;
		}

		public static function clear():void {
			for (var i:String in _unitHash) {
				var tar:IMutualUnit=_unitHash[i];
				tar.remove();
				_unitHash[i]=null;
				delete _unitHash[i];
			}
			for (var j:String in _monsterHash) {
				_monsterHash[j]=null;
				delete _monsterHash[j];
			}
			for (var k:String in _roleHash) {
				_roleHash[k]=null;
				delete _roleHash[k];
			}
			for (var p:String in _petHash) {
				_petHash[p]=null;
				delete _petHash[p];
			}
			for (var m:String in _dropthingHash) {
				_dropthingHash[m]=null;
				delete _dropthingHash[m];
			}
			for (var my:String in myDropThing) {
				myDropThing[my]=null;
				delete myDropThing[my];
			}
			for (var n:String in _snpcHash) {
				_snpcHash[n]=null;
				delete _snpcHash[n];
			}
			for (var a:String in _ybcHash) {
				_ybcHash[a]=null;
				delete _ybcHash[a];
			}
			for (var b:String in _waiterHash) {
				_waiterHash[b]=null;
				delete _waiterHash[b];
			}
			_unitHash=new Dictionary;
			_monsterHash=new Dictionary;
			_roleHash=new Dictionary;
			_dropthingHash=new Dictionary;
			_petHash=new Dictionary;
			_snpcHash=new Dictionary;
			_ybcHash=new Dictionary;
			_waiterHash=new Dictionary;
			myDropThing=new Dictionary;
		}
	}
}
