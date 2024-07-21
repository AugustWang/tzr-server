package modules.chat.views
{
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import modules.chat.ChatModule;
	import modules.system.SystemConfig;
	
	public class ShieldChatChannel extends UIComponent
	{
		private var worldChannel:ShieldCheckBox;
		private var countryChannel:ShieldCheckBox;
		private var familyChannel:ShieldCheckBox;
		private var teamChannel:ShieldCheckBox;
		private var privateChannel:ShieldCheckBox;
		
		public static var clickThis:Boolean;
		
		public function ShieldChatChannel()
		{
			super();
			this.width = 54;
			this.height = 100;
			this.bgColor = 0x000000;
			this.bgAlpha = 0.8;
			initView();
			addEventListener(Event.ADDED_TO_STAGE,onaddtostage);
			
		}
		
		private function onaddtostage(e:Event):void
		{
			setTimeout(addlistener,200);
			if(worldChannel)
				initCheck();
			
		}
		private function addlistener():void
		{
			if(stage)
				stage.addEventListener(MouseEvent.CLICK, onUp);
		}
		
		private function initView():void
		{
			worldChannel = getShieldCheckBox("世界");
			countryChannel = getShieldCheckBox("国家");
			familyChannel = getShieldCheckBox("门派");
			teamChannel= getShieldCheckBox("队伍");
			privateChannel= getShieldCheckBox("私聊");
			
			addChild(worldChannel);
			addChild(countryChannel);
			addChild(familyChannel);
			addChild(teamChannel);
			addChild(privateChannel);
			
			display();
			
			worldChannel.addEventListener(Event.CHANGE, worldCheck);
			countryChannel.addEventListener(Event.CHANGE, countryCheck);
			familyChannel.addEventListener(Event.CHANGE, familyCheck);
			teamChannel.addEventListener(Event.CHANGE, teamCheck);
			privateChannel.addEventListener(Event.CHANGE, privateCheck);
			
//			initCheck();
		}
		
		public function initCheck():void
		{
			worldChannel.setSelected(!SystemConfig.worldChat);
			countryChannel.setSelected(!SystemConfig.nationChat);
			familyChannel.setSelected(!SystemConfig.familyChat);
			teamChannel.setSelected(!SystemConfig.teamChat);
			privateChannel.setSelected(!SystemConfig.privateChat);
		}
		
		private function worldCheck(e:Event):void
		{
			SystemConfig.worldChat = !worldChannel.selected;
			if(worldChannel.selected)
			{
				ChatModule.getInstance().sendChatMsg("综合频道已屏蔽。",null,null);
			}else{
				ChatModule.getInstance().sendChatMsg("综合频道已开启。",null,null);
			}
			
			SystemConfig.save();
		}
		private function countryCheck(e:Event):void
		{
			SystemConfig.nationChat = !countryChannel.selected;
			if(countryChannel.selected)
			{
				ChatModule.getInstance().sendChatMsg("国家频道已屏蔽。",null,null);
			}else{
				ChatModule.getInstance().sendChatMsg("国家频道已开启。",null,null);
			}
			
			SystemConfig.save();
		}
		private function familyCheck(e:Event):void
		{
			SystemConfig.familyChat = !familyChannel.selected;
			if(familyChannel.selected)
			{
				ChatModule.getInstance().sendChatMsg("门派频道已屏蔽。",null,null);
			}else{
				ChatModule.getInstance().sendChatMsg("门派频道已开启。",null,null);
			}
			
			SystemConfig.save();
		}
		private function teamCheck(e:Event):void
		{
			SystemConfig.teamChat = !teamChannel.selected;
			if(teamChannel.selected)
			{
				ChatModule.getInstance().sendChatMsg("组队频道已屏蔽。",null,null);
			}else{
				ChatModule.getInstance().sendChatMsg("组队频道已开启。",null,null);
			}
			
			SystemConfig.save();
		}
		private function privateCheck(e:Event):void
		{
			SystemConfig.privateChat = !privateChannel.selected;
			if(privateChannel.selected)
			{
				ChatModule.getInstance().sendChatMsg("私聊频道已屏蔽。",null,null);
			}else{
				ChatModule.getInstance().sendChatMsg("私聊频道已开启。",null,null);
			}
			
			SystemConfig.save();
		}
		
		private function getShieldCheckBox(text:String,selected:Boolean=false):ShieldCheckBox
		{
			var shielCheck:ShieldCheckBox = new ShieldCheckBox();
//			shielCheck.width = 52;
			shielCheck.height = 19;
			shielCheck.text = text;
			
			return shielCheck;
		}
		
		private function display():void
		{
			var i:int =0;
			var num:int = numChildren;
			for(i=0;i<num;i++)
			{
				var disObj:DisplayObject = this.getChildAt(i) as DisplayObject;
				disObj.y = i * 19;
			}
		}
		
		private function onUp(evt:MouseEvent):void
		{
			
			var distar:DisplayObject = evt.target as DisplayObject;
			
			if(clickThis == true)
			{
				clickThis =false;
				return;
			}
//			if(distar)
//			{
//				var par:ShieldCheckBox = distar.parent as ShieldCheckBox;
//				if(par)
//				{
//					trace();
//					return;
//				}
//			}
			clickThis = false;
			if(stage&&stage.hasEventListener(MouseEvent.CLICK))
			{
				stage.removeEventListener(MouseEvent.CLICK, onUp);
			}
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
			
		}
	}
}