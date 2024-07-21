package proto.login {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_login_flash_tos extends Message
	{
		public var account:String = "";
		public var tstamp:int = 0;
		public var agent_id:int = 0;
		public var server_id:int = 0;
		public var fcm:int = 0;
		public var ticket:String = "";
		public function m_login_flash_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.login.m_login_flash_tos", m_login_flash_tos);
		}
		public override function getMethodName():String {
			return 'login_flash';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.account != null) {				output.writeUTF(this.account.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.tstamp);
			output.writeInt(this.agent_id);
			output.writeInt(this.server_id);
			output.writeInt(this.fcm);
			if (this.ticket != null) {				output.writeUTF(this.ticket.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.account = input.readUTF();
			this.tstamp = input.readInt();
			this.agent_id = input.readInt();
			this.server_id = input.readInt();
			this.fcm = input.readInt();
			this.ticket = input.readUTF();
		}
	}
}
