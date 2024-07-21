package modules.rider
{
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	
	import flash.events.Event;
	
	import modules.BaseModule;
	import modules.ModuleCommand;
	import modules.rider.views.RiderView;

	/**
	 * 坐骑模块
	 * @author yechengcong
	 * 
	 */	
	public class RiderModule extends BaseModule
	{
		public function RiderModule()
		{
			
		}
		
		private static var instance:RiderModule;
		public static function getInstance():RiderModule{
			if(instance == null){
				instance = new RiderModule();
			}
			return instance;
		}
		
		override protected function initListeners():void{
			addMessageListener(ModuleCommand.OPEN_RIDER_VIEW,setupRiderUI);
		}
		
		private var _riderView:RiderView;
		private function setupRiderUI():void
		{
			if(!_riderView)
			{
				_riderView = new RiderView();
				WindowManager.getInstance().popUpWindow(_riderView);
				WindowManager.getInstance().centerWindow(_riderView.riderPlane);
				_riderView.riderPlane.addEventListener(CloseEvent.CLOSE,onCloseHandler);
			}else
			{
				onCloseHandler();
			}
		}
		
		private function onCloseHandler(evt:Event=null):void
		{
			if(_riderView)
			{
				WindowManager.getInstance().removeWindow(_riderView);
				_riderView.dispose();
				_riderView = null;
			}
		}
			
		
	}
}