package proto.chat {
	import proto.common.p_chat_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_in_channel_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var channel_sign:String = "";
		public var msg:String = "";
		public var role_info:p_chat_role = null;
		public var tstamp:int = 0;
		public function m_chat_in_channel_toc() {
			super();
			this.role_info = new p_chat_role;

			flash.net.registerClassAlias("copy.proto.chat.m_chat_in_channel_toc", m_chat_in_channel_toc);
		}
		public override function getMethodName():String {
			return 'chat_in_channel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_role_info:ByteArray = new ByteArray;
			this.role_info.writeToDataOutput(tmp_role_info);
			var size_tmp_role_info:int = tmp_role_info.length;
			output.writeInt(size_tmp_role_info);
			output.writeBytes(tmp_role_info);
			output.writeInt(this.tstamp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.channel_sign = input.readUTF();
			this.msg = input.readUTF();
			var byte_role_info_size:int = input.readInt();
			if (byte_role_info_size > 0) {				this.role_info = new p_chat_role;
				var byte_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_info, 0, byte_role_info_size);
				this.role_info.readFromDataOutput(byte_role_info);
			}
			this.tstamp = input.readInt();
		}
	}
}
