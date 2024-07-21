package proto.common {
	import proto.common.p_drop_colour_mode;
	import proto.common.p_drop_colour_mode;
	import proto.common.p_drop_quality_mode;
	import proto.common.p_drop_quality_mode;
	import proto.common.p_drop_hole_mode;
	import proto.common.p_drop_hole_mode;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_drop_mode extends Message
	{
		public var mode_id:int = 0;
		public var bind_rate:int = 0;
		public var bind_colour:Array = new Array;
		public var unbind_colour:Array = new Array;
		public var bind_quality:Array = new Array;
		public var unbind_quality:Array = new Array;
		public var bind_hole:Array = new Array;
		public var unbind_hole:Array = new Array;
		public var use_bind:int = 1;
		public function p_drop_mode() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_drop_mode", p_drop_mode);
		}
		public override function getMethodName():String {
			return 'drop_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mode_id);
			output.writeInt(this.bind_rate);
			var size_bind_colour:int = this.bind_colour.length;
			output.writeShort(size_bind_colour);
			var temp_repeated_byte_bind_colour:ByteArray= new ByteArray;
			for(i=0; i<size_bind_colour; i++) {
				var t2_bind_colour:ByteArray = new ByteArray;
				var tVo_bind_colour:p_drop_colour_mode = this.bind_colour[i] as p_drop_colour_mode;
				tVo_bind_colour.writeToDataOutput(t2_bind_colour);
				var len_tVo_bind_colour:int = t2_bind_colour.length;
				temp_repeated_byte_bind_colour.writeInt(len_tVo_bind_colour);
				temp_repeated_byte_bind_colour.writeBytes(t2_bind_colour);
			}
			output.writeInt(temp_repeated_byte_bind_colour.length);
			output.writeBytes(temp_repeated_byte_bind_colour);
			var size_unbind_colour:int = this.unbind_colour.length;
			output.writeShort(size_unbind_colour);
			var temp_repeated_byte_unbind_colour:ByteArray= new ByteArray;
			for(i=0; i<size_unbind_colour; i++) {
				var t2_unbind_colour:ByteArray = new ByteArray;
				var tVo_unbind_colour:p_drop_colour_mode = this.unbind_colour[i] as p_drop_colour_mode;
				tVo_unbind_colour.writeToDataOutput(t2_unbind_colour);
				var len_tVo_unbind_colour:int = t2_unbind_colour.length;
				temp_repeated_byte_unbind_colour.writeInt(len_tVo_unbind_colour);
				temp_repeated_byte_unbind_colour.writeBytes(t2_unbind_colour);
			}
			output.writeInt(temp_repeated_byte_unbind_colour.length);
			output.writeBytes(temp_repeated_byte_unbind_colour);
			var size_bind_quality:int = this.bind_quality.length;
			output.writeShort(size_bind_quality);
			var temp_repeated_byte_bind_quality:ByteArray= new ByteArray;
			for(i=0; i<size_bind_quality; i++) {
				var t2_bind_quality:ByteArray = new ByteArray;
				var tVo_bind_quality:p_drop_quality_mode = this.bind_quality[i] as p_drop_quality_mode;
				tVo_bind_quality.writeToDataOutput(t2_bind_quality);
				var len_tVo_bind_quality:int = t2_bind_quality.length;
				temp_repeated_byte_bind_quality.writeInt(len_tVo_bind_quality);
				temp_repeated_byte_bind_quality.writeBytes(t2_bind_quality);
			}
			output.writeInt(temp_repeated_byte_bind_quality.length);
			output.writeBytes(temp_repeated_byte_bind_quality);
			var size_unbind_quality:int = this.unbind_quality.length;
			output.writeShort(size_unbind_quality);
			var temp_repeated_byte_unbind_quality:ByteArray= new ByteArray;
			for(i=0; i<size_unbind_quality; i++) {
				var t2_unbind_quality:ByteArray = new ByteArray;
				var tVo_unbind_quality:p_drop_quality_mode = this.unbind_quality[i] as p_drop_quality_mode;
				tVo_unbind_quality.writeToDataOutput(t2_unbind_quality);
				var len_tVo_unbind_quality:int = t2_unbind_quality.length;
				temp_repeated_byte_unbind_quality.writeInt(len_tVo_unbind_quality);
				temp_repeated_byte_unbind_quality.writeBytes(t2_unbind_quality);
			}
			output.writeInt(temp_repeated_byte_unbind_quality.length);
			output.writeBytes(temp_repeated_byte_unbind_quality);
			var size_bind_hole:int = this.bind_hole.length;
			output.writeShort(size_bind_hole);
			var temp_repeated_byte_bind_hole:ByteArray= new ByteArray;
			for(i=0; i<size_bind_hole; i++) {
				var t2_bind_hole:ByteArray = new ByteArray;
				var tVo_bind_hole:p_drop_hole_mode = this.bind_hole[i] as p_drop_hole_mode;
				tVo_bind_hole.writeToDataOutput(t2_bind_hole);
				var len_tVo_bind_hole:int = t2_bind_hole.length;
				temp_repeated_byte_bind_hole.writeInt(len_tVo_bind_hole);
				temp_repeated_byte_bind_hole.writeBytes(t2_bind_hole);
			}
			output.writeInt(temp_repeated_byte_bind_hole.length);
			output.writeBytes(temp_repeated_byte_bind_hole);
			var size_unbind_hole:int = this.unbind_hole.length;
			output.writeShort(size_unbind_hole);
			var temp_repeated_byte_unbind_hole:ByteArray= new ByteArray;
			for(i=0; i<size_unbind_hole; i++) {
				var t2_unbind_hole:ByteArray = new ByteArray;
				var tVo_unbind_hole:p_drop_hole_mode = this.unbind_hole[i] as p_drop_hole_mode;
				tVo_unbind_hole.writeToDataOutput(t2_unbind_hole);
				var len_tVo_unbind_hole:int = t2_unbind_hole.length;
				temp_repeated_byte_unbind_hole.writeInt(len_tVo_unbind_hole);
				temp_repeated_byte_unbind_hole.writeBytes(t2_unbind_hole);
			}
			output.writeInt(temp_repeated_byte_unbind_hole.length);
			output.writeBytes(temp_repeated_byte_unbind_hole);
			output.writeInt(this.use_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mode_id = input.readInt();
			this.bind_rate = input.readInt();
			var size_bind_colour:int = input.readShort();
			var length_bind_colour:int = input.readInt();
			if (length_bind_colour > 0) {
				var byte_bind_colour:ByteArray = new ByteArray; 
				input.readBytes(byte_bind_colour, 0, length_bind_colour);
				for(i=0; i<size_bind_colour; i++) {
					var tmp_bind_colour:p_drop_colour_mode = new p_drop_colour_mode;
					var tmp_bind_colour_length:int = byte_bind_colour.readInt();
					var tmp_bind_colour_byte:ByteArray = new ByteArray;
					byte_bind_colour.readBytes(tmp_bind_colour_byte, 0, tmp_bind_colour_length);
					tmp_bind_colour.readFromDataOutput(tmp_bind_colour_byte);
					this.bind_colour.push(tmp_bind_colour);
				}
			}
			var size_unbind_colour:int = input.readShort();
			var length_unbind_colour:int = input.readInt();
			if (length_unbind_colour > 0) {
				var byte_unbind_colour:ByteArray = new ByteArray; 
				input.readBytes(byte_unbind_colour, 0, length_unbind_colour);
				for(i=0; i<size_unbind_colour; i++) {
					var tmp_unbind_colour:p_drop_colour_mode = new p_drop_colour_mode;
					var tmp_unbind_colour_length:int = byte_unbind_colour.readInt();
					var tmp_unbind_colour_byte:ByteArray = new ByteArray;
					byte_unbind_colour.readBytes(tmp_unbind_colour_byte, 0, tmp_unbind_colour_length);
					tmp_unbind_colour.readFromDataOutput(tmp_unbind_colour_byte);
					this.unbind_colour.push(tmp_unbind_colour);
				}
			}
			var size_bind_quality:int = input.readShort();
			var length_bind_quality:int = input.readInt();
			if (length_bind_quality > 0) {
				var byte_bind_quality:ByteArray = new ByteArray; 
				input.readBytes(byte_bind_quality, 0, length_bind_quality);
				for(i=0; i<size_bind_quality; i++) {
					var tmp_bind_quality:p_drop_quality_mode = new p_drop_quality_mode;
					var tmp_bind_quality_length:int = byte_bind_quality.readInt();
					var tmp_bind_quality_byte:ByteArray = new ByteArray;
					byte_bind_quality.readBytes(tmp_bind_quality_byte, 0, tmp_bind_quality_length);
					tmp_bind_quality.readFromDataOutput(tmp_bind_quality_byte);
					this.bind_quality.push(tmp_bind_quality);
				}
			}
			var size_unbind_quality:int = input.readShort();
			var length_unbind_quality:int = input.readInt();
			if (length_unbind_quality > 0) {
				var byte_unbind_quality:ByteArray = new ByteArray; 
				input.readBytes(byte_unbind_quality, 0, length_unbind_quality);
				for(i=0; i<size_unbind_quality; i++) {
					var tmp_unbind_quality:p_drop_quality_mode = new p_drop_quality_mode;
					var tmp_unbind_quality_length:int = byte_unbind_quality.readInt();
					var tmp_unbind_quality_byte:ByteArray = new ByteArray;
					byte_unbind_quality.readBytes(tmp_unbind_quality_byte, 0, tmp_unbind_quality_length);
					tmp_unbind_quality.readFromDataOutput(tmp_unbind_quality_byte);
					this.unbind_quality.push(tmp_unbind_quality);
				}
			}
			var size_bind_hole:int = input.readShort();
			var length_bind_hole:int = input.readInt();
			if (length_bind_hole > 0) {
				var byte_bind_hole:ByteArray = new ByteArray; 
				input.readBytes(byte_bind_hole, 0, length_bind_hole);
				for(i=0; i<size_bind_hole; i++) {
					var tmp_bind_hole:p_drop_hole_mode = new p_drop_hole_mode;
					var tmp_bind_hole_length:int = byte_bind_hole.readInt();
					var tmp_bind_hole_byte:ByteArray = new ByteArray;
					byte_bind_hole.readBytes(tmp_bind_hole_byte, 0, tmp_bind_hole_length);
					tmp_bind_hole.readFromDataOutput(tmp_bind_hole_byte);
					this.bind_hole.push(tmp_bind_hole);
				}
			}
			var size_unbind_hole:int = input.readShort();
			var length_unbind_hole:int = input.readInt();
			if (length_unbind_hole > 0) {
				var byte_unbind_hole:ByteArray = new ByteArray; 
				input.readBytes(byte_unbind_hole, 0, length_unbind_hole);
				for(i=0; i<size_unbind_hole; i++) {
					var tmp_unbind_hole:p_drop_hole_mode = new p_drop_hole_mode;
					var tmp_unbind_hole_length:int = byte_unbind_hole.readInt();
					var tmp_unbind_hole_byte:ByteArray = new ByteArray;
					byte_unbind_hole.readBytes(tmp_unbind_hole_byte, 0, tmp_unbind_hole_length);
					tmp_unbind_hole.readFromDataOutput(tmp_unbind_hole_byte);
					this.unbind_hole.push(tmp_unbind_hole);
				}
			}
			this.use_bind = input.readInt();
		}
	}
}
