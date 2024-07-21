package modules.smallMap {

	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.globals.GameParameters;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.net.SocketCommand;
	import com.utils.JSUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastSelf;
	import modules.smallMap.view.RadarBar;
	import modules.smallMap.view.RadarView;
	import modules.smallMap.view.SmallSceneView;
	
	import proto.line.m_map_transfer_toc;
	import proto.line.m_map_transfer_tos;


	public class SmallMapModule extends BaseModule {
		private static var instance:SmallMapModule;
		private var inited:Boolean;
		private var _radarBar:RadarBar;
		private var _radar:RadarView;
		private var _smallScene:SmallSceneView;

		public static function getInstance():SmallMapModule {
			if (instance == null) {
				instance=new SmallMapModule();
			}
			return instance;
		}

		public function SmallMapModule() {

		}

		private function get smallScene():SmallSceneView {
			if (_smallScene == null) {
				_smallScene=new SmallSceneView;
			}
			return _smallScene;
		}

		private function get radar():RadarView {
			if (_radar == null) {
				_radar=new RadarView;
				_radar.y = 20;
				_radar.x= GlobalObjectManager.GAME_WIDTH - 165; //864;
			}
			return _radar;
		}

		private function onEnterGame():void {
			if (inited == false) {
				_radarBar = new RadarBar();
				_radarBar.radarView = radar;
				_radarBar.x = GlobalObjectManager.GAME_WIDTH - _radarBar.width;
				LayerManager.uiLayer.addChild(_radarBar);
				SmallMapDataManager.initBits();
				LayerManager.uiLayer.addChild(radar);
				inited=true;
			}
		}
		
		private function showHideSmallMap(event:MouseEvent):void{
			
		}
		
		private function openSmallScene(isClickTransBtn:Boolean=false):void {
			smallScene.seleteIndex(2);
			smallScene.open();
			WindowManager.getInstance().centerWindow(smallScene);

			if (isClickTransBtn)
				_smallScene.resetTransferBtn(true);
		}

		public function resetTransferBtn(value:Boolean):void {
			_smallScene.resetTransferBtn(value);
		}

		private function onChangeMap():void {
			_radarBar.changeMap();
			smallScene.onChangeMap();
		}

		private function clearMyRoad():void {
			if (smallScene && smallScene.currentCity) {
				smallScene.currentCity.clearPath();
			}
		}

		override protected function initListeners():void {
			addSocketListener(SocketCommand.MAP_TRANSFER, onMapTransfer);
			addMessageListener(ModuleCommand.ENTER_GAME, onEnterGame);
			addMessageListener(ModuleCommand.CLEAR_MAP_PATH, clearMyRoad);
			addMessageListener(ModuleCommand.CHANGE_MAP_ROLE_READY, onChangeMap);
			addMessageListener(ModuleCommand.OPEN_SMALL_SCENE, openSmallScene);
			addMessageListener(ModuleCommand.YBC_POS, updateYBCPos);
			addMessageListener(ModuleCommand.YBC_CLEAR, clearYBCPos);
			addMessageListener(ModuleCommand.DRAW_MY_PATH, drawMyPath);
			addMessageListener(ModuleCommand.OPEN_PAY_HANDLER, openPayHandler);
			addMessageListener(ModuleCommand.STAGE_RESIZE, onStageResize);
			addMessageListener(ModuleCommand.FLASH_SOMETHING, flashSomeThing);
			addMessageListener(ModuleCommand.STOP_FLASH_SOMETHING, stopflashSomeThing);
			addMessageListener(ModuleCommand.ON_SMALL_MAP_COMPLETE, onSmallMapComplete);
			addMessageListener(ModuleCommand.CONFIG_CHANGED, onConfigChanged);
			addMessageListener(ModuleCommand.NET_PING_VALUE,netPingValueHandler);
		}
		
		private function onConfigChanged():void{
			if(radar){
				radar.configChanged();
			}	
		}
		
		private function netPingValueHandler(value:int):void{
			if(radar){
				radar.pingValueChanged(value);
			}
		}
		private function onSmallMapComplete(obj:Object):void {
			radar.onSmallMapComplete(obj.s as BitmapData);
			smallScene.currentCity.onSmallMapComplete(obj.f as BitmapData);
		}

		private function flashSomeThing(str:String):void {
			if (radar) {
				radar.flashSomeThing(str);
			}
		}

		private function stopflashSomeThing(str:String):void {
			if (radar) {
				radar.stopflashSomeThing(str);
			}
		}

		private function onStageResize(value:Object):void {
			if (_radar) {
				_radar.y = 20;
				_radar.x= GlobalObjectManager.GAME_WIDTH - 165; //864;
				_radarBar.x = GlobalObjectManager.GAME_WIDTH - _radarBar.width;
				
			}
		}

		//打开重置页面
		public function openPayHandler():void {
			JSUtil.openPaySite();
		}


		private function updateYBCPos(data:Point):void {
			if (smallScene.currentCity) {
				smallScene.currentCity.drawMyYBC(data.x, data.y);
			}
		}

		private function clearYBCPos():void {
			if (smallScene.currentCity) {
				smallScene.currentCity.clearYBC();
			}
		}

		private function drawMyPath(path:Array):void {
			if (smallScene.currentCity) {
				smallScene.currentCity.drawMyPath(path);
			}
			if (radar.map) {
				radar.map.drawMyPath(path);
			}
		}

		public function onMapTransfer(vo:m_map_transfer_toc):void {
			if (vo.succ) {
				if (smallScene) {
					smallScene.seleteIndex(2);
					smallScene.onChangeMap();
				}
			}
			resetTransferBtn(false);
		}

		//请求跳转
		public function sendToJump(vo:m_map_transfer_tos):void {
			this.sendSocketMessage(vo);
		}

	}
}