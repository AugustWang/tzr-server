package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_quick_toc extends Message
	{
		public var role_id:int = 0;
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public function m_chat_quick_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_quick_toc", m_chat_quick_toc);
		}
		public override function getMethodName():String {
			return 'chat_quick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.channel_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
		}
	}
}
