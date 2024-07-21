package proto.line {
	import proto.common.p_map_bonfire;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bonfire_get_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var bonfire_info:p_map_bonfire = null;
		public function m_bonfire_get_toc() {
			super();
			this.bonfire_info = new p_map_bonfire;

			flash.net.registerClassAlias("copy.proto.line.m_bonfire_get_toc", m_bonfire_get_toc);
		}
		public override function getMethodName():String {
			return 'bonfire_get';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_bonfire_info:ByteArray = new ByteArray;
			this.bonfire_info.writeToDataOutput(tmp_bonfire_info);
			var size_tmp_bonfire_info:int = tmp_bonfire_info.length;
			output.writeInt(size_tmp_bonfire_info);
			output.writeBytes(tmp_bonfire_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_bonfire_info_size:int = input.readInt();
			if (byte_bonfire_info_size > 0) {				this.bonfire_info = new p_map_bonfire;
				var byte_bonfire_info:ByteArray = new ByteArray;
				input.readBytes(byte_bonfire_info, 0, byte_bonfire_info_size);
				this.bonfire_info.readFromDataOutput(byte_bonfire_info);
			}
		}
	}
}
