package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_buy_back_tos extends Message
	{
		public var op_type:int = 0;
		public var goods_id:int = 0;
		public function m_shop_buy_back_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_buy_back_tos", m_shop_buy_back_tos);
		}
		public override function getMethodName():String {
			return 'shop_buy_back';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.goods_id = input.readInt();
		}
	}
}
