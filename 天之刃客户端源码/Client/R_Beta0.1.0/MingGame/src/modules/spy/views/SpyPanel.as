package modules.spy.views
{
	
	import com.components.BasePanel;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.TextInput;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.spy.SpyModule;
	
	import proto.line.m_spy_time_toc;
	
	public class SpyPanel extends BasePanel
	{		
		private var _endTime:TextField;
		private var _startTimeHour:TextInput;
		private var _startTimeMin:TextInput;
		private var _startHourTxt:TextField;
		private var _startMinTxt:TextField;
		private var _modify:TextField;
		private var _modifyInfo:TextField;
		private var _point:TextField;
		private var _data:m_spy_time_toc;
		
		public function SpyPanel(key:String=null)
		{
			super(key);
			initView();
		}
		
		private function initView():void
		{
			this.title = "发布国探";
			this.titleAlign = 2;
			this.width = 265;
			this.height = 345;
			
//			this.panelSkin = Style.getInstance().panelSkinNoBg;
			bgAlpha = 0;
			
			var ui:Sprite = new Sprite();
			ui.x = 7;
			addChild(ui);
			
			var _infoTxt:TextField= ComponentUtil.createTextField("", 20, 10, null, 238, 140, this);
			var glow:GlowFilter = new GlowFilter(0x000000,1,2,2);
			
			var _infoStr:String = "张居正：\n";
			_infoStr += "      国探期间完成刺探军情任务可获得额\n";
			_infoStr += "外的<font color=\"#FFFF00\">30%</font>的经验奖励。经验奖励随着任务\n";
			_infoStr += "次数而翻倍。\n\n";
			_infoStr += "      默认国探时间：\n";
			
			var _tf:TextFormat = new TextFormat;
			_tf.leading = 5;
			
			_infoTxt.defaultTextFormat = _tf;
			_infoTxt.htmlText = _infoStr;
			_infoTxt.filters = [glow];
			addChild(_infoTxt);
			
			_point = ComponentUtil.createTextField(":", 64, 127, null, NaN, 20, this);
			ComponentUtil.createTextField("至", 94, 127, null, NaN, 20, this).filters = [glow];
			
			_startTimeHour = new TextInput;
			_startTimeHour.x = 45;
			_startTimeHour.y = 127;
			_startTimeHour.height = 20;
			_startTimeHour.width = 20;
			_startTimeHour.maxChars = 2;
			_startTimeHour.restrict = "0-9";
			addChild(_startTimeHour);
			_startTimeHour.addEventListener(Event.CHANGE, timeChange);
			
			_startTimeMin = new TextInput;
			_startTimeMin.x = 71;
			_startTimeMin.y = 127;
			_startTimeMin.height = 20;
			_startTimeMin.width = 20;
			_startTimeMin.maxChars = 2;
			_startTimeMin.restrict = "0-9";
			addChild(_startTimeMin);
			_startTimeMin.addEventListener(Event.CHANGE, timeChange);
			
			_endTime = ComponentUtil.createTextField("", 108, 127, null, 43, 20, this);
			_endTime.textColor = 0xffff00;
			_endTime.filters = [glow];
			addChild(_endTime);
			
			_modify = ComponentUtil.createTextField("", 155, 127, _tf, 80, 25, this);
			_modify.htmlText = HtmlUtil.link("修改国探时间", "update", true);
			_modify.textColor = 0x58f1ff;
			_modify.mouseEnabled = true;
			_modify.filters = [glow];
			_modify.addEventListener(TextEvent.LINK, modify);
			
			var sure:TextField = ComponentUtil.createTextField("立即发布", 45, 167, _tf, 200, 25, this);
			sure.htmlText = HtmlUtil.link("立即发布", "sure", true);
			sure.textColor = 0x58f1ff;
			sure.mouseEnabled = true;
			sure.filters = [glow];
			sure.addEventListener(TextEvent.LINK, onSrue);
			
			_modifyInfo = ComponentUtil.createTextField("修改后国探时间将在今天开始起作用", 45, 147, _tf, 200, 25, this);
			_modifyInfo.textColor = 0xffff00;
			_modifyInfo.filters = [glow];
			
			_startHourTxt = ComponentUtil.createTextField("", 48, 127, null, 20, 20, this);
			_startHourTxt.textColor = 0xffff00;
			_startHourTxt.filters = [glow];
			
			_startMinTxt = ComponentUtil.createTextField("", 71, 127, null, 20, 20, this);
			_startMinTxt.textColor = 0xffff00;
			_startMinTxt.filters = [glow];
			
			var _noticeStr:String = "";
			_noticeStr += "注意：可设定国探时间段12:00-24:00；\n";
			_noticeStr += "         国探、国运、国战不可同时进行，\n";
			_noticeStr += "         请分配好时间。";
			
			ComponentUtil.createTextField(_noticeStr, 20, 207, null, 238, 140, this).filters = [glow];
			
			var okBtn:Button = ComponentUtil.createButton("确定", 107, 282, 66, 25);
			addChild(okBtn);
			okBtn.addEventListener(MouseEvent.CLICK, close);
			
			var cancelBtn:Button = ComponentUtil.createButton("取消", 187, 282, 66, 25);
			addChild(cancelBtn);
			cancelBtn.addEventListener(MouseEvent.CLICK, close);
			
		}
		
		private function close(e:Event):void
		{
			this.closeWindow();
		}
		
		private function onSrue(e:TextEvent):void
		{
			SpyModule.getInstance().spyFactionTos();
		}
		
		private function modify(e:TextEvent):void
		{
			if (e.text == "update") {
				var link:String = HtmlUtil.link("确定", "sure", true);
				link += "    ";
				link += HtmlUtil.link("取消", "cancel", true);
				_modify.htmlText = link;
				_startTimeHour.visible = true;
				_startTimeMin.visible = true;
				_startHourTxt.visible = false;
				_startMinTxt.visible = false;
				_point.textColor = 0xfff7ce;
			} else if (e.text == "cancel") {
				setData(_data);
			} else {
				SpyModule.getInstance().spyTimeTos(_startTimeHour.text, _startTimeMin.text);
			}
		}
		
		public function setData($vo:m_spy_time_toc):void
		{		
			_data = $vo;
			_modify.htmlText = HtmlUtil.link("修改国探时间", "update", true);
			_startTimeHour.text = $vo.start_hour.toString();
			_startTimeMin.text = minInt2Str($vo.start_min);
			_startTimeHour.visible = false;
			_startTimeMin.visible = false;
			_point.textColor = 0xffff00;
			
			_startHourTxt.text = $vo.start_hour.toString();
			_startMinTxt.text = minInt2Str($vo.start_min);
			_startHourTxt.visible = true;
			_startMinTxt.visible = true;
			
			_endTime.text = (($vo.start_hour+1)%24) + " : " + minInt2Str(($vo.start_min+60)%60);
			
			if ($vo.has_publish) {
				_modifyInfo.text = "修改后国探时间将在明天开始起作用";				
			} else {
				_modifyInfo.text = "修改后国探时间将在今天开始起作用";
			}
		}
		
		private function timeChange(e:Event):void
		{
			var _hour:int = int(_startTimeHour.text);
			var _min:int = int(_startTimeMin.text);
			
			if (_startTimeHour.text == "" || _startTimeMin.text == "" || _hour < 12 || _hour >= 24 || _min < 0 || _min >= 60) {
				_modifyInfo.htmlText = "<font color=\"#FF0000\">可设定国探时间段12:00-24:00</font>";
			} else {				
				_endTime.text = ((_hour+1)%24) + " : " + minInt2Str((_min+60)%60);
				
				if (_data.has_publish) {
					_modifyInfo.text = "修改后国探时间将在明天开始起作用";
					
				} else {
					_modifyInfo.text = "修改后国探时间将在今天开始起作用";
				}
			}
		}
		
		public function minInt2Str(min:int):String
		{
			if (min < 10) {
				return "0" + min;
			}
			
			return min.toString();
		}
	}
}