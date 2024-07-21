package proto.line {
	import proto.common.p_map_ybc;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ybc_enter_toc extends Message
	{
		public var ybc_info:p_map_ybc = null;
		public function m_ybc_enter_toc() {
			super();
			this.ybc_info = new p_map_ybc;

			flash.net.registerClassAlias("copy.proto.line.m_ybc_enter_toc", m_ybc_enter_toc);
		}
		public override function getMethodName():String {
			return 'ybc_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_ybc_info:ByteArray = new ByteArray;
			this.ybc_info.writeToDataOutput(tmp_ybc_info);
			var size_tmp_ybc_info:int = tmp_ybc_info.length;
			output.writeInt(size_tmp_ybc_info);
			output.writeBytes(tmp_ybc_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_ybc_info_size:int = input.readInt();
			if (byte_ybc_info_size > 0) {				this.ybc_info = new p_map_ybc;
				var byte_ybc_info:ByteArray = new ByteArray;
				input.readBytes(byte_ybc_info, 0, byte_ybc_info_size);
				this.ybc_info.readFromDataOutput(byte_ybc_info);
			}
		}
	}
}
