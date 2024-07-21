package modules.nearPlayer {
	import com.Message;
	import com.events.ParamEvent;
	import com.events.WindowEvent;
	import com.managers.WindowManager;
	import com.scene.sceneData.RunVo;

	import modules.BaseModule;
	import modules.ModuleCommand;

	public class NearPlayerModule extends BaseModule {
		private static var _instance:NearPlayerModule;
		private var _view:NearPlayerView;
		private var inited:Boolean;

		public function NearPlayerModule() {

		}

		public static function getInstance():NearPlayerModule {
			if (_instance == null) {
				_instance=new NearPlayerModule();
			}
			return _instance;
		}

		public function initView():void {
			if (inited == false) {
				_view=new NearPlayerView();
				_view.addEventListener(NearNPCView.CLICK_NPC, onClickNPC);
				_view.addEventListener(WindowEvent.OPEN, _view.refreshHandler);
				inited=true;
			}
		}

		public function showView():void {
			initView();
			_view.centerOpen();
		}
		
		public function showNPCView():void{
			initView();
			_view.centerOpen();
			if(_view.isPopUp){
				_view.selectedIndex(1);
			}
		}
		
		private function onClickNPC(e:ParamEvent):void {
			this.dispatch(ModuleCommand.ROLE_MOVE_TO, e.data as RunVo);
		}

		public function send(vo:Message):void {
			sendSocketMessage(vo);
		}
	}
}