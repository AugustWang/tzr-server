package proto.common {
	import proto.common.p_refresh_info;
	import proto.common.p_drop_info;
	import proto.common.p_monster_skill;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_monster_base_info extends Message
	{
		public var typeid:int = 0;
		public var monstername:String = "";
		public var rarity:int = 0;
		public var level:int = 0;
		public var attacktype:int = 0;
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
		public var ai_type:int = 0;
		public var guard_radius:int = 0;
		public var attention_radius:int = 0;
		public var activity_radius:int = 0;
		public var refresh:p_refresh_info = null;
		public var max_drop_num:int = 0;
		public var droplist:Array = new Array;
		public var exp:int = 0;
		public var min_money:int = 0;
		public var max_money:int = 0;
		public var skinid:int = 0;
		public var is_human:int = 0;
		public var color:int = 0;
		public var money_rate:int = 0;
		public var skills:Array = new Array;
		public function p_monster_base_info() {
			super();
			this.refresh = new p_refresh_info;

			flash.net.registerClassAlias("copy.proto.common.p_monster_base_info", p_monster_base_info);
		}
		public override function getMethodName():String {
			return 'monster_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.typeid);
			if (this.monstername != null) {				output.writeUTF(this.monstername.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.rarity);
			output.writeInt(this.level);
			output.writeInt(this.attacktype);
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
			output.writeInt(this.ai_type);
			output.writeInt(this.guard_radius);
			output.writeInt(this.attention_radius);
			output.writeInt(this.activity_radius);
			var tmp_refresh:ByteArray = new ByteArray;
			this.refresh.writeToDataOutput(tmp_refresh);
			var size_tmp_refresh:int = tmp_refresh.length;
			output.writeInt(size_tmp_refresh);
			output.writeBytes(tmp_refresh);
			output.writeInt(this.max_drop_num);
			var size_droplist:int = this.droplist.length;
			output.writeShort(size_droplist);
			var temp_repeated_byte_droplist:ByteArray= new ByteArray;
			for(i=0; i<size_droplist; i++) {
				var t2_droplist:ByteArray = new ByteArray;
				var tVo_droplist:p_drop_info = this.droplist[i] as p_drop_info;
				tVo_droplist.writeToDataOutput(t2_droplist);
				var len_tVo_droplist:int = t2_droplist.length;
				temp_repeated_byte_droplist.writeInt(len_tVo_droplist);
				temp_repeated_byte_droplist.writeBytes(t2_droplist);
			}
			output.writeInt(temp_repeated_byte_droplist.length);
			output.writeBytes(temp_repeated_byte_droplist);
			output.writeInt(this.exp);
			output.writeInt(this.min_money);
			output.writeInt(this.max_money);
			output.writeInt(this.skinid);
			output.writeInt(this.is_human);
			output.writeInt(this.color);
			output.writeInt(this.money_rate);
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
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.typeid = input.readInt();
			this.monstername = input.readUTF();
			this.rarity = input.readInt();
			this.level = input.readInt();
			this.attacktype = input.readInt();
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
			this.ai_type = input.readInt();
			this.guard_radius = input.readInt();
			this.attention_radius = input.readInt();
			this.activity_radius = input.readInt();
			var byte_refresh_size:int = input.readInt();
			if (byte_refresh_size > 0) {				this.refresh = new p_refresh_info;
				var byte_refresh:ByteArray = new ByteArray;
				input.readBytes(byte_refresh, 0, byte_refresh_size);
				this.refresh.readFromDataOutput(byte_refresh);
			}
			this.max_drop_num = input.readInt();
			var size_droplist:int = input.readShort();
			var length_droplist:int = input.readInt();
			if (length_droplist > 0) {
				var byte_droplist:ByteArray = new ByteArray; 
				input.readBytes(byte_droplist, 0, length_droplist);
				for(i=0; i<size_droplist; i++) {
					var tmp_droplist:p_drop_info = new p_drop_info;
					var tmp_droplist_length:int = byte_droplist.readInt();
					var tmp_droplist_byte:ByteArray = new ByteArray;
					byte_droplist.readBytes(tmp_droplist_byte, 0, tmp_droplist_length);
					tmp_droplist.readFromDataOutput(tmp_droplist_byte);
					this.droplist.push(tmp_droplist);
				}
			}
			this.exp = input.readInt();
			this.min_money = input.readInt();
			this.max_money = input.readInt();
			this.skinid = input.readInt();
			this.is_human = input.readInt();
			this.color = input.readInt();
			this.money_rate = input.readInt();
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
		}
	}
}
