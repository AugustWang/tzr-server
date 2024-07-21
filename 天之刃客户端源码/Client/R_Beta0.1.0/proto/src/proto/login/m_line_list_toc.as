package proto.login {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_line_list_toc extends Message
	{
		public var succ:Boolean = true;
		public var msg:String = "";
		public var lines:Array = new Array;
		public function m_line_list_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.login.m_line_list_toc", m_line_list_toc);
		}
		public override function getMethodName():String {
			return 'line_list';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.msg != null) {				output.writeUTF(this.msg.toString());
			} else {
				output.writeUTF("");
			}
			var size_lines:int = this.lines.length;
			output.writeShort(size_lines);
			var temp_repeated_byte_lines:ByteArray= new ByteArray;
			for(i=0; i<size_lines; i++) {
				var t2_lines:ByteArray = new ByteArray;
				var tVo_lines:p_line_info = this.lines[i] as p_line_info;
				tVo_lines.writeToDataOutput(t2_lines);
				var len_tVo_lines:int = t2_lines.length;
				temp_repeated_byte_lines.writeInt(len_tVo_lines);
				temp_repeated_byte_lines.writeBytes(t2_lines);
			}
			output.writeInt(temp_repeated_byte_lines.length);
			output.writeBytes(temp_repeated_byte_lines);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.msg = input.readUTF();
			var size_lines:int = input.readShort();
			var length_lines:int = input.readInt();
			if (length_lines > 0) {
				var byte_lines:ByteArray = new ByteArray; 
				input.readBytes(byte_lines, 0, length_lines);
				for(i=0; i<size_lines; i++) {
					var tmp_lines:p_line_info = new p_line_info;
					var tmp_lines_length:int = byte_lines.readInt();
					var tmp_lines_byte:ByteArray = new ByteArray;
					byte_lines.readBytes(tmp_lines_byte, 0, tmp_lines_length);
					tmp_lines.readFromDataOutput(tmp_lines_byte);
					this.lines.push(tmp_lines);
				}
			}
		}
	}
}
