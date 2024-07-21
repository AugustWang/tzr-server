package modules.mypackage.views.itemRender
{
	import com.globals.GameConfig;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.managers.ItemLocator;
	import modules.mypackage.views.GoodsImage;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopModule;
	
	public class SimpleGoodInfo extends UIComponent
	{
		
		//商品名字
		private var goodName:TextField;
		//商品图片
		private var goodImage:GoodsImage;
		//商品价格
		private var goodPrice:TextField;
		//购买按钮
		private var bugBtn:Button;
		//该商品的data
		private var content:Object;
		//格子数
		private var num:TextField;
		
		public function SimpleGoodInfo()
		{
			super();
			initUI();
			initListener();
		}
		
		private function initUI():void
		{
			// TODO Auto Generated method stub
			this.width = 100;
			this.height = 170;
			
			var bg:Shape = new Shape();
			bg.graphics.lineStyle(1,0x105e8d);
			bg.graphics.beginFill(0x000000,0.3);
			bg.graphics.drawRoundRect(0,0,100,170,10,10);
			bg.graphics.endFill();
			addChild(bg);
			
			goodName = new TextField();
			goodName.htmlText = "麻布包";
			goodName.height = 18;
			goodName.x = 30;
			goodName.y = 5;
			addChild(goodName);
			
			var imageBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			imageBg.x = 30;
			imageBg.y = goodName.y + goodName.height + 10;
			addChild(imageBg);
			goodImage = new GoodsImage();
			goodImage.x = imageBg.x+4;
			goodImage.y = imageBg.y+4;
			addChild(goodImage);
			
			goodPrice = new TextField();
			goodPrice.x = 10;
			goodPrice.y = goodImage.y + goodImage.height + 10;
			goodPrice.height = 18;
			goodPrice.htmlText = "价格:xxx";
			addChild(goodPrice);
			
			num = new TextField();
			num.x = 10;
			num.y = goodPrice.y + goodPrice.height + 10;
			num.height = 18;
			num.htmlText = "道具位:xxx";
			addChild(num);
			
			bugBtn = new Button();
			bugBtn.x = 18;
			bugBtn.y = num.y + num.height + 10;
			bugBtn.width=65;
			bugBtn.height=25;
			bugBtn.label = "购买";
			addChild(bugBtn);
			
		}
		
		private function initListener():void
		{
			// TODO Auto Generated method stub
			goodImage.addEventListener(MouseEvent.ROLL_OVER, onMouseRollOverHandler);
			goodImage.addEventListener(MouseEvent.ROLL_OUT, onMouseRollOutHandler);
			
			bugBtn.addEventListener(MouseEvent.CLICK, buyHandler);
		}
		
		protected function buyHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(this.content != null){
				ShopModule.getInstance().requestShopItem(30100, this.content.goodId, new Point(stage.mouseX-178, stage.mouseY-90));
			}
		}
		
		protected function onMouseRollOutHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			ToolTipManager.getInstance().hide();
		}
		
		protected function onMouseRollOverHandler(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			if(baseItemVO != null){
				ToolTipManager.getInstance().show(baseItemVO, 0, 0, 0, "targetToolTip");
			}
		}
		
		private var baseItemVO:BaseItemVO=null;
		
		public function setData(data:Object):void{
			this.content = data;
			baseItemVO=ItemLocator.getInstance().getObject(int(data.goodId));
			this.goodName.htmlText = "<font color='"+ItemConstant.COLOR_VALUES[baseItemVO.color]+"'>"+data.name+"</font>";
			this.goodPrice.htmlText = "<font color='"+ItemConstant.COLOR_VALUES[baseItemVO.color]+"'>价格："+data.silver+"</font>";
			this.num.htmlText = "<font color='"+ItemConstant.COLOR_VALUES[baseItemVO.color]+"'>道具位："+data.num+"</font>";
			this.goodImage.setImageContent(baseItemVO,baseItemVO.path);
		}
	}
}