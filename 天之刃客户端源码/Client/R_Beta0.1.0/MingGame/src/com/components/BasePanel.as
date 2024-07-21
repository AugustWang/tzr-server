package com.components
{
	import com.globals.GameConfig;
	import com.loaders.ResourcePool;
	import com.loaders.SourceLoader;
	import com.managers.WindowManager;
	import com.ming.events.CloseEvent;
	import com.ming.events.HelpEvent;
	import com.ming.events.ResizeEvent;
	import com.ming.ui.containers.Panel;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.utils.ScaleShape;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.system.LoaderContext;
	import flash.text.TextFormat;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modules.help.HelpManager;
	
	/**
	 * 窗口面板基类 
	 */ 
	public class BasePanel extends Panel
	{
		public static const TITLE_PATH:String = "/com/assets/panelTitles/";
		public static const titleTF:TextFormat = new TextFormat("",14,0xffffff,true);
		public static const tfilters:Array = [new GlowFilter(0x000000,1,2,2,4)];
		private var paddingBottom:int;
		private var paddingLR:int;
		private var paddingTop:int;
		private var contentBg:ScaleShape;
		private var titleBg:ScaleShape;
		private var smallTitleBg:Bitmap;
		
		public function BasePanel(key:String=null)
		{
			super();
			closeRight = 12;
			titleAlign = 2;
			titleFormat = titleTF;
			headHeight = 40;
			titleFitlers = tfilters;
			addEventListener(CloseEvent.CLOSE,closeHandler);
			addEventListener(HelpEvent.HELP,helpHandle);
			init();
		}
		
		/**
		 * 初始化界面
		 * 
		 */		
		protected function init():void
		{
			
		}
		
		private var _titleImage:String;
		private var  titleImage:Image;
		public function addImageTitle(value:String):void{
			_titleImage = value;
		}
		
		override protected function updateDisplayList(w:Number, h:Number):void{
			super.updateDisplayList(w,h);
			if(titleImage == null && _titleImage){
				titleImage = new Image();
				titleImage.defaultIcon = null;
				titleImage.mouseChildren = titleImage.mouseEnabled = false;
				titleImage.addEventListener(Event.COMPLETE,onTitleLoadComplete);
				titleImage.source = GameConfig.ROOT_URL+TITLE_PATH+_titleImage+".png";
				titleImage.x = w - titleImage.width >> 1;
				titleImage.y = 6;
				addChildToSuper(titleImage);
			}
		}
		
		protected function onTitleLoadComplete(event:Event):void{
			var titleImage:Image = event.currentTarget as Image;
			titleImage.x = width - titleImage.width >> 1;
		}
		
		protected function addTitleBG(value:int=0):void{
			if(titleBg == null){
				titleBg = new ScaleShape(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"panelTitleBg"));
				titleBg.setScale9Grid(new Rectangle(172,31,103,1));
				addChildToSuper(titleBg);
			}
			
			if(value==0){
				titleBg.width = this.width-36;
				titleBg.x = 18;
			}else{
				titleBg.width = value;
				titleBg.x=(this.width - value) >> 1;
			}
		}
		
		protected function addSmaillTitleBG():void{
			if(smallTitleBg==null){
				smallTitleBg = Style.getBitmap(GameConfig.T1_VIEWUI,"smallPanelTitleBg");
				addChildToSuper(smallTitleBg);
			}
			smallTitleBg.x=(this.width - smallTitleBg.width) >> 1;
		}
		
		protected function addContentBG(paddingBottom:Number=30,paddingLR:Number=8,paddingTop:Number=5):void{
			this.paddingBottom = paddingBottom;
			this.paddingLR = paddingLR;
			this.paddingTop = paddingTop;
			if(contentBg == null){
				contentBg = new ScaleShape(Style.getUIBitmapData(GameConfig.T1_VIEWUI,"panelContentBg"));
				contentBg.setScale9Grid(new Rectangle(10,10,286,270));
				addChild(contentBg);
			}
			contentBg.x = paddingLR;
			contentBg.y = paddingTop;
		}
		
		override protected function onReisze(event:ResizeEvent):void{
			super.onReisze(event);
			if(contentBg){		
				contentBg.setSize(width - 2*paddingLR,height-(headHeight+paddingBottom+paddingTop));
			}
		}
		
		private var dataloading:DataLoading;
		private var timeOut:int;
		public function addDataLoading():void
		{
			if(dataloading == null){
				dataloading = new DataLoading();
				dataloading.x = 0;
				dataloading.y = 0;
				dataloading.width = width;
				dataloading.height = height;
			}
			addChild(dataloading);
			clearTimeout(timeOut);
			timeOut = setTimeout(removeDataLoading,10000);
		}
		
		public function removeDataLoading():void
		{
			if(dataloading && contains(dataloading))
			{
				removeChild(dataloading);
			}
		}
		
		protected function helpHandle(event:Event):void
		{
			HelpManager.getInstance().openHelpView();
		}
		
		protected function closeHandler(event:CloseEvent=null):void
		{
			closeWindow();
		}
		
		public function closeWindow(save:Boolean = false):void
		{
			WindowManager.getInstance().removeWindow(this);
		}
		
		public function open():void
		{
			WindowManager.getInstance().popUpWindow(this);	
		}
		
		public function centerOpen():void{
			WindowManager.getInstance().popUpWindow(this);	
			WindowManager.getInstance().centerWindow(this);
		}
		
		public function get isPopUp():Boolean{
			return WindowManager.getInstance().isPopUp(this);
		}
		
		override protected function removeSelf():void{
			//覆盖此方法的操作，以便通过WindowMangager来remove自己
		}
	}
}