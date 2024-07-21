package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_auth_tos extends Message
	{
		public var account:String = "";
		public var roleid:int = 0;
		public var key:String = "";
		public var timestamp:int = 0;
		public function m_chat_auth_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_auth_tos", m_chat_auth_tos);
		}
		public override function getMethodName():String {
			return 'chat_auth';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.account != null) {				output.writeUTF(this.account.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.roleid);
			if (this.key != null) {				output.writeUTF(this.key.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.timestamp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.account = input.readUTF();
			this.roleid = input.readInt();
			this.key = input.readUTF();
			this.timestamp = input.readInt();
		}
	}
}
