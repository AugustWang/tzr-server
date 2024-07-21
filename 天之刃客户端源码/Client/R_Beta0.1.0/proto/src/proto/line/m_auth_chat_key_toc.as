package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_auth_chat_key_toc extends Message
	{
		public var succ:Boolean = true;
		public var times:int = 0;
		public var reason:String = "";
		public var account:String = "";
		public var roleid:int = 0;
		public var timestamp:int = 0;
		public var key:String = "";
		public function m_auth_chat_key_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_auth_chat_key_toc", m_auth_chat_key_toc);
		}
		public override function getMethodName():String {
			return 'auth_chat_key';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.times);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.account != null) {				output.writeUTF(this.account.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.roleid);
			output.writeInt(this.timestamp);
			if (this.key != null) {				output.writeUTF(this.key.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.times = input.readInt();
			this.reason = input.readUTF();
			this.account = input.readUTF();
			this.roleid = input.readInt();
			this.timestamp = input.readInt();
			this.key = input.readUTF();
		}
	}
}
