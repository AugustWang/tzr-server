package proto.common {
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_enemy extends Message
	{
		public var actor_key:int = 0;
		public var total_hurt:int = 0;
		public var last_att_time:int = 0;
		public var pos:p_pos = null;
		public var state:int = 1;
		public function p_enemy() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_enemy", p_enemy);
		}
		public override function getMethodName():String {
			return 'e';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.actor_key);
			output.writeInt(this.total_hurt);
			output.writeInt(this.last_att_time);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.state);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.actor_key = input.readInt();
			this.total_hurt = input.readInt();
			this.last_att_time = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.state = input.readInt();
		}
	}
}
