package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_get_roles_tos extends Message
	{
		public var channel_sign:String = "";
		public function m_chat_get_roles_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_get_roles_tos", m_chat_get_roles_tos);
		}
		public override function getMethodName():String {
			return 'chat_get_roles';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
		}
	}
}
