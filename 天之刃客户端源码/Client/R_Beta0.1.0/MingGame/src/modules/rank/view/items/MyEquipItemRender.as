package modules.rank.view.items
{
	import com.globals.GameConfig;
	import com.ming.core.IDataRenderer;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.views.ItemToolTip;
	import modules.mypackage.vo.BaseItemVO;
	import modules.mypackage.vo.EquipVO;
	import modules.rank.view.EquipListView;
	
	import proto.common.p_goods;
	
	public class MyEquipItemRender extends UIComponent implements IDataRenderer
	{
		public static var currentEquipId:int = -1;
		private var box:Sprite;
		private var orangeSprite:Sprite;
		public function MyEquipItemRender()
		{
			super();
			box = Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			this.addChild(box);
			
			this.addEventListener(MouseEvent.ROLL_OVER,onRollOverHandler);
			this.addEventListener(MouseEvent.ROLL_OUT,onRollOutHandler);
			this.addEventListener(MouseEvent.CLICK,onMouseClickHandler);
		}
		
		private function onRollOverHandler(evt:MouseEvent):void{
			if(data){
				var point:Point = new Point(this.x,this.y);
				point = this.parent.localToGlobal(point);
				ItemToolTip.show(BaseItemVO(data),point.x + 30,point.y + 20,false);
				
			}
		}
		
		private function onRollOutHandler(evt:MouseEvent):void{
			ItemToolTip.hide();
		}
		
		private function onMouseClickHandler(evt:MouseEvent):void{
			if(EquipListView.preEquiup){
				var myEquipItem:MyEquipItemRender = EquipListView.preEquiup;
				if(myEquipItem.orangeSprite && myEquipItem.contains(myEquipItem.orangeSprite)){
					myEquipItem.removeChild(myEquipItem.orangeSprite);
					myEquipItem.orangeSprite = null;
				}
			}
			EquipListView.preEquiup = evt.currentTarget as MyEquipItemRender;
			orangeSprite = Style.getViewBg("packItemOverBg");
			this.addChild(orangeSprite);
			currentEquipId = data.oid;
		}
		override public function get data():Object{
			return super.data;
		}
		
		override public function set data(value:Object):void{
			super.data = value;
			var image:GoodsImage = new GoodsImage();
			box.addChild(image);
			image.x = 1;
			image.y = 1;
			image.setImageContent(BaseItemVO(data),value.path);
//			image.source = value.path;
			
		}
	}
}