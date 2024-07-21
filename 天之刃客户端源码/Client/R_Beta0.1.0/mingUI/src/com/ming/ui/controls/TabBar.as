package com.ming.ui.controls {
	import com.ming.events.ItemEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.constants.TabDirection;
	import com.ming.ui.containers.Container;
	import com.ming.ui.containers.HBox;
	import com.ming.ui.layout.LayoutUtil;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.skins.TabBarSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.events.MouseEvent;

	public class TabBar extends Container {
		public var buttonList:Array;
		private var _selectIndex:int=-1;
		private var indexChanged:Boolean=false;
		private var childChanged:Boolean=false;
		private var skinChanged:Boolean=false;
		private var _tabBarSkin:TabBarSkin;
		private var _direction:String=TabDirection.HORIZONTAL;
		public var itemDoubleClickEnabled:Boolean;

		public function TabBar() {
			buttonList=[];
			bgAlpha=0;
			bgColor=0xffffff;
			selectIndex=0;
			var tabSkin:TabBarSkin=StyleManager.tabBarSkin;
			if (tabSkin) {
				_tabBarSkin=tabSkin;
			}
		}

		public function set tabBarSkin(skin:TabBarSkin):void {
			this._tabBarSkin=skin;
			skinChanged=true
			invalidateDisplayList();
		}

		public function addItem(label:String, w:Number, h:Number=NaN, index:Number = -1):void {
			var btn:ToggleButton=new ToggleButton();
			btn.label=label;
			if (!isNaN(w)) {
				btn.width=w;
			}
			if (!isNaN(h)) {
				btn.height=h;
			}
			if(index == -1){
				addChild(btn);
			}else{
				addChildAt(btn,index);
			}
			if (itemDoubleClickEnabled) {
				btn.doubleClickEnabled=true;
				btn.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			}
			btn.addEventListener(MouseEvent.CLICK, mouseClickHandler);
			if(index == -1){
				buttonList.push(btn);
			}else{
				buttonList.splice(index,0,btn);
			}
			childChanged=true;
			if(index != -1){
				layoutChildren();
			}
			invalidateDisplayList();
		}

		public function updateItem(index:int, label:String, w:Number, h:Number=NaN):void {
			var button:ToggleButton=buttonList[index];
			if (button) {
				button.label=label;
				if (!isNaN(w)) {
					button.width=w;
				}
				if (!isNaN(h)) {
					button.height=h;
				}
				layoutChildren();
			}
		}
			
		public function enabledTabButton(enabled:Boolean,index:int):void{
			var button:ToggleButton=buttonList[index];
			if (button) {
				button.enabled = enabled;	
			}
		}
		
		public function removeItems():void {
			for each (var button:ToggleButton in buttonList) {
				button.dispose();
			}
			buttonList=[];
			_selectIndex=-1;
		}

		public function removeItemByIndex(index:int):void {
			var button:ToggleButton=buttonList[index] as ToggleButton;
			button.dispose();
			buttonList.splice(index, 1);
			_selectIndex=-1;
			layoutChildren();
		}

		public function set selectIndex(value:int):void {
			if (_selectIndex != value) {
				this._selectIndex=value;
				indexChanged=true;
				invalidateDisplayList();
			}
		}

		public function get selectIndex():int {
			return this._selectIndex;
		}

		private var _hPadding:int=0; //水平间距
		private var _hPaddingChanged:Boolean=false;

		public function set hPadding(value:int):void {
			if (_hPadding != value) {
				this._hPadding=value;
				_hPaddingChanged=true;
				invalidateDisplayList();
			}
		}

		public function get hPadding():int {
			return this._hPadding
		}

		private var directionChanged:Boolean=false;

		public function set direction(value:String):void {
			if (_direction != value) {
				_direction=value;
				directionChanged=true;
				invalidateDisplayList();
			}
		}

		public function get direction():String {
			return _direction;
		}

		private function layoutChildren():void {
			if (direction == TabDirection.HORIZONTAL) {
				LayoutUtil.layoutHorizontal(this, hPadding);
			} else if (direction == TabDirection.VECTICAL) {
				LayoutUtil.layoutVectical(this, hPadding);
			}
		}

		private function mouseClickHandler(event:MouseEvent):void {
			selectIndex=buttonList.indexOf(event.currentTarget);
			if (_tabBarSkin && _tabBarSkin.soundFunc != null) {
				_tabBarSkin.soundFunc.apply(null, null);
			}
		}

		private function doubleClickHandler(event:MouseEvent):void {
			dispatchEvent(new ItemEvent(ItemEvent.ITEM_DOUBLE_CLICK, true));
		}

		private function dispatch():void {
			var evt:TabNavigationEvent=new TabNavigationEvent(TabNavigationEvent.SELECT_TAB_CHANGED);
			evt.index=_selectIndex;
			dispatchEvent(evt);
		}

		override protected function updateDisplayList(w:Number, h:Number):void {
			if ((childChanged || skinChanged) && _tabBarSkin) {
				skinChanged=childChanged=false;
				var size:int=buttonList.length;
				for (var n:int=0; n < size; n++) {
					var btn:ToggleButton=buttonList[n] as ToggleButton;
					if (n == 0) {
						_tabBarSkin.firstButtonSkin(btn);
					} else if (n == size - 1) {
						_tabBarSkin.lastButtonSkin(btn);
					} else {
						_tabBarSkin.tabButtonSkin(btn);
					}
					btn.validateNow();
				}
			}
			if (_contentChanaged || _hPaddingChanged || directionChanged) {
				directionChanged=_hPaddingChanged=false;
				_contentChanaged=true;
				layoutChildren();
			}
			super.updateDisplayList(w, h);
			if (indexChanged) {
				indexChanged=false;
				for (var i:int=0; i < buttonList.length; i++) {
					btn=buttonList[i] as ToggleButton;
					if (i == selectIndex) {
						btn.selected=true;
					} else {
						btn.selected=false;
					}
				}
				if(buttonList && buttonList.length > 0){
					dispatch();
				}
			}
		}

	}
}