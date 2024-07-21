package modules.finery.views.item
{
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.LayerManager;
	import com.managers.WindowManager;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.finery.FineryModule;
	import modules.finery.views.StovePanel;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	
	public class MaterialItemRender extends UIComponent implements IDataRenderer
	{
		private var nameTxt:TextField;
		private var box:Sprite;
		private var type:String;
		private var numTxt:TextField;
		
		public function MaterialItemRender()
		{
			super();
			
			this.width = 120;
			this.height = 48;
			this.width = 120;
			this.height = 48;
			Style.setListBgSkin(this);
			
			box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			this.addChild(box);
			box.x = 2;
			box.y = 5;
			
			
			nameTxt = ComponentUtil.createTextField("",box.x + box.width + 2,box.y,null,75,45,this);
			nameTxt.htmlText = "XXOO";
			numTxt = ComponentUtil.createTextField("",box.x + box.width + 2,nameTxt.y + nameTxt.textHeight + 2,null,100,45,this);
			
			box.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			box.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			this.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
			this.addEventListener(MouseEvent.ROLL_OVER,onMouseOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,onMouseOutHandler);
		}
		
		private function onRollOverHandler(evt:MouseEvent):void{
			if(data){
				var point:Point = new Point(this.x,this.y);
				point = this.parent.localToGlobal(point);
				ItemToolTip.show(BaseItemVO(data),point.x + 45,point.y + 20,false);
			}
		}
		
		private function onRollOutHandler(evt:MouseEvent):void{
			ItemToolTip.hide();
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
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			if(evt.shiftKey && data && data.num > 1){
				var split:SplitPanel = new SplitPanel();
				split.maxSize = data.num;
				split.callBack = splitCallBack;
				WindowManager.getInstance().openDialog(split);
				split.x = stage.mouseX - 22;
				split.y = stage.mouseY - 40;
			}else{
				var event:ParamEvent = new ParamEvent("EQUIP_ITEM_CLICK",data,true);
				dispatchEvent(event);
			}
		}
		
		private function splitCallBack(num:int):void{
//			var item:BaseItemVO = ItemLocator.getInstance().getObject(data.typeId);
//			for(var i:String in item){
//				item[i] = data[i];
//			}
//			item.num = num;
			data.num = num
			var event:ParamEvent = new ParamEvent("EQUIP_ITEM_CLICK",data,true);
			dispatchEvent(event);
		}
		
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var image:GoodsImage = new GoodsImage();
			box.addChild(image);
			image.x = 4;
			image.y = 4;
			image.setImageContent(BaseItemVO(data),data.path);
			var colorValue:String = ItemConstant.COLOR_VALUES[BaseItemVO(data).color];
			switch(FineryModule.getInstance().getCurrentIndex()){
				case StovePanel.TABNAME_ARRAY.MATERIAL_COMPOSE:
				case StovePanel.TABNAME_ARRAY.REFINE_FUNCTION:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+BaseItemVO(data).name+"</font>";
					numTxt.htmlText = "x"+ BaseItemVO(data).num;
					break;
				default:
					nameTxt.htmlText = "<font color='"+colorValue+"'>"+BaseItemVO(data).name+"</font>";
					break;
			}
		}
	}
}