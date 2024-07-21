package proto.line {
	import proto.common.p_recommend_member_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_member_recommend_toc extends Message
	{
		public var succ:Boolean = true;
		public var member_info:Array = new Array;
		public var reason:String = "";
		public function m_team_member_recommend_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_member_recommend_toc", m_team_member_recommend_toc);
		}
		public override function getMethodName():String {
			return 'team_member_recommend';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var size_member_info:int = this.member_info.length;
			output.writeShort(size_member_info);
			var temp_repeated_byte_member_info:ByteArray= new ByteArray;
			for(i=0; i<size_member_info; i++) {
				var t2_member_info:ByteArray = new ByteArray;
				var tVo_member_info:p_recommend_member_info = this.member_info[i] as p_recommend_member_info;
				tVo_member_info.writeToDataOutput(t2_member_info);
				var len_tVo_member_info:int = t2_member_info.length;
				temp_repeated_byte_member_info.writeInt(len_tVo_member_info);
				temp_repeated_byte_member_info.writeBytes(t2_member_info);
			}
			output.writeInt(temp_repeated_byte_member_info.length);
			output.writeBytes(temp_repeated_byte_member_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var size_member_info:int = input.readShort();
			var length_member_info:int = input.readInt();
			if (length_member_info > 0) {
				var byte_member_info:ByteArray = new ByteArray; 
				input.readBytes(byte_member_info, 0, length_member_info);
				for(i=0; i<size_member_info; i++) {
					var tmp_member_info:p_recommend_member_info = new p_recommend_member_info;
					var tmp_member_info_length:int = byte_member_info.readInt();
					var tmp_member_info_byte:ByteArray = new ByteArray;
					byte_member_info.readBytes(tmp_member_info_byte, 0, tmp_member_info_length);
					tmp_member_info.readFromDataOutput(tmp_member_info_byte);
					this.member_info.push(tmp_member_info);
				}
			}
			this.reason = input.readUTF();
		}
	}
}
