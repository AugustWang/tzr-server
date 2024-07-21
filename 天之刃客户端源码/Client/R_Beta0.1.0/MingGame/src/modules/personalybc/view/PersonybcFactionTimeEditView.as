package modules.personalybc.view
{
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	import modules.system.SystemConfig;
	import modules.personalybc.PersonalYbcModule;
	
	import proto.line.m_personybc_faction_tos;
	import proto.line.m_personybc_info_toc;
	import proto.line.p_personybc_info;
	
	
	public class PersonybcFactionTimeEditView extends BasePanel
	{
		
		private var _parentUpdateFunc:Function
		private var _tips:TextField;
		private var _endTimeTxt:TextField;
		private var _startHInput:TextInput;
		private var _startMInput:TextInput;
		
		private const FACTION_MIN_H:int = 12;
		private const FACTION_MAX_H:int = 24;
		private var _error:Boolean = false;
		
		private var _editCheckBox:CheckBox;
		private var _startCheckBox:CheckBox
		
		public function PersonybcFactionTimeEditView(_parentUpdateFunc:Function)
		{
			super("personybc_faction_time_edit");
			this._parentUpdateFunc = _parentUpdateFunc;
			initView();
			
		}
		
		public function initView():void
		{
			this.width = 350;
			this.height = 170;
			this.title = "修改国运发布时间";
			var glow:Array = [new GlowFilter(0x000000,1,2,2)];
			
			var _startPosX:int = 20;
			_editCheckBox = new CheckBox();
			_editCheckBox.x = _startPosX;
			_editCheckBox.y = 20;
			_editCheckBox.htmlText = '<font color="#ffffff">修改默认开启国运时间</font>';
			_editCheckBox.textFilter = glow;
			_editCheckBox.addEventListener(Event.CHANGE, _editCheckBoxChange);
			this.addChild(_editCheckBox);
			
			_startCheckBox = new CheckBox();
			_startCheckBox.x = _startPosX;
			_startCheckBox.y = _editCheckBox.y + _editCheckBox.height + 5;
			_startCheckBox.htmlText = '<font color="#ffffff">立即发布今天国运(不会修改默认国运时间)</font>';
			_startCheckBox.textFilter = glow;
			_startCheckBox.addEventListener(Event.CHANGE, _startCheckBoxChange);
			this.addChild(_startCheckBox);
			
			_tips = ComponentUtil.createTextField('', 45, 
				_startCheckBox.y+_startCheckBox.height + 5, 
				null, 250, 20, this);
			_tips.htmlText = '<font color="#ffffff">勾选所有项将修改时间，同时立即发布今天国运。</font>';
			_tips.filters = glow;
			
			_startHInput = ComponentUtil.createTextInput(
				170, _editCheckBox.y, 20, 20, this,
				this._updateTimeStr, 2, '0-9');
			
			var _pointStr:TextField = new TextField();
			_pointStr.htmlText = '<b><font color="#ffffff">:</font></b>';
			_pointStr.filters = glow;
			_pointStr.x = _startHInput.x+_startHInput.width;
			_pointStr.y = _startHInput.y;
			this.addChild(_pointStr);
			
			_startMInput = ComponentUtil.createTextInput(
				_pointStr.x + _pointStr.textWidth + 2, 
				_startHInput.y, 20, 20, this, 
				this._updateTimeStr, 2, '0-9');
			
			_endTimeTxt = ComponentUtil.createTextField('', 
				_startMInput.x + _startMInput.width + 5, 
				_startMInput.y, 
				null, 60, 20, this);
			_endTimeTxt.filters = glow;
			
			var _sureBtn:Button = ComponentUtil.createButton("确定", 200, 100, 66, 25, this);
			_sureBtn.addEventListener(MouseEvent.CLICK, _sureFunc);
			
			
			var _cancelBtn:Button = ComponentUtil.createButton("取消", 270, 100, 66, 25, this);
			_cancelBtn.addEventListener(MouseEvent.CLICK, _closeFunc);
			
			this._updateTimeStr();
		}
		
		private function _updateTimeStr(_e:Event=null):void{
			var _info_toc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			if(_info_toc){
				var _info:p_personybc_info = _info_toc.info;
				if(_info){
					this._error = true;
					
					if(this._startHInput.text == '' && this._startMInput.text == ''){
						var _timeStr:String = DateFormatUtil.formatHM(_info.faction_start_time);
						var _timeArr:Array = _timeStr.split(':');
						this._startHInput.text = _timeArr[0];
						this._startMInput.text = _timeArr[1];
					}
					
					var _timeStartHValue:int = parseInt(this._startHInput.text);
					var _timeStartMValue:int = parseInt(this._startMInput.text);
					
					if(_timeStartHValue >= FACTION_MAX_H || _timeStartHValue < FACTION_MIN_H || _timeStartMValue < 0 || _timeStartMValue > 60){
						this._setTips('#FF0000');
						return;
					}
					
					if(_timeStartMValue == 60){
						_timeStartMValue = 0;
						_timeStartHValue += 1;
					}
					
					var _timeM:int = _info.faction_time_limit/60+_timeStartMValue;
					
					var _timeEndHValue:int = _timeM/60+_timeStartHValue;
					var _timeEndMValue:int = _timeM%60;
					
					if(_timeEndHValue >= FACTION_MAX_H || _timeEndHValue < FACTION_MIN_H || _timeEndMValue < 0 || _timeEndMValue > 60){
						this._setTips('#FF0000');
						return;
					}
					
					this._setTips('#FFFF00');
					
					var _timeEndStr:String = _timeEndHValue.toString()+':';
					_timeEndStr += (_timeEndMValue < 10 ? '0'+_timeEndMValue.toString() : _timeEndMValue.toString());
					
					var _timeStartStr:String = _timeStartHValue.toString()+':';
					_timeStartStr += (_timeStartMValue < 10 ? '0'+_timeStartMValue.toString() : _timeStartMValue.toString());
					
					this._parentUpdateFunc(_timeStartStr, _timeEndStr);
					this._endTimeTxt.htmlText = '<font color="#ffffff"> 至 '+_timeEndStr+'</font>';
					this._error = false;
				}
			}
		}
		
		private function _sureFunc(_e:MouseEvent):void
		{
			
			if(this._error){
				_setTips('#ff0000');
				return;
			}
			if(!this._editCheckBox.selected && !this._startCheckBox.selected){
				this._setTips('#ff0000', '请至少选择一项操作。');
				return;
			}
			
			var _type:int = 0;
			if(this._editCheckBox.selected == true && this._startCheckBox.selected == true){
				_type = 2;
			}else if(this._editCheckBox.selected == true && this._startCheckBox.selected == true){
				_type = 1;
			}
			
			var _vo:m_personybc_faction_tos = new m_personybc_faction_tos();
			_vo.type = _type;
			_vo.start_h = parseInt(this._startHInput.text);
			_vo.start_m = parseInt(this._startMInput.text);
			PersonalYbcModule.getInstance().personybcFactionConfirmFunc(_vo);
			this.closeWindow();
		}
		
		private function _startCheckBoxChange(_e:Event):void{
			var _info_toc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			if(_info_toc && this._startCheckBox.selected == true){
				var _info:p_personybc_info = _info_toc.info;
				if(_info){
					if(SystemConfig.serverTime >= _info.faction_start_time){
						this._setTips('#ff0000', '本国今日国运已开始，不能再次发布。');
						this._startCheckBox.selected = false;
					}		
				}
			}
			this._setTips('#ffff00');
		}
		
		private function _editCheckBoxChange(_e:Event):void{
			var _info_toc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			if(_info_toc && this._editCheckBox.selected == true){
				var _info:p_personybc_info = _info_toc.info;
				if(this._error){
					this._setTips('#ff0000', '你的输入误，请检查。');
					this._editCheckBox.selected = false;
					return;
				}
			}
			this._setTips('#ffff00');
		}
		
		private function _closeFunc(e:MouseEvent):void
		{
			this.closeWindow();
		}
		
		override public function closeWindow(save:Boolean = false):void
		{
			super.closeWindow(save)
		}
		
		private function _setTips(_color:String, _str:String = null):void{
			if(_str == null){
				_str = '注意：可设定国运时间段12:00-24:00';
			}
			this._tips.htmlText = '<font color="'+_color+'">'+_str+'</font>';
		}
		
	}
}