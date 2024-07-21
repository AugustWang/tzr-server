package proto.line {
	import proto.common.p_role_base;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_base_reload_toc extends Message
	{
		public var role_base:p_role_base = null;
		public function m_role2_base_reload_toc() {
			super();
			this.role_base = new p_role_base;

			flash.net.registerClassAlias("copy.proto.line.m_role2_base_reload_toc", m_role2_base_reload_toc);
		}
		public override function getMethodName():String {
			return 'role2_base_reload';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_role_base:ByteArray = new ByteArray;
			this.role_base.writeToDataOutput(tmp_role_base);
			var size_tmp_role_base:int = tmp_role_base.length;
			output.writeInt(size_tmp_role_base);
			output.writeBytes(tmp_role_base);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_role_base_size:int = input.readInt();
			if (byte_role_base_size > 0) {				this.role_base = new p_role_base;
				var byte_role_base:ByteArray = new ByteArray;
				input.readBytes(byte_role_base, 0, byte_role_base_size);
				this.role_base.readFromDataOutput(byte_role_base);
			}
		}
	}
}
