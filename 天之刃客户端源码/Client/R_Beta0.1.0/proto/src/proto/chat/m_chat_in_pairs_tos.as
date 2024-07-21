package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_in_pairs_tos extends Message
	{
		public var msg:String = "";
		public var to_rolename:String = "";
		public var show_type:int = 1;
		public function m_chat_in_pairs_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_in_pairs_tos", m_chat_in_pairs_tos);
		}
		public override function getMethodName():String {
			return 'chat_in_pairs';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			if (this.to_rolename != null) {				output.writeUTF(this.to_rolename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.show_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.msg = input.readUTF();
			this.to_rolename = input.readUTF();
			this.show_type = input.readInt();
		}
	}
}
