package modules.broadcast.views {
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.friend.FriendsModule;
	import modules.vip.VipModule;

	public class PopupWindow extends Sprite {
		public static const POPUP_WINDOW:String="POPUP_WINDOW"

		private var func:Function;
		private var argsObj:Object;
		private var tf:TextFormat;

		public function PopupWindow(key:String=null) {
			init();
		}

		private var _content:VScrollText; //TextField;
		private var _linkText:TextField;
		private var _timer:Timer;

		protected function init():void {
			var skin:Skin=Style.getSkin("tipBgSkin", GameConfig.T1_UI);
			addChild(skin);
			var closeButton:UIComponent=new UIComponent();
			closeButton.addEventListener(MouseEvent.CLICK, closeHandler);
			closeButton.bgSkin=Style.getButtonSkin("close_1skin", "close_2skin", "close_3skin", null, GameConfig.T1_UI);
			closeButton.x=221;
			closeButton.y=150;
			closeButton.buttonMode=true;
			closeButton.useHandCursor=true;
			addChild(closeButton);
			addEventListener(MouseEvent.ROLL_OVER, onFocusInHandler);
			addEventListener(MouseEvent.ROLL_OUT, onFocueOutHandler);
			var ttf:TextFormat=new TextFormat(null, 15, 0xF3832F, true, null, null, null, null, "center");
			var warmTip:TextField=ComponentUtil.createTextField("温馨提示", 12, 150, ttf, 228, 22, this);
			tf=new TextFormat("", 12, 0x00ff00);
			tf.align="right";

			_timer=new Timer(1000, 5);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);

			_content=new VScrollText();
			_content.direction=ScrollDirection.RIGHT;
			_content.verticalScrollPolicy=ScrollPolicy.OFF; //AUTO;
			_content.width=228;
			_content.height=60; //有LINK时44，没link时60 
			_content.x=12;
			_content.y=172;
			_content.textField.defaultTextFormat=getTextFormat();
			_content.textField.multiline=true;
			_content.textField.selectable=false;
			_content.textField.wordWrap=true;
			_content.htmlText="你的好友 十三姨 上线了！"
			addChild(_content);
			_content.addEventListener(TextEvent.LINK, onLink);
			var tf2:TextFormat=new TextFormat(null,null,0x00ff00,null,null,null,null,null,"right");
			_linkText=ComponentUtil.createTextField("", 12, 220, tf2, 228, 22, this);
			_linkText.mouseEnabled=true;
			_linkText.addEventListener(TextEvent.LINK, onLink);
		}

		public function setContent(value:String, linkStr:String="", clickFun:Function=null, argObj:Object=null):void {
			value="    " + value; //空2个字
			_content.htmlText=value;
			if (linkStr == "") {
				_content.height=60;
				_linkText.visible=false;
			} else {
				_content.height=44;
				argsObj=argObj;
				if (clickFun != null) {
					func=clickFun;
				}
				_linkText.htmlText=HtmlUtil.link(linkStr, "link", true);
				_linkText.visible=true;
			}
		}

		private function onLink(e:TextEvent):void {
			var link:Array=e.text.split("#");
			var order:String=link[0] as String;
			if (order == "openVip") {
				VipModule.getInstance().onOpenVipPannel();
			} else if (order == "friendCongratula") {
				var args:Array=String(link[1]).split(",");
				FriendsModule.getInstance().goodLuckHandler(args[0], args[1], args[2]);
			} else if (func != null) {
				if (argsObj) {
					func.apply(null, [argsObj]);
				} else {
					func.apply(null, null);
				}
			}

			closeHandler();
		}

		private function getTextFormat():TextFormat {
			var textFormat:TextFormat=new TextFormat();
			textFormat.color=0xFFF799;
			textFormat.size=12;
			return textFormat;
		}

		private var _yPos:Number;

		public function popup(sec:int=5):void //默认5秒
		{
			_timer.reset();
			_timer.repeatCount=sec;
			_timer.start();
			this.x=GlobalObjectManager.GAME_WIDTH - this.width - 20;
			this.y=GlobalObjectManager.GAME_HEIGHT - this.height - 62;
			LayerManager.uiLayer.addChild(this);
		}

		private function popupHandler(evt:Event):void {
			var distance:Number=y - _yPos
			if (distance <= 0) {
				removeEventListener(Event.ENTER_FRAME, popupHandler);
				this.y=_yPos;
			} else {
				this.y-=6;
			}
		}

		protected function closeHandler(event:MouseEvent=null):void {
			_timer.stop();
			if (parent)
				parent.removeChild(this);
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}

		private function timerHandler(evt:TimerEvent):void {
			closeHandler();
		}

		private function onFocusInHandler(evt:MouseEvent):void {
			_timer.stop();
		}

		private function onFocueOutHandler(evt:MouseEvent):void {
			_timer.reset();
			_timer.start();
		}
	}
}