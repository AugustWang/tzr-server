package modules.bank.views
{
	import com.components.HeaderBar;
	import com.globals.GameConfig;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.GraphicsUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.bank.BankConstant;
	
	public class BankList extends Canvas
	{
		private var _listType:String;
		public function BankList(listType:String="PERSON")
		{
//			this.verticalScrollPolicy = ScrollPolicy.OFF;
			_listType = listType;
		}
		
		private var _listHeader:ListHeader;
		private var _listHead:HeaderBar;
		private var _bankList:List;
		private var _showListHeader:Boolean;
		
		
		
		public function setupUI():void
		{
			var buySaleui:UIComponent;
			
			if(_listType == BankConstant.MARKET)
			{
				buySaleui = ComponentUtil.createUIComponent(0,2,254,22);
				buySaleui.bgSkin = Style.getSkin("titleBar",GameConfig.T1_VIEWUI,new Rectangle(10,4,333,15));
				addChild(buySaleui);
				
				marketHead(showListHeader);
				
			}else{
			
				if(showListHeader)
				{
					var i:int;
					_listHead = new HeaderBar();
					_listHead.textFormat = new TextFormat("Tahoma",12,0xafe0ee);//0xb0e0ec
					_listHead.y = 2;
					_listHead.width = 264;
					for(i=0;i<BankConstant.selfNameArr.length;i++)
					{
						_listHead.addColumn(BankConstant.selfNameArr[i],62);
					}
					_listHead.validateNow();
				}
			}
			
			_bankList = new List();
			_bankList.verticalScrollPolicy = ScrollPolicy.OFF;
			_bankList.bgSkin = null;
			_bankList.itemRenderer = itemRender;
			_bankList.itemHeight = itemHeight;
			_bankList.width = listWidth;
			_bankList.height = listHeight;
			_bankList.x = 1;
			if(_listHead)
			{
				_bankList.y = _listHead.y + _listHead.height;
				addChild(_listHead);
			}
			if(buySaleui)
			{
				_bankList.y = buySaleui.y + buySaleui.height + 18;// 23;
//				addChild(_listHead);
			}
			
			addChild(_bankList);
		}
		
		private function marketHead(flag:Boolean):void
		{
			var text:TextField = ComponentUtil.createTextField("",100,3,Style.themeTextFormat,58,20,this);
			if(flag)
			{
				text.text = "买入元宝";
			}else{
				text.text = "元宝卖出";
			}
			var headuiBg:Sprite = new Sprite();
			GraphicsUtil.drawRoundRect(headuiBg.graphics,2,0,250,18,1,0x105e8d,3,3);
			headuiBg.x = 0;
			headuiBg.y = 24;
			addChild(headuiBg);
			
			var tf:TextFormat = new TextFormat("Tahoma",12,0xB3D5E6);
			
			var price:TextField = ComponentUtil.createTextField("价格",33,-1,tf,34,20,headuiBg);
			var num:TextField = ComponentUtil.createTextField("数量",117,-1,tf,34,20,headuiBg);
			var operate:TextField = ComponentUtil.createTextField("操作",196,-1,tf,34,20,headuiBg);
			
			createLine(88,headuiBg);
			createLine(175,headuiBg);
			
		}
		private function createLine(x:int,parent:Sprite = null):Bitmap{
			var line:Bitmap = Style.getBitmap(GameConfig.T1_VIEWUI,"vline");
			line.x = x;
			if(parent)
				parent.addChild(line);
			else
				addChild(line);
			return line;
		}
		
		
		public function get list():List
		{
			if(_bankList)
				return _bankList;
			return null;
		}
		
		public function set showListHeader(value:Boolean):void
		{
			_showListHeader = value;
		}
		
		public function get showListHeader():Boolean
		{
			return _showListHeader;
		}
		
		private var _listWidth:Number;
		public function set listWidth(value:Number):void
		{
			_listWidth = value;	
		}
		
		public function get listWidth():Number
		{
			if(_listWidth)
				return _listWidth;
			return -1;
		}
		
		private var _listHeight:Number;
		public function set listHeight(value:Number):void
		{
			_listHeight = value;
		}
		
		public function get listHeight():Number
		{
			if(_listHeight)
				return _listHeight;
			return -1;
		}
		
		private var _itemRender:Class
		public function set itemRender(value:Class):void
		{
			_itemRender = value;
		}
		
		public function get itemRender():Class
		{
			if(_itemRender)
				return _itemRender;
			return null;
		}
		
		private var _itemHeight:Number
		public function set itemHeight(value:Number):void
		{
			_itemHeight = value;
		}
		
		public function get itemHeight():Number
		{
			if(_itemHeight)
				return _itemHeight;
			return -1;
		}
	}
}