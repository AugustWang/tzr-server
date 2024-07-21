package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_cancel_tos extends Message
	{
		public var src_roleid:int = 0;
		public var cancel_type:int = 0;
		public function m_exchange_cancel_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_cancel_tos", m_exchange_cancel_tos);
		}
		public override function getMethodName():String {
			return 'exchange_cancel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.src_roleid);
			output.writeInt(this.cancel_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.src_roleid = input.readInt();
			this.cancel_type = input.readInt();
		}
	}
}
