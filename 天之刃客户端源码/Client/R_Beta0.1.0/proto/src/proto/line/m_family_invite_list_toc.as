package proto.line {
	import proto.common.p_family_invite;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_invite_list_toc extends Message
	{
		public var invite_list:Array = new Array;
		public function m_family_invite_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_invite_list_toc", m_family_invite_list_toc);
		}
		public override function getMethodName():String {
			return 'family_invite_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_invite_list:int = this.invite_list.length;
			output.writeShort(size_invite_list);
			var temp_repeated_byte_invite_list:ByteArray= new ByteArray;
			for(i=0; i<size_invite_list; i++) {
				var t2_invite_list:ByteArray = new ByteArray;
				var tVo_invite_list:p_family_invite = this.invite_list[i] as p_family_invite;
				tVo_invite_list.writeToDataOutput(t2_invite_list);
				var len_tVo_invite_list:int = t2_invite_list.length;
				temp_repeated_byte_invite_list.writeInt(len_tVo_invite_list);
				temp_repeated_byte_invite_list.writeBytes(t2_invite_list);
			}
			output.writeInt(temp_repeated_byte_invite_list.length);
			output.writeBytes(temp_repeated_byte_invite_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_invite_list:int = input.readShort();
			var length_invite_list:int = input.readInt();
			if (length_invite_list > 0) {
				var byte_invite_list:ByteArray = new ByteArray; 
				input.readBytes(byte_invite_list, 0, length_invite_list);
				for(i=0; i<size_invite_list; i++) {
					var tmp_invite_list:p_family_invite = new p_family_invite;
					var tmp_invite_list_length:int = byte_invite_list.readInt();
					var tmp_invite_list_byte:ByteArray = new ByteArray;
					byte_invite_list.readBytes(tmp_invite_list_byte, 0, tmp_invite_list_length);
					tmp_invite_list.readFromDataOutput(tmp_invite_list_byte);
					this.invite_list.push(tmp_invite_list);
				}
			}
		}
	}
}
