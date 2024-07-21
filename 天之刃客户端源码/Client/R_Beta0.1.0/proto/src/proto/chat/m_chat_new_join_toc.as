package proto.chat {
	import proto.common.p_chat_channel_role_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_new_join_toc extends Message
	{
		public var role_info:p_chat_channel_role_info = null;
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public function m_chat_new_join_toc() {
			super();
			this.role_info = new p_chat_channel_role_info;

			flash.net.registerClassAlias("copy.proto.chat.m_chat_new_join_toc", m_chat_new_join_toc);
		}
		public override function getMethodName():String {
			return 'chat_new_join';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_role_info:ByteArray = new ByteArray;
			this.role_info.writeToDataOutput(tmp_role_info);
			var size_tmp_role_info:int = tmp_role_info.length;
			output.writeInt(size_tmp_role_info);
			output.writeBytes(tmp_role_info);
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.channel_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_role_info_size:int = input.readInt();
			if (byte_role_info_size > 0) {				this.role_info = new p_chat_channel_role_info;
				var byte_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_info, 0, byte_role_info_size);
				this.role_info.readFromDataOutput(byte_role_info);
			}
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
		}
	}
}
