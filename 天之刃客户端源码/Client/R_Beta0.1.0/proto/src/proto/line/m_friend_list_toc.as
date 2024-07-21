package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var friend_list:Array = new Array;
		public var reason:String = "";
		public function m_friend_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_list_toc", m_friend_list_toc);
		}
		public override function getMethodName():String {
			return 'friend_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_friend_list:int = this.friend_list.length;
			output.writeShort(size_friend_list);
			var temp_repeated_byte_friend_list:ByteArray= new ByteArray;
			for(i=0; i<size_friend_list; i++) {
				var t2_friend_list:ByteArray = new ByteArray;
				var tVo_friend_list:p_friend_info = this.friend_list[i] as p_friend_info;
				tVo_friend_list.writeToDataOutput(t2_friend_list);
				var len_tVo_friend_list:int = t2_friend_list.length;
				temp_repeated_byte_friend_list.writeInt(len_tVo_friend_list);
				temp_repeated_byte_friend_list.writeBytes(t2_friend_list);
			}
			output.writeInt(temp_repeated_byte_friend_list.length);
			output.writeBytes(temp_repeated_byte_friend_list);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_friend_list:int = input.readShort();
			var length_friend_list:int = input.readInt();
			if (length_friend_list > 0) {
				var byte_friend_list:ByteArray = new ByteArray; 
				input.readBytes(byte_friend_list, 0, length_friend_list);
				for(i=0; i<size_friend_list; i++) {
					var tmp_friend_list:p_friend_info = new p_friend_info;
					var tmp_friend_list_length:int = byte_friend_list.readInt();
					var tmp_friend_list_byte:ByteArray = new ByteArray;
					byte_friend_list.readBytes(tmp_friend_list_byte, 0, tmp_friend_list_length);
					tmp_friend_list.readFromDataOutput(tmp_friend_list_byte);
					this.friend_list.push(tmp_friend_list);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
