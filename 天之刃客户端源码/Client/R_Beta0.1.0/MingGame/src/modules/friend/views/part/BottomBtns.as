package modules.friend.views.part
{
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import modules.broadcast.views.Tips;
	import modules.friend.FriendsModule;
	
	public class BottomBtns extends Sprite
	{
		private var addBtn:Button;
		private var settingBtn:Button;
		private var friendOneKey:Button;
		//弹出的好友友设置界面
		private var addPanel:AddFriendPanel;
		private var isPopup:Boolean;
		
		private var _searchFunc:Function;
		
		public function BottomBtns()
		{
			super();
			init();
		}
		
		private function init():void
		{
			addBtn = ComponentUtil.createButton("添加",0,0,70,25,this);
			settingBtn = ComponentUtil.createButton("设置",0,0,70,25,this);
			//friendOneKey = ComponentUtil.createButton("一键征友",0,0,75,25,this);
		
			addBtn.addEventListener(MouseEvent.CLICK,popup);
			settingBtn.addEventListener(MouseEvent.CLICK,onSettingHandler);
			//friendOneKey.addEventListener(MouseEvent.CLICK,onFriendOneKey);
			LayoutUtil.layoutHorizontal(this,15);
		}
		public function show():void
		{

		}
		
		private function onFriendOneKey(evt:MouseEvent):void
		{
			FriendsModule.getInstance().doFriendAdvertise();
		}
		
		private function onSettingHandler(evt:MouseEvent):void{
			FriendsModule.getInstance().openFriendManagerPanel();
		}
		
		private function popup(evt:Event):void
		{
//代码重构
//			if(this.addBtn)TaskModule.getInstance().colseFlash(this.addBtn);
			if(addBtn.label == "添加")
			{
				AddFriendPanel.getInstance().show();
			}else{
				Tips.getInstance().addTipsMsg("此功能暂未开放！");
			}
			
		}
				
		private function addHandler(rolename:String):void
		{
			WindowManager.getInstance().removeWindow(addPanel);
			isPopup = false;
		}
		
		public function changeBtns(isfriendList:Boolean):void
		{
			if(isfriendList)
			{
				addBtn.label = "添加好友";
			}else{	
				addBtn.label = "创建群";
			}
		}
		
	}
}