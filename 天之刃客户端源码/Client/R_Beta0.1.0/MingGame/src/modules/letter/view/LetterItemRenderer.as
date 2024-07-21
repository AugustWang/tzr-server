package modules.letter.view {
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.letter.LetterType;
	import modules.letter.LetterVOs;
	import modules.system.SystemConfig;
	
	import proto.line.p_letter_simple_info;

	public class LetterItemRenderer extends UIComponent implements IDataRenderer {
		private var _data:p_letter_simple_info;

		private var type:TextField;
		public var checkBox:CheckBox;

		private var title:TextField;
		private var icon:Bitmap;
		private var accessory:Bitmap;

		private var time:TextField;
		private var leaveTime:TextField;
		
		public static const MAX_DAY:int = 14;
		public function LetterItemRenderer() {
			init();
		}


		private function init():void {
			//复选框
			checkBox=new CheckBox;
			checkBox.width=20;
			checkBox.height=20;
			checkBox.x=5;
			addChild(checkBox);

			//信件类型
			type=new TextField;
			type.defaultTextFormat=new TextFormat("Tahoma", 12, 0xb7e700);
			type.mouseEnabled=false;
			type.x=checkBox.x + checkBox.width + 5;
			type.y=checkBox.y;
			type.width=60;
			type.height=26;
			addChild(type);

			//信件图标
			icon=new Bitmap();
			addChild(icon);

			//信件标题
			title=new TextField();
			title.width=190;
			title.height=26;
			title.mouseEnabled=false;
			title.x=115;
			title.y=checkBox.y;
			title.defaultTextFormat=new TextFormat("Tahoma", 12, 0xffcc00);
			addChild(title);

			//时间
			time=new TextField();
			time.defaultTextFormat=new TextFormat(null, 12, 0xb7e700);
			time.mouseEnabled=false;
			time.selectable=false;
			time.width=120;
			time.height=26;
			time.x=305;
			time.y=checkBox.y;
			addChild(time);

			leaveTime=new TextField();
			leaveTime.defaultTextFormat=new TextFormat(null, 12, 0x00ff00,null,null,null,null,null,"center");
			leaveTime.mouseEnabled=false;
			leaveTime.selectable=false;
			leaveTime.width=30;
			leaveTime.height=26;
			leaveTime.x=425;
			leaveTime.y=checkBox.y;
			addChild(leaveTime);
			
			this.buttonMode=true;
			this.useHandCursor=true;


			//装附件图标的容器
			accessory=new Bitmap();
			this.addChild(accessory);
			accessory.x=98 - 15;
			accessory.y=4;
		}

		public function selected(bool:Boolean):void {
			checkBox.selected=bool;
		}

		override public function get data():Object {
			return this._data;
		}

		override public function set data(value:Object):void {
			this._data=value as p_letter_simple_info;

			//信件类型0:私人，3：退信
			if (this._data.type == 0 || _data.type == 3) {
				type.text="私人";
			} else if (_data.type == 1) {
				type.text="门派";
			} else if (_data.type == 2) {
				type.text="系统";
			} else if (_data.type == 4) {
				type.text="GM";
			}
			//附件图标
			accessory.bitmapData = null;
			if (_data.is_have_goods) {
				accessory.bitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"letter_newfj");
			}
			//信件标题
			title.htmlText=LetterVOs.getTitle(value);
			var bg:BitmapData = Style.getUIBitmapData(GameConfig.T1_VIEWUI,"letter_unread");
			if (_data.state == LetterType.UNOPEN) {
				if (this._data.sender == GlobalObjectManager.getInstance().user.base.role_name) {
					bg=Style.getUIBitmapData(GameConfig.T1_VIEWUI,"readedLetter");
				} else {
					bg=Style.getUIBitmapData(GameConfig.T1_VIEWUI,"letter_unread");
				}
			} else if (_data.state == LetterType.OPEN) {
				bg=Style.getUIBitmapData(GameConfig.T1_VIEWUI,"letter_read");
				title.htmlText=LetterVOs.getTitle(value, "open");
			} else {
				bg=Style.getUIBitmapData(GameConfig.T1_VIEWUI,"letter_reply");
			}
			icon.bitmapData = bg;
			icon.x=109 - 15;
			icon.y=4;

			//信件时间
			time.text=parseDate(_data.send_time);
			leaveTime.text = MAX_DAY - Math.ceil((SystemConfig.serverTime - _data.send_time)/(24*3600))+"";
		}

		public static function parseDate(value:int):String {
			var date:Date=new Date();
			date.setTime(value * 1000);
			if ((date.month + 1) < 10) {
				var mon:String="0" + (date.month + 1);
			} else {
				mon=date.month + 1 + "";
			}
			if (date.date < 10) {
				var day:String="0" + date.date;
			} else {
				day=date.date + "";
			}
			if (date.hours < 10) {
				var h:String="0" + date.hours;
			} else {
				h=date.hours + "";
			}
			if (date.minutes < 10) {
				var min:String="0" + date.minutes;
			} else {
				min=date.minutes + "";
			}
			return date.fullYear + "-" + mon + "-" + day + " " + h + ":" + min;
		}
	}
}