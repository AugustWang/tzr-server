package modules.pet.view {


	import com.globals.GameConfig;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.skins.Skin;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.mypackage.views.GoodsItem;
	import modules.mypackage.vo.BaseItemVO;
	import modules.pet.PetModule;
	import modules.shop.ShopDataManager;
	import modules.shop.ShopItem;
	import modules.shop.ShopModule;
	import modules.vip.VipModule;

	public class GoodsListRender extends UIComponent {
		private var vo:BaseItemVO;
		private var img:GoodsItem;
		private var nameTxt:TextField;
		private var buyTxt:TextField;
		private var bg:Sprite;
		private var shopItem:ShopItem;//添加的---
		//商品描述。

		public function GoodsListRender():void {
//			this.mouseChildren=false;
			this.buttonMode=true;
			var tf:TextFormat=new TextFormat(null, 12, 0xffffff);
			nameTxt=new TextField();
			nameTxt.defaultTextFormat=tf;
			nameTxt.y=8;
			nameTxt.x=36;

			addChild(nameTxt);
			nameTxt.selectable=false;
			buyTxt=ComponentUtil.createTextField("购买", 110, 8, tf, 60, 22, this);
			buyTxt.selectable=false;
			buyTxt.htmlText="<a href=\"event:buy\"><font color='#00FF00'><u>购买</u></font></a>";
			buyTxt.addEventListener(TextEvent.LINK, toBuy);
			buyTxt.mouseEnabled=true;

			bg=Style.getSpriteBitmap(GameConfig.T1_VIEWUI,"packItemBg");
			addChild(bg);
			bg.width=35;
			bg.height=35;

			
			var skin:Skin=StyleManager.listItemSkin;
			if (skin) {
				bgSkin=skin;
			}



			addEventListener(Event.ADDED, onAdded);

			var line:Bitmap=Style.getBitmap(GameConfig.T1_VIEWUI,"hightLightLine");
			line.y=36;
			line.width=146;
			addChild(line);
			

		}
		private function wrapperHandler(text:TextField):void
		{
			text.wordWrap = true;
		}

		private function onAdded(event:Event):void {
			width=146;
			height=36;
		}

		public override function set data(value:Object):void {
			super.data=value;
			vo=value as BaseItemVO;
            
			if (vo != null) {
				if (img == null) {
					img=new GoodsItem(vo);
					img.x=img.y=4;
					bg.addChild(img);
					img.mouseEnabled = true;
					////获取商品项
					img.addEventListener(MouseEvent.ROLL_OVER,openGoodDesc);
					img.addEventListener(MouseEvent.ROLL_OUT,closeGoodDesc);
				} else {
					img.updateContent(vo);
				}
				nameTxt.text=vo.name;
				if (vo.num > 0) {
					img.filters=null;
					buyTxt.visible=false;
				} else {
					img.filters=[PetModule.filter];
					buyTxt.visible=true;
				}
			}
			
			
			
		}
		private function openGoodDesc(evt:MouseEvent):void
		{
		   GoodsListTip.getInstance().point(this.stage.mouseX,this.stage.mouseY,this);
			//var item:ShopItem=getShopItem(vo);
			GoodsListTip.getInstance().show(vo);
			//var htmlText:String=wrapperHTML(vo);
			//ToolTipManager.getInstance().show(htmlText,300);//添加了鼠标坐标
		

		}	
		private function closeGoodDesc(evt:MouseEvent):void
		{
			GoodsListTip.getInstance().hide();
			//ToolTipManager.getInstance().hide();

		}
        /*private function getShopItem(vob:BaseItemVO):ShopItem{
			var item:ShopItem=ShopModule.getInstance().getShopItem(10103,vob.typeId);
			return item;
		}*/
		private function toBuy(e:Event=null):void {
			if (vo != null) {
				ShopModule.getInstance().requestShopItem(10103, vo.typeId, new Point(stage.mouseX-178, stage.mouseY-90));
			}
		}
		private function wrapperHTML(vo:BaseItemVO):String
		{
            var item:ShopItem=ShopDataManager.getInstance().getItem(vo.typeId,10103);
			var color:String=ItemConstant.COLOR_VALUES[vo.color];
			var htmlText:String=getName(vo.name,color);
			var len:int=vo.desc.length;
			var i:int=0;
			var desc:String=vo.desc.split("\\n").join("\n");//5/17添加的语句
			
			/*
			while(len>12&&desc.length<len)
			{
				//desc+=vo.desc.substr(i*12,12)+"\n";//去掉\n
				desc+=vo.desc.substr(i*12,12);
				i++;
			}*/
			desc+="\n";
			htmlText+=getDesc(desc,color);
		     if(item!=null)
			{	
				 if(VipModule.getInstance().isVip() && item.priceVip && item.discountType !=0){
					 htmlText += getPrice(item.priceVip);
				 }else if(item.price){
					 htmlText += getPrice(item.price);
				 }
				htmlText+=item.sellTime;
			}
			
			return htmlText;
		}
		private function getName(name:String,color:String):String
		{
			return HtmlUtil.fontBr(HtmlUtil.bold(name), color, 14);
			
		}
		private function getDesc(desc:String,color:String):String
		{
			return HtmlUtil.font(desc,color,12);
		}
		private function getPrice(price:String):String
		{
			var price_str:String = HtmlUtil.font("单价：",'#0099ff');
			
			price_str += HtmlUtil.font(price,"#0099ff");
			
			price_str += "\n";
			return price_str;
		}

	}
}
