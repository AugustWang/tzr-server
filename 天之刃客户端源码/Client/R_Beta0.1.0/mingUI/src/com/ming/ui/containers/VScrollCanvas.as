package com.ming.ui.containers
{
	import com.ming.events.ResizeEvent;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.ScrollBar;
	import com.ming.ui.skins.ScrollBarSkin;
	import com.ming.ui.style.StyleManager;
	
	import flash.events.MouseEvent;

	/**
	 * 支持滚动条的容器组件
	 */ 
	public class VScrollCanvas extends Container
	{		
		public var vscrollBar:ScrollBar;
		
		private var _direction:String = ScrollDirection.LEFT;
		private var _vScrollPolicy:String = ScrollPolicy.ON; //不支持ON状态
		
		private var directionChanged:Boolean = true;
		private var _vScrollPolicyChanged:Boolean = false;
		private var childChanged:Boolean = false;
		public var mouseWheelSpeed:int = 10; //鼠标滑动速度
		private var _scrollBarSkin:ScrollBarSkin;
		private var scrollBarSkinChanged:Boolean = false;
		private var _scrollBarHeight:Number = NaN;
		private var _scrollBarChanged:Boolean = false;
		private var _pageScrollSize:int = 25;
		
		public function VScrollCanvas()
		{
			verticalScrollPolicy = ScrollPolicy.ON;
			var scrollSkin:ScrollBarSkin = StyleManager.textScrollSkin;
			if(scrollSkin){
				this.scrollBarSkin = scrollSkin;
			}
		}
		
		public function set scrollBarHeight(value:Number):void{
			if(value != _scrollBarHeight){
				_scrollBarHeight = value;
				_scrollBarChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get scrollBarHeight():Number{
			return _scrollBarHeight;
		}
		
		public function set scrollBarSkin(skin:ScrollBarSkin):void{
			if(skin){
				scrollBarSkinChanged = true;
				_scrollBarSkin = skin;
				invalidateDisplayList();
			}	
		}
		
		public function set direction(value:String):void{
			if(value != _direction){
				_direction = value;
				directionChanged = true;
				invalidateDisplayList();
			}
		}
		public function get direction():String{
			return _direction;
		}	
			
		public function set vScrollPosition(value:Number) : void
		{
			if(vscrollBar){
				vscrollBar.scrollPosition = value;
			}
		}
		
		public function get vScrollPosition() : Number
		{
			return  vscrollBar ? vscrollBar.scrollPosition : 0;
		}                                                                      
		
		public function set pageScrollSize(value:int):void{
			_pageScrollSize = value;
		}
		
		public function set verticalScrollPolicy(type:String) : void
		{
			_vScrollPolicy = type;
			_vScrollPolicyChanged = true;
			invalidateDisplayList();			
		}
		
		public function get verticalScrollPolicy() : String
		{
			return _vScrollPolicy;
		}
		
		protected function mouseWheelHandler(event:MouseEvent):void{
			vscrollBar.scrollPosition += -mouseWheelSpeed*event.delta;
		}
	
		protected function verticalScroll(event:ScrollEvent):void{
			contentPane.y = -event.position;
		}
				
		protected function updateScrollBar() : void
		{
			if(verticalScrollPolicy == ScrollPolicy.OFF){
				removeScrollBar();
				return;
			}
			var contentSize:Array = getContentSize();
			var contentHeight:Number = contentSize[1];
			if(verticalScrollPolicy == ScrollPolicy.ON){
				createScrollBar();
			}
			if(height < contentHeight && verticalScrollPolicy != ScrollPolicy.OFF)
			{
				if(vscrollBar == null){
					createScrollBar();
				}
				vscrollBar.pageSize = height;
				vscrollBar.maxScrollPosition = contentHeight - height;			
			}else if(height >= contentHeight && verticalScrollPolicy == ScrollPolicy.ON){
				vscrollBar.pageSize = 0;
				vscrollBar.maxScrollPosition = 0;
			}else if(height >= contentHeight && verticalScrollPolicy == ScrollPolicy.AUTO){
				removeScrollBar();
			}
			if(vscrollBar){
				if(isNaN(_scrollBarHeight)){
					vscrollBar.height = height;
				}else{
					vscrollBar.height = _scrollBarHeight;
				}
				vscrollBar.validateNow();
			}
		}
		
		private function createScrollBar():void{
			if(vscrollBar == null){
				vscrollBar = new ScrollBar();
				vscrollBar.pageScrollSize = _pageScrollSize;
				if(_scrollBarSkin){
					vscrollBar.scrollBarSkin = _scrollBarSkin
				}
				vscrollBar.direction = ScrollDirection.VERTICAL;
				vscrollBar.addEventListener(ScrollEvent.SCROLL,verticalScroll);
				addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
				addChildToSuper(vscrollBar);
				updatePosition();
			}
		}
		
		private function removeScrollBar():void{
			if(vscrollBar && vscrollBar.parent){
				vscrollBar.removeEventListener(ScrollEvent.SCROLL,verticalScroll);
				removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
				removeSuperChild(vscrollBar);		
				vscrollBar = null;
			}
			contentPane.y = 0;
		}
		
		protected override function onReisze(event:ResizeEvent):void{
			super.onReisze(event);
			updateScrollBar();
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void
		{
			childChanged = _contentChanaged;
			super.updateDisplayList(w, h);
			if(childChanged){
				childChanged = false;
				updateScrollBar();
			}
			if(directionChanged){
				directionChanged = false;
				updatePosition();
			}
			if(_scrollBarChanged){
				_scrollBarChanged = false;
				if(vscrollBar){
					vscrollBar.height = scrollBarHeight;
				}
			}
			if(scrollBarSkinChanged){
				scrollBarSkinChanged = false;
				if(vscrollBar){
					vscrollBar.scrollBarSkin = _scrollBarSkin;
				}
			}
		}
		
		protected function updatePosition():void{
			if(vscrollBar){
				if(direction == ScrollDirection.LEFT){
					vscrollBar.x = 0;
					contentPane.x = vscrollBar.width;
				}else{
					vscrollBar.x = width - vscrollBar.width;
					contentPane.x = 0;
				}
			}
		}
	}
}