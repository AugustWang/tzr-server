package modules.mypackage.views
{
	import com.common.FilterCommon;
	import com.common.dragManager.DragConstant;
	import com.common.dragManager.IDragItem;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.PackageModule;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.GeneralVO;

	public class ExtraPackItem extends UIComponent implements IDragItem
	{
		protected var content:*;
		public var packId:int;
		public var typeId:int;
		public var count:int;
		public function ExtraPackItem()
		{
			this.height = this.width = 36;
			this.mouseChildren = false;
			this.buttonMode = true;
			this.useHandCursor = true;
			addChild(Style.getBitmap(GameConfig.T1_VIEWUI,"extralPackBg"));
			this.addEventListener(MouseEvent.CLICK, buyHandler);
			
			var buyTxt:TextField = ComponentUtil.createTextField("", 7, 9, null, 30, 20, this);
			buyTxt.filters = FilterCommon.FONT_BLACK_FILTERS;
			buyTxt.htmlText = "<a href='event:buy'>购买</a>";
			buyTxt.textColor = 0x00FF00;
		}
		
		private function buyHandler(evt:Event):void
		{
			if (!content && this.stage) {
				PackageModule.getInstance().openExPack();
			}
		}
		
		public function allowAccept(itemVO:Object,name:String):Boolean{
			var generalVO:GeneralVO = itemVO as GeneralVO;
			if(name == DragConstant.PACKAGE_ITEM && generalVO && generalVO.kind == ItemConstant.KIND_PACK){
				return true;	
			}
			return false;
		}
		
		protected function createContent():void{
			content = new GoodsItem(data as BaseItemVO);
			addChild(content);
			updatePosition();
		}
		
		protected function updatePosition():void{
			if(content){
				content.x = 4;
				content.y = 4;
			}
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			if(data){
				createContent();
			}
		}

		public function setContent(_content:*,_data:*):void{
			content = _content;
			setData(_data);
			addChild(_content);
			updatePosition();
		}		
		
		public function getContent():*{		
			return content;
		}
		
		public function setData(value:*):void{
			super.data = value;
		}
		
		public function disposeContent():void{
			if(content && contains(content)){
				removeChild(content);
			}
			content = null;
			setData(null);
		}
		
		public function dragDrop(dragData:Object, dragTarget:DisplayObject, itemName:String):void{
			var item:GoodsItem = dragTarget as GoodsItem;
			var tempData:BaseItemVO = dragData as BaseItemVO;
			if(itemName == DragConstant.PACKAGE_ITEM){
				//setContent(dragTarget,dragData);
				PackageModule.getInstance().useItem(tempData.oid);
			}
		}			
	}
}