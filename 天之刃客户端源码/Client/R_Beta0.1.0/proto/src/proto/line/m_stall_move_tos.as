package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_move_tos extends Message
	{
		public var goodsid:int = 0;
		public var pos:int = 0;
		public function m_stall_move_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_move_tos", m_stall_move_tos);
		}
		public override function getMethodName():String {
			return 'stall_move';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goodsid);
			output.writeInt(this.pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goodsid = input.readInt();
			this.pos = input.readInt();
		}
	}
}
