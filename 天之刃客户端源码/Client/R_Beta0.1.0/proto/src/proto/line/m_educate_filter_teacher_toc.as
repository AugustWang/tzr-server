package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_filter_teacher_toc extends Message
	{
		public var roles:Array = new Array;
		public function m_educate_filter_teacher_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_filter_teacher_toc", m_educate_filter_teacher_toc);
		}
		public override function getMethodName():String {
			return 'educate_filter_teacher';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				var t2_roles:ByteArray = new ByteArray;
				var tVo_roles:p_educate_role_info = this.roles[i] as p_educate_role_info;
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
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			if (length_roles > 0) {
				var byte_roles:ByteArray = new ByteArray; 
				input.readBytes(byte_roles, 0, length_roles);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:p_educate_role_info = new p_educate_role_info;
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
