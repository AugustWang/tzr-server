package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_leave_channel_toc extends Message
	{
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public function m_chat_leave_channel_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_leave_channel_toc", m_chat_leave_channel_toc);
		}
		public override function getMethodName():String {
			return 'chat_leave_channel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.channel_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
		}
	}
}
