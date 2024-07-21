package proto.line {
	import proto.common.p_map_role;
	import proto.common.p_map_monster;
	import proto.common.p_map_server_npc;
	import proto.common.p_map_ybc;
	import proto.common.p_map_pet;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_update_actor_mapinfo_toc extends Message
	{
		public var actor_id:int = 0;
		public var actor_type:int = 0;
		public var role_info:p_map_role = null;
		public var monster_info:p_map_monster = null;
		public var server_npc:p_map_server_npc = null;
		public var ybc_info:p_map_ybc = null;
		public var pet_info:p_map_pet = null;
		public function m_map_update_actor_mapinfo_toc() {
			super();
			this.role_info = new p_map_role;
			this.monster_info = new p_map_monster;
			this.server_npc = new p_map_server_npc;
			this.ybc_info = new p_map_ybc;
			this.pet_info = new p_map_pet;

			flash.net.registerClassAlias("copy.proto.line.m_map_update_actor_mapinfo_toc", m_map_update_actor_mapinfo_toc);
		}
		public override function getMethodName():String {
			return 'map_update_actor_mapinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.actor_id);
			output.writeInt(this.actor_type);
			var tmp_role_info:ByteArray = new ByteArray;
			this.role_info.writeToDataOutput(tmp_role_info);
			var size_tmp_role_info:int = tmp_role_info.length;
			output.writeInt(size_tmp_role_info);
			output.writeBytes(tmp_role_info);
			var tmp_monster_info:ByteArray = new ByteArray;
			this.monster_info.writeToDataOutput(tmp_monster_info);
			var size_tmp_monster_info:int = tmp_monster_info.length;
			output.writeInt(size_tmp_monster_info);
			output.writeBytes(tmp_monster_info);
			var tmp_server_npc:ByteArray = new ByteArray;
			this.server_npc.writeToDataOutput(tmp_server_npc);
			var size_tmp_server_npc:int = tmp_server_npc.length;
			output.writeInt(size_tmp_server_npc);
			output.writeBytes(tmp_server_npc);
			var tmp_ybc_info:ByteArray = new ByteArray;
			this.ybc_info.writeToDataOutput(tmp_ybc_info);
			var size_tmp_ybc_info:int = tmp_ybc_info.length;
			output.writeInt(size_tmp_ybc_info);
			output.writeBytes(tmp_ybc_info);
			var tmp_pet_info:ByteArray = new ByteArray;
			this.pet_info.writeToDataOutput(tmp_pet_info);
			var size_tmp_pet_info:int = tmp_pet_info.length;
			output.writeInt(size_tmp_pet_info);
			output.writeBytes(tmp_pet_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.actor_id = input.readInt();
			this.actor_type = input.readInt();
			var byte_role_info_size:int = input.readInt();
			if (byte_role_info_size > 0) {				this.role_info = new p_map_role;
				var byte_role_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_info, 0, byte_role_info_size);
				this.role_info.readFromDataOutput(byte_role_info);
			}
			var byte_monster_info_size:int = input.readInt();
			if (byte_monster_info_size > 0) {				this.monster_info = new p_map_monster;
				var byte_monster_info:ByteArray = new ByteArray;
				input.readBytes(byte_monster_info, 0, byte_monster_info_size);
				this.monster_info.readFromDataOutput(byte_monster_info);
			}
			var byte_server_npc_size:int = input.readInt();
			if (byte_server_npc_size > 0) {				this.server_npc = new p_map_server_npc;
				var byte_server_npc:ByteArray = new ByteArray;
				input.readBytes(byte_server_npc, 0, byte_server_npc_size);
				this.server_npc.readFromDataOutput(byte_server_npc);
			}
			var byte_ybc_info_size:int = input.readInt();
			if (byte_ybc_info_size > 0) {				this.ybc_info = new p_map_ybc;
				var byte_ybc_info:ByteArray = new ByteArray;
				input.readBytes(byte_ybc_info, 0, byte_ybc_info_size);
				this.ybc_info.readFromDataOutput(byte_ybc_info);
			}
			var byte_pet_info_size:int = input.readInt();
			if (byte_pet_info_size > 0) {				this.pet_info = new p_map_pet;
				var byte_pet_info:ByteArray = new ByteArray;
				input.readBytes(byte_pet_info, 0, byte_pet_info_size);
				this.pet_info.readFromDataOutput(byte_pet_info);
			}
		}
	}
}
