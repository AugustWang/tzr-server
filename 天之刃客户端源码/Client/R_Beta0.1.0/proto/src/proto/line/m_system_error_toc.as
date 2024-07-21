package proto.line {
	import proto.login.p_line_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_error_toc extends Message
	{
		public var if_close_connect:Boolean = true;
		public var type:String = 'line';
		public var error_info:String = "";
		public var error_no:int = 0;
		public var need_reconnect:Boolean = false;
		public var key:String = "";
		public var line_info:p_line_info = null;
		public function m_system_error_toc() {
			super();
			this.line_info = new p_line_info;

			flash.net.registerClassAlias("copy.proto.line.m_system_error_toc", m_system_error_toc);
		}
		public override function getMethodName():String {
			return 'system_error';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.if_close_connect);
			if (this.type != null) {				output.writeUTF(this.type.toString());
			} else {
				output.writeUTF("");
			}
			if (this.error_info != null) {				output.writeUTF(this.error_info.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.error_no);
			output.writeBoolean(this.need_reconnect);
			if (this.key != null) {				output.writeUTF(this.key.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_line_info:ByteArray = new ByteArray;
			this.line_info.writeToDataOutput(tmp_line_info);
			var size_tmp_line_info:int = tmp_line_info.length;
			output.writeInt(size_tmp_line_info);
			output.writeBytes(tmp_line_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.if_close_connect = input.readBoolean();
			this.type = input.readUTF();
			this.error_info = input.readUTF();
			this.error_no = input.readInt();
			this.need_reconnect = input.readBoolean();
			this.key = input.readUTF();
			var byte_line_info_size:int = input.readInt();
			if (byte_line_info_size > 0) {				this.line_info = new p_line_info;
				var byte_line_info:ByteArray = new ByteArray;
				input.readBytes(byte_line_info, 0, byte_line_info_size);
				this.line_info.readFromDataOutput(byte_line_info);
			}
		}
	}
}
