package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_level_gift_accept_tos extends Message
	{
		public var id:int = 0;
		public function m_level_gift_accept_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_level_gift_accept_tos", m_level_gift_accept_tos);
		}
		public override function getMethodName():String {
			return 'level_gift_accept';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
		}
	}
}
