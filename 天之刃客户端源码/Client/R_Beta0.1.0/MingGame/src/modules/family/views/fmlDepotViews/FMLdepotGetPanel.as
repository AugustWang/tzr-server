package modules.family.views.fmlDepotViews
{
	import com.components.alert.Alert;
	import com.components.components.DragUIComponent;
	import com.globals.GameConfig;
	import com.ming.events.CloseEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.NumericStepper;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	
	import modules.family.FamilyDepotModule;
	import modules.mypackage.ItemConstant;
	import modules.mypackage.vo.BaseItemVO;
	import modules.shop.ShopConstant;
	import modules.shop.ShopItem;
	import modules.shop.views.ShopItemImg;

//	import modules.shop.views.ShopGoodsItem;
	
	public class FMLdepotGetPanel extends DragUIComponent
	{
		private var _nameTf:TextField; 
		private var tmp_goods:ShopItemImg;
		
		private var dec_text:TextField;
		
		private var numText:TextField;
		
		private var numStep:NumericStepper;
		
		public var buyButton:Button;
		
		/* 变量 */
		private var bag_id:int;
		private var id:int;
		private var price:String;
		private var priceObjArr:Array;
		private var price_id:int;
		
		private var num:int;
		private var moneyType:int;
		private var money:String;
		private var _name:String;
		private var totalCost:String;
		private var datetxt:TextField;
		
		public function FMLdepotGetPanel()
		{
			super();
			
			//			title = "回城卷    500铜";
			this.width = 228;//215;
			this.height = 111;//155;
			//			this.allowDrag = false;
			
			Style.setRectBorder(this);
			this.showCloseButton = true;
			
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.width = 222;
			line.height = 2;
			line.x = 3;
			line.y = 28;
			addChild(line);
			
			init();
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAddStage);
		}
		
		override protected function onCloseHandler(event:MouseEvent):void
		{
			var e:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			dispatchEvent(e);
		}
		
		private function onAddStage(e:Event):void
		{
			numStep.textFiled.setFocus();
			numStep.textFiled.validateNow();
			numStep.textFiled.textField.setSelection(0,numStep.textFiled.text.length);
		}
		
		private function init():void
		{
			var tf:TextFormat = new TextFormat("Tahoma",15,0xffffff);
			_nameTf = ComponentUtil.createTextField("",8,6,tf,175,23,this);
			
			tmp_goods= new ShopItemImg();
			tmp_goods.x = 8;
			tmp_goods.y = 31;//35;
			tmp_goods.width =tmp_goods.height = 37;
			tmp_goods.toolTipOff();
			
			addChild(tmp_goods);
			
			
			var txtformat:TextFormat = new TextFormat("Tahoma",12,0xece8bb);
			
			numText = ComponentUtil.createTextField(ShopConstant.NUM_TEXT ,46,35,txtformat,46,23,this); // new TextField();
			
			
			numStep = new NumericStepper();
			numStep.x = 83;
			numStep.y = 34;//82;
			numStep.textFiled.restrict = "0-9";
			numStep.textFiled.maxChars=3;
			numStep.maxnum = 50;
			numStep.minnum = 1;
			numStep.stepSize = 1;
			numStep.textFiled.textField.defaultTextFormat = new TextFormat("Tahoma",12,0xffffff);
			numStep.value = 1;
			numStep.width = 60;// 70;
			
			addChild(numStep);
			numStep.addEventListener(Event.CHANGE,onNumChange);
			numStep.addEventListener(KeyboardEvent.KEY_UP,onGetEnter);
			
			datetxt = ComponentUtil.createTextField("",48,62,txtformat,160,23,this);
			datetxt.textColor = 0xff0000;
			
			//			numStep.addEventListener(KeyboardEvent.KEY_UP,onGetEnter);
			
			
			buyButton = ComponentUtil.createButton("确认取出",64,80,88,22, this); //new Button();
			Style.setRedBtnStyle(buyButton);
			
			buyButton.addEventListener(MouseEvent.CLICK,onGetClick);
		}
		
		private function onGetClick(evt:MouseEvent):void
		{
			
			buyHandler();
		}
		
		private function buyHandler():void
		{
			if(num<1)
			{
				Alert.show("请输入取出的数量。","提示：",null,null,"确定","",null,false);
				return;
			}
			//to do 
			FamilyDepotModule.getInstance().getOut(id,num);
//			getGoods(bag_id,id,num);
			buyButton.enabled = false;
			var evt:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			this.dispatchEvent(evt);
		}
		
		private function onGetEnter(evt:KeyboardEvent):void
		{
			if(evt.keyCode == Keyboard.ENTER)
				buyHandler();
		}
		
		private function onNumChange(evt:Event):void
		{
			if(!numStep.value)//== NaN
			{
				numStep.value = 1;
				numStep.textFiled.setFocus();
				numStep.textFiled.validateNow();
				numStep.textFiled.textField.setSelection(0,1);
			}
			num = numStep.value;
			
		}
		
		public function setBaseItemVo(value:BaseItemVO):void  //商品的 Vo 赋值  Object
		{
			if(!value)
				return;
			
			bag_id = value.bagid;
			
			id = value.oid;
			_name = value.name;//item_n_name
			
			numStep.maxnum = value.num;
			numStep.value = value.num;
			num = numStep.value;
			
			
			var color:String = ItemConstant.COLOR_VALUES[value.color];
			var goodname:String = HtmlUtil.font(HtmlUtil.bold(value.name),color,15);
			
			setTitle(goodname);//, money);
			
			setImage(value);
		}
		
		public function get goodsNum():int
		{
			return num; //*packe_num
		}
		public function get goodsName():String
		{
			return _name;
		}
		
		private function setTitle(name:String):void //,value:String
		{
			_nameTf.htmlText =  name ;
			
		}
		
		private function setImage(vo:BaseItemVO):void   // obj.url = 图片路径
		{
			if(vo)
			{
				var obj:ShopItem = new ShopItem();
				obj.url = vo.path;
				tmp_goods.data = obj;
			}
		}
		
		
		override public function dispose():void
		{
			super.dispose();
			
			if(tmp_goods)
				tmp_goods.dispose();
			
			if(numStep&&numStep.hasEventListener(Event.CHANGE))
			{
				numStep.removeEventListener(Event.CHANGE,onNumChange);
				numStep.removeEventListener(KeyboardEvent.KEY_UP,onGetEnter);
				buyButton.removeEventListener(MouseEvent.CLICK,onGetClick);
			}
			
			while(numChildren>0)
			{
				var obj:DisplayObject = getChildAt(0) as DisplayObject;
				removeChild(obj);
				obj = null;
			}
		}
		
	}
}

