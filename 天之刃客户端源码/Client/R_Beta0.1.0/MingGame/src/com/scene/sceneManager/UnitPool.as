package com.scene.sceneManager {
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.Monster;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Pet;
	import com.scene.sceneUnit.Role;
	import com.scene.sceneUnit.Waiter;
	import com.scene.sceneUnit.YBC;

	public class UnitPool {
		private static var monsterPool:Vector.<Monster>=new Vector.<Monster>;
		private static var rolePool:Vector.<Role>=new Vector.<Role>;
		private static var dropThingPool:Vector.<DropThing>=new Vector.<DropThing>;
		private static var petPool:Vector.<Pet>=new Vector.<Pet>;
		private static var ybcPool:Vector.<YBC>=new Vector.<YBC>;
		private static var waiterPool:Vector.<Waiter>=new Vector.<Waiter>;
		private static var myRole:MyRole=new MyRole;

		public function UnitPool() {
		}

		public static function getMyRole():MyRole {
			if (myRole == null) {
				myRole=new MyRole;
			}
			return myRole;
		}

		public static function getMonster():Monster {
			if (monsterPool.length > 0) {
				return monsterPool.pop();
			}
			return new Monster();
		}

		public static function disposeMonster(m:Monster):void {
			if (monsterPool.length < 80) {
				monsterPool.push(m);
			}
		}

		public static function getRole():Role {
			if (rolePool.length > 0) {
				return rolePool.pop();
			}
			return new Role();
		}

		public static function disposeRole(m:Role):void {
			if (rolePool.length < 108) { //改为108好汉
				rolePool.push(m);
			}
		}

		public static function getDropThing():DropThing {
			if (dropThingPool.length > 0) {
				return dropThingPool.pop();
			}
			return new DropThing();
		}

		public static function disposeDropThing(m:DropThing):void {
			dropThingPool.push(m);
		}

		public static function getPet():Pet {
			if (petPool.length > 0) {
				return petPool.pop();
			}
			return new Pet();
		}

		public static function disposePet(m:Pet):void {
			if (petPool.length < 80) {
				petPool.push(m);
			}
		}

		public static function getYBC():YBC {
			if (ybcPool.length > 0) {
				return ybcPool.pop();
			}
			return new YBC();
		}

		public static function disposeYBC(m:YBC):void {
			if (ybcPool.length < 30) {
				ybcPool.push(m);
			}
		}

		public static function getWaiter():Waiter {
			if (waiterPool.length > 0) {
				return waiterPool.pop();
			}
			return new Waiter();
		}

		public static function disposeWaiter(m:Waiter):void {
			if (waiterPool.length < 40) {
				waiterPool.push(m);
			}
		}
	}
}