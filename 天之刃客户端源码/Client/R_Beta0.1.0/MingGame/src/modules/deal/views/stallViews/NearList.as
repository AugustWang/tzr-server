package modules.deal.views.stallViews
{
	import com.ming.events.ItemEvent;
	import com.ming.ui.containers.List;
	
	import modules.deal.DealModule;
	
	import proto.line.p_stall_info;
	
	public class NearList extends List
	{
		public function NearList()
		{
			super();
			this.width = 460;
			this.height = 234;
			this.itemHeight = 32;
			this.itemRenderer = S;
			
			this.addEventListener(ItemEvent.ITEM_CLICK, onFindWay);
		}
		
		public function initData(array:Array):void
		{
			if(array)
				this.dataProvider = array;
			
		}
			
		
		private function onFindWay(evt:ItemEvent):void
		{
			// to do 通知寻路 走到该摊位前！
			var s:S = evt.target as S;
			
			var stallInfo:p_stall_info = s.data as p_stall_info;
			if(!stallInfo)
				return;
			DealModule.getInstance().walkToStall(stallInfo);
			
			goto(stallInfo.tx ,stallInfo.ty);
		}
		private function goto(sx:Number,sy:Number):void
		{
			//  trace(sx,"  x and y   ",sy);
		}
		
	}
}

	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.text.TextField;
	import flash.text.TextFormat;

class S extends UIComponent implements IDataRenderer{
	
	private var goodsName:TextField ;
	private var num:TextField;
	private var price:TextField;
	private var stallName:TextField;
	private var stallOwner:TextField;
	
	private var textformat:TextFormat = new TextFormat("Tahoma",14,0xffffff,null,null,null,null,null,"center");
	
	public function S():void
	{
		
		this.mouseChildren = false;
		init();
	}
	
	private function init():void
	{
		goodsName = ComponentUtil.createTextField("",5,5,textformat,126,25,this); // new TextField();
		
		num = ComponentUtil.createTextField("",131,5,textformat,46,25,this); // new TextField();
		
		
		//		price = new TextField();
		//		price.x = 192;
		//		price.width = 91;
		//		price.height = 25;
		//		
		//		price.defaultTextFormat = textformat;
		//		addChild(price);
		
		stallName = ComponentUtil.createTextField("",192,5,textformat,112,25,this); //new TextField();
		
		
		stallOwner = ComponentUtil.createTextField("",328,5,textformat,112,25,this); //new TextField();
		
	}
	
	override public function set data(value:Object):void
	{
		super.data = value;
		goodsName.text = data.goods_name;
		num.text = String(data.goods_num);
//		price.text = String(data.price)+ ShopConstant.getMoneyType(data.type);
		
		stallName.text = data.stall_name;
		stallOwner.text = data.owner;
		
	}
	
}