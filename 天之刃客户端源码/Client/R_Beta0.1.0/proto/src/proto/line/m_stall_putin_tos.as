package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_putin_tos extends Message
	{
		public var goods_id:int = 0;
		public var price:int = 0;
		public var pos:int = 0;
		public var price_type:int = 0;
		public function m_stall_putin_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_putin_tos", m_stall_putin_tos);
		}
		public override function getMethodName():String {
			return 'stall_putin';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.price);
			output.writeInt(this.pos);
			output.writeInt(this.price_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.price = input.readInt();
			this.pos = input.readInt();
			this.price_type = input.readInt();
		}
	}
}
