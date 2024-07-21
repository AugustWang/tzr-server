package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var members:Array = new Array;
		public function m_family_ybc_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_list_toc", m_family_ybc_list_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_members:int = this.members.length;
			output.writeShort(size_members);
			var temp_repeated_byte_members:ByteArray= new ByteArray;
			for(i=0; i<size_members; i++) {
				var t2_members:ByteArray = new ByteArray;
				var tVo_members:p_family_ybc_member_info = this.members[i] as p_family_ybc_member_info;
				tVo_members.writeToDataOutput(t2_members);
				var len_tVo_members:int = t2_members.length;
				temp_repeated_byte_members.writeInt(len_tVo_members);
				temp_repeated_byte_members.writeBytes(t2_members);
			}
			output.writeInt(temp_repeated_byte_members.length);
			output.writeBytes(temp_repeated_byte_members);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var size_members:int = input.readShort();
			var length_members:int = input.readInt();
			if (length_members > 0) {
				var byte_members:ByteArray = new ByteArray; 
				input.readBytes(byte_members, 0, length_members);
				for(i=0; i<size_members; i++) {
					var tmp_members:p_family_ybc_member_info = new p_family_ybc_member_info;
					var tmp_members_length:int = byte_members.readInt();
					var tmp_members_byte:ByteArray = new ByteArray;
					byte_members.readBytes(tmp_members_byte, 0, tmp_members_length);
					tmp_members.readFromDataOutput(tmp_members_byte);
					this.members.push(tmp_members);
				}
			}
		}
	}
}
