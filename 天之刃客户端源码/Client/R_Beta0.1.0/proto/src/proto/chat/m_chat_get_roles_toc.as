package proto.chat {
	import proto.common.p_chat_channel_role_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_get_roles_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public var roles:Array = new Array;
		public function m_chat_get_roles_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_get_roles_toc", m_chat_get_roles_toc);
		}
		public override function getMethodName():String {
			return 'chat_get_roles';
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
			output.writeInt(this.channel_type);
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				var t2_roles:ByteArray = new ByteArray;
				var tVo_roles:p_chat_channel_role_info = this.roles[i] as p_chat_channel_role_info;
				tVo_roles.writeToDataOutput(t2_roles);
				var len_tVo_roles:int = t2_roles.length;
				temp_repeated_byte_roles.writeInt(len_tVo_roles);
				temp_repeated_byte_roles.writeBytes(t2_roles);
			}
			output.writeInt(temp_repeated_byte_roles.length);
			output.writeBytes(temp_repeated_byte_roles);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			if (length_roles > 0) {
				var byte_roles:ByteArray = new ByteArray; 
				input.readBytes(byte_roles, 0, length_roles);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:p_chat_channel_role_info = new p_chat_channel_role_info;
					var tmp_roles_length:int = byte_roles.readInt();
					var tmp_roles_byte:ByteArray = new ByteArray;
					byte_roles.readBytes(tmp_roles_byte, 0, tmp_roles_length);
					tmp_roles.readFromDataOutput(tmp_roles_byte);
					this.roles.push(tmp_roles);
				}
			}
		}
	}
}
