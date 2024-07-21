package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_other_role_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var faction_id:int = 0;
		public var family_name:String = "";
		public var five_ele_attr:int = 0;
		public var office_name:String = "";
		public var charm:int = 0;
		public var category:int = 0;
		public var level:int = 0;
		public var level_rank:int = 0;
		public var equips:Array = new Array;
		public var vip_level:int = 0;
		public var gongxun:int = 0;
		public var pk_point:int = 0;
		public var moral_value:int = 0;
		public var str:int = 0;
		public var int2:int = 0;
		public var con:int = 0;
		public var dex:int = 0;
		public var men:int = 0;
		public var max_phy_attack:int = 0;
		public var min_phy_attack:int = 0;
		public var max_magic_attack:int = 0;
		public var min_magic_attack:int = 0;
		public var double_attack:int = 0;
		public var phy_defence:int = 0;
		public var magic_defence:int = 0;
		public var birthday:int = 0;
		public var province:int = 0;
		public var pet_id:int = 0;
		public var city:int = 0;
		public var luck:int = 0;
		public var miss:int = 0;
		public var no_defence:int = 0;
		public var hit_rate:int = 0;
		public var sum_prestige:Number = 0;
		public var cur_prestige:Number = 0;
		public var cur_title:String = "";
		public var pk_title:int = 0;
		public var max_hp:int = 0;
		public var max_mp:int = 0;
		public var cur_energy:int = 0;
		public var max_energy:int = 0;
		public function p_other_role_info() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_other_role_info", p_other_role_info);
		}
		public override function getMethodName():String {
			return 'other_role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
			if (this.family_name != null) {				output.writeUTF(this.family_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.five_ele_attr);
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.charm);
			output.writeInt(this.category);
			output.writeInt(this.level);
			output.writeInt(this.level_rank);
			var size_equips:int = this.equips.length;
			output.writeShort(size_equips);
			var temp_repeated_byte_equips:ByteArray= new ByteArray;
			for(i=0; i<size_equips; i++) {
				var t2_equips:ByteArray = new ByteArray;
				var tVo_equips:p_goods = this.equips[i] as p_goods;
				tVo_equips.writeToDataOutput(t2_equips);
				var len_tVo_equips:int = t2_equips.length;
				temp_repeated_byte_equips.writeInt(len_tVo_equips);
				temp_repeated_byte_equips.writeBytes(t2_equips);
			}
			output.writeInt(temp_repeated_byte_equips.length);
			output.writeBytes(temp_repeated_byte_equips);
			output.writeInt(this.vip_level);
			output.writeInt(this.gongxun);
			output.writeInt(this.pk_point);
			output.writeInt(this.moral_value);
			output.writeInt(this.str);
			output.writeInt(this.int2);
			output.writeInt(this.con);
			output.writeInt(this.dex);
			output.writeInt(this.men);
			output.writeInt(this.max_phy_attack);
			output.writeInt(this.min_phy_attack);
			output.writeInt(this.max_magic_attack);
			output.writeInt(this.min_magic_attack);
			output.writeInt(this.double_attack);
			output.writeInt(this.phy_defence);
			output.writeInt(this.magic_defence);
			output.writeInt(this.birthday);
			output.writeInt(this.province);
			output.writeInt(this.pet_id);
			output.writeInt(this.city);
			output.writeInt(this.luck);
			output.writeInt(this.miss);
			output.writeInt(this.no_defence);
			output.writeInt(this.hit_rate);
			output.writeDouble(this.sum_prestige);
			output.writeDouble(this.cur_prestige);
			if (this.cur_title != null) {				output.writeUTF(this.cur_title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.pk_title);
			output.writeInt(this.max_hp);
			output.writeInt(this.max_mp);
			output.writeInt(this.cur_energy);
			output.writeInt(this.max_energy);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
			this.family_name = input.readUTF();
			this.five_ele_attr = input.readInt();
			this.office_name = input.readUTF();
			this.charm = input.readInt();
			this.category = input.readInt();
			this.level = input.readInt();
			this.level_rank = input.readInt();
			var size_equips:int = input.readShort();
			var length_equips:int = input.readInt();
			if (length_equips > 0) {
				var byte_equips:ByteArray = new ByteArray; 
				input.readBytes(byte_equips, 0, length_equips);
				for(i=0; i<size_equips; i++) {
					var tmp_equips:p_goods = new p_goods;
					var tmp_equips_length:int = byte_equips.readInt();
					var tmp_equips_byte:ByteArray = new ByteArray;
					byte_equips.readBytes(tmp_equips_byte, 0, tmp_equips_length);
					tmp_equips.readFromDataOutput(tmp_equips_byte);
					this.equips.push(tmp_equips);
				}
			}
			this.vip_level = input.readInt();
			this.gongxun = input.readInt();
			this.pk_point = input.readInt();
			this.moral_value = input.readInt();
			this.str = input.readInt();
			this.int2 = input.readInt();
			this.con = input.readInt();
			this.dex = input.readInt();
			this.men = input.readInt();
			this.max_phy_attack = input.readInt();
			this.min_phy_attack = input.readInt();
			this.max_magic_attack = input.readInt();
			this.min_magic_attack = input.readInt();
			this.double_attack = input.readInt();
			this.phy_defence = input.readInt();
			this.magic_defence = input.readInt();
			this.birthday = input.readInt();
			this.province = input.readInt();
			this.pet_id = input.readInt();
			this.city = input.readInt();
			this.luck = input.readInt();
			this.miss = input.readInt();
			this.no_defence = input.readInt();
			this.hit_rate = input.readInt();
			this.sum_prestige = input.readDouble();
			this.cur_prestige = input.readDouble();
			this.cur_title = input.readUTF();
			this.pk_title = input.readInt();
			this.max_hp = input.readInt();
			this.max_mp = input.readInt();
			this.cur_energy = input.readInt();
			this.max_energy = input.readInt();
		}
	}
}
