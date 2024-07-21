package proto.chat {
	import proto.common.p_channel_info;
	import proto.common.p_chat_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_join_channel_toc extends Message
	{
		public var channel_info:p_channel_info = null;
		public var role_info:p_chat_role = null;
		public function m_chat_join_channel_toc() {
			super();
			this.channel_info = new p_channel_info;
			this.role_info = new p_chat_role;

			flash.net.registerClassAlias("copy.proto.chat.m_chat_join_channel_toc", m_chat_join_channel_toc);
		}
		public override function getMethodName():String {
			return 'chat_join_channel';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_channel_info:ByteArray = new ByteArray;
			this.channel_info.writeToDataOutput(tmp_channel_info);
			var size_tmp_channel_info:int = tmp_channel_info.length;
			output.writeInt(size_tmp_channel_info);
			output.writeBytes(tmp_channel_info);
			var tmp_role_info:ByteArray = new ByteArray;
			this.role_info.writeToDataOutput(tmp_role_info);
			var size_tmp_role_info:int = tmp_role_info.length;
			output.writeInt(size_tmp_role_info);
			output.writeBytes(tmp_role_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_channel_info_size:int = input.readInt();
			if (byte_channel_info_size > 0) {				this.channel_info = new p_channel_info;
				var byte_channel_info:ByteArray = new ByteArray;
				input.readBytes(byte_channel_info, 0, byte_channel_info_size);
				this.channel_info.readFromDataOutput(byte_channel_info);
			}
			var byte_role_info_size:int = input.readInt();
			if (byte_role_info_size > 0) {				this.role_info = new p_chat_role;
				var byte_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_info, 0, byte_role_info_size);
				this.role_info.readFromDataOutput(byte_role_info);
			}
		}
	}
}
