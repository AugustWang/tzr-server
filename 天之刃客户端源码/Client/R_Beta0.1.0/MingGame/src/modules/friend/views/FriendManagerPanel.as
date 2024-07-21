package modules.friend.views
{
	
	import com.components.BasePanel;
	import com.components.alert.Alert;
	import com.globals.GameParameters;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.ToggleButton;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import modules.family.FamilyModule;
	import modules.friend.FriendsModule;
	import modules.friend.views.friends.FriendView;
	import modules.friend.views.friendsetting.FriendSetting;
	
	public class FriendManagerPanel  extends BasePanel
	{
		private var leftContainer:UIComponent;
		private var rightContainer:Sprite;
		private var currentView:Sprite;
		private var viewsPool:Dictionary;
		private var tabNames:Vector.<String>;
		private var tabs:Vector.<ToggleButton>;
		private var copyAddress:Button;
		public function FriendManagerPanel(){
			super();	
		}
		
		override protected function init():void 
		{
			this.width = 600;
			this.height = 395;
			addTitleBG(446);
			addImageTitle("title_friend");
			tabNames = new Vector.<String>();
			tabNames.push("好友","个人设置");
			leftContainer = ComponentUtil.createUIComponent(8,5,120,343);
			Style.setBorderSkin(leftContainer);
			var toggleButton:ToggleButton;
			tabs = new Vector.<ToggleButton>;
			for(var i:int=0;i<2;i++){
				var yNumber:Number = (26+1)*i+5;
				toggleButton = ComponentUtil.createToggleButton(tabNames[i],3,yNumber,100,26,leftContainer);
				toggleButton.x = 10;
				toggleButton.addEventListener(MouseEvent.CLICK,onChangeView);
				toggleButton.name = i.toString();
				tabs.push(toggleButton);
			}
			addChild(leftContainer);
			
			rightContainer = new Sprite();
			rightContainer.x = leftContainer.width + 9;
			rightContainer.y = 5;
			
			tabs[0].selected = true;
			var _friendView:FriendView = FriendsModule.getInstance().getFriendView();
			rightContainer.addChild(_friendView);
			currentView = _friendView;
			addChild(rightContainer);
			
			viewsPool = new Dictionary;
			viewsPool[0] = _friendView;
			
			copyAddress = ComponentUtil.createButton("邀请好友",505,5,75,26,this);
			copyAddress.textColor = 0xffff00;
			copyAddress.setToolTip("邀请好友，一起成就天之刃英雄传奇，点击复制链接",100);
			copyAddress.addEventListener(MouseEvent.CLICK,onCopyAddress);
		}
		
		private function onChangeView(event:MouseEvent):void
		{
			var toggleButton:ToggleButton = event.currentTarget as ToggleButton;
			changeView(toggleButton);
		}
		
		private function changeView(toggleButton:ToggleButton):void{
			if(toggleButton){
				for each(var t:ToggleButton in tabs){
					t.selected = false;
				}
				toggleButton.selected = true;
				var index:int = int(toggleButton.name);
				var view:Sprite = viewsPool[index];
				if(view == null){
					if(index == 1){
						view = new FriendSetting();
					}
					viewsPool[index] = view;
				}
				if(view != currentView && view){
					if(currentView){
						rightContainer.removeChild(currentView);
					}
					rightContainer.addChild(view);
					currentView = view;
					if(index == 1){
						FriendSetting(view).init();
					}
				}
			}
		}
		
		public function changeFamilyView():void{
			var view:Sprite = viewsPool[1];
			var newview:Sprite = FamilyModule.getInstance().getFamilyView();
			viewsPool[1] = newview;
			if(view && rightContainer.contains(view)){
				rightContainer.removeChild(view);
				currentView = newview;
				rightContainer.addChild(newview);
			}	
		}
		
		public function set selectedIndex(value:int):void{
			changeView(tabs[value]);
		}
		
		private function onCopyAddress(event:MouseEvent):void{
			var proxyName:String = GameParameters.getInstance().proxyName;
			var copyValue:String = "推荐一款我喜欢的游戏给你吧："+proxyName+"《天之刃》，希望你和我一起玩，"+GameParameters.getInstance().shareURL;
			System.setClipboard(copyValue);
			Alert.show("游戏名称和地址已复制，可以粘贴到QQ，MSN，BLOG推荐给好友了。","邀请好友",null,null,"确定","",null,false);
		}
	}
}