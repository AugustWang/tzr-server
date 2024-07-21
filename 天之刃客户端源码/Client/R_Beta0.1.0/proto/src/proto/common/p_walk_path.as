package proto.common {
	import proto.common.p_map_tile;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_walk_path extends Message
	{
		public var bpx:int = 0;
		public var bpy:int = 0;
		public var path:Array = new Array;
		public var epx:int = 0;
		public var epy:int = 0;
		public function p_walk_path() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_walk_path", p_walk_path);
		}
		public override function getMethodName():String {
			return 'walk_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bpx);
			output.writeInt(this.bpy);
			var size_path:int = this.path.length;
			output.writeShort(size_path);
			var temp_repeated_byte_path:ByteArray= new ByteArray;
			for(i=0; i<size_path; i++) {
				var t2_path:ByteArray = new ByteArray;
				var tVo_path:p_map_tile = this.path[i] as p_map_tile;
				tVo_path.writeToDataOutput(t2_path);
				var len_tVo_path:int = t2_path.length;
				temp_repeated_byte_path.writeInt(len_tVo_path);
				temp_repeated_byte_path.writeBytes(t2_path);
			}
			output.writeInt(temp_repeated_byte_path.length);
			output.writeBytes(temp_repeated_byte_path);
			output.writeInt(this.epx);
			output.writeInt(this.epy);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bpx = input.readInt();
			this.bpy = input.readInt();
			var size_path:int = input.readShort();
			var length_path:int = input.readInt();
			if (length_path > 0) {
				var byte_path:ByteArray = new ByteArray; 
				input.readBytes(byte_path, 0, length_path);
				for(i=0; i<size_path; i++) {
					var tmp_path:p_map_tile = new p_map_tile;
					var tmp_path_length:int = byte_path.readInt();
					var tmp_path_byte:ByteArray = new ByteArray;
					byte_path.readBytes(tmp_path_byte, 0, tmp_path_length);
					tmp_path.readFromDataOutput(tmp_path_byte);
					this.path.push(tmp_path);
				}
			}
			this.epx = input.readInt();
			this.epy = input.readInt();
		}
	}
}
