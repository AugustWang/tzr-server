package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_reconnect_tos extends Message
	{
		public function m_chat_reconnect_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_reconnect_tos", m_chat_reconnect_tos);
		}
		public override function getMethodName():String {
			return 'chat_reconnect';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
