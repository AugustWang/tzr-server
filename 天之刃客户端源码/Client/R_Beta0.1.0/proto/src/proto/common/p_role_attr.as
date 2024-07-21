package proto.common {
	import proto.common.p_skin;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_attr extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var next_level_exp:Number = 0;
		public var exp:Number = 0;
		public var level:int = 0;
		public var five_ele_attr:int = 0;
		public var last_login_location:String = "";
		public var equips:Array = new Array;
		public var jungong:int = 0;
		public var charm:int = 0;
		public var couple_id:int = 0;
		public var couple_name:String = "";
		public var skin:p_skin = null;
		public var cur_energy:int = 2000;
		public var max_energy:int = 2000;
		public var remain_skill_points:int = 0;
		public var gold:int = 0;
		public var gold_bind:int = 0;
		public var silver:int = 0;
		public var silver_bind:int = 0;
		public var show_cloth:Boolean = true;
		public var moral_values:int = 0;
		public var gongxun:int = 0;
		public var last_login_ip:String = "";
		public var office_id:int = 0;
		public var office_name:String = "";
		public var unbund:Boolean = false;
		public var family_contribute:int = 0;
		public var active_points:int = 0;
		public var category:int = 0;
		public var show_equip_ring:Boolean = true;
		public var is_payed:Boolean = false;
		public var sum_prestige:Number = 0;
		public var cur_prestige:Number = 0;
		public function p_role_attr() {
			super();
			this.skin = new p_skin;

			flash.net.registerClassAlias("copy.proto.common.p_role_attr", p_role_attr);
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
			output.writeDouble(this.next_level_exp);
			output.writeDouble(this.exp);
			output.writeInt(this.level);
			output.writeInt(this.five_ele_attr);
			if (this.last_login_location != null) {				output.writeUTF(this.last_login_location.toString());
			} else {
				output.writeUTF("");
			}
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
			output.writeInt(this.jungong);
			output.writeInt(this.charm);
			output.writeInt(this.couple_id);
			if (this.couple_name != null) {				output.writeUTF(this.couple_name.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_skin:ByteArray = new ByteArray;
			this.skin.writeToDataOutput(tmp_skin);
			var size_tmp_skin:int = tmp_skin.length;
			output.writeInt(size_tmp_skin);
			output.writeBytes(tmp_skin);
			output.writeInt(this.cur_energy);
			output.writeInt(this.max_energy);
			output.writeInt(this.remain_skill_points);
			output.writeInt(this.gold);
			output.writeInt(this.gold_bind);
			output.writeInt(this.silver);
			output.writeInt(this.silver_bind);
			output.writeBoolean(this.show_cloth);
			output.writeInt(this.moral_values);
			output.writeInt(this.gongxun);
			if (this.last_login_ip != null) {				output.writeUTF(this.last_login_ip.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.office_id);
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.unbund);
			output.writeInt(this.family_contribute);
			output.writeInt(this.active_points);
			output.writeInt(this.category);
			output.writeBoolean(this.show_equip_ring);
			output.writeBoolean(this.is_payed);
			output.writeDouble(this.sum_prestige);
			output.writeDouble(this.cur_prestige);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.next_level_exp = input.readDouble();
			this.exp = input.readDouble();
			this.level = input.readInt();
			this.five_ele_attr = input.readInt();
			this.last_login_location = input.readUTF();
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
			this.jungong = input.readInt();
			this.charm = input.readInt();
			this.couple_id = input.readInt();
			this.couple_name = input.readUTF();
			var byte_skin_size:int = input.readInt();
			if (byte_skin_size > 0) {				this.skin = new p_skin;
				var byte_skin:ByteArray = new ByteArray;
				input.readBytes(byte_skin, 0, byte_skin_size);
				this.skin.readFromDataOutput(byte_skin);
			}
			this.cur_energy = input.readInt();
			this.max_energy = input.readInt();
			this.remain_skill_points = input.readInt();
			this.gold = input.readInt();
			this.gold_bind = input.readInt();
			this.silver = input.readInt();
			this.silver_bind = input.readInt();
			this.show_cloth = input.readBoolean();
			this.moral_values = input.readInt();
			this.gongxun = input.readInt();
			this.last_login_ip = input.readUTF();
			this.office_id = input.readInt();
			this.office_name = input.readUTF();
			this.unbund = input.readBoolean();
			this.family_contribute = input.readInt();
			this.active_points = input.readInt();
			this.category = input.readInt();
			this.show_equip_ring = input.readBoolean();
			this.is_payed = input.readBoolean();
			this.sum_prestige = input.readDouble();
			this.cur_prestige = input.readDouble();
		}
	}
}
