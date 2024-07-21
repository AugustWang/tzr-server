package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_stall extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var stall_name:String = "";
		public var mode:int = 0;
		public var pos:p_pos = null;
		public function p_map_stall() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_stall", p_map_stall);
		}
		public override function getMethodName():String {
			return 'map_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.stall_name != null) {				output.writeUTF(this.stall_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.mode);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.stall_name = input.readUTF();
			this.mode = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
		}
	}
}
