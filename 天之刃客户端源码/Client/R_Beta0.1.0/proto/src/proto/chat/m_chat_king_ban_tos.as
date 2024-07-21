package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_king_ban_tos extends Message
	{
		public var roleid:int = 0;
		public var rolename:String = "";
		public var total_times:int = 0;
		public function m_chat_king_ban_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_king_ban_tos", m_chat_king_ban_tos);
		}
		public override function getMethodName():String {
			return 'chat_king_ban';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.roleid);
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.total_times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.roleid = input.readInt();
			this.rolename = input.readUTF();
			this.total_times = input.readInt();
		}
	}
}
