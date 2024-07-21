package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_remove_black_tos extends Message
	{
		public var rolename:String = "";
		public function m_chat_remove_black_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_remove_black_tos", m_chat_remove_black_tos);
		}
		public override function getMethodName():String {
			return 'chat_remove_black';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.rolename != null) {				output.writeUTF(this.rolename.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rolename = input.readUTF();
		}
	}
}
