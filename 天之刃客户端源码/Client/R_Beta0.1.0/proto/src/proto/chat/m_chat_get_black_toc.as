package proto.chat {
	import proto.common.p_chat_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_get_black_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_list:Array = new Array;
		public function m_chat_get_black_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_get_black_toc", m_chat_get_black_toc);
		}
		public override function getMethodName():String {
			return 'chat_get_black';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_role_list:int = this.role_list.length;
			output.writeShort(size_role_list);
			var temp_repeated_byte_role_list:ByteArray= new ByteArray;
			for(i=0; i<size_role_list; i++) {
				var t2_role_list:ByteArray = new ByteArray;
				var tVo_role_list:p_chat_role = this.role_list[i] as p_chat_role;
				tVo_role_list.writeToDataOutput(t2_role_list);
				var len_tVo_role_list:int = t2_role_list.length;
				temp_repeated_byte_role_list.writeInt(len_tVo_role_list);
				temp_repeated_byte_role_list.writeBytes(t2_role_list);
			}
			output.writeInt(temp_repeated_byte_role_list.length);
			output.writeBytes(temp_repeated_byte_role_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_role_list:int = input.readShort();
			var length_role_list:int = input.readInt();
			if (length_role_list > 0) {
				var byte_role_list:ByteArray = new ByteArray; 
				input.readBytes(byte_role_list, 0, length_role_list);
				for(i=0; i<size_role_list; i++) {
					var tmp_role_list:p_chat_role = new p_chat_role;
					var tmp_role_list_length:int = byte_role_list.readInt();
					var tmp_role_list_byte:ByteArray = new ByteArray;
					byte_role_list.readBytes(tmp_role_list_byte, 0, tmp_role_list_length);
					tmp_role_list.readFromDataOutput(tmp_role_list_byte);
					this.role_list.push(tmp_role_list);
				}
			}
		}
	}
}
