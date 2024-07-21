package proto.line {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ybc_faraway_toc extends Message
	{
		public var pos:p_pos = null;
		public var map_id:int = 0;
		public function m_ybc_faraway_toc() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_ybc_faraway_toc", m_ybc_faraway_toc);
		}
		public override function getMethodName():String {
			return 'ybc_faraway';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.map_id = input.readInt();
		}
	}
}
