package modules.scene.other {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.BroadcastView;
	import modules.scene.SceneModule;
	import modules.system.SystemConfig;

	public class HangMachineTip {
		private static var timeOut_id:int;
		private static var timer:Timer;

		public function HangMachineTip() {
		}

		public static function showHangMachineTip():void {
			var level:int=GlobalObjectManager.getInstance().user.attr.level;
			if (level >= 15 && level <= 20 && SystemConfig.open == false) {
				if (Math.random() < 0.3) {
					onTimer();
					if (timer == null) {
						timer=new Timer(12000, 2);
						timer.addEventListener(TimerEvent.TIMER, onTimer);
					}
					timer.reset();
					timer.start();
				}
			}
		}

		private static function onTimer(e:TimerEvent=null):void {
//			var s1:String=TextUnitManager.colorText("按“", 0xffffff);
//			var s2:String=TextUnitManager.colorText("Z", 0xff0000);
//			var s3:String=TextUnitManager.colorText("”键或小地图的“", 0xffffff);
//			var s4:String=TextUnitManager.colorText("挂", 0xff0000);
//			var s5:String=TextUnitManager.colorText("”，可自动打怪", 0xffffff);
			if( !SceneModule.isAutoHit ){
				BroadcastView.getInstance().addBroadcastMsg("按'Z'键或小地图的'挂'可自动打怪");
				Dispatch.dispatch(ModuleCommand.FLASH_SOMETHING, "gua");
			}
			
			clearTimeout(timeOut_id);
			timeOut_id=setTimeout(function stop():void {
					Dispatch.dispatch(ModuleCommand.STOP_FLASH_SOMETHING, "gua");
				},5000);
		}

	}
}