package modules.trading.views.item
{
	import com.globals.GameConfig;
	import com.ming.ui.controls.Image;
	import com.ming.ui.controls.core.UIComponent;
	import com.ming.ui.style.StyleManager;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.mypackage.ItemConstant;
	import modules.trading.views.TradingGoodsToolTip;
	import modules.trading.vo.TradingGoodVo;
	
	public class TradingItem extends UIComponent
	{
		private var _data:Object;
		private var img:Image;
		private var numTxt:TextField;
		private var num:int;
		public var is_role_item:Boolean;
		
		public function TradingItem()
		{
			super();
			this.height = this.width = 36;
			var itemBg:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"packItemBg");;
			//			itemBg.x = itemBg.y = 2.3;
			addChild(itemBg);
			
			
		}
		
		public function toolTipOff():void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER,ontipHandler);
			this.removeEventListener(MouseEvent.ROLL_OUT,offtipHandler);
		}
		
		private function ontipHandler(evt:MouseEvent):void
		{
//			if(data)
//				ToolTipManager.getInstance().show(wrapperHTML(data as TradingGoodVo) + data.sell_time,100,0,0,"goodsToolTip");
			TradingGoodsToolTip.getInstance().point(this.stage.mouseX,this.stage.mouseY,this);
			
			TradingGoodsToolTip.getInstance().show(data as TradingGoodVo);
		}
		private function offtipHandler(evt:MouseEvent):void
		{
			TradingGoodsToolTip.getInstance().hide();
			//			ShopToolTip.hide();
		}
		
		override public function set data(value:Object):void{
			this._data = value;
			if(value && value.url != ""){
				createContent();
				if(!this.hasEventListener(MouseEvent.ROLL_OVER))
				{
					this.addEventListener(MouseEvent.ROLL_OVER,ontipHandler);
					this.addEventListener(MouseEvent.ROLL_OUT,offtipHandler);
				}
			}
			
		}
		override public function get data():Object
		{
			return _data;
		}
		
		public function updateContent(itemVO:TradingGoodVo):void{
			if(itemVO == null){
				disposeContent();
				return;
			}
		}
		private function disposeContent():void
		{
			TradingGoodsToolTip.getInstance().hide();
			if(this.hasEventListener(MouseEvent.ROLL_OVER))
			{
				this.removeEventListener(MouseEvent.ROLL_OVER,ontipHandler);
				this.removeEventListener(MouseEvent.ROLL_OUT,offtipHandler);
			}
			if(img!=null)
			{
				img.removeEventListener(Event.COMPLETE,onLoadComplete);
				img.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				
				removeChild(img);
				img = null;
				
				if(is_role_item)
				{
					if(numTxt!=null)
					{
						num = 0;
						numTxt.text = "";
						removeChild(numTxt);
						numTxt = null;
					}
				}
			}
			buttonMode = useHandCursor = false;
		}
		
		private function createContent():void{
			if(!data)
				return;
			if(img!=null)
			{
				img.removeEventListener(Event.COMPLETE,onLoadComplete);
				img.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
				
				removeChild(img);
				img = null;
			}
			img = new Image();
			img.source = data.url;
			img.addEventListener(Event.COMPLETE,onLoadComplete);
			img.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			img.x = img.y = 2;//11.8;
			addChild(img);
			
			//
			
			//
			if(numTxt!=null)
			{
				numTxt.text = "";
				removeChild(numTxt);
				numTxt = null;
			}
			if(is_role_item)
			{
				num = data.num;
				if(!numTxt && num>1)
				{
					var tf:TextFormat = StyleManager.textFormat;
					tf.size = 11;
					numTxt= ComponentUtil.createTextField(num+"",0,18,tf,33,NaN,this);
					numTxt.filters = [new GlowFilter(0x000000,1,2,2,4,1,false,false)];
					numTxt.selectable = false;		
					numTxt.autoSize = "right";	
				}
			}
		}
		
		private function onLoadComplete(event:Event):void{
			if(img)
			{
				img.x = img.y = 2;//11.8;
				img.removeEventListener(Event.COMPLETE,onLoadComplete);
				img.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
//				addChild(img);
			}
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void{
			if(img)
			{
				img.removeEventListener(Event.COMPLETE,onLoadComplete);
				img.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			}
		}
		
		
		
		//////////////////////////////////////////////////////////////////		
		private function wrapperHTML(vo:TradingGoodVo):String
		{
			var color:String = ItemConstant.COLOR_VALUES[vo.color];
			var htmlText:String = getName(vo.name,color);
			htmlText += "\n";
				
			var desc:String = vo.desc.split("\\n").join("\n");
			htmlText += wapper("",desc,color,color);//描述
			
			return htmlText;
			
			
		}
		
		//		private function getPrice(price:String):String // 单价。。。 用‘文’为单位　再来转成　锭　两　文
		//		{
		//			var price_str:String = HtmlUtil.font("单价：",'#0099ff');
		//			
		//			price_str += HtmlUtil.font(price,"#0099ff");
		//			
		//			price_str += "\n";
		//			return price_str;
		//			
		//		}
		
		
		private function getName(name:String,color:String):String
		{	
			return HtmlUtil.font(HtmlUtil.bold(name),color,15);
		}
		
		private function getBindable(bind:Boolean):String
		{
			if (bind)
				return HtmlUtil.fontBr("绑定","#2e6723");
			return "";
		}
		
		
		
		private function wapper(name:String,data:String,nameColor:String="#ffffff",textColor:String="#ffffff"):String{
			var str:String = data; //.toString();
			var str1:String;
			var str2:String;
			return HtmlUtil.font(name,nameColor)+HtmlUtil.fontBr(""+ str ,textColor);
		}
		
		
		
		
		
		override public function dispose():void
		{
			if(this.hasEventListener(MouseEvent.ROLL_OVER))
			{
				toolTipOff();
			}
			
			if(img!=null)
			{
				removeChild(img);
				//				img.dispose();
				img = null;
			}
			while(numChildren>0)
			{
				var displayobj:DisplayObject = getChildAt(0);
				removeChild(displayobj);
				displayobj = null;
			}
		}
		
	}
}

