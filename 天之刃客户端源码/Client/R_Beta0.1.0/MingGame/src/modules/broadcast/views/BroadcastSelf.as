package modules.broadcast.views
{
	import com.common.GlobalObjectManager;
	import com.events.WindowEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.scene.GameScene;
	import com.scene.tile.Pt;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.HtmlUtil;
	import com.utils.PathUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.setTimeout;
	
	import modules.Activity.ActivityModule;
	import modules.ModuleCommand;
	import modules.broadcast.BroadCastConstant;
	import modules.friend.FriendsModule;
	import modules.playerGuide.PlayerGuideModule;
	import modules.system.Anti_addiction;
	import modules.system.SystemModule;
	
	import proto.line.m_system_fcm_toc;
	
	public class BroadcastSelf extends Sprite
	{
		private static var instance:BroadcastSelf;
		private var text:TextField;
		private var items:Array = [];
		
		public var textColor:uint = 0xffffff; 
		public var linkColor:uint = 0xffff00;
		public var hoverColor:uint = 0xffff00;
		
		private var openClose:UIComponent;
		private var historyMessages:Array = [];
		private var openSkin:ButtonSkin;
		private var closeSkin:ButtonSkin;
		private var click_map:Boolean = true;
		public function BroadcastSelf()
		{
			super();
			
			// 157 120
			this.mouseEnabled=false;
			var tf:TextFormat = new TextFormat("Arail",12,0xffffff);
			text = ComponentUtil.createTextField("",0,2,tf,152,130); 
			text.multiline = true;
			text.wordWrap = true;
			text.mouseEnabled = true;
			text.addEventListener(TextEvent.LINK, linkHandler);
			text.filters=[new GlowFilter(0x0, 1, 2, 2, 20)];
			addChild(text);
			openSkin = Style.getButtonSkin("add_1skin","add_2skin","add_3skin","",GameConfig.T1_UI);
			closeSkin = Style.getButtonSkin("reduce_1skin","reduce_2skin","reduce_3skin","",GameConfig.T1_UI);
			openClose = ComponentUtil.createUIComponent(132,115,16,15,openSkin);
			openClose.addEventListener(MouseEvent.CLICK,onOpenCloseHistory);
			addChild(openClose);
			Dispatch.register(ModuleCommand.STAGE_RESIZE,onStageResize);
			addEventListener(MouseEvent.CLICK,clickMapHandler);
			onStageResize();
		}
		
		private function clickMapHandler(event:MouseEvent):void{
			if(click_map && event.target is TextField){
				GameScene.getInstance().onClickMap();
				GameScene.getInstance().clearRoadCounter();
			}
			click_map = true;
		}
		
		private function onStageResize(obj:Object=null):void{
			this.x = GlobalObjectManager.GAME_WIDTH - 155;
			this.y = GlobalObjectManager.GAME_HEIGHT - 230;
		}
		
		
		private var broadcastPanel:BroadcastPanel;
		private function onOpenCloseHistory(event:MouseEvent):void{
			if(broadcastPanel == null){
				broadcastPanel = new BroadcastPanel();
				broadcastPanel.addEventListener(TextEvent.LINK,linkHandler);
				broadcastPanel.addEventListener(WindowEvent.CLOSEED,closeHandler);
				broadcastPanel.messages = historyMessages;
			}
			broadcastPanel.centerOpen();
			openClose.bgSkin = broadcastPanel.isPopUp ? closeSkin : openSkin;
		}
		
		private function closeHandler(event:WindowEvent):void{
			openClose.bgSkin = broadcastPanel.isPopUp ? closeSkin : openSkin;
		}
		
		private function addHistoryMsg(msg:String):void{
			var date:Date = new Date();
			msg = HtmlUtil.font("["+DateFormatUtil.formatHours(date.time/1000)+"]","#ffff00")+msg;
			historyMessages.push(msg);
			if(broadcastPanel){
				broadcastPanel.update();
			}
		}
		
		private function linkHandler(e:TextEvent):void
		{
			click_map = false;
			var args:Array=e.text.split('#');
			if(args.length>0){
				var order:String=args.shift()
				var key:String;
				
				switch(order){
					
					case "goto":
						args=args[0].split(',');
						PathUtil.goto(args[0], new Pt(args[1], 0, args[2]));
						break;
					case Anti_addiction.OPEN_VIEW:
						args=args[0].split('$')
						var value:m_system_fcm_toc = new m_system_fcm_toc();
						value.info = String(args[0])
						value.total_time = int(args[1]);
						value.remain_time = int(args[2]);
						SystemModule.getInstance().openFCMWindow(value);
						break;
					case BroadCastConstant.ATTACK:
						args = args[0].split(','); 
						var menu:KillAttackMenu = new KillAttackMenu();
						if(stage){
							menu.popup(stage.mouseX-100, stage.mouseY, args);//mouseX-109,mouseY-45
						}
						break;
					case ModuleCommand.TO_LV_UP:
						showToLvUp();
						break;
					case ModuleCommand.OPEN_FAMILY:
						openFamilyPanel();
						break;
					case ModuleCommand.OPEN_ACTIVE:
						openActive();
						break;
					case "gotoNPC":
						PathUtil.findNpcAndOpen( args[0].toString() );
						break;
					case "useSuperEquip":
						PlayerGuideModule.getInstance().useSuperEquip( args[0] );
						break;
					case "openVip":
						Dispatch.dispatch(ModuleCommand.VIP_PANEL);
						break;
				}
			}
			
		}
		
		private var lvUpMenu:TradingLvUpMenu;
		private function hideLvUpTip(e:MouseEvent):void
		{
			if(stage&& stage.hasEventListener(MouseEvent.CLICK))
				stage.removeEventListener(MouseEvent.CLICK,hideLvUpTip);
			if(lvUpMenu&&lvUpMenu.parent)
			{
//				WindowManager.getInstance().openDialogLayer.removeChild(lvUpMenu);
				ToolTipManager.getInstance().getContainer().removeChild(lvUpMenu);
				lvUpMenu.dispose();
				lvUpMenu = null;
				
			}
		}
		private function showToLvUp():void
		{
			if(lvUpMenu)
			{
				return;
			}
			
			lvUpMenu = new TradingLvUpMenu();
			lvUpMenu.x = 610;
			lvUpMenu.y = 338+mouseY ;
			
			ToolTipManager.getInstance().getContainer().addChild(lvUpMenu);
			setTimeout(addlisten,300);
			
		}
		private function addlisten():void
		{
			if(stage && !stage.hasEventListener(MouseEvent.CLICK))
				stage.addEventListener(MouseEvent.CLICK,hideLvUpTip);
		}
		
		private function openFamilyPanel():void
		{
			FriendsModule.getInstance().openFamilyView();
		}
		
		private function openActive():void
		{
			ActivityModule.getInstance().openActivityWin();
		}
		
		public static function getInstance():BroadcastSelf
		{
			if(!instance)
			{
				instance = new BroadcastSelf();
			}
			return instance;
		}
		
		public function appendMsg(str:String):void
		{
			if(str == ''){
				return;
			}
			if(items.length >5 ){
				items.splice(0,1);
			}
			var tempstr:String = "";
			tempstr = _delLastBr(str);
			items.push(tempstr);
			addHistoryMsg(tempstr);
			if(_checkBreakLine(tempstr)){
				text.htmlText = items.join("\n");
			}else{
				text.htmlText = items.join("");
			}
		}
		
		private function _delLastBr(str:String):String
		{
			var tm:String = str.substring(str.length -13,str.length);
			var tep:String;// = str.substr(0,str.length-13);
			if(str.length>13 && tm.toLocaleLowerCase()=="<br /></font>")
			{
				tep = str.substr(0,str.length-13) + "</font>";//str.substring(str.length-7,str.length);
			}else
			{
				tep = str;
			}
			return tep;
		}
		private function _checkBreakLine(_str:String):Boolean
		{
			var str:String = _str.toLowerCase();
			if(str.substr(-1,6) == '<br />'){
				return false;
			}else if(str.substr(-1,5) == '<br/>'){
				return false;
			}else if(str.substr(-1,4) == '<p/>'){
				return false;
			}else if(str.substr(-1,5) == '<p />'){
				return false;
			}
			
			return true;
		}
		
		public static function logger(msg:String):void{
			getInstance().appendMsg(msg);
		}
	}
}

