package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_get_info_toc extends Message
	{
		public var roleinfo:p_educate_role_info = null;
		public var reason:String = "";
		public function m_educate_get_info_toc() {
			super();
			this.roleinfo = new p_educate_role_info;

			flash.net.registerClassAlias("copy.proto.line.m_educate_get_info_toc", m_educate_get_info_toc);
		}
		public override function getMethodName():String {
			return 'educate_get_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_roleinfo:ByteArray = new ByteArray;
			this.roleinfo.writeToDataOutput(tmp_roleinfo);
			var size_tmp_roleinfo:int = tmp_roleinfo.length;
			output.writeInt(size_tmp_roleinfo);
			output.writeBytes(tmp_roleinfo);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_roleinfo_size:int = input.readInt();
			if (byte_roleinfo_size > 0) {				this.roleinfo = new p_educate_role_info;
				var byte_roleinfo:ByteArray = new ByteArray;
				input.readBytes(byte_roleinfo, 0, byte_roleinfo_size);
				this.roleinfo.readFromDataOutput(byte_roleinfo);
			}
			this.reason = input.readUTF();
		}
	}
}
