package com.ming.ui.containers
{
	import com.ming.events.CloseEvent;
	import com.ming.events.HelpEvent;
	import com.ming.events.ResizeEvent;
	import com.ming.managers.DragManager;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.PanelSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	import com.ming.utils.TextUtil;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	
	public class Panel extends Container
	{
		protected var _dragBar:UIComponent; //顶部拖拽条
		protected var _closeButton:UIComponent; //关闭按钮
		protected var _helpButton:UIComponent;//帮助按钮
		private var _closeWidth:int=11; //关闭按钮的宽度
		private var _closeHeight:int=12; //关闭按钮的高度
		private var _closeSkin:Skin; //关闭按钮的皮肤
		private var _helpSkin:Skin;//帮助按钮的皮肤
		private var _headerSkin:Skin; //头部皮肤
		private var _closeTop:int=6; //关闭按钮距顶部的距离
		private var _closeRight:int=6; //关闭按钮距右边的距离
		private var _headHeightChanged:Boolean=true; //顶部的高度是否发生改变
		protected var _titleText:TextField; //头部标题
		private var _showCloseButton:Boolean=true; //是否需要关闭按钮
		private var _showHelpButton:Boolean=false;//是否需要帮助按钮
		private var _closePositionChanged:Boolean=false; //关闭按钮位置是否发生改变
		private var _headHeight:int=30; //头部高度
		private var _title:String=""; //头部标题内容
		private var _titleAlign:int = 1;
		private var _titleChanged:Boolean=false; //标题内容是否发生改变
		private var _allowDrag:Boolean = false;
		private var _bodySkin:Skin;//内容皮肤
		public function Panel()
		{
			 //初始化界面
			
			this.init()
//			this.no_mask();
		
		}
		public function set allowDrag(value:Boolean):void{
			if(_allowDrag != value){
				this._allowDrag = value;
				if(_allowDrag){
					DragManager.register(_dragBar,this,null,DragManager.BORDER);
				}else{
					DragManager.unregister(_dragBar);
				}
			}
		}
		
		public function get dragBar():UIComponent{
			return _dragBar;
		}
		
		public function get allowDrag():Boolean{
			return this._allowDrag;
		}
		/**
		 * 获取和设置关闭按钮距离右边的距离
		 */
		public function get closeRight():int
		{
			return _closeRight;
		}
		
		public function set closeRight(value:int):void
		{
			_closeRight=value;
			_closePositionChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 设置和获取头部的文本格式化对象
		 */ 
		private var _tf:TextFormat = new TextFormat(null, 15, 0xffffff,false);
		public function set titleFormat(format:TextFormat):void
		{
			_tf = format;
			if(_titleText){
				_titleText.defaultTextFormat = _tf;
				_titleText.setTextFormat(_tf);;
			}
		}	
		
		public function get titleFormat():TextFormat
		{
			return _tf;
		}
		/**
		 * 设置获取获取title得高度
		 */ 
		public function set headHeight(value:int):void
		{
			_headHeight=value;
			_headHeightChanged=true;
			invalidateDisplayList();
		}		
		public function get headHeight():int
		{
			return _headHeight;
		}
		/**
		 * 设置和获取关闭按钮的皮肤
		 */
		public function set closeSkin(buttonSkin:Skin):void
		{
			_closeSkin=buttonSkin;
			if(_closeButton){
				_closeButton.bgSkin=buttonSkin;
			}
		}
		
		public function set helpSkin(helpSkin:Skin):void{
			_helpSkin=helpSkin;
			if(_helpButton){
				_helpButton.bgSkin=helpSkin;
			}
		}
		
		public function set headerSkin(headerSkin:Skin):void{
			this._headerSkin = headerSkin;
			_dragBar.bgSkin = headerSkin;
		}
		
		public function set bodySkin(skin:Skin):void{
			if(skin){
				_bodySkin = skin;
				_bodySkin.mouseChildren=_bodySkin.mouseEnabled=false;
				rawChildren.addChildAt(_bodySkin,0);
			}
		}
		
		public function get closeWidth():int
		{
			return _closeWidth;
		}		
		/**
		 * 初始化界面
		 */
		private function init():void
		{
			_dragBar=new UIComponent();
			_dragBar.width=width;
			_dragBar.height=headHeight;
			allowDrag = true;
			addChildToSuper(_dragBar);
			createCloseButton();
			createHelpButton();
			panelSkin = StyleManager.panelSkin;
			contentPane.mask = null;
			rawChildren.mask = null;
		}

		private var _panelSkin:PanelSkin;
		public function set panelSkin(skin:PanelSkin):void{
			if(skin){
				_panelSkin = skin;
				if(_panelSkin.panelBgSkin)
					bgSkin=_panelSkin.panelBgSkin;
				if(_panelSkin.headerSkin)
					headerSkin = _panelSkin.headerSkin;
				if(_panelSkin.bodySkin)
					bodySkin = _panelSkin.bodySkin;
				if(_panelSkin.closeSkin){
					closeSkin = _panelSkin.closeSkin;
				}if(_panelSkin.helpSkin){
					helpSkin = _panelSkin.helpSkin;
				}
			}
		}
		
		private function createCloseButton():void{
			if(showCloseButton && !_closeButton){
				_closeButton=new UIComponent();
				_closeButton.addEventListener(MouseEvent.CLICK, closeBtnClickHandler);
				_closeButton.width=closeWidth;
				_closeButton.height=closeHeight;
				_closeButton.x=this.width - _closeButton.width - closeRight;
				_closeButton.bgAlpha = 1;
				_closeButton.bgColor = 0xff00ff;
				if(_closeSkin){
					_closeButton.bgSkin = _closeSkin;
				}
				_closeButton.y=closeTop;
				_closeButton.buttonMode=true;
				_closeButton.useHandCursor=true;
				addChildToSuper(_closeButton);
			}else if(_closeButton && !showCloseButton){
				if(_closeButton.parent)
					removeSuperChild(_closeButton);
				_closeButton.removeEventListener(MouseEvent.CLICK, closeBtnClickHandler);
				_closeButton = null;
			}		
		}
		
		private function createHelpButton():void{
			if(showHelpButton && !_helpButton){
				_helpButton = new UIComponent();
				_helpButton.addEventListener(MouseEvent.CLICK, helpBtnClickHandler);
				_helpButton.width=closeWidth;
				_helpButton.height=closeHeight;
				_helpButton.x=this.width - 2*_closeButton.width - closeRight - 3;
				_helpButton.bgAlpha = 1;
				_helpButton.bgColor = 0xff00ff;
				if(_helpSkin){
					_helpButton.bgSkin = _helpSkin;
				}
				_helpButton.y=closeTop;
				_helpButton.buttonMode=true;
				_helpButton.useHandCursor=true;
				addChildToSuper(_helpButton);
			}else if(_helpButton && !showHelpButton){
				if(_helpButton.parent)
					removeSuperChild(_helpButton);
				_helpButton.removeEventListener(MouseEvent.CLICK, helpBtnClickHandler);
				_helpButton = null;
			}
		}
		
		protected function helpBtnClickHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var evt:HelpEvent = new HelpEvent(HelpEvent.HELP);
			dispatchEvent(evt);
		}
		
		/**
		 * 
		 * 设置是否隐藏和显示帮助按钮
		 * 
		 */		
		public function set showHelpButton(value:Boolean):void{
			_showHelpButton=value;
			createHelpButton();
		}
		
		public function get showHelpButton():Boolean{
			return _showHelpButton;
		}
		
		/**
		 * 设置是否隐藏和显示关闭按钮
		 */ 
		public function set showCloseButton(value:Boolean):void
		{
			_showCloseButton=value;
			createCloseButton();
		}
		public function get showCloseButton():Boolean
		{
			return _showCloseButton;
		}
		
		private var _titleFitlers:Array;
		public function set titleFitlers(values:Array):void{
			_titleFitlers = values;
		}
		
		public function set title(value:String):void
		{
			if (value == null)return;
			_title=value;
			if (value == "" && _titleText != null)
			{
				removeChild(_titleText);
				_titleText=null;
			}
			if (_titleText == null && value != "")
			{
				_titleText = new TextField();
				_titleText.filters = _titleFitlers;
				_titleText.defaultTextFormat = _tf;
				_titleText.autoSize = "left";
				_titleText.mouseEnabled=false;
				
				addChildToSuper(_titleText);
			}
			if (_titleText != null)
			{
				_titleText.text=value;
			}
			_titleChanged=true;
			invalidateDisplayList();
		}
		
		public function get title():String
		{
			return _title;
		}
		
		/**
		 * 设置title的位置，1为左边，2为中间
		 * @return 
		 * 
		 */	
		public function set titleAlign(value:int):void
		{
			this._titleAlign = value;
		}
		public function get titleAlign():int
		{
			return this._titleAlign;
		}
		/**
		 * 设置和获取关闭按钮距离顶部的距离
		 */ 
		public function get closeTop():int
		{
			return _closeTop;
		}
		public function set closeTop(value:int):void
		{
			_closeTop=value;
			_closePositionChanged=true;
			invalidateDisplayList();
		}
		/**
		 * 获取和设置关闭按钮的高度
		 */ 
		public function set closeHeight(value:int):void
		{
			_closeHeight=value;
			_closePositionChanged=true;
			invalidateDisplayList();
		}		
		public function get closeHeight():int
		{
			return _closeHeight;
		}
		
		private function closeBtnClickHandler(event:MouseEvent):void
		{
			var evt:CloseEvent=new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(evt);
		}
		
		public function set closeWidth(value:int):void
		{
			_closeWidth=value;
			_closePositionChanged=true;
			invalidateDisplayList();
		}
		
		protected override function onReisze(event:ResizeEvent):void{
			//super.onReisze(event);
			if(_closeButton){
				_closeButton.x = this.width - _closeButton.width - closeRight;
				_closeButton.y = closeTop;
			}
			if(_helpButton){
				_helpButton.x = this.width - 2*_helpButton.width - closeRight - 3;
				_helpButton.y = closeTop;
			}
			_dragBar.width = width;
			if(_titleText){
				changeTitlePos();
				TextUtil.fitText(_titleText,title,_dragBar.width - _titleText.x);
			}
			if(_bodySkin){
				_bodySkin.height = height - _headHeight;
				_bodySkin.width = width;			
			}
		}
		private function changeTitlePos():void
		{
			if(titleAlign == 1)
				_titleText.x= 10;
			else if(titleAlign == 2)
				_titleText.x = _dragBar.width / 2 - _titleText.textWidth / 2;
			
			_titleText.y=(_headHeight - _titleText.height) / 2;	
			_titleText.width = _dragBar.width - _titleText.x;
		}
		
		override public function dispose() : void{
			super.dispose();
			if(allowDrag){
				DragManager.unregister(_dragBar);
			}
			if(_closeButton){
				_closeButton.dispose();
			}
			if(_helpButton){
				_helpButton.dispose();
			}
			dragBar.dispose();
		}
		override protected function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			if (_headHeightChanged || _titleChanged)
			{
				if (_titleText != null)
				{
					changeTitlePos();
				}
				if (_headHeightChanged)
				{
					contentPane.y=_headHeight; 
					_dragBar.height=_headHeight;
					if(_bodySkin){
						_bodySkin.y = contentPane.y;
					}
				}
				_titleChanged=false;
				_headHeightChanged=false;
			}
			if (_closePositionChanged)
			{
				if(_closeButton){
					_closeButton.width=closeWidth;
					_closeButton.height=closeHeight;
					_closeButton.x=this.width - _closeButton.width - closeRight;
					_closeButton.y=closeTop;
				}
				_closePositionChanged=false;
			}
		}
	}
}
