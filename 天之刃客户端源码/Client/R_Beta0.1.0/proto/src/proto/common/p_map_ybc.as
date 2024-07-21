package proto.common {
	import proto.common.p_pos;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_ybc extends Message
	{
		public var ybc_id:int = 0;
		public var status:int = 0;
		public var hp:int = 0;
		public var max_hp:int = 0;
		public var pos:p_pos = null;
		public var move_speed:int = 0;
		public var name:String = "";
		public var create_type:int = 0;
		public var creator_id:int = 0;
		public var color:int = 0;
		public var create_time:int = 0;
		public var end_time:int = 0;
		public var buffs:Array = new Array;
		public var group_id:int = 0;
		public var group_type:int = 0;
		public var can_attack:Boolean = true;
		public var faction_id:int = 0;
		public var physical_defence:int = 0;
		public var magic_defence:int = 0;
		public var recover_speed:int = 0;
		public var level:int = 0;
		public function p_map_ybc() {
			super();
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_map_ybc", p_map_ybc);
		}
		public override function getMethodName():String {
			return 'map';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.ybc_id);
			output.writeInt(this.status);
			output.writeInt(this.hp);
			output.writeInt(this.max_hp);
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
			output.writeInt(this.move_speed);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.create_type);
			output.writeInt(this.creator_id);
			output.writeInt(this.color);
			output.writeInt(this.create_time);
			output.writeInt(this.end_time);
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
			output.writeInt(this.group_id);
			output.writeInt(this.group_type);
			output.writeBoolean(this.can_attack);
			output.writeInt(this.faction_id);
			output.writeInt(this.physical_defence);
			output.writeInt(this.magic_defence);
			output.writeInt(this.recover_speed);
			output.writeInt(this.level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.ybc_id = input.readInt();
			this.status = input.readInt();
			this.hp = input.readInt();
			this.max_hp = input.readInt();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
			this.move_speed = input.readInt();
			this.name = input.readUTF();
			this.create_type = input.readInt();
			this.creator_id = input.readInt();
			this.color = input.readInt();
			this.create_time = input.readInt();
			this.end_time = input.readInt();
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
			this.group_id = input.readInt();
			this.group_type = input.readInt();
			this.can_attack = input.readBoolean();
			this.faction_id = input.readInt();
			this.physical_defence = input.readInt();
			this.magic_defence = input.readInt();
			this.recover_speed = input.readInt();
			this.level = input.readInt();
		}
	}
}
