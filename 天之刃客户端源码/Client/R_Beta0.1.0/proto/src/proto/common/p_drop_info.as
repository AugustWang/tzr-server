package proto.common {
	import proto.common.p_single_drop;
	import proto.common.p_drop_mode;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_drop_info extends Message
	{
		public var drops:Array = new Array;
		public var rate:int = 0;
		public var max_num:int = 1;
		public var drop_mode:p_drop_mode = null;
		public function p_drop_info() {
			super();
			this.drop_mode = new p_drop_mode;

			flash.net.registerClassAlias("copy.proto.common.p_drop_info", p_drop_info);
		}
		public override function getMethodName():String {
			return 'drop_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_drops:int = this.drops.length;
			output.writeShort(size_drops);
			var temp_repeated_byte_drops:ByteArray= new ByteArray;
			for(i=0; i<size_drops; i++) {
				var t2_drops:ByteArray = new ByteArray;
				var tVo_drops:p_single_drop = this.drops[i] as p_single_drop;
				tVo_drops.writeToDataOutput(t2_drops);
				var len_tVo_drops:int = t2_drops.length;
				temp_repeated_byte_drops.writeInt(len_tVo_drops);
				temp_repeated_byte_drops.writeBytes(t2_drops);
			}
			output.writeInt(temp_repeated_byte_drops.length);
			output.writeBytes(temp_repeated_byte_drops);
			output.writeInt(this.rate);
			output.writeInt(this.max_num);
			var tmp_drop_mode:ByteArray = new ByteArray;
			this.drop_mode.writeToDataOutput(tmp_drop_mode);
			var size_tmp_drop_mode:int = tmp_drop_mode.length;
			output.writeInt(size_tmp_drop_mode);
			output.writeBytes(tmp_drop_mode);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_drops:int = input.readShort();
			var length_drops:int = input.readInt();
			if (length_drops > 0) {
				var byte_drops:ByteArray = new ByteArray; 
				input.readBytes(byte_drops, 0, length_drops);
				for(i=0; i<size_drops; i++) {
					var tmp_drops:p_single_drop = new p_single_drop;
					var tmp_drops_length:int = byte_drops.readInt();
					var tmp_drops_byte:ByteArray = new ByteArray;
					byte_drops.readBytes(tmp_drops_byte, 0, tmp_drops_length);
					tmp_drops.readFromDataOutput(tmp_drops_byte);
					this.drops.push(tmp_drops);
				}
			}
			this.rate = input.readInt();
			this.max_num = input.readInt();
			var byte_drop_mode_size:int = input.readInt();
			if (byte_drop_mode_size > 0) {				this.drop_mode = new p_drop_mode;
				var byte_drop_mode:ByteArray = new ByteArray;
				input.readBytes(byte_drop_mode, 0, byte_drop_mode_size);
				this.drop_mode.readFromDataOutput(byte_drop_mode);
			}
		}
	}
}
