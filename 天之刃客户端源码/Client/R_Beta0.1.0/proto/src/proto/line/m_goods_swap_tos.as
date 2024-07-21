package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goods_swap_tos extends Message
	{
		public var id1:int = 0;
		public var position2:int = 0;
		public var bagid2:int = 0;
		public function m_goods_swap_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goods_swap_tos", m_goods_swap_tos);
		}
		public override function getMethodName():String {
			return 'goods_swap';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id1);
			output.writeInt(this.position2);
			output.writeInt(this.bagid2);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id1 = input.readInt();
			this.position2 = input.readInt();
			this.bagid2 = input.readInt();
		}
	}
}
