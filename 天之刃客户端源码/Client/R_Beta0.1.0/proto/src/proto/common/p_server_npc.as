package proto.common {
	import proto.common.p_pos;
	import proto.common.p_enemy;
	import proto.common.p_enemy;
	import proto.common.p_enemy;
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_server_npc extends Message
	{
		public var npc_id:int = 0;
		public var type_id:int = 0;
		public var npc_name:String = "";
		public var npc_type:int = 0;
		public var state:int = 0;
		public var map_id:int = 0;
		public var level:int = 0;
		public var hp:int = 0;
		public var mp:int = 0;
		public var reborn_pos:p_pos = null;
		public var first_enemies:Array = new Array;
		public var second_enemies:Array = new Array;
		public var third_enemies:Array = new Array;
		public var max_mp:int = 0;
		public var max_hp:int = 0;
		public var buffs:Array = new Array;
		public var npc_country:int = 0;
		public var is_undead:Boolean = true;
		public var phy_defence:int = 0;
		public var magic_defence:int = 0;
		public var blood_resume_speed:int = 0;
		public var magic_resume_speed:int = 0;
		public var dead_attack:int = 0;
		public var lucky:int = 0;
		public var move_speed:int = 0;
		public var attack_speed:int = 0;
		public var miss:int = 0;
		public var no_defence:int = 0;
		public var min_attack:int = 0;
		public var max_attack:int = 0;
		public var phy_anti:int = 0;
		public var magic_anti:int = 0;
		public var poisoning_resist:int = 0;
		public var dizzy_resist:int = 0;
		public var freeze_resist:int = 0;
		public var equip_score:int = 0;
		public var spec_score_one:int = 0;
		public var spec_score_two:int = 0;
		public var hit_rate:int = 10000;
		public function p_server_npc() {
			super();
			this.reborn_pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.common.p_server_npc", p_server_npc);
		}
		public override function getMethodName():String {
			return 'server';
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
			output.writeInt(this.map_id);
			output.writeInt(this.level);
			output.writeInt(this.hp);
			output.writeInt(this.mp);
			var tmp_reborn_pos:ByteArray = new ByteArray;
			this.reborn_pos.writeToDataOutput(tmp_reborn_pos);
			var size_tmp_reborn_pos:int = tmp_reborn_pos.length;
			output.writeInt(size_tmp_reborn_pos);
			output.writeBytes(tmp_reborn_pos);
			var size_first_enemies:int = this.first_enemies.length;
			output.writeShort(size_first_enemies);
			var temp_repeated_byte_first_enemies:ByteArray= new ByteArray;
			for(i=0; i<size_first_enemies; i++) {
				var t2_first_enemies:ByteArray = new ByteArray;
				var tVo_first_enemies:p_enemy = this.first_enemies[i] as p_enemy;
				tVo_first_enemies.writeToDataOutput(t2_first_enemies);
				var len_tVo_first_enemies:int = t2_first_enemies.length;
				temp_repeated_byte_first_enemies.writeInt(len_tVo_first_enemies);
				temp_repeated_byte_first_enemies.writeBytes(t2_first_enemies);
			}
			output.writeInt(temp_repeated_byte_first_enemies.length);
			output.writeBytes(temp_repeated_byte_first_enemies);
			var size_second_enemies:int = this.second_enemies.length;
			output.writeShort(size_second_enemies);
			var temp_repeated_byte_second_enemies:ByteArray= new ByteArray;
			for(i=0; i<size_second_enemies; i++) {
				var t2_second_enemies:ByteArray = new ByteArray;
				var tVo_second_enemies:p_enemy = this.second_enemies[i] as p_enemy;
				tVo_second_enemies.writeToDataOutput(t2_second_enemies);
				var len_tVo_second_enemies:int = t2_second_enemies.length;
				temp_repeated_byte_second_enemies.writeInt(len_tVo_second_enemies);
				temp_repeated_byte_second_enemies.writeBytes(t2_second_enemies);
			}
			output.writeInt(temp_repeated_byte_second_enemies.length);
			output.writeBytes(temp_repeated_byte_second_enemies);
			var size_third_enemies:int = this.third_enemies.length;
			output.writeShort(size_third_enemies);
			var temp_repeated_byte_third_enemies:ByteArray= new ByteArray;
			for(i=0; i<size_third_enemies; i++) {
				var t2_third_enemies:ByteArray = new ByteArray;
				var tVo_third_enemies:p_enemy = this.third_enemies[i] as p_enemy;
				tVo_third_enemies.writeToDataOutput(t2_third_enemies);
				var len_tVo_third_enemies:int = t2_third_enemies.length;
				temp_repeated_byte_third_enemies.writeInt(len_tVo_third_enemies);
				temp_repeated_byte_third_enemies.writeBytes(t2_third_enemies);
			}
			output.writeInt(temp_repeated_byte_third_enemies.length);
			output.writeBytes(temp_repeated_byte_third_enemies);
			output.writeInt(this.max_mp);
			output.writeInt(this.max_hp);
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
			output.writeInt(this.npc_country);
			output.writeBoolean(this.is_undead);
			output.writeInt(this.phy_defence);
			output.writeInt(this.magic_defence);
			output.writeInt(this.blood_resume_speed);
			output.writeInt(this.magic_resume_speed);
			output.writeInt(this.dead_attack);
			output.writeInt(this.lucky);
			output.writeInt(this.move_speed);
			output.writeInt(this.attack_speed);
			output.writeInt(this.miss);
			output.writeInt(this.no_defence);
			output.writeInt(this.min_attack);
			output.writeInt(this.max_attack);
			output.writeInt(this.phy_anti);
			output.writeInt(this.magic_anti);
			output.writeInt(this.poisoning_resist);
			output.writeInt(this.dizzy_resist);
			output.writeInt(this.freeze_resist);
			output.writeInt(this.equip_score);
			output.writeInt(this.spec_score_one);
			output.writeInt(this.spec_score_two);
			output.writeInt(this.hit_rate);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.type_id = input.readInt();
			this.npc_name = input.readUTF();
			this.npc_type = input.readInt();
			this.state = input.readInt();
			this.map_id = input.readInt();
			this.level = input.readInt();
			this.hp = input.readInt();
			this.mp = input.readInt();
			var byte_reborn_pos_size:int = input.readInt();
			if (byte_reborn_pos_size > 0) {				this.reborn_pos = new p_pos;
				var byte_reborn_pos:ByteArray = new ByteArray;
				input.readBytes(byte_reborn_pos, 0, byte_reborn_pos_size);
				this.reborn_pos.readFromDataOutput(byte_reborn_pos);
			}
			var size_first_enemies:int = input.readShort();
			var length_first_enemies:int = input.readInt();
			if (length_first_enemies > 0) {
				var byte_first_enemies:ByteArray = new ByteArray; 
				input.readBytes(byte_first_enemies, 0, length_first_enemies);
				for(i=0; i<size_first_enemies; i++) {
					var tmp_first_enemies:p_enemy = new p_enemy;
					var tmp_first_enemies_length:int = byte_first_enemies.readInt();
					var tmp_first_enemies_byte:ByteArray = new ByteArray;
					byte_first_enemies.readBytes(tmp_first_enemies_byte, 0, tmp_first_enemies_length);
					tmp_first_enemies.readFromDataOutput(tmp_first_enemies_byte);
					this.first_enemies.push(tmp_first_enemies);
				}
			}
			var size_second_enemies:int = input.readShort();
			var length_second_enemies:int = input.readInt();
			if (length_second_enemies > 0) {
				var byte_second_enemies:ByteArray = new ByteArray; 
				input.readBytes(byte_second_enemies, 0, length_second_enemies);
				for(i=0; i<size_second_enemies; i++) {
					var tmp_second_enemies:p_enemy = new p_enemy;
					var tmp_second_enemies_length:int = byte_second_enemies.readInt();
					var tmp_second_enemies_byte:ByteArray = new ByteArray;
					byte_second_enemies.readBytes(tmp_second_enemies_byte, 0, tmp_second_enemies_length);
					tmp_second_enemies.readFromDataOutput(tmp_second_enemies_byte);
					this.second_enemies.push(tmp_second_enemies);
				}
			}
			var size_third_enemies:int = input.readShort();
			var length_third_enemies:int = input.readInt();
			if (length_third_enemies > 0) {
				var byte_third_enemies:ByteArray = new ByteArray; 
				input.readBytes(byte_third_enemies, 0, length_third_enemies);
				for(i=0; i<size_third_enemies; i++) {
					var tmp_third_enemies:p_enemy = new p_enemy;
					var tmp_third_enemies_length:int = byte_third_enemies.readInt();
					var tmp_third_enemies_byte:ByteArray = new ByteArray;
					byte_third_enemies.readBytes(tmp_third_enemies_byte, 0, tmp_third_enemies_length);
					tmp_third_enemies.readFromDataOutput(tmp_third_enemies_byte);
					this.third_enemies.push(tmp_third_enemies);
				}
			}
			this.max_mp = input.readInt();
			this.max_hp = input.readInt();
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
			this.npc_country = input.readInt();
			this.is_undead = input.readBoolean();
			this.phy_defence = input.readInt();
			this.magic_defence = input.readInt();
			this.blood_resume_speed = input.readInt();
			this.magic_resume_speed = input.readInt();
			this.dead_attack = input.readInt();
			this.lucky = input.readInt();
			this.move_speed = input.readInt();
			this.attack_speed = input.readInt();
			this.miss = input.readInt();
			this.no_defence = input.readInt();
			this.min_attack = input.readInt();
			this.max_attack = input.readInt();
			this.phy_anti = input.readInt();
			this.magic_anti = input.readInt();
			this.poisoning_resist = input.readInt();
			this.dizzy_resist = input.readInt();
			this.freeze_resist = input.readInt();
			this.equip_score = input.readInt();
			this.spec_score_one = input.readInt();
			this.spec_score_two = input.readInt();
			this.hit_rate = input.readInt();
		}
	}
}
