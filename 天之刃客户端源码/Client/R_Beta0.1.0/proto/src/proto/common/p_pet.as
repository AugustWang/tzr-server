package proto.common {
	import proto.common.p_actor_buf;
	import proto.common.p_pet_skill;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet extends Message
	{
		public var pet_id:int = 0;
		public var type_id:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var hp:int = 0;
		public var max_hp:int = 0;
		public var pet_name:String = "";
		public var color:int = 0;
		public var understanding:int = 0;
		public var sex:int = 0;
		public var pk_mode:int = 0;
		public var bind:Boolean = false;
		public var mate_id:int = 0;
		public var mate_name:String = "";
		public var level:int = 0;
		public var exp:Number = 0;
		public var life:int = 0;
		public var generated:Boolean = false;
		public var buffs:Array = new Array;
		public var str:int = 0;
		public var int2:int = 0;
		public var con:int = 0;
		public var dex:int = 0;
		public var men:int = 0;
		public var base_str:int = 0;
		public var base_int2:int = 0;
		public var base_con:int = 0;
		public var base_dex:int = 0;
		public var base_men:int = 0;
		public var remain_attr_points:int = 0;
		public var phy_defence:int = 0;
		public var magic_defence:int = 0;
		public var phy_attack:int = 0;
		public var magic_attack:int = 0;
		public var double_attack:int = 0;
		public var hit_rate:int = 0;
		public var miss:int = 0;
		public var attack_speed:int = 0;
		public var equip_score:int = 0;
		public var spec_score_one:int = 0;
		public var spec_score_two:int = 0;
		public var attack_type:int = 0;
		public var period:int = 1;
		public var skills:Array = new Array;
		public var title:String = "";
		public var max_hp_aptitude:int = 0;
		public var phy_defence_aptitude:int = 0;
		public var magic_defence_aptitude:int = 0;
		public var phy_attack_aptitude:int = 0;
		public var magic_attack_aptitude:int = 0;
		public var double_attack_aptitude:int = 0;
		public var get_tick:int = 0;
		public var next_level_exp:Number = 0;
		public var state:int = 1;
		public var max_hp_grow_add:int = 0;
		public var phy_defence_grow_add:int = 0;
		public var magic_defence_grow_add:int = 0;
		public var phy_attack_grow_add:int = 0;
		public var magic_attack_grow_add:int = 0;
		public var max_skill_grid:int = 4;
		public function p_pet() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet", p_pet);
		}
		public override function getMethodName():String {
			return '';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			output.writeInt(this.type_id);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.hp);
			output.writeInt(this.max_hp);
			if (this.pet_name != null) {				output.writeUTF(this.pet_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.color);
			output.writeInt(this.understanding);
			output.writeInt(this.sex);
			output.writeInt(this.pk_mode);
			output.writeBoolean(this.bind);
			output.writeInt(this.mate_id);
			if (this.mate_name != null) {				output.writeUTF(this.mate_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeDouble(this.exp);
			output.writeInt(this.life);
			output.writeBoolean(this.generated);
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
			output.writeInt(this.str);
			output.writeInt(this.int2);
			output.writeInt(this.con);
			output.writeInt(this.dex);
			output.writeInt(this.men);
			output.writeInt(this.base_str);
			output.writeInt(this.base_int2);
			output.writeInt(this.base_con);
			output.writeInt(this.base_dex);
			output.writeInt(this.base_men);
			output.writeInt(this.remain_attr_points);
			output.writeInt(this.phy_defence);
			output.writeInt(this.magic_defence);
			output.writeInt(this.phy_attack);
			output.writeInt(this.magic_attack);
			output.writeInt(this.double_attack);
			output.writeInt(this.hit_rate);
			output.writeInt(this.miss);
			output.writeInt(this.attack_speed);
			output.writeInt(this.equip_score);
			output.writeInt(this.spec_score_one);
			output.writeInt(this.spec_score_two);
			output.writeInt(this.attack_type);
			output.writeInt(this.period);
			var size_skills:int = this.skills.length;
			output.writeShort(size_skills);
			var temp_repeated_byte_skills:ByteArray= new ByteArray;
			for(i=0; i<size_skills; i++) {
				var t2_skills:ByteArray = new ByteArray;
				var tVo_skills:p_pet_skill = this.skills[i] as p_pet_skill;
				tVo_skills.writeToDataOutput(t2_skills);
				var len_tVo_skills:int = t2_skills.length;
				temp_repeated_byte_skills.writeInt(len_tVo_skills);
				temp_repeated_byte_skills.writeBytes(t2_skills);
			}
			output.writeInt(temp_repeated_byte_skills.length);
			output.writeBytes(temp_repeated_byte_skills);
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.max_hp_aptitude);
			output.writeInt(this.phy_defence_aptitude);
			output.writeInt(this.magic_defence_aptitude);
			output.writeInt(this.phy_attack_aptitude);
			output.writeInt(this.magic_attack_aptitude);
			output.writeInt(this.double_attack_aptitude);
			output.writeInt(this.get_tick);
			output.writeDouble(this.next_level_exp);
			output.writeInt(this.state);
			output.writeInt(this.max_hp_grow_add);
			output.writeInt(this.phy_defence_grow_add);
			output.writeInt(this.magic_defence_grow_add);
			output.writeInt(this.phy_attack_grow_add);
			output.writeInt(this.magic_attack_grow_add);
			output.writeInt(this.max_skill_grid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.type_id = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.hp = input.readInt();
			this.max_hp = input.readInt();
			this.pet_name = input.readUTF();
			this.color = input.readInt();
			this.understanding = input.readInt();
			this.sex = input.readInt();
			this.pk_mode = input.readInt();
			this.bind = input.readBoolean();
			this.mate_id = input.readInt();
			this.mate_name = input.readUTF();
			this.level = input.readInt();
			this.exp = input.readDouble();
			this.life = input.readInt();
			this.generated = input.readBoolean();
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
			this.str = input.readInt();
			this.int2 = input.readInt();
			this.con = input.readInt();
			this.dex = input.readInt();
			this.men = input.readInt();
			this.base_str = input.readInt();
			this.base_int2 = input.readInt();
			this.base_con = input.readInt();
			this.base_dex = input.readInt();
			this.base_men = input.readInt();
			this.remain_attr_points = input.readInt();
			this.phy_defence = input.readInt();
			this.magic_defence = input.readInt();
			this.phy_attack = input.readInt();
			this.magic_attack = input.readInt();
			this.double_attack = input.readInt();
			this.hit_rate = input.readInt();
			this.miss = input.readInt();
			this.attack_speed = input.readInt();
			this.equip_score = input.readInt();
			this.spec_score_one = input.readInt();
			this.spec_score_two = input.readInt();
			this.attack_type = input.readInt();
			this.period = input.readInt();
			var size_skills:int = input.readShort();
			var length_skills:int = input.readInt();
			if (length_skills > 0) {
				var byte_skills:ByteArray = new ByteArray; 
				input.readBytes(byte_skills, 0, length_skills);
				for(i=0; i<size_skills; i++) {
					var tmp_skills:p_pet_skill = new p_pet_skill;
					var tmp_skills_length:int = byte_skills.readInt();
					var tmp_skills_byte:ByteArray = new ByteArray;
					byte_skills.readBytes(tmp_skills_byte, 0, tmp_skills_length);
					tmp_skills.readFromDataOutput(tmp_skills_byte);
					this.skills.push(tmp_skills);
				}
			}
			this.title = input.readUTF();
			this.max_hp_aptitude = input.readInt();
			this.phy_defence_aptitude = input.readInt();
			this.magic_defence_aptitude = input.readInt();
			this.phy_attack_aptitude = input.readInt();
			this.magic_attack_aptitude = input.readInt();
			this.double_attack_aptitude = input.readInt();
			this.get_tick = input.readInt();
			this.next_level_exp = input.readDouble();
			this.state = input.readInt();
			this.max_hp_grow_add = input.readInt();
			this.phy_defence_grow_add = input.readInt();
			this.magic_defence_grow_add = input.readInt();
			this.phy_attack_grow_add = input.readInt();
			this.magic_attack_grow_add = input.readInt();
			this.max_skill_grid = input.readInt();
		}
	}
}
