package proto.line {
	import proto.common.p_map_role;
	import proto.common.p_map_monster;
	import proto.common.p_map_dropthing;
	import proto.common.p_map_stall;
	import proto.common.p_map_collect;
	import proto.common.p_map_ybc;
	import proto.common.p_role_pos;
	import proto.common.p_map_server_npc;
	import proto.common.p_map_role;
	import proto.common.p_map_pet;
	import proto.common.p_map_trap;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_map_enter_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var roles:Array = new Array;
		public var monsters:Array = new Array;
		public var dropthings:Array = new Array;
		public var stalls:Array = new Array;
		public var grafts:Array = new Array;
		public var ybcs:Array = new Array;
		public var pos:p_role_pos = null;
		public var server_npcs:Array = new Array;
		public var role_map_info:p_map_role = null;
		public var pets:Array = new Array;
		public var trap_list:Array = new Array;
		public function m_map_enter_toc() {
			super();
			this.pos = new p_role_pos;
			this.role_map_info = new p_map_role;

			flash.net.registerClassAlias("copy.proto.line.m_map_enter_toc", m_map_enter_toc);
		}
		public override function getMethodName():String {
			return 'map_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var size_roles:int = this.roles.length;
			output.writeShort(size_roles);
			var temp_repeated_byte_roles:ByteArray= new ByteArray;
			for(i=0; i<size_roles; i++) {
				var t2_roles:ByteArray = new ByteArray;
				var tVo_roles:p_map_role = this.roles[i] as p_map_role;
				tVo_roles.writeToDataOutput(t2_roles);
				var len_tVo_roles:int = t2_roles.length;
				temp_repeated_byte_roles.writeInt(len_tVo_roles);
				temp_repeated_byte_roles.writeBytes(t2_roles);
			}
			output.writeInt(temp_repeated_byte_roles.length);
			output.writeBytes(temp_repeated_byte_roles);
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
			var size_dropthings:int = this.dropthings.length;
			output.writeShort(size_dropthings);
			var temp_repeated_byte_dropthings:ByteArray= new ByteArray;
			for(i=0; i<size_dropthings; i++) {
				var t2_dropthings:ByteArray = new ByteArray;
				var tVo_dropthings:p_map_dropthing = this.dropthings[i] as p_map_dropthing;
				tVo_dropthings.writeToDataOutput(t2_dropthings);
				var len_tVo_dropthings:int = t2_dropthings.length;
				temp_repeated_byte_dropthings.writeInt(len_tVo_dropthings);
				temp_repeated_byte_dropthings.writeBytes(t2_dropthings);
			}
			output.writeInt(temp_repeated_byte_dropthings.length);
			output.writeBytes(temp_repeated_byte_dropthings);
			var size_stalls:int = this.stalls.length;
			output.writeShort(size_stalls);
			var temp_repeated_byte_stalls:ByteArray= new ByteArray;
			for(i=0; i<size_stalls; i++) {
				var t2_stalls:ByteArray = new ByteArray;
				var tVo_stalls:p_map_stall = this.stalls[i] as p_map_stall;
				tVo_stalls.writeToDataOutput(t2_stalls);
				var len_tVo_stalls:int = t2_stalls.length;
				temp_repeated_byte_stalls.writeInt(len_tVo_stalls);
				temp_repeated_byte_stalls.writeBytes(t2_stalls);
			}
			output.writeInt(temp_repeated_byte_stalls.length);
			output.writeBytes(temp_repeated_byte_stalls);
			var size_grafts:int = this.grafts.length;
			output.writeShort(size_grafts);
			var temp_repeated_byte_grafts:ByteArray= new ByteArray;
			for(i=0; i<size_grafts; i++) {
				var t2_grafts:ByteArray = new ByteArray;
				var tVo_grafts:p_map_collect = this.grafts[i] as p_map_collect;
				tVo_grafts.writeToDataOutput(t2_grafts);
				var len_tVo_grafts:int = t2_grafts.length;
				temp_repeated_byte_grafts.writeInt(len_tVo_grafts);
				temp_repeated_byte_grafts.writeBytes(t2_grafts);
			}
			output.writeInt(temp_repeated_byte_grafts.length);
			output.writeBytes(temp_repeated_byte_grafts);
			var size_ybcs:int = this.ybcs.length;
			output.writeShort(size_ybcs);
			var temp_repeated_byte_ybcs:ByteArray= new ByteArray;
			for(i=0; i<size_ybcs; i++) {
				var t2_ybcs:ByteArray = new ByteArray;
				var tVo_ybcs:p_map_ybc = this.ybcs[i] as p_map_ybc;
				tVo_ybcs.writeToDataOutput(t2_ybcs);
				var len_tVo_ybcs:int = t2_ybcs.length;
				temp_repeated_byte_ybcs.writeInt(len_tVo_ybcs);
				temp_repeated_byte_ybcs.writeBytes(t2_ybcs);
			}
			output.writeInt(temp_repeated_byte_ybcs.length);
			output.writeBytes(temp_repeated_byte_ybcs);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
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
			var tmp_role_map_info:ByteArray = new ByteArray;
			this.role_map_info.writeToDataOutput(tmp_role_map_info);
			var size_tmp_role_map_info:int = tmp_role_map_info.length;
			output.writeInt(size_tmp_role_map_info);
			output.writeBytes(tmp_role_map_info);
			var size_pets:int = this.pets.length;
			output.writeShort(size_pets);
			var temp_repeated_byte_pets:ByteArray= new ByteArray;
			for(i=0; i<size_pets; i++) {
				var t2_pets:ByteArray = new ByteArray;
				var tVo_pets:p_map_pet = this.pets[i] as p_map_pet;
				tVo_pets.writeToDataOutput(t2_pets);
				var len_tVo_pets:int = t2_pets.length;
				temp_repeated_byte_pets.writeInt(len_tVo_pets);
				temp_repeated_byte_pets.writeBytes(t2_pets);
			}
			output.writeInt(temp_repeated_byte_pets.length);
			output.writeBytes(temp_repeated_byte_pets);
			var size_trap_list:int = this.trap_list.length;
			output.writeShort(size_trap_list);
			var temp_repeated_byte_trap_list:ByteArray= new ByteArray;
			for(i=0; i<size_trap_list; i++) {
				var t2_trap_list:ByteArray = new ByteArray;
				var tVo_trap_list:p_map_trap = this.trap_list[i] as p_map_trap;
				tVo_trap_list.writeToDataOutput(t2_trap_list);
				var len_tVo_trap_list:int = t2_trap_list.length;
				temp_repeated_byte_trap_list.writeInt(len_tVo_trap_list);
				temp_repeated_byte_trap_list.writeBytes(t2_trap_list);
			}
			output.writeInt(temp_repeated_byte_trap_list.length);
			output.writeBytes(temp_repeated_byte_trap_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			var size_roles:int = input.readShort();
			var length_roles:int = input.readInt();
			if (length_roles > 0) {
				var byte_roles:ByteArray = new ByteArray; 
				input.readBytes(byte_roles, 0, length_roles);
				for(i=0; i<size_roles; i++) {
					var tmp_roles:p_map_role = new p_map_role;
					var tmp_roles_length:int = byte_roles.readInt();
					var tmp_roles_byte:ByteArray = new ByteArray;
					byte_roles.readBytes(tmp_roles_byte, 0, tmp_roles_length);
					tmp_roles.readFromDataOutput(tmp_roles_byte);
					this.roles.push(tmp_roles);
				}
			}
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
			var size_dropthings:int = input.readShort();
			var length_dropthings:int = input.readInt();
			if (length_dropthings > 0) {
				var byte_dropthings:ByteArray = new ByteArray; 
				input.readBytes(byte_dropthings, 0, length_dropthings);
				for(i=0; i<size_dropthings; i++) {
					var tmp_dropthings:p_map_dropthing = new p_map_dropthing;
					var tmp_dropthings_length:int = byte_dropthings.readInt();
					var tmp_dropthings_byte:ByteArray = new ByteArray;
					byte_dropthings.readBytes(tmp_dropthings_byte, 0, tmp_dropthings_length);
					tmp_dropthings.readFromDataOutput(tmp_dropthings_byte);
					this.dropthings.push(tmp_dropthings);
				}
			}
			var size_stalls:int = input.readShort();
			var length_stalls:int = input.readInt();
			if (length_stalls > 0) {
				var byte_stalls:ByteArray = new ByteArray; 
				input.readBytes(byte_stalls, 0, length_stalls);
				for(i=0; i<size_stalls; i++) {
					var tmp_stalls:p_map_stall = new p_map_stall;
					var tmp_stalls_length:int = byte_stalls.readInt();
					var tmp_stalls_byte:ByteArray = new ByteArray;
					byte_stalls.readBytes(tmp_stalls_byte, 0, tmp_stalls_length);
					tmp_stalls.readFromDataOutput(tmp_stalls_byte);
					this.stalls.push(tmp_stalls);
				}
			}
			var size_grafts:int = input.readShort();
			var length_grafts:int = input.readInt();
			if (length_grafts > 0) {
				var byte_grafts:ByteArray = new ByteArray; 
				input.readBytes(byte_grafts, 0, length_grafts);
				for(i=0; i<size_grafts; i++) {
					var tmp_grafts:p_map_collect = new p_map_collect;
					var tmp_grafts_length:int = byte_grafts.readInt();
					var tmp_grafts_byte:ByteArray = new ByteArray;
					byte_grafts.readBytes(tmp_grafts_byte, 0, tmp_grafts_length);
					tmp_grafts.readFromDataOutput(tmp_grafts_byte);
					this.grafts.push(tmp_grafts);
				}
			}
			var size_ybcs:int = input.readShort();
			var length_ybcs:int = input.readInt();
			if (length_ybcs > 0) {
				var byte_ybcs:ByteArray = new ByteArray; 
				input.readBytes(byte_ybcs, 0, length_ybcs);
				for(i=0; i<size_ybcs; i++) {
					var tmp_ybcs:p_map_ybc = new p_map_ybc;
					var tmp_ybcs_length:int = byte_ybcs.readInt();
					var tmp_ybcs_byte:ByteArray = new ByteArray;
					byte_ybcs.readBytes(tmp_ybcs_byte, 0, tmp_ybcs_length);
					tmp_ybcs.readFromDataOutput(tmp_ybcs_byte);
					this.ybcs.push(tmp_ybcs);
				}
			}
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_role_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
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
			var byte_role_map_info_size:int = input.readInt();
			if (byte_role_map_info_size > 0) {				this.role_map_info = new p_map_role;
				var byte_role_map_info:ByteArray = new ByteArray;
				input.readBytes(byte_role_map_info, 0, byte_role_map_info_size);
				this.role_map_info.readFromDataOutput(byte_role_map_info);
			}
			var size_pets:int = input.readShort();
			var length_pets:int = input.readInt();
			if (length_pets > 0) {
				var byte_pets:ByteArray = new ByteArray; 
				input.readBytes(byte_pets, 0, length_pets);
				for(i=0; i<size_pets; i++) {
					var tmp_pets:p_map_pet = new p_map_pet;
					var tmp_pets_length:int = byte_pets.readInt();
					var tmp_pets_byte:ByteArray = new ByteArray;
					byte_pets.readBytes(tmp_pets_byte, 0, tmp_pets_length);
					tmp_pets.readFromDataOutput(tmp_pets_byte);
					this.pets.push(tmp_pets);
				}
			}
			var size_trap_list:int = input.readShort();
			var length_trap_list:int = input.readInt();
			if (length_trap_list > 0) {
				var byte_trap_list:ByteArray = new ByteArray; 
				input.readBytes(byte_trap_list, 0, length_trap_list);
				for(i=0; i<size_trap_list; i++) {
					var tmp_trap_list:p_map_trap = new p_map_trap;
					var tmp_trap_list_length:int = byte_trap_list.readInt();
					var tmp_trap_list_byte:ByteArray = new ByteArray;
					byte_trap_list.readBytes(tmp_trap_list_byte, 0, tmp_trap_list_length);
					tmp_trap_list.readFromDataOutput(tmp_trap_list_byte);
					this.trap_list.push(tmp_trap_list);
				}
			}
		}
	}
}
