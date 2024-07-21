package com.ming.ui.controls {
	import com.ming.events.ResizeEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.TabDirection;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.TabBarSkin;
	import com.ming.ui.skins.TabNavigationSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.DisplayObject;

	public class TabNavigation extends UIComponent {
		private var init:Boolean=false;
		public var tabBar:TabBar;
		public var tabContainer:TabContainer;
		private var _selectedIndex:int=0;
		private var updateLayout:Boolean=false;
		private var _direction:String=TabDirection.TOP;

		public function TabNavigation() {
			bgAlpha=0;
			tabBar=new TabBar();
			tabBar.selectIndex=0;
			tabContainer=new TabContainer();
			tabBavigationSkin = StyleManager.tabNavigationSkin;
			tabBar.addEventListener(ResizeEvent.RESIZE, onResize);
			tabBar.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, selectTabChangedHandler);
			addEventListener(ResizeEvent.RESIZE, onResizeHandler);
		}

		public function set isTween(value:Boolean):void {
			if (tabContainer) {
				tabContainer.isTween=value;
			}
		}
		
		public function set tabBavigationSkin(skin:TabNavigationSkin):void{
			tabBarSkin = skin.tabBar;
			tabContainerSkin = skin.tabContainer;
		}
		
		public function removeTabContainerSkin():void{
			tabBarSkin = StyleManager.tabNavigationSkin.tabBar;
			tabContainerSkin = null;
		}
		
		private var _tabBarPaddingLeft:int = 10;
		public function set tabBarPaddingLeft(value:int):void {
			_tabBarPaddingLeft = value;
			if(direction == TabDirection.LEFT || direction == TabDirection.RIGHT){
				tabBar.y=_tabBarPaddingLeft;
			}else{
				tabBar.x=_tabBarPaddingLeft;
			}
		}

		public function set itemDoubleClickEnabled(value:Boolean):void {
			tabBar.itemDoubleClickEnabled=value;
		}

		public function set contentVisible(value:Boolean):void {
			if (tabContainer) {
				tabContainer.visible=value;
			}
		}

		public function get contentVisible():Boolean {
			return tabContainer ? tabContainer.visible : false;
		}

		public function removeTabContainer():void {
			if (tabContainer) {
				removeChild(tabContainer);
			}
		}

		public function addTabContainer():void {
			if (tabContainer) {
				addChildAt(tabContainer, 0);
			}
		}

		public function set tabBarSkin(skin:TabBarSkin):void {
			tabBar.tabBarSkin=skin;
		}

		public function set tabContainerSkin(skin:Skin):void {
			tabContainer.bgSkin=skin;
		}

		public function set direction(value:String):void {
			if (value != _direction) {
				_direction=value;
				updateLayout=true;
				invalidateDisplayList();
			}
		}

		public function get direction():String {
			return _direction;
		}

		override public function set mouseEnabled(enabled:Boolean):void {
			tabContainer.mouseEnabled=enabled;
			super.mouseEnabled=enabled;
		}

		private function selectTabChangedHandler(event:TabNavigationEvent):void {
			_selectedIndex=event.index;
			tabContainer.selectIndex=event.index;
			tabContainer.validateNow();
			dispatchEvent(event.clone());
		}

		private function show():void {
			if (!init) {
				init=true;
				addChild(tabContainer);
				addChild(tabBar);
			}
		}

		private function onResize(evt:ResizeEvent):void {
			updateLayout=true;
			invalidateDisplayList();
		}

		public function addItem(label:String, tab:DisplayObject, w:Number=NaN, h:Number=NaN, index:Number=-1):void {
			tabBar.addItem(label, w, h,index);
			tabContainer.addItem(tab,index);
			if(index == -1){
				selectedIndex=0;
			}
			show();
		}

		private function autoLayout():void {
			if (direction == TabDirection.BOTTOM) {
				tabContainer.width=this.width;
				tabContainer.height=this.height - tabBar.height;
				tabContainer.y=0;
				tabBar.y=tabContainer.height;
			} else if (direction == TabDirection.TOP) {
				tabContainer.width=this.width;
				tabContainer.height=this.height - tabBar.height;
				tabBar.y=0;
				tabBar.x=_tabBarPaddingLeft;
				tabContainer.y=tabBar.height-2;
			} else if (direction == TabDirection.LEFT) {
				tabBar.direction=TabDirection.VECTICAL;
				tabBar.validateNow();
				tabBar.x=0;
				tabBar.y=_tabBarPaddingLeft;
				tabContainer.x=tabBar.width+tabBar.x;
				tabContainer.width=this.width - tabBar.width;
				tabContainer.height=this.height;
			} else if (direction == TabDirection.RIGHT) {
				tabBar.direction=TabDirection.VECTICAL;
				tabBar.x=tabContainer.width;
				tabContainer.width=this.width - tabBar.width;
				tabContainer.height=this.height;
			}
		}

		public function set selectedIndex(index:int):void {
			_selectedIndex=index;
			tabBar.selectIndex=index;
		}

		public function get selectedIndex():int {
			return _selectedIndex;
		}

		override public function dispose():void {
			super.dispose();
			if (tabBar) {
				tabBar.dispose();
			}
			if (tabContainer) {
				tabContainer.dispose();
			}
		}

		private function onResizeHandler(event:ResizeEvent):void {
			autoLayout();
		}

		override protected function updateDisplayList(w:Number, h:Number):void {
			super.updateDisplayList(w, h);
			if (updateLayout) {
				updateLayout=false;
				autoLayout();
			}
		}
	}
}