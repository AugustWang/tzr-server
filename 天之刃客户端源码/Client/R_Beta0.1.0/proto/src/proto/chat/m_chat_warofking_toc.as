package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_warofking_toc extends Message
	{
		public var family_name:String = "";
		public var role_name:String = "";
		public function m_chat_warofking_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_warofking_toc", m_chat_warofking_toc);
		}
		public override function getMethodName():String {
			return 'chat_warofking';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.family_name = input.readUTF();
			this.role_name = input.readUTF();
		}
	}
}
