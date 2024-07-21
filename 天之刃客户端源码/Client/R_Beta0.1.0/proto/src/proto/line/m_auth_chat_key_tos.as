package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_auth_chat_key_tos extends Message
	{
		public var times:int = 1;
		public function m_auth_chat_key_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_auth_chat_key_tos", m_auth_chat_key_tos);
		}
		public override function getMethodName():String {
			return 'auth_chat_key';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.times = input.readInt();
		}
	}
}
