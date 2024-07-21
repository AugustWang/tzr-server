package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_buy_tos extends Message
	{
		public var goods_id:int = 0;
		public var price_id:int = 0;
		public var goods_num:int = 1;
		public var shop_id:int = 0;
		public function m_shop_buy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_buy_tos", m_shop_buy_tos);
		}
		public override function getMethodName():String {
			return 'shop_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.price_id);
			output.writeInt(this.goods_num);
			output.writeInt(this.shop_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.price_id = input.readInt();
			this.goods_num = input.readInt();
			this.shop_id = input.readInt();
		}
	}
}
