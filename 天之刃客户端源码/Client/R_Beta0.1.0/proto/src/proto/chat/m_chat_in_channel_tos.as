package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_in_channel_tos extends Message
	{
		public var channel_sign:String = "";
		public var msg:String = "";
		public function m_chat_in_channel_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_in_channel_tos", m_chat_in_channel_tos);
		}
		public override function getMethodName():String {
			return 'chat_in_channel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
			this.msg = input.readUTF();
		}
	}
}
