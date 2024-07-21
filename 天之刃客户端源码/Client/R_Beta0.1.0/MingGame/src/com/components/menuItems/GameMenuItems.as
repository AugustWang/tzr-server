package com.components.menuItems
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class GameMenuItems extends UIComponent
	{
		private var targetRoleInfo:TargetRoleInfo;
		private var cacheItems:Dictionary;
		private var rendererItems:Vector.<Button>;
//		private var lines:Vector.<Skin>;
		private static var instance:GameMenuItems;
		public var menuItems:Array = [];
		public function GameMenuItems()
		{
			super();
			rendererItems = new Vector.<Button>();
//			lines = new Vector.<Skin>();
			cacheItems = new Dictionary();
			width = 116;
			Style.setMenuItemBg(this);
		}	
		
		public static function getInstance():GameMenuItems{
			if(instance == null){
				instance = new GameMenuItems();
			}
			return instance;
		}
		/**
		 *  传递数组是为更好的排列顺序
		 */		
		public function show(_menuItems:Array,targetRoleInfo:TargetRoleInfo):void{
			if(_menuItems == null)return;
			this.targetRoleInfo = targetRoleInfo;
			if(_menuItems.toString() != menuItems.toString()){
				this.menuItems = _menuItems;
				createItems(menuItems);
			}else{
				for each(var menuItem:Button in rendererItems){
					menuItem.enabled = MenuItemConstant.isEnabled(targetRoleInfo,uint(menuItem.data));
				}
			}
			var stage:Stage = LayerManager.stage;
			x = stage.mouseX;
			y = stage.mouseY;
			if(x + width > stage.stageWidth)
				x  = stage.stageWidth - width;
			else if(x < 0)
				x = 0;
			if(y + height > stage.stageHeight)
				y = stage.stageHeight - height;
			
			LayerManager.main.addChild(this);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		}
		
		private function onMouseDown(event:MouseEvent):void{
			var target:DisplayObject = event.target as DisplayObject;
			if(!contains(target)){
				close();
			}	
		}
		
		private function close():void{
			if(parent){
				stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
				parent.removeChild(this);
			}	
		}
		
		private function createItems(menuItems:Array):void{
			while(rendererItems.length > 0){
				removeChild(rendererItems.shift() as DisplayObject);
			}
//			while(lines.length > 0){
//				removeChild(lines.shift() as DisplayObject);
//			}

			var startY:int = 5;
			var cloneItems:Array = menuItems.concat();
			for(var i:int;i < cloneItems.length ; i++){
				var flag:uint = cloneItems[i];
				var label:String = MenuItemConstant.getLabelName(flag);
				if(label == ""){
					cloneItems.splice(i,1);
					i--;
					continue;
				}
				var item:Button = cacheItems[flag];
				if(item == null){
					item = new Button();
					Style.setMenuItemSkin(item);
					item.label = label;
					item.width = 100;
					item.height = 28;
					item.addEventListener(MouseEvent.CLICK,onItemClick);
					item.x = 8;
					item.data = flag;
					cacheItems[flag] = item;
				}
				item.y = startY;
				startY = item.height + item.y;
				item.enabled = MenuItemConstant.isEnabled(targetRoleInfo,flag);
				addChild(item);
//				if(i != cloneItems.length - 1){
//					var sp:Skin = cacheItems["line"+i];
//					if(sp == null){
//						sp = Style.getSkin("sparete",GameConfig.T1_UI);
//						cacheItems["line"+i] = sp;
//						sp.setSize(90,2);
//						sp.x = 10;
//					}
//					sp.y = startY - 2;
//					addChild(sp);
//					lines.push(sp);
//				}
				rendererItems.push(item);
			}
			height = startY + 5;
			validateNow();
		}
		
		private function onItemClick(event:MouseEvent):void{
			var item:Button = event.currentTarget as Button;
			if(item){
				MenuItemConstant.itemHandler(uint(item.data),targetRoleInfo);
				close();
			}
		}
	}
}