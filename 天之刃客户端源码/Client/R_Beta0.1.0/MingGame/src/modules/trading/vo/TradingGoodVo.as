package modules.trading.vo
{
	public class TradingGoodVo
	{
		/*
		required int32 type_id = 1;//商品类型id
		required int32 order_index = 2;//商品显示顺序
		required string name = 3;//商品名称
		required int32 price = 4;//商品当前价格
		required int32 number = 5;//商品数量
		*/
		public var type_id:int;
		public var order_index:int;
		public var name:String ;
		public var buy_price:int; //买入价格　　之前买进时该物品的价格。
		public var sale_price:int; //卖出价格   即现在这物品在商店里的价格。
		public var num:int;        //商品数量
		
		public var url:String;     //商品图片 url
		public var desc:String;    //描述
		public var color:String =  "#ffffff";
		public var npcId:int ;
		public var showType:int;//显示类型，1用户已经刚买的物品，2商店的物品
		
		public function TradingGoodVo()
		{
		}
		
		
	}
}

