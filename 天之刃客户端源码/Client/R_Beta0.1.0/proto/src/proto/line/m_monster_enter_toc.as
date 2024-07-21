package proto.line {
	import proto.common.p_map_monster;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_monster_enter_toc extends Message
	{
		public var monsters:Array = new Array;
		public function m_monster_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_monster_enter_toc", m_monster_enter_toc);
		}
		public override function getMethodName():String {
			return 'monster_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_monsters:int = this.monsters.length;
			output.writeShort(size_monsters);
			var temp_repeated_byte_monsters:ByteArray= new ByteArray;
			for(i=0; i<size_monsters; i++) {
				var t2_monsters:ByteArray = new ByteArray;
				var tVo_monsters:p_map_monster = this.monsters[i] as p_map_monster;
				tVo_monsters.writeToDataOutput(t2_monsters);
				var len_tVo_monsters:int = t2_monsters.length;
				temp_repeated_byte_monsters.writeInt(len_tVo_monsters);
				temp_repeated_byte_monsters.writeBytes(t2_monsters);
			}
			output.writeInt(temp_repeated_byte_monsters.length);
			output.writeBytes(temp_repeated_byte_monsters);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_monsters:int = input.readShort();
			var length_monsters:int = input.readInt();
			if (length_monsters > 0) {
				var byte_monsters:ByteArray = new ByteArray; 
				input.readBytes(byte_monsters, 0, length_monsters);
				for(i=0; i<size_monsters; i++) {
					var tmp_monsters:p_map_monster = new p_map_monster;
					var tmp_monsters_length:int = byte_monsters.readInt();
					var tmp_monsters_byte:ByteArray = new ByteArray;
					byte_monsters.readBytes(tmp_monsters_byte, 0, tmp_monsters_length);
					tmp_monsters.readFromDataOutput(tmp_monsters_byte);
					this.monsters.push(tmp_monsters);
				}
			}
		}
	}
}
