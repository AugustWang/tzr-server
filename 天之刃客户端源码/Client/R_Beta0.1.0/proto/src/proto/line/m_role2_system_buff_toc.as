package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_system_buff_toc extends Message
	{
		public var sys_buff:Array = new Array;
		public function m_role2_system_buff_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_system_buff_toc", m_role2_system_buff_toc);
		}
		public override function getMethodName():String {
			return 'role2_system_buff';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_sys_buff:int = this.sys_buff.length;
			output.writeShort(size_sys_buff);
			var temp_repeated_byte_sys_buff:ByteArray= new ByteArray;
			for(i=0; i<size_sys_buff; i++) {
				var t2_sys_buff:ByteArray = new ByteArray;
				var tVo_sys_buff:p_sys_buff_info = this.sys_buff[i] as p_sys_buff_info;
				tVo_sys_buff.writeToDataOutput(t2_sys_buff);
				var len_tVo_sys_buff:int = t2_sys_buff.length;
				temp_repeated_byte_sys_buff.writeInt(len_tVo_sys_buff);
				temp_repeated_byte_sys_buff.writeBytes(t2_sys_buff);
			}
			output.writeInt(temp_repeated_byte_sys_buff.length);
			output.writeBytes(temp_repeated_byte_sys_buff);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_sys_buff:int = input.readShort();
			var length_sys_buff:int = input.readInt();
			if (length_sys_buff > 0) {
				var byte_sys_buff:ByteArray = new ByteArray; 
				input.readBytes(byte_sys_buff, 0, length_sys_buff);
				for(i=0; i<size_sys_buff; i++) {
					var tmp_sys_buff:p_sys_buff_info = new p_sys_buff_info;
					var tmp_sys_buff_length:int = byte_sys_buff.readInt();
					var tmp_sys_buff_byte:ByteArray = new ByteArray;
					byte_sys_buff.readBytes(tmp_sys_buff_byte, 0, tmp_sys_buff_length);
					tmp_sys_buff.readFromDataOutput(tmp_sys_buff_byte);
					this.sys_buff.push(tmp_sys_buff);
				}
			}
		}
	}
}
