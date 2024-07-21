package proto.line {
	import proto.common.p_map_bonfire;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bonfire_add_fagot_toc extends Message
	{
		public var succ:Boolean = true;
		public var bonfire:p_map_bonfire = null;
		public var reason:String = "";
		public function m_bonfire_add_fagot_toc() {
			super();
			this.bonfire = new p_map_bonfire;

			flash.net.registerClassAlias("copy.proto.line.m_bonfire_add_fagot_toc", m_bonfire_add_fagot_toc);
		}
		public override function getMethodName():String {
			return 'bonfire_add_fagot';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_bonfire:ByteArray = new ByteArray;
			this.bonfire.writeToDataOutput(tmp_bonfire);
			var size_tmp_bonfire:int = tmp_bonfire.length;
			output.writeInt(size_tmp_bonfire);
			output.writeBytes(tmp_bonfire);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_bonfire_size:int = input.readInt();
			if (byte_bonfire_size > 0) {				this.bonfire = new p_map_bonfire;
				var byte_bonfire:ByteArray = new ByteArray;
				input.readBytes(byte_bonfire, 0, byte_bonfire_size);
				this.bonfire.readFromDataOutput(byte_bonfire);
			}
			this.reason = input.readUTF();
		}
	}
}
