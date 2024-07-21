package proto.line {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_move_walk_tos extends Message
	{
		public var pos:p_pos = null;
		public function m_move_walk_tos() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_move_walk_tos", m_move_walk_tos);
		}
		public override function getMethodName():String {
			return 'move_walk';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
		}
	}
}
