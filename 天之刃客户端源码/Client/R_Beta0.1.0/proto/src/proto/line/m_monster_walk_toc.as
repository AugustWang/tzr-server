package proto.line {
	import proto.common.p_map_monster;
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_walk_toc extends Message
	{
		public var monsterinfo:p_map_monster = null;
		public var pos:p_pos = null;
		public function m_monster_walk_toc() {
			super();
			this.monsterinfo = new p_map_monster;
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_monster_walk_toc", m_monster_walk_toc);
		}
		public override function getMethodName():String {
			return 'monster_walk';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_monsterinfo:ByteArray = new ByteArray;
			this.monsterinfo.writeToDataOutput(tmp_monsterinfo);
			var size_tmp_monsterinfo:int = tmp_monsterinfo.length;
			output.writeInt(size_tmp_monsterinfo);
			output.writeBytes(tmp_monsterinfo);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_monsterinfo_size:int = input.readInt();
			if (byte_monsterinfo_size > 0) {				this.monsterinfo = new p_map_monster;
				var byte_monsterinfo:ByteArray = new ByteArray;
				input.readBytes(byte_monsterinfo, 0, byte_monsterinfo_size);
				this.monsterinfo.readFromDataOutput(byte_monsterinfo);
			}
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
		}
	}
}
