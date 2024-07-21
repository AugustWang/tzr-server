package proto.common {
	import proto.common.p_pos;
	import proto.common.p_walk_path;
	import proto.common.p_pos;
	import proto.common.p_skin;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_role extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var faction_id:int = 0;
		public var cur_title:String = "";
		public var family_id:int = 0;
		public var family_name:String = "";
		public var pos:p_pos = null;
		public var last_walk_path:p_walk_path = null;
		public var last_key_path:p_pos = null;
		public var hp:int = 0;
		public var max_hp:int = 0;
		public var mp:int = 0;
		public var max_mp:int = 0;
		public var skin:p_skin = null;
		public var move_speed:int = 0;
		public var team_id:int = 0;
		public var level:int = 0;
		public var pk_point:int = 0;
		public var state:int = 0;
		public var gray_name:Boolean = true;
		public var state_buffs:Array = new Array;
		public var show_cloth:Boolean = true;
		public var cur_title_color:String = "ffffff";
		public var equip_ring_color:int = 0;
		public var show_equip_ring:Boolean = true;
		public var vip_level:int = 0;
		public var mount_color:int = 0;
		public var sex:int = 0;
		public var category:int = 0;
		public function p_map_role() {
			super();
			this.pos = new p_pos;
			this.last_walk_path = new p_walk_path;
			this.last_key_path = new p_pos;
			this.skin = new p_skin;

			flash.net.registerClassAlias("copy.proto.common.p_map_role", p_map_role);
		}
		public override function getMethodName():String {
			return 'map_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			if (this.cur_title != null) {				output.writeUTF(this.cur_title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			var tmp_last_walk_path:ByteArray = new ByteArray;
			this.last_walk_path.writeToDataOutput(tmp_last_walk_path);
			var size_tmp_last_walk_path:int = tmp_last_walk_path.length;
			output.writeInt(size_tmp_last_walk_path);
			output.writeBytes(tmp_last_walk_path);
			var tmp_last_key_path:ByteArray = new ByteArray;
			this.last_key_path.writeToDataOutput(tmp_last_key_path);
			var size_tmp_last_key_path:int = tmp_last_key_path.length;
			output.writeInt(size_tmp_last_key_path);
			output.writeBytes(tmp_last_key_path);
			output.writeInt(this.hp);
			output.writeInt(this.max_hp);
			output.writeInt(this.mp);
			output.writeInt(this.max_mp);
			var tmp_skin:ByteArray = new ByteArray;
			this.skin.writeToDataOutput(tmp_skin);
			var size_tmp_skin:int = tmp_skin.length;
			output.writeInt(size_tmp_skin);
			output.writeBytes(tmp_skin);
			output.writeInt(this.move_speed);
			output.writeInt(this.team_id);
			output.writeInt(this.level);
			output.writeInt(this.pk_point);
			output.writeInt(this.state);
			output.writeBoolean(this.gray_name);
			var size_state_buffs:int = this.state_buffs.length;
			output.writeShort(size_state_buffs);
			var temp_repeated_byte_state_buffs:ByteArray= new ByteArray;
			for(i=0; i<size_state_buffs; i++) {
				var t2_state_buffs:ByteArray = new ByteArray;
				var tVo_state_buffs:p_actor_buf = this.state_buffs[i] as p_actor_buf;
				tVo_state_buffs.writeToDataOutput(t2_state_buffs);
				var len_tVo_state_buffs:int = t2_state_buffs.length;
				temp_repeated_byte_state_buffs.writeInt(len_tVo_state_buffs);
				temp_repeated_byte_state_buffs.writeBytes(t2_state_buffs);
			}
			output.writeInt(temp_repeated_byte_state_buffs.length);
			output.writeBytes(temp_repeated_byte_state_buffs);
			output.writeBoolean(this.show_cloth);
			if (this.cur_title_color != null) {				output.writeUTF(this.cur_title_color.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.equip_ring_color);
			output.writeBoolean(this.show_equip_ring);
			output.writeInt(this.vip_level);
			output.writeInt(this.mount_color);
			output.writeInt(this.sex);
			output.writeInt(this.category);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.faction_id = input.readInt();
			this.cur_title = input.readUTF();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			var byte_last_walk_path_size:int = input.readInt();
			if (byte_last_walk_path_size > 0) {				this.last_walk_path = new p_walk_path;
				var byte_last_walk_path:ByteArray = new ByteArray;
				input.readBytes(byte_last_walk_path, 0, byte_last_walk_path_size);
				this.last_walk_path.readFromDataOutput(byte_last_walk_path);
			}
			var byte_last_key_path_size:int = input.readInt();
			if (byte_last_key_path_size > 0) {				this.last_key_path = new p_pos;
				var byte_last_key_path:ByteArray = new ByteArray;
				input.readBytes(byte_last_key_path, 0, byte_last_key_path_size);
				this.last_key_path.readFromDataOutput(byte_last_key_path);
			}
			this.hp = input.readInt();
			this.max_hp = input.readInt();
			this.mp = input.readInt();
			this.max_mp = input.readInt();
			var byte_skin_size:int = input.readInt();
			if (byte_skin_size > 0) {				this.skin = new p_skin;
				var byte_skin:ByteArray = new ByteArray;
				input.readBytes(byte_skin, 0, byte_skin_size);
				this.skin.readFromDataOutput(byte_skin);
			}
			this.move_speed = input.readInt();
			this.team_id = input.readInt();
			this.level = input.readInt();
			this.pk_point = input.readInt();
			this.state = input.readInt();
			this.gray_name = input.readBoolean();
			var size_state_buffs:int = input.readShort();
			var length_state_buffs:int = input.readInt();
			if (length_state_buffs > 0) {
				var byte_state_buffs:ByteArray = new ByteArray; 
				input.readBytes(byte_state_buffs, 0, length_state_buffs);
				for(i=0; i<size_state_buffs; i++) {
					var tmp_state_buffs:p_actor_buf = new p_actor_buf;
					var tmp_state_buffs_length:int = byte_state_buffs.readInt();
					var tmp_state_buffs_byte:ByteArray = new ByteArray;
					byte_state_buffs.readBytes(tmp_state_buffs_byte, 0, tmp_state_buffs_length);
					tmp_state_buffs.readFromDataOutput(tmp_state_buffs_byte);
					this.state_buffs.push(tmp_state_buffs);
				}
			}
			this.show_cloth = input.readBoolean();
			this.cur_title_color = input.readUTF();
			this.equip_ring_color = input.readInt();
			this.show_equip_ring = input.readBoolean();
			this.vip_level = input.readInt();
			this.mount_color = input.readInt();
			this.sex = input.readInt();
			this.category = input.readInt();
		}
	}
}
