package modules.mission.views {
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.ToolTip;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mission.MissionConstant;
	import modules.mission.vo.MissionVO;
	import modules.system.SystemConfig;

	public class MissionShouBianTimeView extends UIComponent {

		private var _vo:MissionVO;
		private var _text:TextField;
		private var _toolTipsStr:String;
		private var _remainSeconds:int;
		private var _colorTrigger:int = 1;
		
		public function MissionShouBianTimeView(_vo:MissionVO) {
			super();

			this._vo=_vo;

			var textFormat:TextFormat=new TextFormat();

			textFormat.color="0xFFF673";
			textFormat.size=12;
			textFormat.align="left";

			var borderView:UIComponent=new UIComponent;
			borderView.width=100;
			borderView.height=40;
			Style.setMenuItemBg(borderView); //背景

			this._text=ComponentUtil.createTextField("", 5, 8, textFormat, 100, 20, this);
			this.addChild(borderView);
			this.addChild(this._text);
			this.addEventListener(MouseEvent.MOUSE_OVER, this.mouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, this.mouseOut);
		}
		
		private var heightValue:int=40;
		override public function get height():Number{
			return heightValue;
		}

		public function set vo(value:MissionVO):void{
			this._vo = value;
			this.update();
		}
		
		private var _dispatchedStatusChange:Boolean = false;
		public function update():void {
			var status:int = this._vo.currentModelStatus;
			var textStr:String;
			
			switch(status){
				case MissionConstant.SHOU_BIAN_STATUS_WAIT:
					this._toolTipsStr = '倒计时结束需向沐英将军汇报军情。';
					textStr = this.formatRemainTime('守边状态：');
					break;
				case MissionConstant.SHOU_BIAN_STATUS_SUCC:
					this._toolTipsStr = '倒计时结束则任务失败，无法获得任务奖励。';
					textStr = this.formatRemainTime('汇报状态：');
					break;
				case MissionConstant.SHOU_BIAN_STATUS_TIMEOUT:
					this._toolTipsStr = '守卫国土已超时。';
					textStr = '守卫国土已超时';
					LoopManager.removeFromSceond(MissionConstant.SHOU_BIAN_TIMER_KEY);
					break;
				default:
					break;
			}
			
			if(this._remainSeconds == 0 && _dispatchedStatusChange == false){
				Dispatch.dispatch(ModuleCommand.MISSION_SHOU_BIAN_STATUS_CHANGE, this._vo.id);
				_dispatchedStatusChange = true;
			}else{
				_dispatchedStatusChange = false;
			}
			this._text.htmlText = textStr;
		}

		private function formatRemainTime(statusStr:String):String {
			
			var systemTime:int = SystemConfig.serverTime;
			this._remainSeconds = this._vo.statusChangeTime + this._vo.statusTimeLlimit - systemTime;
			if(this._remainSeconds <= 0){
				this._remainSeconds = 0;
			}
			
			
			var str:String=''
			var h:int=this._remainSeconds / 3600;
			var m:int=this._remainSeconds / 60;
			var s:int=this._remainSeconds % 60;

			if (h >= 10) {
				str+=h + ':';
			} else if (h > 0) {
				str+='0' + h + ':';
			}

			if (m >= 10) {
				str+=m + ':';
			} else {
				str+='0' + m + ':';
			}

			if (s >= 10) {
				str+=s;
			} else {
				str+='0' + s;
			}
			if (this._remainSeconds <= 60) {
				if (_colorTrigger == 1) {
					_colorTrigger=2;
					return '<font color="#ffffff">' + statusStr + str + '</font>';
				} else {
					_colorTrigger=1;
					return '<font color="#ff0000">' + statusStr + str + '</font>';
				}
			} else {
				return statusStr + str;
			}
		}

		private function mouseOver(event:MouseEvent):void {
			if (_toolTipsStr) {
				ToolTipManager.getInstance().show(_toolTipsStr);
			}
		}

		private function mouseOut(event:MouseEvent):void {
			ToolTipManager.getInstance().hide();
		}
	}
}