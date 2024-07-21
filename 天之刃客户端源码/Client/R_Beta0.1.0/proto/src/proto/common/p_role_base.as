package proto.common {
	import proto.common.p_actor_buf;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_base extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var account_name:String = "";
		public var sex:int = 0;
		public var create_time:int = 0;
		public var status:int = 0;
		public var head:int = 0;
		public var faction_id:int = 0;
		public var team_id:int = 0;
		public var family_id:int = 0;
		public var family_name:String = "";
		public var max_hp:int = 0;
		public var max_mp:int = 0;
		public var str:int = 0;
		public var int2:int = 0;
		public var con:int = 0;
		public var dex:int = 0;
		public var men:int = 0;
		public var base_str:int = 0;
		public var base_int:int = 0;
		public var base_con:int = 0;
		public var base_dex:int = 0;
		public var base_men:int = 0;
		public var remain_attr_points:int = 0;
		public var pk_title:int = 0;
		public var max_phy_attack:int = 0;
		public var min_phy_attack:int = 0;
		public var max_magic_attack:int = 0;
		public var min_magic_attack:int = 0;
		public var phy_defence:int = 0;
		public var magic_defence:int = 0;
		public var hp_recover_speed:int = 0;
		public var mp_recover_speed:int = 0;
		public var luck:int = 0;
		public var move_speed:int = 0;
		public var attack_speed:int = 0;
		public var erupt_attack_rate:int = 0;
		public var no_defence:int = 0;
		public var miss:int = 0;
		public var double_attack:int = 0;
		public var phy_anti:int = 0;
		public var magic_anti:int = 0;
		public var cur_title:String = "";
		public var cur_title_color:String = "";
		public var pk_mode:int = 0;
		public var pk_points:int = 0;
		public var last_gray_name:int = 0;
		public var if_gray_name:Boolean = false;
		public var weapon_type:int = 0;
		public var buffs:Array = new Array;
		public var phy_hurt_rate:int = 0;
		public var magic_hurt_rate:int = 0;
		public var disable_menu:Array = new Array;
		public var dizzy:int = 0;
		public var poisoning:int = 0;
		public var freeze:int = 0;
		public var hurt:int = 0;
		public var poisoning_resist:int = 0;
		public var dizzy_resist:int = 0;
		public var freeze_resist:int = 0;
		public var hurt_rebound:int = 0;
		public var achievement:int = 0;
		public var equip_score:int = 0;
		public var spec_score_one:int = 0;
		public var spec_score_two:int = 0;
		public var hit_rate:int = 10000;
		public var account_type:int = 0;
		public function p_role_base() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_base", p_role_base);
		}
		public override function getMethodName():String {
			return 'role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.account_name != null) {				output.writeUTF(this.account_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.create_time);
			output.writeInt(this.status);
			output.writeInt(this.head);
			output.writeInt(this.faction_id);
			output.writeInt(this.team_id);
			output.writeInt(this.family_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.max_hp);
			output.writeInt(this.max_mp);
			output.writeInt(this.str);
			output.writeInt(this.int2);
			output.writeInt(this.con);
			output.writeInt(this.dex);
			output.writeInt(this.men);
			output.writeInt(this.base_str);
			output.writeInt(this.base_int);
			output.writeInt(this.base_con);
			output.writeInt(this.base_dex);
			output.writeInt(this.base_men);
			output.writeInt(this.remain_attr_points);
			output.writeInt(this.pk_title);
			output.writeInt(this.max_phy_attack);
			output.writeInt(this.min_phy_attack);
			output.writeInt(this.max_magic_attack);
			output.writeInt(this.min_magic_attack);
			output.writeInt(this.phy_defence);
			output.writeInt(this.magic_defence);
			output.writeInt(this.hp_recover_speed);
			output.writeInt(this.mp_recover_speed);
			output.writeInt(this.luck);
			output.writeInt(this.move_speed);
			output.writeInt(this.attack_speed);
			output.writeInt(this.erupt_attack_rate);
			output.writeInt(this.no_defence);
			output.writeInt(this.miss);
			output.writeInt(this.double_attack);
			output.writeInt(this.phy_anti);
			output.writeInt(this.magic_anti);
			if (this.cur_title != null) {				output.writeUTF(this.cur_title.toString());
			} else {
				output.writeUTF("");
			}
			if (this.cur_title_color != null) {				output.writeUTF(this.cur_title_color.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pk_mode);
			output.writeInt(this.pk_points);
			output.writeInt(this.last_gray_name);
			output.writeBoolean(this.if_gray_name);
			output.writeInt(this.weapon_type);
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
			output.writeInt(this.phy_hurt_rate);
			output.writeInt(this.magic_hurt_rate);
			var size_disable_menu:int = this.disable_menu.length;
			output.writeShort(size_disable_menu);
			var temp_repeated_byte_disable_menu:ByteArray= new ByteArray;
			for(i=0; i<size_disable_menu; i++) {
				temp_repeated_byte_disable_menu.writeInt(this.disable_menu[i]);
			}
			output.writeInt(temp_repeated_byte_disable_menu.length);
			output.writeBytes(temp_repeated_byte_disable_menu);
			output.writeInt(this.dizzy);
			output.writeInt(this.poisoning);
			output.writeInt(this.freeze);
			output.writeInt(this.hurt);
			output.writeInt(this.poisoning_resist);
			output.writeInt(this.dizzy_resist);
			output.writeInt(this.freeze_resist);
			output.writeInt(this.hurt_rebound);
			output.writeInt(this.achievement);
			output.writeInt(this.equip_score);
			output.writeInt(this.spec_score_one);
			output.writeInt(this.spec_score_two);
			output.writeInt(this.hit_rate);
			output.writeInt(this.account_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.account_name = input.readUTF();
			this.sex = input.readInt();
			this.create_time = input.readInt();
			this.status = input.readInt();
			this.head = input.readInt();
			this.faction_id = input.readInt();
			this.team_id = input.readInt();
			this.family_id = input.readInt();
			this.family_name = input.readUTF();
			this.max_hp = input.readInt();
			this.max_mp = input.readInt();
			this.str = input.readInt();
			this.int2 = input.readInt();
			this.con = input.readInt();
			this.dex = input.readInt();
			this.men = input.readInt();
			this.base_str = input.readInt();
			this.base_int = input.readInt();
			this.base_con = input.readInt();
			this.base_dex = input.readInt();
			this.base_men = input.readInt();
			this.remain_attr_points = input.readInt();
			this.pk_title = input.readInt();
			this.max_phy_attack = input.readInt();
			this.min_phy_attack = input.readInt();
			this.max_magic_attack = input.readInt();
			this.min_magic_attack = input.readInt();
			this.phy_defence = input.readInt();
			this.magic_defence = input.readInt();
			this.hp_recover_speed = input.readInt();
			this.mp_recover_speed = input.readInt();
			this.luck = input.readInt();
			this.move_speed = input.readInt();
			this.attack_speed = input.readInt();
			this.erupt_attack_rate = input.readInt();
			this.no_defence = input.readInt();
			this.miss = input.readInt();
			this.double_attack = input.readInt();
			this.phy_anti = input.readInt();
			this.magic_anti = input.readInt();
			this.cur_title = input.readUTF();
			this.cur_title_color = input.readUTF();
			this.pk_mode = input.readInt();
			this.pk_points = input.readInt();
			this.last_gray_name = input.readInt();
			this.if_gray_name = input.readBoolean();
			this.weapon_type = input.readInt();
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
			this.phy_hurt_rate = input.readInt();
			this.magic_hurt_rate = input.readInt();
			var size_disable_menu:int = input.readShort();
			var length_disable_menu:int = input.readInt();
			var byte_disable_menu:ByteArray = new ByteArray; 
			if (size_disable_menu > 0) {
				input.readBytes(byte_disable_menu, 0, size_disable_menu * 4);
				for(i=0; i<size_disable_menu; i++) {
					var tmp_disable_menu:int = byte_disable_menu.readInt();
					this.disable_menu.push(tmp_disable_menu);
				}
			}
			this.dizzy = input.readInt();
			this.poisoning = input.readInt();
			this.freeze = input.readInt();
			this.hurt = input.readInt();
			this.poisoning_resist = input.readInt();
			this.dizzy_resist = input.readInt();
			this.freeze_resist = input.readInt();
			this.hurt_rebound = input.readInt();
			this.achievement = input.readInt();
			this.equip_score = input.readInt();
			this.spec_score_one = input.readInt();
			this.spec_score_two = input.readInt();
			this.hit_rate = input.readInt();
			this.account_type = input.readInt();
		}
	}
}
