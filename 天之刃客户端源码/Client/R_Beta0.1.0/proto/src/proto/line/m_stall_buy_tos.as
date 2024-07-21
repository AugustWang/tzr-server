package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_buy_tos extends Message
	{
		public var role_id:int = 0;
		public var goods_id:int = 0;
		public var number:int = 0;
		public var goods_price:int = 0;
		public var buy_from:int = 0;
		public function m_stall_buy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_buy_tos", m_stall_buy_tos);
		}
		public override function getMethodName():String {
			return 'stall_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.goods_id);
			output.writeInt(this.number);
			output.writeInt(this.goods_price);
			output.writeInt(this.buy_from);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.goods_id = input.readInt();
			this.number = input.readInt();
			this.goods_price = input.readInt();
			this.buy_from = input.readInt();
		}
	}
}
