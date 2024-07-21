package proto.line {
	import proto.common.p_map_server_npc;
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_server_npc_walk_toc extends Message
	{
		public var server_npc_info:p_map_server_npc = null;
		public var pos:p_pos = null;
		public function m_server_npc_walk_toc() {
			super();
			this.server_npc_info = new p_map_server_npc;
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.m_server_npc_walk_toc", m_server_npc_walk_toc);
		}
		public override function getMethodName():String {
			return 'server_npc_walk';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_server_npc_info:ByteArray = new ByteArray;
			this.server_npc_info.writeToDataOutput(tmp_server_npc_info);
			var size_tmp_server_npc_info:int = tmp_server_npc_info.length;
			output.writeInt(size_tmp_server_npc_info);
			output.writeBytes(tmp_server_npc_info);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_server_npc_info_size:int = input.readInt();
			if (byte_server_npc_info_size > 0) {				this.server_npc_info = new p_map_server_npc;
				var byte_server_npc_info:ByteArray = new ByteArray;
				input.readBytes(byte_server_npc_info, 0, byte_server_npc_info_size);
				this.server_npc_info.readFromDataOutput(byte_server_npc_info);
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
