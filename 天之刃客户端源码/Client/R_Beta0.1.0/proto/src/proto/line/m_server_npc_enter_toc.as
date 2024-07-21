package proto.line {
	import proto.common.p_map_server_npc;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_server_npc_enter_toc extends Message
	{
		public var server_npcs:Array = new Array;
		public function m_server_npc_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_server_npc_enter_toc", m_server_npc_enter_toc);
		}
		public override function getMethodName():String {
			return 'server_npc_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_server_npcs:int = this.server_npcs.length;
			output.writeShort(size_server_npcs);
			var temp_repeated_byte_server_npcs:ByteArray= new ByteArray;
			for(i=0; i<size_server_npcs; i++) {
				var t2_server_npcs:ByteArray = new ByteArray;
				var tVo_server_npcs:p_map_server_npc = this.server_npcs[i] as p_map_server_npc;
				tVo_server_npcs.writeToDataOutput(t2_server_npcs);
				var len_tVo_server_npcs:int = t2_server_npcs.length;
				temp_repeated_byte_server_npcs.writeInt(len_tVo_server_npcs);
				temp_repeated_byte_server_npcs.writeBytes(t2_server_npcs);
			}
			output.writeInt(temp_repeated_byte_server_npcs.length);
			output.writeBytes(temp_repeated_byte_server_npcs);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_server_npcs:int = input.readShort();
			var length_server_npcs:int = input.readInt();
			if (length_server_npcs > 0) {
				var byte_server_npcs:ByteArray = new ByteArray; 
				input.readBytes(byte_server_npcs, 0, length_server_npcs);
				for(i=0; i<size_server_npcs; i++) {
					var tmp_server_npcs:p_map_server_npc = new p_map_server_npc;
					var tmp_server_npcs_length:int = byte_server_npcs.readInt();
					var tmp_server_npcs_byte:ByteArray = new ByteArray;
					byte_server_npcs.readBytes(tmp_server_npcs_byte, 0, tmp_server_npcs_length);
					tmp_server_npcs.readFromDataOutput(tmp_server_npcs_byte);
					this.server_npcs.push(tmp_server_npcs);
				}
			}
		}
	}
}
