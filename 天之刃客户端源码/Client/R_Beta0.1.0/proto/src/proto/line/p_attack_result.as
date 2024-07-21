package proto.line {
	import proto.common.p_map_tile;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_attack_result extends Message
	{
		public var dest_id:int = 0;
		public var is_erupt:Boolean = false;
		public var is_no_defence:Boolean = false;
		public var is_miss:Boolean = false;
		public var dest_type:int = 0;
		public var dest_tile:p_map_tile = null;
		public var buffs:Array = new Array;
		public var result_type:int = 0;
		public var result_value:int = 0;
		public function p_attack_result() {
			super();
			this.dest_tile = new p_map_tile;

			flash.net.registerClassAlias("copy.proto.line.p_attack_result", p_attack_result);
		}
		public override function getMethodName():String {
			return 'attack_re';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.dest_id);
			output.writeBoolean(this.is_erupt);
			output.writeBoolean(this.is_no_defence);
			output.writeBoolean(this.is_miss);
			output.writeInt(this.dest_type);
			var tmp_dest_tile:ByteArray = new ByteArray;
			this.dest_tile.writeToDataOutput(tmp_dest_tile);
			var size_tmp_dest_tile:int = tmp_dest_tile.length;
			output.writeInt(size_tmp_dest_tile);
			output.writeBytes(tmp_dest_tile);
			var size_buffs:int = this.buffs.length;
			output.writeShort(size_buffs);
			var temp_repeated_byte_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_buffs; i++) {
				var t2_buffs:ByteArray = new ByteArray;
				var tVo_buffs:p_actor_buf = this.buffs[i] as p_actor_buf;
				tVo_buffs.writeToDataOutput(t2_buffs);
				var len_tVo_buffs:int = t2_buffs.length;
				temp_repeated_byte_buffs.writeInt(len_tVo_buffs);
				temp_repeated_byte_buffs.writeBytes(t2_buffs);
			}
			output.writeInt(temp_repeated_byte_buffs.length);
			output.writeBytes(temp_repeated_byte_buffs);
			output.writeInt(this.result_type);
			output.writeInt(this.result_value);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.dest_id = input.readInt();
			this.is_erupt = input.readBoolean();
			this.is_no_defence = input.readBoolean();
			this.is_miss = input.readBoolean();
			this.dest_type = input.readInt();
			var byte_dest_tile_size:int = input.readInt();
			if (byte_dest_tile_size > 0) {				this.dest_tile = new p_map_tile;
				var byte_dest_tile:ByteArray = new ByteArray;
				input.readBytes(byte_dest_tile, 0, byte_dest_tile_size);
				this.dest_tile.readFromDataOutput(byte_dest_tile);
			}
			var size_buffs:int = input.readShort();
			var length_buffs:int = input.readInt();
			if (length_buffs > 0) {
				var byte_buffs:ByteArray = new ByteArray; 
				input.readBytes(byte_buffs, 0, length_buffs);
				for(i=0; i<size_buffs; i++) {
					var tmp_buffs:p_actor_buf = new p_actor_buf;
					var tmp_buffs_length:int = byte_buffs.readInt();
					var tmp_buffs_byte:ByteArray = new ByteArray;
					byte_buffs.readBytes(tmp_buffs_byte, 0, tmp_buffs_length);
					tmp_buffs.readFromDataOutput(tmp_buffs_byte);
					this.buffs.push(tmp_buffs);
				}
			}
			this.result_type = input.readInt();
			this.result_value = input.readInt();
		}
	}
}
