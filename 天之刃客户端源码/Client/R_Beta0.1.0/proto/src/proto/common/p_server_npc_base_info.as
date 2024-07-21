package proto.common {
	import proto.common.p_refresh_info;
	import proto.common.p_monster_skill;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_server_npc_base_info extends Message
	{
		public var type_id:int = 0;
		public var npc_name:String = "";
		public var npc_country:int = 0;
		public var npc_type:int = 0;
		public var level:int = 0;
		public var max_hp:int = 0;
		public var max_mp:int = 0;
		public var min_attack:int = 0;
		public var max_attack:int = 0;
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
		public var phy_anti:int = 0;
		public var magic_anti:int = 0;
		public var poisoning_resist:int = 0;
		public var dizzy_resist:int = 0;
		public var freeze_resist:int = 0;
		public var equip_score:int = 0;
		public var spec_score_one:int = 0;
		public var spec_score_two:int = 0;
		public var hit_rate:int = 10000;
		public var attack_type:int = 0;
		public var is_undead:Boolean = true;
		public var guard_radius:int = 0;
		public var attention_radius:int = 0;
		public var activity_radius:int = 0;
		public var refresh:p_refresh_info = null;
		public var skills:Array = new Array;
		public var gongxun:int = 0;
		public function p_server_npc_base_info() {
			super();
			this.refresh = new p_refresh_info;

			flash.net.registerClassAlias("copy.proto.common.p_server_npc_base_info", p_server_npc_base_info);
		}
		public override function getMethodName():String {
			return 'server_npc_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			if (this.npc_name != null) {				output.writeUTF(this.npc_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.npc_country);
			output.writeInt(this.npc_type);
			output.writeInt(this.level);
			output.writeInt(this.max_hp);
			output.writeInt(this.max_mp);
			output.writeInt(this.min_attack);
			output.writeInt(this.max_attack);
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
			output.writeInt(this.phy_anti);
			output.writeInt(this.magic_anti);
			output.writeInt(this.poisoning_resist);
			output.writeInt(this.dizzy_resist);
			output.writeInt(this.freeze_resist);
			output.writeInt(this.equip_score);
			output.writeInt(this.spec_score_one);
			output.writeInt(this.spec_score_two);
			output.writeInt(this.hit_rate);
			output.writeInt(this.attack_type);
			output.writeBoolean(this.is_undead);
			output.writeInt(this.guard_radius);
			output.writeInt(this.attention_radius);
			output.writeInt(this.activity_radius);
			var tmp_refresh:ByteArray = new ByteArray;
			this.refresh.writeToDataOutput(tmp_refresh);
			var size_tmp_refresh:int = tmp_refresh.length;
			output.writeInt(size_tmp_refresh);
			output.writeBytes(tmp_refresh);
			var size_skills:int = this.skills.length;
			output.writeShort(size_skills);
			var temp_repeated_byte_skills:ByteArray= new ByteArray;
			for(i=0; i<size_skills; i++) {
				var t2_skills:ByteArray = new ByteArray;
				var tVo_skills:p_monster_skill = this.skills[i] as p_monster_skill;
				tVo_skills.writeToDataOutput(t2_skills);
				var len_tVo_skills:int = t2_skills.length;
				temp_repeated_byte_skills.writeInt(len_tVo_skills);
				temp_repeated_byte_skills.writeBytes(t2_skills);
			}
			output.writeInt(temp_repeated_byte_skills.length);
			output.writeBytes(temp_repeated_byte_skills);
			output.writeInt(this.gongxun);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.npc_name = input.readUTF();
			this.npc_country = input.readInt();
			this.npc_type = input.readInt();
			this.level = input.readInt();
			this.max_hp = input.readInt();
			this.max_mp = input.readInt();
			this.min_attack = input.readInt();
			this.max_attack = input.readInt();
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
			this.phy_anti = input.readInt();
			this.magic_anti = input.readInt();
			this.poisoning_resist = input.readInt();
			this.dizzy_resist = input.readInt();
			this.freeze_resist = input.readInt();
			this.equip_score = input.readInt();
			this.spec_score_one = input.readInt();
			this.spec_score_two = input.readInt();
			this.hit_rate = input.readInt();
			this.attack_type = input.readInt();
			this.is_undead = input.readBoolean();
			this.guard_radius = input.readInt();
			this.attention_radius = input.readInt();
			this.activity_radius = input.readInt();
			var byte_refresh_size:int = input.readInt();
			if (byte_refresh_size > 0) {				this.refresh = new p_refresh_info;
				var byte_refresh:ByteArray = new ByteArray;
				input.readBytes(byte_refresh, 0, byte_refresh_size);
				this.refresh.readFromDataOutput(byte_refresh);
			}
			var size_skills:int = input.readShort();
			var length_skills:int = input.readInt();
			if (length_skills > 0) {
				var byte_skills:ByteArray = new ByteArray; 
				input.readBytes(byte_skills, 0, length_skills);
				for(i=0; i<size_skills; i++) {
					var tmp_skills:p_monster_skill = new p_monster_skill;
					var tmp_skills_length:int = byte_skills.readInt();
					var tmp_skills_byte:ByteArray = new ByteArray;
					byte_skills.readBytes(tmp_skills_byte, 0, tmp_skills_length);
					tmp_skills.readFromDataOutput(tmp_skills_byte);
					this.skills.push(tmp_skills);
				}
			}
			this.gongxun = input.readInt();
		}
	}
}
