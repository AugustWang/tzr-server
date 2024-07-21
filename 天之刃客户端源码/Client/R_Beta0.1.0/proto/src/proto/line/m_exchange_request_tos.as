package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_request_tos extends Message
	{
		public var target_roleid:int = 0;
		public function m_exchange_request_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_request_tos", m_exchange_request_tos);
		}
		public override function getMethodName():String {
			return 'exchange_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.target_roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.target_roleid = input.readInt();
		}
	}
}
