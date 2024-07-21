package proto.line {
	import proto.common.p_role_attr;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_attr_reload_toc extends Message
	{
		public var role_attr:p_role_attr = null;
		public function m_role2_attr_reload_toc() {
			super();
			this.role_attr = new p_role_attr;

			flash.net.registerClassAlias("copy.proto.line.m_role2_attr_reload_toc", m_role2_attr_reload_toc);
		}
		public override function getMethodName():String {
			return 'role2_attr_reload';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_role_attr:ByteArray = new ByteArray;
			this.role_attr.writeToDataOutput(tmp_role_attr);
			var size_tmp_role_attr:int = tmp_role_attr.length;
			output.writeInt(size_tmp_role_attr);
			output.writeBytes(tmp_role_attr);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_role_attr_size:int = input.readInt();
			if (byte_role_attr_size > 0) {				this.role_attr = new p_role_attr;
				var byte_role_attr:ByteArray = new ByteArray;
				input.readBytes(byte_role_attr, 0, byte_role_attr_size);
				this.role_attr.readFromDataOutput(byte_role_attr);
			}
		}
	}
}
