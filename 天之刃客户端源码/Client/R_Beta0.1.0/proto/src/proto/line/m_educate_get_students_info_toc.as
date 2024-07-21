package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_students_info_toc extends Message
	{
		public var students:Array = new Array;
		public function m_educate_get_students_info_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_students_info_toc", m_educate_get_students_info_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_students_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_students:int = this.students.length;
			output.writeShort(size_students);
			var temp_repeated_byte_students:ByteArray= new ByteArray;
			for(i=0; i<size_students; i++) {
				var t2_students:ByteArray = new ByteArray;
				var tVo_students:p_educate_role_info = this.students[i] as p_educate_role_info;
				tVo_students.writeToDataOutput(t2_students);
				var len_tVo_students:int = t2_students.length;
				temp_repeated_byte_students.writeInt(len_tVo_students);
				temp_repeated_byte_students.writeBytes(t2_students);
			}
			output.writeInt(temp_repeated_byte_students.length);
			output.writeBytes(temp_repeated_byte_students);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_students:int = input.readShort();
			var length_students:int = input.readInt();
			if (length_students > 0) {
				var byte_students:ByteArray = new ByteArray; 
				input.readBytes(byte_students, 0, length_students);
				for(i=0; i<size_students; i++) {
					var tmp_students:p_educate_role_info = new p_educate_role_info;
					var tmp_students_length:int = byte_students.readInt();
					var tmp_students_byte:ByteArray = new ByteArray;
					byte_students.readBytes(tmp_students_byte, 0, tmp_students_length);
					tmp_students.readFromDataOutput(tmp_students_byte);
					this.students.push(tmp_students);
				}
			}
		}
	}
}
