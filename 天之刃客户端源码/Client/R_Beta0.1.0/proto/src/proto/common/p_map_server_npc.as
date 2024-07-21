package proto.common {
	import proto.common.p_pos;
	import proto.common.p_walk_path;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_server_npc extends Message
	{
		public var npc_id:int = 0;
		public var type_id:int = 0;
		public var npc_name:String = "";
		public var npc_type:int = 0;
		public var state:int = 0;
		public var max_mp:int = 0;
		public var max_hp:int = 0;
		public var hp:int = 0;
		public var mp:int = 0;
		public var map_id:int = 0;
		public var pos:p_pos = null;
		public var move_speed:int = 0;
		public var last_walk_path:p_walk_path = null;
		public var state_buffs:Array = new Array;
		public var is_undead:Boolean = true;
		public var npc_country:int = 0;
		public function p_map_server_npc() {
			super();
			this.pos = new p_pos;
			this.last_walk_path = new p_walk_path;

			flash.net.registerClassAlias("copy.proto.common.p_map_server_npc", p_map_server_npc);
		}
		public override function getMethodName():String {
			return 'map_server';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.type_id);
			if (this.npc_name != null) {				output.writeUTF(this.npc_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.npc_type);
			output.writeInt(this.state);
			output.writeInt(this.max_mp);
			output.writeInt(this.max_hp);
			output.writeInt(this.hp);
			output.writeInt(this.mp);
			output.writeInt(this.map_id);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.move_speed);
			var tmp_last_walk_path:ByteArray = new ByteArray;
			this.last_walk_path.writeToDataOutput(tmp_last_walk_path);
			var size_tmp_last_walk_path:int = tmp_last_walk_path.length;
			output.writeInt(size_tmp_last_walk_path);
			output.writeBytes(tmp_last_walk_path);
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
			output.writeBoolean(this.is_undead);
			output.writeInt(this.npc_country);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.type_id = input.readInt();
			this.npc_name = input.readUTF();
			this.npc_type = input.readInt();
			this.state = input.readInt();
			this.max_mp = input.readInt();
			this.max_hp = input.readInt();
			this.hp = input.readInt();
			this.mp = input.readInt();
			this.map_id = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.move_speed = input.readInt();
			var byte_last_walk_path_size:int = input.readInt();
			if (byte_last_walk_path_size > 0) {				this.last_walk_path = new p_walk_path;
				var byte_last_walk_path:ByteArray = new ByteArray;
				input.readBytes(byte_last_walk_path, 0, byte_last_walk_path_size);
				this.last_walk_path.readFromDataOutput(byte_last_walk_path);
			}
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
			this.is_undead = input.readBoolean();
			this.npc_country = input.readInt();
		}
	}
}
