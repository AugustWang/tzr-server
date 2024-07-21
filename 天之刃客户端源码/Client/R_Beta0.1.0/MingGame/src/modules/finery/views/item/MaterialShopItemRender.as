package modules.finery.views.item {
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.finery.StoveConstant;
	import modules.finery.views.StovePanel;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.PackManager;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopModule;

	public class MaterialShopItemRender extends UIComponent {
		private var box:Sprite;
		private var nameTxt:TextField;
		private var numTxt:TextField;
		private var pctTxt:TextField;
		private var buyTxt:TextField;
		public var isBind:Boolean = false;
		private var matrix:Array = [ 0.5,0.5,0.5,0,-50,
			0.5,0.5,0.5,0,-50,
			0.5,0.5,0.5,0,-50,
			0,0,0,1,0 ];
		private var grayMatrix:ColorMatrixFilter = new ColorMatrixFilter(matrix);

		public function MaterialShopItemRender() {
			super();
			init();
		}

		private function init():void {
			this.width=120;
			this.height=48;
			Style.setListBgSkin(this);
			
			box=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			this.addChild(box);
			box.x=2;
			box.y=5;

			box.addEventListener(MouseEvent.ROLL_OVER, onRollOverHandler);
			box.addEventListener(MouseEvent.ROLL_OUT, onRollOutHandler);
			this.addEventListener(MouseEvent.CLICK, onMouseClickHandler);
			this.addEventListener(MouseEvent.ROLL_OVER, onMouseOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, onMouseOutHandler);

			nameTxt=ComponentUtil.createTextField("XXOO", box.x + box.width + 2,2, null, 75, 25, this);
			numTxt=ComponentUtil.createTextField("XX00", box.x + box.width + 2, 16, null, 75, 25, this);
			pctTxt=ComponentUtil.createTextField("", box.x + box.width + 2, 30, null, 75, 25, this);
			nameTxt.htmlText="XXOO\n100";
			//nameTxt.wordWrap=true;
			//nameTxt.multiline=true;

			buyTxt=ComponentUtil.createTextField("", this.width - 35, this.height - 25, null, 33, 26, this);
			buyTxt.mouseEnabled=true;
			buyTxt.htmlText="<font color='#00ff00'><u><a href='event:buy'>购买</a></u></font>";
			buyTxt.addEventListener(TextEvent.LINK, onTextLinkHandler);

		}

		private function onRollOverHandler(evt:MouseEvent):void {
			if (data) {
				var point:Point=new Point(this.x, this.y);
				point=this.parent.localToGlobal(point);
				ItemToolTip.show(BaseItemVO(data), point.x + 45, point.y + 20, false);
			}
		}

		private function onRollOutHandler(evt:MouseEvent):void {
			ItemToolTip.hide();
		}

		private function onMouseClickHandler(evt:MouseEvent):void {
			if(evt.target == buyTxt)return;
			var goods:Array = PackManager.getInstance().getGoodsByType(BaseItemVO(data).typeId);
			for(var i:int=0; i < goods.length; i++){
				var item:BaseItemVO = goods[i];
				if(item.bind != isBind){
					goods.splice(i,1)
					i--;
				}
			}
			if(getGoodsNum() > 0){
				var event:ParamEvent = new ParamEvent("MATERIAL_ITEM_CLICK",goods[0],true);
				dispatchEvent(event);
			}else{
				ShopModule.getInstance().requestShopItem(30100, BaseItemVO(data).typeId, new Point(stage.mouseX-178, stage.mouseY-90),2);
			}
			updateNum();
		}

		private function onTextLinkHandler(evt:TextEvent):void {
			evt.stopPropagation();
			if (evt.text == "buy" && BaseItemVO(data)!=null) {
				ShopModule.getInstance().requestShopItem(30100, BaseItemVO(data).typeId, new Point(stage.mouseX-178, stage.mouseY-90),2,data.bind);
			}
		}
		
		private var _select:Boolean
		public function select(value:Boolean):void{
			if(_select == value){
				return;
			}
			_select = value;
			if(_select){
				filters = [new GlowFilter(0xFBCF22,0.9,6,6,2,1,true)];//#5CEAE7 FBCF22 #00EBF8
			}else{
				filters = [];
			}
		}
		
		private function onMouseOverHandler(event:MouseEvent):void{
			if(!_select){
				filters = [new GlowFilter(0xFBCF22,0.5,12,12,2,1,true)];
			}
		}
		
		private function onMouseOutHandler(event:MouseEvent):void{
			if(!_select){
				filters = [];
			}
		}

		override public function get data():Object {
			return super.data;
		}

		override public function set data(value:Object):void {
			super.data=value.vo;
			isBind = value.isBind;
			data.bind = isBind;
			var image:GoodsImage=new GoodsImage();
			box.addChild(image);
			image.x=4;
			image.y=4;
			image.setImageContent(BaseItemVO(data), data.path);
			nameTxt.htmlText=HtmlUtil.font(BaseItemVO(data).name, ItemConstant.COLOR_VALUES[BaseItemVO(data).color]);
			numTxt.htmlText="×" +getGoodsNum();
			if(StovePanel.currentIndex == StovePanel.TABNAME_ARRAY.EQUIP_EXALT){
//				var exaltEquip:BaseItemVO = FineryModule.getInstance().stovePanel.exaltView.getValue();
//				if(exaltEquip){
//					pctTxt.htmlText=StoveMaterialFilter.percent(exaltEquip,data as BaseItemVO)+'% 成功率';
//					buyTxt.y = numTxt.y;
//				}else{
//					pctTxt.htmlText="";
//				}
			}
			
			if(StoveConstant.SHOP_ID.indexOf(BaseItemVO(data).typeId) != -1){
				buyTxt.visible = true;
			}else{
				buyTxt.visible = false;
			}
			if(getGoodsNum() == 0){
				nameTxt.filters = [grayMatrix];
				image.filters = [grayMatrix];
			}else{
				nameTxt.filters = [];
				image.filters = [];
			}
		}
		
		public function updateNum():void{
			numTxt.htmlText="×" +getGoodsNum();
		}
		
		private function getGoodsNum():int{
			var num:int;
			var materials:Array;
			if(data){
				if(isBind){
					num = PackManager.getInstance().getBindGoodsNunByTypeId(data.typeId,true);
				}else{
					num = PackManager.getInstance().getBindGoodsNunByTypeId(data.typeId,false);
				}
				switch(StovePanel.currentIndex){
					case StovePanel.TABNAME_ARRAY.EQUIP_EXALT:
//						materials = FineryModule.getInstance().stovePanel.exaltView.getMaterials();
//						for(var i:int=0; i < materials.length; i++){
//							var item:BaseItemVO = materials[i];
//							if(item.typeId == data.typeId && item.bind == isBind){
//								num--;
//							}
//						}
						break;
				}
			}
			return num;
		}
	}
}