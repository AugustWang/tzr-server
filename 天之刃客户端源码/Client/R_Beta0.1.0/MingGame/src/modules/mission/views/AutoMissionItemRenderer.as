package modules.mission.views {
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.*;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.ModuleCommand;
	import modules.mission.*;
	import modules.system.SystemConfig;
	
	import proto.line.m_mission_do_auto_tos;
	import proto.line.p_mission_auto;

	public class AutoMissionItemRenderer extends UIComponent implements IDataRenderer {
		private var _data:p_mission_auto;

		private var _checkBox:CheckBox;
		private var _statusText:TextField;
		private var _titleText:TextField;
		private var _loopTimesText:TextField;
		private var _timeText:TextField;
		private var _costText:TextField;

		private var _tf:TextFormat;
		
		public function AutoMissionItemRenderer() {
			init();
		}


		private function init():void {

			//复选框
			_checkBox = new CheckBox;
			_checkBox.width = 20;
			_checkBox.height = 20;
			_checkBox.x = 5;
			_checkBox.y = 2;
			addChild(_checkBox);
			
//			_checkBox.addEventListener(Event.CHANGE, checkBoxChanged);//整条都加上热区，点击右边的也可以勾选的修改
			this.mouseChildren=false;
			this.buttonMode=true;

			this._tf = new TextFormat("Tahoma", 12, 0xffffff);
			
			this._statusText=ComponentUtil.createTextField('', _checkBox.x, _checkBox.y, this._tf, 50, 26, this);
			this._statusText.filters=[Style.BLACK_FILTER];
			
			this._titleText=ComponentUtil.createTextField('', _checkBox.x + _checkBox.width + 5, _checkBox.y, this._tf, 170, 26, this);
			this._titleText.filters=[Style.BLACK_FILTER];
			
			_tf.align = "center";
			this._loopTimesText=ComponentUtil.createTextField('', _titleText.x + _titleText.width + 5, _checkBox.y, this._tf, 80, 26, this);
			this._loopTimesText.filters=[Style.BLACK_FILTER];
			
			this._timeText=ComponentUtil.createTextField('', _loopTimesText.x + _loopTimesText.width + 5, _checkBox.y, this._tf, 100, 26, this);
			this._timeText.filters=[Style.BLACK_FILTER];
			
			this._costText=ComponentUtil.createTextField('', _timeText.x + _timeText.width + 5, _checkBox.y, this._tf, 100, 26, this);
			this._costText.filters=[Style.BLACK_FILTER];

			this.bgAlpha = 1;
			this.useHandCursor = true;
			
			
			this.addEventListener(MouseEvent.CLICK,checkBoxChanged);
		}
		public function setCheckBoxEnable(enable:Boolean):void {
			this._checkBox.enable = enable;
		}
		
		public function getCheckBoxEnable():Boolean{
			return this._checkBox.enable;
		}
		
		private function setTextColor(color:uint):void{
			this._tf.color = color;
			
			this._statusText.defaultTextFormat = this._tf;
			this._titleText.defaultTextFormat = this._tf;
			this._loopTimesText.defaultTextFormat = this._tf;
			this._timeText.defaultTextFormat = this._tf;
			this._costText.defaultTextFormat = this._tf;
		}
		
		private function set statusTextStr(_value:String):void {
			this._statusText.htmlText = _value;
			if (_value == '') {
				this._statusText.visible = false;
				_titleText.x = _checkBox.x + _checkBox.width + 5;
			} else {
				this._statusText.visible = true;
				_titleText.x = _statusText.x + _statusText.textWidth + 5;
			}
		}

		/**
		 * 当选择或取消选择时
		 */
		private function checkBoxChanged(e:Event):void {
			this._checkBox.selected=!this._checkBox.selected;
			if (this._checkBox.selected) {
				dispatchCheckBoxSelected();
			} else {
				dispatchCheckBoxUnSelected();
			}
		}

		private function dispatchCheckBoxSelected():void{
			Dispatch.dispatch(ModuleCommand.MISSION_AUTO_SELECTED, this);
		}
		private function dispatchCheckBoxUnSelected():void{
			Dispatch.dispatch(ModuleCommand.MISSION_AUTO_UN_SELECTED, this);
		}
		
		override public function get data():Object {
			return this._data;
		}

		override public function set data(value:Object):void {
			this._data = value as p_mission_auto;
			switch(this._data.status){
				case MissionConstant.AUTO_STATUS_TIMES_LIMIT:
					this.setTextColor(0xcccccc);
					this._checkBox.enable = false;
					if(this._checkBox.selected == false){
						this.dispatchCheckBoxUnSelected();
					}else{
						this._checkBox.selected = false;
					}
					this._timeText.htmlText = '-';
					this._titleText.htmlText = this._data.name+'（达到上限）';
					break;
				
				case MissionConstant.AUTO_STATUS_DOING:
					this._checkBox.enable = false;
					if(this._checkBox.selected == true){
						this.dispatchCheckBoxSelected();
					}else{
						this._checkBox.selected = true;
					}
					this._timeText.htmlText = this.formatTime();
					this._dispatchedDO = false;
					this._titleText.htmlText = this._data.name+'（委托中）';
					break;
				
				case MissionConstant.AUTO_STATUS_WAIT_DO:
					this._checkBox.enable = true;
					if(this._checkBox.selected == false){
						this.dispatchCheckBoxUnSelected();
					}else{
						this._checkBox.selected = false;
					}
					this._timeText.htmlText = this.formatTime();
					this._titleText.htmlText = this._data.name;
					break;
			}
			
			this._loopTimesText.htmlText = this._data.loop_times.toString();
			this._costText.htmlText = this._data.need_gold.toString();
		}
		
		private var _dispatchedDO:Boolean = false;
		private function formatTime():String{
			if(this._data.start_time > 0){
				var serverTime:int = SystemConfig.serverTime;
				var remainTime:int = this._data.start_time + this._data.total_time - serverTime;
				if(remainTime <= 0){
					if(this._dispatchedDO == false){
						this._dispatchedDO = true;
						var doVO:m_mission_do_auto_tos = new m_mission_do_auto_tos();
						doVO.id = this._data.id;
						Dispatch.dispatch(ModuleCommand.MISSION_AUTO_DO, [doVO]);
					}
					remainTime = 0;
				}
				var passTime:int = this._data.total_time-remainTime;
				passTime = passTime <= 0 ? 0 : passTime;
				return Math.floor(passTime/60).toString()+'/'+Math.ceil(this._data.total_time/60);
				
			}else{
				return Math.ceil(this._data.total_time/60).toString();
			}
		}
		
		public function updateTime():void{
			this._timeText.htmlText = this.formatTime();
		}
	}
}