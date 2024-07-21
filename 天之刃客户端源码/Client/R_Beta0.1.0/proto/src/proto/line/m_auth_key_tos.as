package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_auth_key_tos extends Message
	{
		public var account_name:String = "";
		public var role_id:int = 0;
		public var key:String = "";
		public var time:int = 0;
		public function m_auth_key_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_auth_key_tos", m_auth_key_tos);
		}
		public override function getMethodName():String {
			return 'auth_key';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.account_name != null) {				output.writeUTF(this.account_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.key != null) {				output.writeUTF(this.key.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.account_name = input.readUTF();
			this.role_id = input.readInt();
			this.key = input.readUTF();
			this.time = input.readInt();
		}
	}
}
