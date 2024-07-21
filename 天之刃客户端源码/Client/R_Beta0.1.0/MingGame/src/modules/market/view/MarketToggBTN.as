package modules.market.view {
	import com.loaders.SourceLoader;
	import com.ming.ui.controls.Button;
	import com.ming.ui.skins.ButtonSkin;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.MouseEvent;
	
	import modules.market.MarketModule;

	public class MarketToggBTN extends Button {
		//默认由小到大排序
		public var type:Boolean=true;
		//loader对象
		private var loader:SourceLoader;
		//是否是排序的
		private var isSort:Boolean;
		//向上箭头
		private var upBitmap:Bitmap;
		//向下箭头
		private var downBitmap:Bitmap;
		
		/**
		 * 
		 * @param loader loader对象
		 * @param name	label的名字
		 * @param width button的长度
		 * @param isSort 是否排序
		 * 
		 */		
		public function MarketToggBTN(name:String, width:int, isSort:Boolean=false) {
			this.loader=loader;
			this.label = name;
			this.width = width;
			this.isSort = isSort;
			
			initUI();
			if(this.isSort != true)
			{
				this.mouseChildren = false;
				this.mouseEnabled = false;
			}
			else
			{
				initLitener();
			}
		}
		
		private function initUI():void
		{
			this.loader = MarketModule.getInstance().getLoader();
			var btnSkin:ButtonSkin = new ButtonSkin();
			//常skin
			var skin:BitmapData = this.loader.getBitmapData("sc__bg4");
			btnSkin.skin = skin;
			
			if(isSort == true)
			{
				//被选择后的skin
				var selectedSkin:BitmapData = this.loader.getBitmapData("sc__bg4_down");
				btnSkin.selectedSkin = selectedSkin;
				
				var upBitmapData:BitmapData = this.loader.getBitmapData("m2_sc_top");
				var downBitmapData:BitmapData = this.loader.getBitmapData("m2_sc_down");
				
				upBitmap = new Bitmap(upBitmapData);
				downBitmap = new Bitmap(downBitmapData);
				
				upBitmap.x = downBitmap.x = this.width - upBitmap.width-10;
				upBitmap.y = downBitmap.y = 8;
					
				addChild(upBitmap);
				addChild(downBitmap);
				//默认向下排序
				upBitmap.visible = false;
			}
			
			this.bgSkin = btnSkin;
		}
		
		private function initLitener():void
		{
			addEventListener(MouseEvent.CLICK, onMouseClick);
		}
		
//		public function set selected(value:Boolean) : void{
//			_selected = value;
//			updateStateSkin();
//		}
//		public function get selected() : Boolean
//		{
//			return _selected;
//		}  
//		
//		private function updateStateSkin():void{
//			var skin:ButtonSkin = bgSkin as ButtonSkin;
//			if(skin){
//				skin.selected = selected;
//			}
//		}
//		
//		public function set typeStyle(type:Boolean=true):void
//		{
//			this.type = type;
//			if(type == true){
//				upBitmap.visible = false;
//				downBitmap.visible = true;
//			}else {
//				upBitmap.visible = true;
//				downBitmap.visible = false;
//			}
//			selected = false;
//		}
		
		public function onMouseClick(event:MouseEvent):void
		{
			//如果已经选择了，看看是不是可以排序的
			if(isSort == true)
			{
				if(type == true)
				{
					type = false;
					upBitmap.visible = true;
					downBitmap.visible = false;
				}
				else
				{
					type = true;
					upBitmap.visible = false;
					downBitmap.visible = true;
				}
			}
		}
	}
}