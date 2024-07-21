package modules.scene.cases {
	import com.scene.GameScene;
	import com.scene.sceneUnit.Collection;
	import com.scene.sceneUtils.SceneUnitType;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.collect.CollectModule;
	
	import proto.common.p_map_collect;
	import proto.line.m_collect_remove_grafts_toc;
	import proto.line.m_collect_updata_grafts_toc;

	public class CollectCase extends BaseModule {
		private static var _instance:CollectCase;
		private var _view:GameScene;

		public function CollectCase():void {
			_view=GameScene.getInstance();
		}

		public static function getInstance():CollectCase {
			if (_instance == null) {
				_instance=new CollectCase;
			}
			return _instance;
		}

		public function remove(vo:m_collect_remove_grafts_toc):void {
			var collects:Array=vo.grafts;
			for (var i:int=0; i < collects.length; i++) {
				_view.removeUnit(collects[i].id, SceneUnitType.COLLECT_TYPE);
			}
		}

		public function updata(vo:m_collect_updata_grafts_toc):void {
			var grafts:Array=vo.grafts;
			for (var i:int=0; i < grafts.length; i++) {
				var pvo:p_map_collect=p_map_collect(grafts[i])
				var collection:Collection=new Collection();
				collection.reset(pvo);
				_view.addUnit(collection, pvo.pos.tx, pvo.pos.ty);
			}
		}

		override protected function initListeners():void {
			addMessageListener(ModuleCommand.UPDATE_COLLECTION, updata);
			addMessageListener(ModuleCommand.REMOVE_COLLECTION, remove);
		}
	}
}