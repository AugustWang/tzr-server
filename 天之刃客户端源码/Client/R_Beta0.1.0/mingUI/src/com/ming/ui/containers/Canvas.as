package com.ming.ui.containers
{
	import com.ming.events.ResizeEvent;
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.ScrollBar;
	import com.ming.ui.skins.ScrollBarSkin;
	
	import flash.events.MouseEvent;

	/**
	 * 支持滚动条的容器组件
	 */ 
	public class Canvas extends Container
	{		
		private var _hScrollPolicyChanged:Boolean = false;
		private var _vScrollPolicyChanged:Boolean = false;
		
		public var vScrollBar:ScrollBar;
		public var hScrollBar:ScrollBar;
		
		private var _hScrollPolicy:String = ScrollPolicy.AUTO; //不支持ON状态
		private var _vScrollPolicy:String = ScrollPolicy.AUTO; //不支持ON状态
		
		private var _vScrollPosition:Number;
		private var _hScrollPosition:Number;
		
		private var vScrollPositionChanged:Boolean = false;
		private var hScrollPositionChanged:Boolean = false;
		private var childChanged:Boolean = false;
		public var mouseWheelSpeed:int = 10; //鼠标滑动速度
		private var _scrollBarSkin:ScrollBarSkin;
		
		public function Canvas()
		{
			
		}
		
		public function set scrollBarSkin(skin:ScrollBarSkin):void{
			if(skin){
				_scrollBarSkin = skin;
			}	
		}
		
		public function set vScrollPosition(value:Number) : void
		{
			_vScrollPosition = value;
			if(vScrollBar){
				vScrollBar.scrollPosition = _vScrollPosition;
			}else{
				vScrollPositionChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get vScrollPosition() : Number
		{
			return vScrollBar ? vScrollBar.scrollPosition : 0;
		}

		public function set hScrollPosition(value:Number) : void
		{
			_hScrollPosition = value;
			if(hScrollBar){
				hScrollBar.scrollPosition = _hScrollPosition;
			}else{
				hScrollPositionChanged = true;
				invalidateDisplayList();
			}
		}
		
		public function get hScrollPosition() : Number
		{
			return hScrollBar ? hScrollBar.scrollPosition : 0;
		}                                                                                    
		
		public function createScrollBar(direction:String):ScrollBar{
			var scrollBar:ScrollBar = new ScrollBar();
			if(_scrollBarSkin){
				scrollBar.scrollBarSkin = _scrollBarSkin;
			}
			scrollBar.direction = direction;
			if(direction == ScrollDirection.VERTICAL){
				scrollBar.addEventListener(ScrollEvent.SCROLL,verticalScroll);
				addEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
			}else{
				scrollBar.addEventListener(ScrollEvent.SCROLL,horizontalScroll);
			}
			addChildToSuper(scrollBar);
			return scrollBar;
		}
		
		protected function mouseWheelHandler(event:MouseEvent):void{
			vScrollBar.scrollPosition += -mouseWheelSpeed*event.delta;
		}
		
		private function removeVScrollBar():void{
			if(vScrollBar && vScrollBar.parent){
				contentPane.y = 0;
				vScrollBar.removeEventListener(ScrollEvent.SCROLL, verticalScroll);
				removeEventListener(MouseEvent.MOUSE_WHEEL,mouseWheelHandler);
				removeSuperChild(vScrollBar);
				vScrollBar = null;
			}
		}
		
		private function removeHScrollBar():void{
			if(hScrollBar && hScrollBar.parent){
				contentPane.x = 0;
				hScrollBar.removeEventListener(ScrollEvent.SCROLL, horizontalScroll);
				removeSuperChild(hScrollBar);
				hScrollBar = null;
			}
		}		
				
		protected function horizontalScroll(event:ScrollEvent) : void
		{
			contentPane.x = -event.position;
		}
		protected function verticalScroll(event:ScrollEvent) : void
		{
			contentPane.y = -event.position;
		}
		
		public function set horizontalScrollPolicy(type:String) : void
		{
			_hScrollPolicy = type;
			_hScrollPolicyChanged = true;
			invalidateDisplayList();
		}				
		public function get horizontalScrollPolicy() : String
		{
			return _hScrollPolicy;
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
				
		protected function resizeScrollBar() : void
		{
			var contentSize:Array = getContentSize();
			var contentWidth:Number = contentSize[0];
			var contentHeight:Number = contentSize[1];
			if(verticalScrollPolicy == ScrollPolicy.ON){
				if (vScrollBar == null)
				{
					vScrollBar = createScrollBar(ScrollDirection.VERTICAL);
					vScrollBar.y = 0;
					vScrollBar.x = this.width - vScrollBar.width;
				}
			}
			if (verticalScrollPolicy == ScrollPolicy.OFF)
			{
				removeVScrollBar();
			}
			else if (verticalScrollPolicy == ScrollPolicy.AUTO && this.height >= contentHeight)
			{
				removeVScrollBar();
			}
			else if(verticalScrollPolicy != ScrollPolicy.OFF && this.height < contentHeight)
			{
				if (vScrollBar == null)
				{
					vScrollBar = createScrollBar(ScrollDirection.VERTICAL);
					vScrollBar.y = 0;
				}
				vScrollBar.x = this.width - vScrollBar.width;
				vScrollBar.pageSize = height;
				vScrollBar.maxScrollPosition = contentHeight - height;
				if(vScrollPositionChanged){
					vScrollPositionChanged = false;
					vScrollPosition = _vScrollPosition;
				}		
			}else if(verticalScrollPolicy == ScrollPolicy.ON && this.height >= contentHeight){
				if(vScrollBar){
					vScrollBar.maxScrollPosition = 0;
					vScrollBar.scrollPosition = 0;
				}
			}
			if(horizontalScrollPolicy == ScrollPolicy.ON){
				if (hScrollBar == null)
				{
					hScrollBar = createScrollBar(ScrollDirection.HORIZONTAL);
					hScrollBar.x = 0;
					hScrollBar.y = this.height;
				}
			}
			if (horizontalScrollPolicy == ScrollPolicy.OFF)
			{
				removeHScrollBar();
			}
			else if (horizontalScrollPolicy == ScrollPolicy.AUTO && this.width >= contentWidth)
			{
				removeHScrollBar();
			}
			else if (horizontalScrollPolicy != ScrollPolicy.OFF && this.width < contentWidth)
			{
				if (hScrollBar == null)
				{
					hScrollBar = createScrollBar(ScrollDirection.HORIZONTAL);
					hScrollBar.x = 0;
				}
				hScrollBar.y = this.height;
				hScrollBar.pageSize = width;
				hScrollBar.maxScrollPosition = contentWidth - width;
				if(hScrollPositionChanged){
					hScrollPositionChanged = false;
					hScrollPosition = _hScrollPosition;
				}				
			}else if(horizontalScrollPolicy == ScrollPolicy.ON && this.width >= contentWidth){
				if(hScrollBar){
					hScrollBar.maxScrollPosition = 0;
					hScrollBar.scrollPosition = 0;
				}
			}
			
			if (hScrollBar != null && vScrollBar != null)
			{
				vScrollBar.height = this.height - hScrollBar.width;
				hScrollBar.height = this.width;
				vScrollBar.maxScrollPosition = vScrollBar.maxScrollPosition + hScrollBar.width;
				vScrollBar.validateNow();
				hScrollBar.maxScrollPosition = hScrollBar.maxScrollPosition + vScrollBar.width;
				hScrollBar.validateNow();
			}
			else if (hScrollBar != null && vScrollBar == null)
			{
				hScrollBar.height = this.width;
				hScrollBar.validateNow();
			}
			else if(hScrollBar == null && vScrollBar != null)
			{
				vScrollBar.height = this.height;
				vScrollBar.validateNow();
			}
		}
		
		protected override function onReisze(event:ResizeEvent):void{
			super.onReisze(event);
			resizeScrollBar();
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void
		{
			childChanged = _contentChanaged;
			super.updateDisplayList(w, h);
			if (_vScrollPolicyChanged  || _hScrollPolicyChanged || childChanged)
			{	
				if(childChanged){
					contentChanged();
				}
				_vScrollPolicyChanged = false;
				_hScrollPolicyChanged = false;
				childChanged = false;
			}			
		}
		
		protected function contentChanged():void{
			resizeScrollBar();
		}
	}
}