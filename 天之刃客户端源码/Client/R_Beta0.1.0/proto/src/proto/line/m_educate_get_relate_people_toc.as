package proto.line {
	import proto.line.p_educate_role_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_relate_people_toc extends Message
	{
		public var educate_role_info:Array = new Array;
		public function m_educate_get_relate_people_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_relate_people_toc", m_educate_get_relate_people_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_relate_people';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_educate_role_info:int = this.educate_role_info.length;
			output.writeShort(size_educate_role_info);
			var temp_repeated_byte_educate_role_info:ByteArray= new ByteArray;
			for(i=0; i<size_educate_role_info; i++) {
				var t2_educate_role_info:ByteArray = new ByteArray;
				var tVo_educate_role_info:p_educate_role_info = this.educate_role_info[i] as p_educate_role_info;
				tVo_educate_role_info.writeToDataOutput(t2_educate_role_info);
				var len_tVo_educate_role_info:int = t2_educate_role_info.length;
				temp_repeated_byte_educate_role_info.writeInt(len_tVo_educate_role_info);
				temp_repeated_byte_educate_role_info.writeBytes(t2_educate_role_info);
			}
			output.writeInt(temp_repeated_byte_educate_role_info.length);
			output.writeBytes(temp_repeated_byte_educate_role_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_educate_role_info:int = input.readShort();
			var length_educate_role_info:int = input.readInt();
			if (length_educate_role_info > 0) {
				var byte_educate_role_info:ByteArray = new ByteArray; 
				input.readBytes(byte_educate_role_info, 0, length_educate_role_info);
				for(i=0; i<size_educate_role_info; i++) {
					var tmp_educate_role_info:p_educate_role_info = new p_educate_role_info;
					var tmp_educate_role_info_length:int = byte_educate_role_info.readInt();
					var tmp_educate_role_info_byte:ByteArray = new ByteArray;
					byte_educate_role_info.readBytes(tmp_educate_role_info_byte, 0, tmp_educate_role_info_length);
					tmp_educate_role_info.readFromDataOutput(tmp_educate_role_info_byte);
					this.educate_role_info.push(tmp_educate_role_info);
				}
			}
		}
	}
}
