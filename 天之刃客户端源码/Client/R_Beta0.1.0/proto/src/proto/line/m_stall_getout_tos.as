package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_getout_tos extends Message
	{
		public var goods_id:int = 0;
		public var bagid:int = 0;
		public var pos:int = 0;
		public function m_stall_getout_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_getout_tos", m_stall_getout_tos);
		}
		public override function getMethodName():String {
			return 'stall_getout';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.bagid);
			output.writeInt(this.pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.bagid = input.readInt();
			this.pos = input.readInt();
		}
	}
}
