package proto.line {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_mission_touch_area extends Message
	{
		public var map:int = 0;
		public var pos:p_pos = null;
		public var sign:int = 0;
		public function p_mission_touch_area() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.p_mission_touch_area", p_mission_touch_area);
		}
		public override function getMethodName():String {
			return 'mission_touch_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.map);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.sign);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.map = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.sign = input.readInt();
		}
	}
}
