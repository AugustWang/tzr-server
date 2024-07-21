package modules.broadcast.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.managers.LayerManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.VScrollText;
	import com.ming.ui.controls.CheckBox;
	import com.utils.PathUtil;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import modules.npc.NPCConstant;
	import modules.roleStateG.RoleStateModule;
	import modules.vip.VipModule;
	
	/**
	 * @author handing
	 * createTime:2011.4.21 - 12:00
	 * function:武器耐久度提示的窗口
	 */	
	public class EnduranceCheckWindow extends BasePanel
	{
		
		public static const POPUP_WINDOW:String = "ENDURANCE_CHECK_WINDOW";
		private var func:Function;
		private var argsObj:Object;
		private var tf:TextFormat;
		
		public function EnduranceCheckWindow(key:String=null)
		{
			super(key);
			this.panelSkin = Style.getInstance().tipPanelSkin;
		}
		
		private var _content:VScrollText;//TextField;
		private var _linkText:TextField;
		private var _timer:Timer;
		
		private var _checkBox:CheckBox;
		
		override protected function init():void
		{
			title = "《天之刃》温馨提示";
			titleAlign = 2;
			this.headHeight = 23;
			this.closeTop = 1;
			this.closeRight = 1;
			titleFormat = getTextFormat();
			allowDrag = false;
//			width = 250;
//			height = 80;//100;
			
			addEventListener(MouseEvent.MOUSE_OVER,onFocusInHandler);
			addEventListener(MouseEvent.MOUSE_OUT,onFocueOutHandler);
			
			setupUI();
		}
		
		private function setupUI():void
		{
			tf = new TextFormat("",12,0x00ff00);
			tf.align = "right";
			
			_timer = new Timer(1000,5);
			//			_timer.addEventListener(TimerEvent.TIMER,timerHandler);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerHandler);
			
			_content = new VScrollText(); //new TextField();
			_content.direction = ScrollDirection.RIGHT;
			_content.verticalScrollPolicy = ScrollPolicy.OFF;//AUTO;
			_content.width = 250;//160
			_content.height = 50;// 55;
			_content.x = 10;
			_content.y = 3;
			_content.textField.defaultTextFormat = getTextFormat();
			_content.textField.autoSize = TextFieldAutoSize.CENTER;
			_content.textField.multiline = true;
			_content.textField.selectable = false;
			_content.textField.wordWrap = true;
//			_content.htmlText = "你的好友 十三姨 上线了！"
			_content.htmlText = "您装备耐久度为<font color='#FF0000'>0</font>,可点击<font color='#00ff00'><a href='event:findNPC'><u>铁匠铺</u></a></font>前往修理.";
			
			addChild(_content);
			_content.addEventListener(TextEvent.LINK, onLink);
			
			_checkBox = new CheckBox();
			_checkBox.x = 100;
			_checkBox.y = _content.y + _content.height - 30;
			
			_checkBox.text = "今天不再提示!!!";
			_checkBox.textFormat = getTextFormat();
			addChild(_checkBox);
		}
		
		private function onLink(e:TextEvent):void
		{
			switch (e.text) { 
				case  "findNPC":
					var roleFaction:int = GlobalObjectManager.getInstance().user.base.faction_id;
					var tieJiangNPCID:int = NPCConstant.NPC_JING_CHENG_TIE_JIANG_ID[roleFaction];
					PathUtil.findNpcAndOpen(tieJiangNPCID);
				break;
				
				default:
					break;
			}
		}
		
		private function getTextFormat():TextFormat
		{
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = 0xFFF799;
			textFormat.size = 12;
			return textFormat;
		}
		
		private var _yPos:Number;
		public function popup(yPos:Number,sec:int = 5):void       //默认5秒
		{
			_timer.reset();
			_timer.repeatCount = sec;
			_timer.start();
			_yPos = yPos;
			
			this.y = _yPos;
			LayerManager.uiLayer.addChild(this);
		}
		
		private function popupHandler(evt:Event):void
		{
			var distance:Number = y - _yPos
			if(distance<=0)
			{
				removeEventListener(Event.ENTER_FRAME,popupHandler);
				this.y = _yPos;
			}else
			{
				this.y -=6;
			}
		}
		
		override protected function closeHandler(event:CloseEvent=null):void
		{
			if(_checkBox.selected == true && RoleStateModule.getInstance().mediator.playSet != "yes")
			{
				RoleStateModule.getInstance().mediator.playSet = "yes";
				
				GlobalObjectManager.getInstance().addObject("checkEndurance","yes",true);
			}
			
			_timer.stop();
			if(_linkText &&this.contains(_linkText))
			{
				removeChild(_linkText);
				_linkText.removeEventListener(TextEvent.LINK, onLink);
			}
			if(parent)	
				parent.removeChild(this);
		}
		
		private function timerHandler(evt:TimerEvent):void
		{
			closeHandler();
		}
		
		private function onFocusInHandler(evt:MouseEvent):void
		{
			_timer.stop();
		}
		
		private function onFocueOutHandler(evt:MouseEvent):void
		{
			_timer.reset();
			_timer.start();
		}
	}
}