package proto.chat {
	import proto.common.p_chat_role;
	import proto.common.p_chat_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_in_pairs_toc extends Message
	{
		public var succ:Boolean = true;
		public var show_type:int = 1;
		public var reason:String = "";
		public var msg:String = "";
		public var from_role_info:p_chat_role = null;
		public var to_role_info:p_chat_role = null;
		public var tstamp:int = 0;
		public var error_code:int = 0;
		public var to_role_id:int = 0;
		public function m_chat_in_pairs_toc() {
			super();
			this.from_role_info = new p_chat_role;
			this.to_role_info = new p_chat_role;

			flash.net.registerClassAlias("copy.proto.chat.m_chat_in_pairs_toc", m_chat_in_pairs_toc);
		}
		public override function getMethodName():String {
			return 'chat_in_pairs';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.show_type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_from_role_info:ByteArray = new ByteArray;
			this.from_role_info.writeToDataOutput(tmp_from_role_info);
			var size_tmp_from_role_info:int = tmp_from_role_info.length;
			output.writeInt(size_tmp_from_role_info);
			output.writeBytes(tmp_from_role_info);
			var tmp_to_role_info:ByteArray = new ByteArray;
			this.to_role_info.writeToDataOutput(tmp_to_role_info);
			var size_tmp_to_role_info:int = tmp_to_role_info.length;
			output.writeInt(size_tmp_to_role_info);
			output.writeBytes(tmp_to_role_info);
			output.writeInt(this.tstamp);
			output.writeInt(this.error_code);
			output.writeInt(this.to_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.show_type = input.readInt();
			this.reason = input.readUTF();
			this.msg = input.readUTF();
			var byte_from_role_info_size:int = input.readInt();
			if (byte_from_role_info_size > 0) {				this.from_role_info = new p_chat_role;
				var byte_from_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_from_role_info, 0, byte_from_role_info_size);
				this.from_role_info.readFromDataOutput(byte_from_role_info);
			}
			var byte_to_role_info_size:int = input.readInt();
			if (byte_to_role_info_size > 0) {				this.to_role_info = new p_chat_role;
				var byte_to_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_to_role_info, 0, byte_to_role_info_size);
				this.to_role_info.readFromDataOutput(byte_to_role_info);
			}
			this.tstamp = input.readInt();
			this.error_code = input.readInt();
			this.to_role_id = input.readInt();
		}
	}
}
