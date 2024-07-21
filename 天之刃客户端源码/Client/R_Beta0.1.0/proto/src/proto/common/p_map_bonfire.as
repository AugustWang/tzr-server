package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_bonfire extends Message
	{
		public var id:int = 0;
		public var state:int = 0;
		public var pos:p_pos = null;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var rate:int = 0;
		public var members:int = 0;
		public var fagot:int = 0;
		public function p_map_bonfire() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_bonfire", p_map_bonfire);
		}
		public override function getMethodName():String {
			return 'map_bon';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.state);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.rate);
			output.writeInt(this.members);
			output.writeInt(this.fagot);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.state = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.rate = input.readInt();
			this.members = input.readInt();
			this.fagot = input.readInt();
		}
	}
}
