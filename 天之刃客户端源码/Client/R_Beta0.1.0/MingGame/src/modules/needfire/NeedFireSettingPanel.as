package modules.needfire {
	import com.components.components.DragUIComponent;
	import com.managers.WindowManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.broadcast.views.Tips;
	import modules.family.FamilyLocator;
	import modules.system.SystemConfig;
	
	import proto.common.p_map_bonfire;

	public class NeedFireSettingPanel extends DragUIComponent {
		public var callback:Function;
		private var FACTION_MAX_H:int = 23;
		private var FACTION_MIN_H:int = 0;
		
		private var _startHInput:TextInput;
		private var _startMInput:TextInput;
		private var _endTimeTxt:TextField;
		private var _btnYes:Button;
		private var _title:TextField;
		private var _tips:TextField;
		
		private var vo:p_map_bonfire;
		
		public function NeedFireSettingPanel() {
			showCloseButton=true;
		}

		public function initUI():void {
			width=223;
			height=109;
			Style.setRectBorder(this);
			var _glow:GlowFilter=new GlowFilter(0x000000, 1, 2, 2);

			_startHInput=ComponentUtil.createTextInput(18, 36, 20, 20, this, this.timeChange, 2, '0-9');
			_startHInput.addEventListener(MouseEvent.CLICK, onEmptyH);

			_title=ComponentUtil.createTextField('', _startHInput.x, _startHInput.y - 22, null, 80, 20, this);
			_title.filters=[_glow];
			_title.htmlText='<font color="#ffffff">每天点燃时间：</font>';

			_tips=ComponentUtil.createTextField('', _startHInput.x, _startHInput.y + _startHInput.height + 2, null, 220,
				140, this);
			_tips.filters=[_glow];
			_tips.htmlText='<font color="#ffff00">可设定点燃时间段00:00-23:59</font>';

			var _pointStr:TextField=new TextField();
			_pointStr.htmlText='<b><font color="#ffffff">:</font></b>';
			_pointStr.filters=[_glow];
			_pointStr.x=_startHInput.x + _startHInput.width+5;
			_pointStr.y=_startHInput.y;
			_pointStr.width=12;
			_pointStr.selectable=false;
			addChild(_pointStr);

			_startMInput=ComponentUtil.createTextInput(_pointStr.x + _pointStr.textWidth + 5, _startHInput.y, 20, 20, this,
				this.timeChange, 2, '0-9');
			_startMInput.addEventListener(MouseEvent.CLICK, onEmptyM);

			_endTimeTxt=ComponentUtil.createTextField('', _startMInput.x + _startMInput.width+15, _startMInput.y, null, 80,
				20, this);
			_endTimeTxt.filters=[_glow];

			_btnYes=ComponentUtil.createButton("确定", 160, 75, 52, 25, this)
			Style.setRedBtnStyle(_btnYes);
			_btnYes.addEventListener(MouseEvent.CLICK,onBtnYesClick);
		}
		
		private function onEmptyH(event:MouseEvent):void{
			_startHInput.setFocus();
			_startHInput.textField.setSelection(0,_startHInput.text.length);
		}
		
		private function onEmptyM(event:MouseEvent):void{
			_startMInput.setFocus();
			_startMInput.textField.setSelection(0,_startMInput.text.length);
		}
		
		private function onBtnYesClick(event:MouseEvent):void{
			callback(int(_startHInput.text),int(_startMInput.text));
			WindowManager.getInstance().removeWindow(this);
		}
		
		private function _setTips(color:String,value:String):void{
			_tips.htmlText = HtmlUtil.font(value,color);
		}
		
		private function timeChange(event:Event=null):void {
			var _nowTimeStr:String=DateFormatUtil.formatHM(SystemConfig.serverTime);
			var _nowTimeArr:Array=_nowTimeStr.split(':');
			_nowTimeArr[0]=parseInt(_nowTimeArr[0]);
			_nowTimeArr[1]=parseInt(_nowTimeArr[1]);
			
			var _timeStartHValue:int = parseInt(this._startHInput.text);
			var _timeStartMValue:int = parseInt(this._startMInput.text);
			
			if(_timeStartHValue > FACTION_MAX_H || _timeStartHValue < FACTION_MIN_H || _timeStartMValue < 0 || _timeStartMValue >= 60){
				this._setTips('#FF0000', '可设定点燃时间段00:00-23:59');
				_btnYes.enabled = false;
				return;
			}
			_btnYes.enabled = true;
			var _timeEndHValue:int = _timeStartHValue+1;
			if(_timeEndHValue > 23)_timeEndHValue=0;
			var _timeEndStr:String = '';
			_timeEndStr += (_timeEndHValue < 10 ? '0'+_timeEndHValue : _timeEndHValue.toString());
			_updateTimeStr(_timeEndStr +"："+_startMInput.text);
			
			if(vo.start_time > SystemConfig.serverTime && _timeStartHValue >= _nowTimeArr[0]){
				this._setTips('#FFFF00', '修改后点燃时间将在今天开始启用。');
			}else{
				this._setTips('#FFFF00', '修改后点燃时间将在明天开始启用。');
			}
		}

		private function _updateTimeStr(_endTimeStr:String):void {
			this._endTimeTxt.htmlText='<font color="#ffffff"> 至 </font><font color="#ffff00">' + _endTimeStr + '</font>';
		}

		public function reset(vo:p_map_bonfire):void {
//			_updateTimeStr(DateFormatUtil.formatHM(vo.end_time));
			var startTxt:String = DateFormatUtil.formatHM(vo.start_time);
//			var startArr:Array = startTxt.split(':');
//			_startHInput.text = startArr[0];
//			_startMInput.text = startArr[1];
			this.vo = vo;
			if (FamilyLocator.getInstance().familyInfo.hour < 10) {
				_startHInput.text='0' + FamilyLocator.getInstance().familyInfo.hour;
			} else {
				_startHInput.text=''+FamilyLocator.getInstance().familyInfo.hour;
			}
			if (FamilyLocator.getInstance().familyInfo.minute < 10) {
				_startMInput.text='0' + FamilyLocator.getInstance().familyInfo.minute;
			} else {
				_startMInput.text=''+FamilyLocator.getInstance().familyInfo.minute;
			}
			var endHour:int = FamilyLocator.getInstance().familyInfo.hour + 1;
			if(endHour > 23){
				_updateTimeStr("00："+_startMInput.text)
			}else if(endHour < 10){
				_updateTimeStr("0"+endHour+"："+_startMInput.text);
			}else{
				_updateTimeStr(endHour+"："+_startMInput.text);
			}
			this._setTips('#FF0000', '可设定点燃时间段00:00-23:59');
		}

		override protected function onCloseHandler(event:MouseEvent):void {
			WindowManager.getInstance().removeWindow(this);
		}
	}
}