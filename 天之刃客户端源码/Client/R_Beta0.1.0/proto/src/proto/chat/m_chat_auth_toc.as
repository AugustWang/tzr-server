package proto.chat {
	import proto.common.p_channel_info;
	import proto.common.p_chat_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_auth_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var channel_list:Array = new Array;
		public var black_list:Array = new Array;
		public var gm_auth:Array = new Array;
		public function m_chat_auth_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_auth_toc", m_chat_auth_toc);
		}
		public override function getMethodName():String {
			return 'chat_auth';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_channel_list:int = this.channel_list.length;
			output.writeShort(size_channel_list);
			var temp_repeated_byte_channel_list:ByteArray= new ByteArray;
			for(i=0; i<size_channel_list; i++) {
				var t2_channel_list:ByteArray = new ByteArray;
				var tVo_channel_list:p_channel_info = this.channel_list[i] as p_channel_info;
				tVo_channel_list.writeToDataOutput(t2_channel_list);
				var len_tVo_channel_list:int = t2_channel_list.length;
				temp_repeated_byte_channel_list.writeInt(len_tVo_channel_list);
				temp_repeated_byte_channel_list.writeBytes(t2_channel_list);
			}
			output.writeInt(temp_repeated_byte_channel_list.length);
			output.writeBytes(temp_repeated_byte_channel_list);
			var size_black_list:int = this.black_list.length;
			output.writeShort(size_black_list);
			var temp_repeated_byte_black_list:ByteArray= new ByteArray;
			for(i=0; i<size_black_list; i++) {
				var t2_black_list:ByteArray = new ByteArray;
				var tVo_black_list:p_chat_role = this.black_list[i] as p_chat_role;
				tVo_black_list.writeToDataOutput(t2_black_list);
				var len_tVo_black_list:int = t2_black_list.length;
				temp_repeated_byte_black_list.writeInt(len_tVo_black_list);
				temp_repeated_byte_black_list.writeBytes(t2_black_list);
			}
			output.writeInt(temp_repeated_byte_black_list.length);
			output.writeBytes(temp_repeated_byte_black_list);
			var size_gm_auth:int = this.gm_auth.length;
			output.writeShort(size_gm_auth);
			var temp_repeated_byte_gm_auth:ByteArray= new ByteArray;
			for(i=0; i<size_gm_auth; i++) {
				if (this.gm_auth != null) {					temp_repeated_byte_gm_auth.writeUTF(this.gm_auth[i].toString());
				} else {
					temp_repeated_byte_gm_auth.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_gm_auth.length);
			output.writeBytes(temp_repeated_byte_gm_auth);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_channel_list:int = input.readShort();
			var length_channel_list:int = input.readInt();
			if (length_channel_list > 0) {
				var byte_channel_list:ByteArray = new ByteArray; 
				input.readBytes(byte_channel_list, 0, length_channel_list);
				for(i=0; i<size_channel_list; i++) {
					var tmp_channel_list:p_channel_info = new p_channel_info;
					var tmp_channel_list_length:int = byte_channel_list.readInt();
					var tmp_channel_list_byte:ByteArray = new ByteArray;
					byte_channel_list.readBytes(tmp_channel_list_byte, 0, tmp_channel_list_length);
					tmp_channel_list.readFromDataOutput(tmp_channel_list_byte);
					this.channel_list.push(tmp_channel_list);
				}
			}
			var size_black_list:int = input.readShort();
			var length_black_list:int = input.readInt();
			if (length_black_list > 0) {
				var byte_black_list:ByteArray = new ByteArray; 
				input.readBytes(byte_black_list, 0, length_black_list);
				for(i=0; i<size_black_list; i++) {
					var tmp_black_list:p_chat_role = new p_chat_role;
					var tmp_black_list_length:int = byte_black_list.readInt();
					var tmp_black_list_byte:ByteArray = new ByteArray;
					byte_black_list.readBytes(tmp_black_list_byte, 0, tmp_black_list_length);
					tmp_black_list.readFromDataOutput(tmp_black_list_byte);
					this.black_list.push(tmp_black_list);
				}
			}
			var size_gm_auth:int = input.readShort();
			var length_gm_auth:int = input.readInt();
			if (size_gm_auth>0) {
				var byte_gm_auth:ByteArray = new ByteArray; 
				input.readBytes(byte_gm_auth, 0, length_gm_auth);
				for(i=0; i<size_gm_auth; i++) {
					var tmp_gm_auth:String = byte_gm_auth.readUTF(); 
					this.gm_auth.push(tmp_gm_auth);
				}
			}
		}
	}
}
