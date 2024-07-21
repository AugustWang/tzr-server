package modules.scene.cases {
	import com.scene.GameScene;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.DropThing;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	
	import flash.utils.Dictionary;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.system.SystemConfig;

	public class SettingCase extends BaseModule {
		private static var _instance:SettingCase;

		public function SettingCase():void {
		}

		public static function getInstance():SettingCase {
			if (_instance == null) {
				_instance=new SettingCase;
			}
			return _instance;
		}

		private function get view():GameScene {
			return GameScene.getInstance();
		}

		private function get hero():MyRole {
			return GameScene.getInstance().hero;
		}

		private function onSystemConfigChange():void {
			reshowGuaJi(SystemConfig.open);
			reShowDropThingName();
			reShowRoleNames();
			reShowCloths();
		}

		public function reshowGuaJi(show:Boolean):void {
			if (hero != null) {
				hero.showGuaJi(show);
			}
		}

		private function reShowDropThingName():void {
			var dic:Dictionary=SceneUnitManager.dropthingHash;
			for (var s:String in dic) {
				var obj:DropThing=dic[s];
				obj.showName=SystemConfig.showDropGoodsName;
			}
		}

		private function reShowRoleNames():void {
			var dic:Dictionary=SceneUnitManager.roleHash;
			for (var s:String in dic) {
				var tar:IRole=dic[s];
				if (tar is Role) {
					tar.doNameJob();
				}
			}
		}

		private function reShowCloths():void {
			var dic:Dictionary=SceneUnitManager.roleHash;
			for (var s:String in dic) {
				var tar:IRole=dic[s];
				tar.showCloth(SystemConfig.showClothing);
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.CONFIG_CHANGED, onSystemConfigChange);
		}
	}
}