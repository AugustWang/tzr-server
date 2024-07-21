package proto.line {
	import proto.common.p_map_tile;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fight_attack_tos extends Message
	{
		public var tile:p_map_tile = null;
		public var skillid:int = 0;
		public var target_id:int = 0;
		public var target_type:int = 0;
		public var src_type:int = 1;
		public var dir:int = 0;
		public function m_fight_attack_tos() {
			super();
			this.tile = new p_map_tile;

			flash.net.registerClassAlias("copy.proto.line.m_fight_attack_tos", m_fight_attack_tos);
		}
		public override function getMethodName():String {
			return 'fight_attack';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_tile:ByteArray = new ByteArray;
			this.tile.writeToDataOutput(tmp_tile);
			var size_tmp_tile:int = tmp_tile.length;
			output.writeInt(size_tmp_tile);
			output.writeBytes(tmp_tile);
			output.writeInt(this.skillid);
			output.writeInt(this.target_id);
			output.writeInt(this.target_type);
			output.writeInt(this.src_type);
			output.writeInt(this.dir);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_tile_size:int = input.readInt();
			if (byte_tile_size > 0) {				this.tile = new p_map_tile;
				var byte_tile:ByteArray = new ByteArray;
				input.readBytes(byte_tile, 0, byte_tile_size);
				this.tile.readFromDataOutput(byte_tile);
			}
			this.skillid = input.readInt();
			this.target_id = input.readInt();
			this.target_type = input.readInt();
			this.src_type = input.readInt();
			this.dir = input.readInt();
		}
	}
}
