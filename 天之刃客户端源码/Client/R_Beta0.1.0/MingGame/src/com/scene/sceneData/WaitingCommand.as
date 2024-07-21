package com.scene.sceneData {
	import com.scene.tile.Pt;

	public class WaitingCommand {
		public var hasCommand:Boolean;
		public var tarPt:Pt;
		public var cut:int;
		public var handler:HandlerAction;
		public var runMode:String="NORMAL_RUN";

		public function WaitingCommand() {
		}

		public function setCommand(tarPt:Pt, cut:int, handler:HandlerAction, runMode:String):void {
			this.tarPt=tarPt;
			this.cut=cut;
			this.handler=handler;
			this.runMode=runMode;
			hasCommand=true;
		}

		public function clearCommand():void {
			tarPt=null;
			cut=0;
			handler=null;
			runMode="NORMAL_RUN";
			hasCommand=false;
		}
	}
}