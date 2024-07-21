package proto.line {
	import proto.common.p_recommend_member_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_recommend_toc extends Message
	{
		public var succ:Boolean = true;
		public var friend_info:Array = new Array;
		public var reason:String = "";
		public function m_friend_recommend_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_recommend_toc", m_friend_recommend_toc);
		}
		public override function getMethodName():String {
			return 'friend_recommend';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_friend_info:int = this.friend_info.length;
			output.writeShort(size_friend_info);
			var temp_repeated_byte_friend_info:ByteArray= new ByteArray;
			for(i=0; i<size_friend_info; i++) {
				var t2_friend_info:ByteArray = new ByteArray;
				var tVo_friend_info:p_recommend_member_info = this.friend_info[i] as p_recommend_member_info;
				tVo_friend_info.writeToDataOutput(t2_friend_info);
				var len_tVo_friend_info:int = t2_friend_info.length;
				temp_repeated_byte_friend_info.writeInt(len_tVo_friend_info);
				temp_repeated_byte_friend_info.writeBytes(t2_friend_info);
			}
			output.writeInt(temp_repeated_byte_friend_info.length);
			output.writeBytes(temp_repeated_byte_friend_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_friend_info:int = input.readShort();
			var length_friend_info:int = input.readInt();
			if (length_friend_info > 0) {
				var byte_friend_info:ByteArray = new ByteArray; 
				input.readBytes(byte_friend_info, 0, length_friend_info);
				for(i=0; i<size_friend_info; i++) {
					var tmp_friend_info:p_recommend_member_info = new p_recommend_member_info;
					var tmp_friend_info_length:int = byte_friend_info.readInt();
					var tmp_friend_info_byte:ByteArray = new ByteArray;
					byte_friend_info.readBytes(tmp_friend_info_byte, 0, tmp_friend_info_length);
					tmp_friend_info.readFromDataOutput(tmp_friend_info_byte);
					this.friend_info.push(tmp_friend_info);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
