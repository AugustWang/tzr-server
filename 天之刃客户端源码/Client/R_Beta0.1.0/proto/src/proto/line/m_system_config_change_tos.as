package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_config_change_tos extends Message
	{
		public var sys_config:p_sys_config = null;
		public function m_system_config_change_tos() {
			super();
			this.sys_config = new p_sys_config;

			flash.net.registerClassAlias("copy.proto.line.m_system_config_change_tos", m_system_config_change_tos);
		}
		public override function getMethodName():String {
			return 'system_config_change';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_sys_config:ByteArray = new ByteArray;
			this.sys_config.writeToDataOutput(tmp_sys_config);
			var size_tmp_sys_config:int = tmp_sys_config.length;
			output.writeInt(size_tmp_sys_config);
			output.writeBytes(tmp_sys_config);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_sys_config_size:int = input.readInt();
			if (byte_sys_config_size > 0) {				this.sys_config = new p_sys_config;
				var byte_sys_config:ByteArray = new ByteArray;
				input.readBytes(byte_sys_config, 0, byte_sys_config_size);
				this.sys_config.readFromDataOutput(byte_sys_config);
			}
		}
	}
}
