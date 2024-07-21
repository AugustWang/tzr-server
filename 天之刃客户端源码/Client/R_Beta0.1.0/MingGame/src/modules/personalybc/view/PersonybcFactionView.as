package modules.personalybc.view
{
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.system.SystemConfig;
	import modules.personalybc.PersonalYbcModule;
	
	import proto.line.m_personybc_faction_tos;
	import proto.line.m_personybc_info_toc;
	import proto.line.p_personybc_info;
	
	public class PersonybcFactionView extends BasePanel
	{
		private var _infoTxt:TextField
		private var _tips:TextField;
		private var _pointStr:TextField;
		
		private var _startHInput:TextInput;
		private var _startMInput:TextInput;
		private var _startTimeTxt:TextField;
		private var _endTimeTxt:TextField;
		
		private const FACTION_MIN_H:int = 12;
		private const FACTION_MAX_H:int = 24;
		private var _error:Boolean = false;
		
		private var _startCheckBox:CheckBox
		private var _editView:Sprite;
		private var _editTxt:TextField;
		private var _editTipsTxt:TextField;
		
		public function PersonybcFactionView(key:String=null)
		{
			super(key);
			initView();
			
		}
		
		public function initView():void
		{
			//代码优化注释
			//this.x = NPCModel.getInstance().view.x;
			//this.y = NPCModel.getInstance().view.y;
			//代码优化注释
			this.title = "发布运";
			this.titleAlign = 2;
			this.width = 265;
			this.height = 345;
			var _startX:int = 22;
				
//			this.panelSkin = Style.getInstance().panelSkinNoBg;
			bgAlpha = 0;
			
			var ui:Sprite = new Sprite();
			ui.x = 7;
			addChild(ui);
			
			_infoTxt = ComponentUtil.createTextField("", _startX, 12, null, 220, 140, this);
			var _glow:GlowFilter = new GlowFilter(0x000000,1,2,2);
			
			var _infoStr:String = "张居正：\n";
			_infoStr += '      国运期间完成国运拉镖任务，额外获得';
			_infoStr += '<font color="#FFFF00">50%</font>的经验奖励，获得的银子奖励';
			_infoStr += '<font color="#FFFF00">25%</font>为不绑定银子。</font>';
			_infoStr += '\n\n      <font color="#ffffff">每天国运时间：</font>\n';
			
			var _tf:TextFormat = new TextFormat;
			_tf.leading = 5;
			
			_infoTxt.defaultTextFormat = _tf;
			_infoTxt.htmlText = _infoStr;
			_infoTxt.filters = [_glow];
			_infoTxt.multiline = true;
			_infoTxt.wordWrap = true;
			
			_startTimeTxt = ComponentUtil.createTextField('', 43, 125, null, 35, 20, this);
			_startTimeTxt.filters = [_glow];
			_endTimeTxt = ComponentUtil.createTextField('', _startTimeTxt.x+_startTimeTxt.width, _startTimeTxt.y, null, 60, 20, this);
			_endTimeTxt.filters = [_glow];
			
			
			_editTxt = ComponentUtil.createTextField('', _endTimeTxt.x+_endTimeTxt.width, _endTimeTxt.y, null, 100, 20, this);
			_editTxt.htmlText = '<font color="#58f1ff">'+HtmlUtil.link(" 修改国运时间", "edit", true)+'</font>';
			_editTxt.filters = [_glow];
			_editTxt.mouseEnabled = true;
			_editTxt.addEventListener(TextEvent.LINK, _editFunc);
			
			this._setCurrentTimeStr();
			
			
			_startCheckBox = new CheckBox();
			_startCheckBox.x = 45;
			_startCheckBox.y = 165;
			_startCheckBox.htmlText = '<font color="#ffffff">立即发布今天国运</font>';
			//_startCheckBox.textFilter = [_glow];
			this.addChild(_startCheckBox);
			
			
			this._editTipsTxt = ComponentUtil.createTextField('', 43, 145, null, 220, 140, this);
			this._editTipsTxt.filters = [_glow];
			
			this._tips = ComponentUtil.createTextField('', 21, 200, null, 220, 140, this);
			this._tips.filters = [_glow];
			this._tips.htmlText = '<font color="#ffff00">注意：可设定国运时间段12:00-24:00\n         国探、国运、国战不可同时进行！\n</font>';
			
			var _sureBtn:Button = ComponentUtil.createButton("确定", 115, 282, 66, 25, this);
			_sureBtn.addEventListener(MouseEvent.CLICK, _sureFunc);
			
			var _closelBtn:Button = ComponentUtil.createButton("取消", 187, 282, 66, 25, this);
			_closelBtn.addEventListener(MouseEvent.CLICK, _closeFunc);
			
			this._setEditView(false);
			this._startCheckBoxCheck();
			
			this.addEventListener(WindowEvent.OPEN, this._winOpen);
		}
		
		private function _setCurrentTimeStr():void{
			var _infoToc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			if(_infoToc && _infoToc.info){
				this._updateTimeStr(
					DateFormatUtil.formatHM(_infoToc.info.faction_start_time),
					DateFormatUtil.formatHM(_infoToc.info.faction_start_time + _infoToc.info.time_limit));
			}
		}
		
		private function _updateTimeStr(_startTimeStr:String, _endTimeStr:String):void{
			this._startTimeTxt.htmlText = '<font color="#ffff00">'+_startTimeStr+'</font>';
			this._endTimeTxt.htmlText = '<font color="#ffffff"> 至 </font><font color="#ffff00">'+_endTimeStr+'</font>';
		}
		
		private function _closeFunc(e:MouseEvent):void
		{
			this.closeWindow();
		}
		
		override public function closeWindow(save:Boolean = false):void
		{
			this._timeChange();
			this._startCheckBoxCheck();
			super.closeWindow(save);
			this._setEditView(false);
		}
		
		private function _editFunc(e:TextEvent):void
		{
			var _text:String = e.text;
			switch(_text){
				case 'edit':
					_setEditView(true);
					break;
				
				case 'cancel':
					_setEditView(false);
					break;
				
				default:
					break;
			}
		}
		
		private function _setEditView(_visible:Boolean=false):void{
			if(!_editView){
				_editView = new Sprite();
				this.addChild(_editView);
				
				_startHInput = ComponentUtil.createTextInput(
					0, 0, 20, 20, _editView,
					this._timeChange, 2, '0-9');
				
				var _glow:GlowFilter = new GlowFilter(0x000000,1,2,2);
				var _pointStr:TextField = new TextField();
				_pointStr.htmlText = '<b><font color="#ffffff">:</font></b>';
				_pointStr.filters = [_glow];
				_pointStr.x = _startHInput.x+_startHInput.width;
				_pointStr.y = _startHInput.y;
				_pointStr.width = 12;
				_pointStr.selectable = false;
				_editView.addChild(_pointStr);
				
				_startMInput = ComponentUtil.createTextInput(
					_pointStr.x+_pointStr.textWidth+4, 0, 20, 20, _editView, 
					this._timeChange, 2, '0-9');
				
				_editView.x = 45;
				_editView.y = 125;
			}
			
			if(_visible){
				this._editTxt.htmlText = '<font color="#58f1ff">'+HtmlUtil.link("取消", "cancel", true)+'</font>';
				this._startTimeTxt.htmlText = '';
				this._startTimeTxt.visible = false;
				this._setCurrentTimeStr();
				this._endTimeTxt.x = 90;
				this._timeChange();
			}else{
				_editTxt.htmlText = '<font color="#58f1ff">'+HtmlUtil.link("修改国运时间", "edit", true)+'</font>';
				this._setCurrentTimeStr();
				this._startTimeTxt.visible = true;
				this._endTimeTxt.x = this._startTimeTxt.x+this._startTimeTxt.width;
			}
			_editView.visible = _visible;
			this._editTxt.x = this._endTimeTxt.x+this._endTimeTxt.width;
		}
		
		private function _timeChange(_e:Event=null):void{
			var _info_toc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			if(_info_toc){
				var _info:p_personybc_info = _info_toc.info;
				if(_info){
					this._error = true;
					
					var _nowTimeStr:String = DateFormatUtil.formatHM(SystemConfig.serverTime);
					var _nowTimeArr:Array = _nowTimeStr.split(':');
					_nowTimeArr[0] = parseInt(_nowTimeArr[0]);
					_nowTimeArr[1] = parseInt(_nowTimeArr[1]);
					
					var _currentTimeStr:String = DateFormatUtil.formatHM(_info.faction_start_time);
					var _currentTimeArr:Array = _currentTimeStr.split(':');
					if(this._startHInput.text == '' && this._startMInput.text == ''){
						this._startHInput.text = _currentTimeArr[0];
						this._startMInput.text = _currentTimeArr[1];
					}
					_currentTimeArr[0] = parseInt(_currentTimeArr[0]);
					_currentTimeArr[1] = parseInt(_currentTimeArr[1]);
					
					var _timeStartHValue:int = parseInt(this._startHInput.text);
					var _timeStartMValue:int = parseInt(this._startMInput.text);
					
					if(_timeStartHValue >= FACTION_MAX_H || _timeStartHValue < FACTION_MIN_H || _timeStartMValue < 0 || _timeStartMValue > 60){
						this._setTips('#FF0000', '可设定国运时间段12:00-24:00');
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
						this._setTips('#FF0000', '可设定国运时间段12:00-24:00');
						return;
					}
					
					if(_info.faction_start_time > SystemConfig.serverTime && _timeStartHValue >= _nowTimeArr[0]){
						this._setTips('#FFFF00', '修改后国运时间将在今天开始启用。');
					}else{
						this._setTips('#FFFF00', '修改后国运时间将在明天开始启用。');
					}
					
					
					var _timeEndStr:String = _timeEndHValue.toString()+':';
					_timeEndStr += (_timeEndMValue < 10 ? '0'+_timeEndMValue.toString() : _timeEndMValue.toString());
					
					var _timeStartStr:String = _timeStartHValue.toString()+':';
					_timeStartStr += (_timeStartMValue < 10 ? '0'+_timeStartMValue.toString() : _timeStartMValue.toString());
					
					this._updateTimeStr(_timeStartStr, _timeEndStr);
					this._error = false;
				}
			}
		}
		
		private function _startCheckBoxCheck():void{
			var _info_toc:m_personybc_info_toc = PersonalYbcModule.getInstance().view.info_toc;
			var _now:int = SystemConfig.serverTime;
			var _currentDate:Array = DateFormatUtil.formatHM(_now).split(':');
				
			if(_info_toc){
				var _info:p_personybc_info = _info_toc.info;
				if(_info){
					if(parseInt(_currentDate[0]) < FACTION_MIN_H || SystemConfig.serverTime >= _info.faction_start_time){
						this._startCheckBox.enable = false;
						this._startCheckBox.selected = false;
						this._startCheckBox.htmlText = '<font color="#cccccc">立即发布今天国运</font>';
						return;
					}		
				}
			}
			this._startCheckBox.enable = true;
			this._startCheckBox.htmlText = '<font color="#ffffff">立即发布今天国运</font>';
		}
		
		private function _setTips(_color:String, _str:String = null):void{
			this._editTipsTxt.htmlText = '<font color="'+_color+'">'+_str+'</font>';
		}
		
		private function _winOpen(_e:WindowEvent):void{
			this._timeChange();
			this._startCheckBoxCheck();
		}
		
		
		private function _sureFunc(_e:MouseEvent):void
		{
			
			if(this._error){
				return;
			}
			
			var _type:int = 0;//只修改时间
			//var _type:int = 1;//只发布
			if(this._startCheckBox.selected == true){
				_type = 2;//即发布国运又修改时间
			}
			
			var _vo:m_personybc_faction_tos = new m_personybc_faction_tos();
			_vo.type = _type;
			_vo.start_h = parseInt(this._startHInput.text);
			_vo.start_m = parseInt(this._startMInput.text);
			PersonalYbcModule.getInstance().personybcFactionConfirmFunc(_vo);
			this.closeWindow();
		}
		
	}
}