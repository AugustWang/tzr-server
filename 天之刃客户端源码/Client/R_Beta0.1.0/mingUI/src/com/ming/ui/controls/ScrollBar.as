package com.ming.ui.controls
{
	import com.ming.events.ScrollEvent;
	import com.ming.ui.constants.ScrollDirection;
	import com.ming.ui.containers.Container;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ScrollBarSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.utils.*;
	
	public class ScrollBar extends UIComponent
	{		
		private var _trackBarTimer:Timer;
		private var _buttonTimer:Timer;
		
		private var skinChange:Boolean = false;
		private var _heightChange:Boolean = false;
		private var _buttonHeightChange:Boolean = false;
		private var _pageSizeChange:Boolean = false;
		private var _widthChange:Boolean = false;	
		private var _maxScrollPositionChange:Boolean = false;
		public var minThumbBarHeight:int = 20;
		public var minButtonHeight:int = 20;
		public var pageScrollSize:int = 30;
		public var traceBarWidth:int = 17;
		public var thumbBarWidth:int = 17;
		public function ScrollBar()
		{
			init();
		}
		
		private function init() : void{
			_buttonTimer = new Timer(250);
			this.bgAlpha = 0;
			this.width = 17;
			createTrackBar();
			createUpButton();
			createDownButton();
			createThumbBar();
			var scrollSkin:ScrollBarSkin = StyleManager.scrollBarSkin;
			if(scrollSkin){
				_scrollBarSkin = scrollSkin;
			}
			updateSkin();
		}
		
		private var _trackBar:UIComponent;
		private function createTrackBar() : void{
			_trackBar = new UIComponent();
			_trackBar.addEventListener(MouseEvent.CLICK, trackBarClickHandler);
			_trackBar.addEventListener(MouseEvent.MOUSE_DOWN, trackBarMouseDown);
			_trackBar.width = traceBarWidth;
			_trackBar.height = this.height;
			_trackBar.x = 0;
			_trackBar.y = 0;
			addChild(_trackBar);
		}
		
		private var _upButton:UIComponent;
		private function createUpButton() : void{
			_upButton = new UIComponent();
			_upButton.addEventListener(MouseEvent.CLICK, upButtonClick);
			_upButton.addEventListener(MouseEvent.MOUSE_DOWN, upButtonMouseDown);
			_upButton.width = this.width;
			_upButton.height = buttonHeight;
			_upButton.x = 0;
			_upButton.y = 0;
			addChild(_upButton);
		}
		
		private var _downButton:UIComponent;
		private function createDownButton() : void{
			_downButton = new UIComponent();
			_downButton.addEventListener(MouseEvent.CLICK, downButtonClick);
			_downButton.addEventListener(MouseEvent.MOUSE_DOWN, downButtonMouseDown);
			_downButton.width = this.width;
			_downButton.height = buttonHeight;
			_downButton.x = 0;
			_downButton.y = this.height - _downButton.height;
			addChild(_downButton);
		}
		
		private var _thumbBar:ThumbBar;
		private function createThumbBar() : void{
			_thumbBar = new ThumbBar();
			_thumbBar.addEventListener(MouseEvent.MOUSE_DOWN, thumbBarMouseDown);
			_thumbBar.width = thumbBarWidth;
			_thumbBar.height = this.height - _upButton.height - _downButton.height;
			_thumbBar.x = 0;
			_thumbBar.y = _upButton.height;
			addChild(_thumbBar);
		}
		
		public var buttonWidth:int = 18;
		private var _buttonHeight:int = 18;
		public function set buttonHeight(value:int) : void{
			_buttonHeight = value;
			_buttonHeightChange = true;
			invalidateDisplayList();
		}
		
		public function get buttonHeight() : int{
			return _buttonHeight;
		}
		
		private var _direction:String = ScrollDirection.VERTICAL;		
		public function set direction(value:String) : void{
			_direction = value;
			rotation = _direction == ScrollDirection.VERTICAL ? 0 : 270;
		}
		
		public function get direction() : String{
			return _direction;
		}
		
		private var _pageSize:int = 0;
		public function set pageSize(value:int) : void{
			if(_pageSize != value){
				_pageSize = value;
				_pageSizeChange = true;
				invalidateDisplayList();
			}
		}
		public function get pageSize() : int{
			return _pageSize;
		}
		
		private var _maxScrollPosition:int;
		public function set maxScrollPosition(value:int):void{
			if(value != _maxScrollPosition){
				_maxScrollPositionChange = true;
				_maxScrollPosition = value;
				invalidateDisplayList();
			}
		}

		public function get maxScrollPosition():int{
			return _maxScrollPosition;
		}
		
		private var _scrollBarSkin:ScrollBarSkin;
		public function set scrollBarSkin(skin:ScrollBarSkin):void{
			this._scrollBarSkin = skin;
			skinChange = true;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(w:Number, h:Number) : void{
			super.updateDisplayList(w, h);
			if (_buttonHeightChange){
				_upButton.height = _downButton.height = _buttonHeight;
				_upButton.width = _downButton.width = buttonWidth;
				_downButton.y = height - _downButton.height;
				_buttonHeightChange = false;
				if(_thumbBar.y < _buttonHeight){
					_thumbBar.y = _buttonHeight;
				}
				_pageSizeChange = true;
			}
			if (_widthChange){
				_downButton.x = w - _downButton.width >> 1
				_upButton.x = w - _upButton.width >> 1
				_trackBar.x = w - _trackBar.width >> 1;
				_thumbBar.x = w - _thumbBar.width >> 1;
				_widthChange = false;
			}
			if (_heightChange){
				var minHeight:int = minButtonHeight*2 + minThumbBarHeight;
				if(height < minHeight){
					removeChild(_thumbBar);
				}else if(!contains(_thumbBar)){
					addChild(_thumbBar);
					_pageSizeChange = true;
				}
				_downButton.y = height - _downButton.height;
				_trackBar.height = height;
				_heightChange = false;
			}
			if (_pageSizeChange || _maxScrollPositionChange){
				if (maxScrollPosition > 0){
					_thumbBar.visible = true;
					var tempHeight:int = pageSize/(pageSize + maxScrollPosition) * (this.height - _upButton.height - _downButton.height);
					tempHeight = Math.max(tempHeight,minThumbBarHeight);
					if(scrollPosition > maxScrollPosition){
						_thumbBar.height = tempHeight;
						_thumbBar.validateNow();
						scrollPosition = maxScrollPosition;
					}
					else{
						_thumbBar.y = _scrollPosition / maxScrollPosition * (this.height - _upButton.height - _downButton.height-tempHeight) + _upButton.height;
						_thumbBar.height = tempHeight;
						_thumbBar.validateNow();
					}
				}else{
					_thumbBar.visible = false;
				}
				_pageSizeChange = _maxScrollPositionChange = false;
			}
			if(_scrollPositionChange){
				_scrollPositionChange = false;
				setScrollPosition(_scrollPosition,true);
			}
			if(skinChange){
				updateSkin();
				skinChange = false;
			}
		}
		
		private function thumbBarMouseUp(event:MouseEvent) : void{
			_thumbBar.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, thumbBarMouseUp);
			removeEventListener(Event.ENTER_FRAME, thumbBarEnterFrame);
		}
		
		private function trackBarClickHandler(event:MouseEvent) : void{
			trackBarMouseHandler();
		}

		private function thumbBarMouseDown(event:MouseEvent) : void{
			var contentHeight:int = Math.ceil(this.height - _thumbBar.height - _downButton.height - _upButton.height);
			_thumbBar.startDrag(false, new Rectangle(_thumbBar.x, _upButton.height, 0, contentHeight));
			stage.addEventListener(MouseEvent.MOUSE_UP, thumbBarMouseUp);
			addEventListener(Event.ENTER_FRAME, thumbBarEnterFrame);
		}
		
		private function downButtonMouseUp(event:Event) : void{
			_buttonTimer.removeEventListener(TimerEvent.TIMER, downButtonTimer);
			_buttonTimer.stop();
		}
		
		private function upButtonTimer(event:TimerEvent) : void{
			upButtonClick();
		}
		
		private function downButtonTimer(event:TimerEvent) : void{
			downButtonClick();
		}
		
		private function thumbBarEnterFrame(event:Event) : void{
			var value:int = pointChangePosition(_thumbBar.y - _upButton.height);
			if(value != scrollPosition){
				var delta:int = scrollPosition - value;
				_scrollPosition = value;
				if(_scrollPosition < 0)_scrollPosition = 0;
				if(_scrollPosition > maxScrollPosition)_scrollPosition = maxScrollPosition;
				var evt:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
				evt.position = value;
				evt.delta = delta;
				dispatchEvent(evt);
			}
		}
		
		private function upButtonMouseDown(event:MouseEvent) : void{
			stage.addEventListener(MouseEvent.MOUSE_UP, upButtonMouseUp);
			_buttonTimer.addEventListener(TimerEvent.TIMER, upButtonTimer);
			_buttonTimer.start();
		}
		
		private var _scrollPositionChange:Boolean = false;
		private var _scrollPosition:int = 0;
		public function set scrollPosition(value:int) : void{
			if(_maxScrollPositionChange || _pageSizeChange){ //防止没有计算完而导致错误
				_scrollPositionChange = true;
				_scrollPosition = value;
			}else if(_scrollPosition != value){
				setScrollPosition(value,true);
			}
		}
		public function get scrollPosition() : int{
			return _scrollPosition;
		}
		
		public function setScrollPosition(value:int,flag:Boolean=false):void{
			var delta:int = value - _scrollPosition;
			if(value < 0)value = 0;
			if(value > maxScrollPosition)value = maxScrollPosition;
			this._scrollPosition = value;
			_thumbBar.y = positionChangePoint(value) + _upButton.height;
			if(flag){
				var evt:ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
				evt.position = value;
				evt.delta = delta;
				dispatchEvent(evt);
			}
		}
		
		private function upButtonMouseUp(event:Event) : void
		{
			_buttonTimer.removeEventListener(TimerEvent.TIMER, upButtonTimer);
			_buttonTimer.stop();
		}
		
		private function trackBarMouseHandler(event:Event = null) : void
		{
			if (mouseY > _thumbBar.y && mouseY < _thumbBar.y + _thumbBar.height){
				return;
			}
			var offsetPosition:int = pointChangePosition(_thumbBar.height);
			if (mouseY < _thumbBar.y){
				if (scrollPosition - offsetPosition > 0){
					scrollPosition = scrollPosition - offsetPosition;
				}
				else{
					scrollPosition = 0;
				}
			}
			else if (scrollPosition + offsetPosition > maxScrollPosition){
				scrollPosition = maxScrollPosition;
			}
			else{
				scrollPosition = scrollPosition + offsetPosition;
			}
		}
		
		private function downButtonMouseDown(event:MouseEvent) : void{
			stage.addEventListener(MouseEvent.MOUSE_UP, downButtonMouseUp);
			_buttonTimer.addEventListener(TimerEvent.TIMER, downButtonTimer);
			_buttonTimer.start();
		}
			
		private function upButtonClick(event:MouseEvent = null) : void{
			if (scrollPosition - pageScrollSize > 0){
				scrollPosition = scrollPosition - pageScrollSize;
			}
			else{
				scrollPosition = 0;
			}
		}
		
		public function updateSkin() : void
		{
			if(_scrollBarSkin){
				_trackBar.bgSkin = _scrollBarSkin.trackSkin;
				_upButton.bgSkin = _scrollBarSkin.upSkin;
				_downButton.bgSkin = _scrollBarSkin.downSkin;
				_thumbBar.bgSkin = _scrollBarSkin.thumbSkin;
				_thumbBar.iconSkin = _scrollBarSkin.barIcon;
				minThumbBarHeight = _scrollBarSkin.minThumbBarHeight;
				minButtonHeight = _scrollBarSkin.minButtonHeight;
				width = _scrollBarSkin.width;
				buttonHeight = _scrollBarSkin.buttonHeight;
				buttonWidth = _scrollBarSkin.buttonWidth;
				traceBarWidth = _scrollBarSkin.traceBarWidth;
				thumbBarWidth = _scrollBarSkin.thumbBarWidth
				_trackBar.width = traceBarWidth;
				_thumbBar.width = thumbBarWidth;
				_trackBar.validateNow();
				_thumbBar.validateNow();
				_trackBar.x = width - _trackBar.width >> 1;
				_thumbBar.x = width - _thumbBar.width >> 1;
			}else{
				_trackBar.bgColor = 15658734;
				_trackBar.bgAlpha = 0.5;
				_upButton.bgColor = 10027008;
				_downButton.bgColor = 10027008;
				_thumbBar.bgColor = 16711680;
			}
		}

		private function trackBarMouseUpHandler(event:MouseEvent) : void{
			stage.removeEventListener(MouseEvent.MOUSE_UP, trackBarMouseUpHandler);
			if (_trackBarTimer != null){
				_trackBarTimer.removeEventListener(TimerEvent.TIMER, trackBarMouseHandler);
				_trackBarTimer.stop();
				_trackBarTimer = null;
			}
		}
		
		private function downButtonClick(event:MouseEvent = null) : void{
			if (scrollPosition + pageScrollSize < maxScrollPosition){
				scrollPosition = scrollPosition + pageScrollSize;
			}
			else{
				scrollPosition = maxScrollPosition;
			}
		}
		
		override public function set width(value:Number):void{
			if(width != value){
				super.width = value;
				_widthChange = true;
				invalidateDisplayList();
			}
		}
		
		override public function set height(value:Number):void{
			if(height != value){
				super.height = value;
				_heightChange = true;
				invalidateDisplayList();
			}
		}		

		private function trackBarMouseDown(event:MouseEvent) : void{
			_trackBarTimer = new Timer(150);
			_trackBarTimer.addEventListener(TimerEvent.TIMER, trackBarMouseHandler);
			_trackBarTimer.start();
			stage.addEventListener(MouseEvent.MOUSE_UP, trackBarMouseUpHandler);
		}
		
		private function positionChangePoint(position:Number):int{
			var trackHeight:Number = this.height - _downButton.height - _thumbBar.height - _upButton.height;
			return position/maxScrollPosition*trackHeight;
		}
		private function pointChangePosition(point:Number):int{
			var trackHeight:Number = this.height - _downButton.height - _thumbBar.height - _upButton.height;
			var min:int = Math.min(point/trackHeight*maxScrollPosition,scrollPosition);
			return point/trackHeight*maxScrollPosition;
		}
	}
}
