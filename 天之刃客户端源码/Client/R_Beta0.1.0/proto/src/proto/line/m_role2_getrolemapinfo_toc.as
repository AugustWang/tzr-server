package proto.line {
	import proto.common.p_map_role;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_getrolemapinfo_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var role_info:p_map_role = null;
		public function m_role2_getrolemapinfo_toc() {
			super();
			this.role_info = new p_map_role;

			flash.net.registerClassAlias("copy.proto.line.m_role2_getrolemapinfo_toc", m_role2_getrolemapinfo_toc);
		}
		public override function getMethodName():String {
			return 'role2_getrolemapinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_role_info:ByteArray = new ByteArray;
			this.role_info.writeToDataOutput(tmp_role_info);
			var size_tmp_role_info:int = tmp_role_info.length;
			output.writeInt(size_tmp_role_info);
			output.writeBytes(tmp_role_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_role_info_size:int = input.readInt();
			if (byte_role_info_size > 0) {				this.role_info = new p_map_role;
				var byte_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_info, 0, byte_role_info_size);
				this.role_info.readFromDataOutput(byte_role_info);
			}
		}
	}
}
