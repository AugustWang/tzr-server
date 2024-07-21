package com.components.menuItems
{
	import com.ming.ui.controls.Button;
	
	public class MenuBarItem extends Button
	{
		public var labelField:String;
		public var iconField:String;
		private var menuItemData:MenuItemData;
		public function MenuBarItem()
		{
			super();
			Style.setMenuItemSkin(this);
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(labelField){
				initProperty("label",data[labelField]);
			}else{
				initProperty("label",data);
			}
			if(iconField){
				if(data[iconField]){
					initProperty("icon",data[iconField]);
				}
			}
			if(data.hasOwnProperty("enabled")){
				initProperty("enabled",data["enabled"]);
			}
			if(data.hasOwnProperty("toolTip")){
				setToolTip(data["toolTip"]);
			}
			if(menuItemData){
				menuItemData.removeEventListener(MenuItemEvent.VALUE_CHANGED,onValueChanged);
			}
			menuItemData = value as MenuItemData;
			if(menuItemData){
				menuItemData.addEventListener(MenuItemEvent.VALUE_CHANGED,onValueChanged);
			}
		}
		
		private function onValueChanged(event:MenuItemEvent):void{
			if(event.propertyName == labelField){
				label = event.value;
			}else if(event.propertyName == iconField){
				icon = event.value;
			}else if(event.propertyName == "toolTip"){
				setToolTip(data["toolTip"]);
			}else if(hasOwnProperty(event.propertyName)){
				this[event.propertyName] = event.value;
			}
		}
		
		private function initProperty(propertyName:String,value:*):void{
			this[propertyName] = value;
		}
		
		override public function dispose():void{
			super.dispose();
			if(menuItemData){
				menuItemData.removeEventListener(MenuItemEvent.VALUE_CHANGED,onValueChanged);
			}
		}
	}
}