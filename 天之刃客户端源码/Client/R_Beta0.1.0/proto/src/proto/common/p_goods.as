package proto.common {
	import proto.common.p_property_add;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_goods extends Message
	{
		public var id:int = 0;
		public var type:int = 0;
		public var roleid:int = 0;
		public var bagposition:int = 0;
		public var current_num:int = 0;
		public var bagid:int = 0;
		public var sell_type:int = 1;
		public var sell_price:int = 0;
		public var typeid:int = 0;
		public var bind:Boolean = false;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var current_colour:int = 0;
		public var state:int = 0;
		public var name:String = "";
		public var level:int = 0;
		public var embe_pos:int = 0;
		public var embe_equipid:int = 0;
		public var loadposition:int = 0;
		public var quality:int = 0;
		public var current_endurance:int = 0;
		public var forge_num:int = 0;
		public var reinforce_result:int = 0;
		public var punch_num:int = 0;
		public var stone_num:int = 0;
		public var add_property:p_property_add = null;
		public var stones:Array = new Array;
		public var reinforce_rate:int = 0;
		public var endurance:int = 0;
		public var signature:String = "";
		public var equip_bind_attr:Array = new Array;
		public var refining_index:int = 0;
		public var sign_role_id:int = 0;
		public var five_ele_attr:p_equip_five_ele = null;
		public var whole_attr:p_equip_whole_attr = null;
		public var reinforce_result_list:Array = new Array;
		public var use_bind:int = 0;
		public var sub_quality:int = 0;
		public var quality_rate:int = 0;
		public function p_goods() {
			super();
			this.add_property = new p_property_add;
			this.five_ele_attr = new p_equip_five_ele;
			this.whole_attr = new p_equip_whole_attr;

			flash.net.registerClassAlias("copy.proto.common.p_goods", p_goods);
		}
		public override function getMethodName():String {
			return 'g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type);
			output.writeInt(this.roleid);
			output.writeInt(this.bagposition);
			output.writeInt(this.current_num);
			output.writeInt(this.bagid);
			output.writeInt(this.sell_type);
			output.writeInt(this.sell_price);
			output.writeInt(this.typeid);
			output.writeBoolean(this.bind);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.current_colour);
			output.writeInt(this.state);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.embe_pos);
			output.writeInt(this.embe_equipid);
			output.writeInt(this.loadposition);
			output.writeInt(this.quality);
			output.writeInt(this.current_endurance);
			output.writeInt(this.forge_num);
			output.writeInt(this.reinforce_result);
			output.writeInt(this.punch_num);
			output.writeInt(this.stone_num);
			var tmp_add_property:ByteArray = new ByteArray;
			this.add_property.writeToDataOutput(tmp_add_property);
			var size_tmp_add_property:int = tmp_add_property.length;
			output.writeInt(size_tmp_add_property);
			output.writeBytes(tmp_add_property);
			var size_stones:int = this.stones.length;
			output.writeShort(size_stones);
			var temp_repeated_byte_stones:ByteArray= new ByteArray;
			for(i=0; i<size_stones; i++) {
				var t2_stones:ByteArray = new ByteArray;
				var tVo_stones:p_goods = this.stones[i] as p_goods;
				tVo_stones.writeToDataOutput(t2_stones);
				var len_tVo_stones:int = t2_stones.length;
				temp_repeated_byte_stones.writeInt(len_tVo_stones);
				temp_repeated_byte_stones.writeBytes(t2_stones);
			}
			output.writeInt(temp_repeated_byte_stones.length);
			output.writeBytes(temp_repeated_byte_stones);
			output.writeInt(this.reinforce_rate);
			output.writeInt(this.endurance);
			if (this.signature != null) {				output.writeUTF(this.signature.toString());
			} else {
				output.writeUTF("");
			}
			var size_equip_bind_attr:int = this.equip_bind_attr.length;
			output.writeShort(size_equip_bind_attr);
			var temp_repeated_byte_equip_bind_attr:ByteArray= new ByteArray;
			for(i=0; i<size_equip_bind_attr; i++) {
				var t2_equip_bind_attr:ByteArray = new ByteArray;
				var tVo_equip_bind_attr:p_equip_bind_attr = this.equip_bind_attr[i] as p_equip_bind_attr;
				tVo_equip_bind_attr.writeToDataOutput(t2_equip_bind_attr);
				var len_tVo_equip_bind_attr:int = t2_equip_bind_attr.length;
				temp_repeated_byte_equip_bind_attr.writeInt(len_tVo_equip_bind_attr);
				temp_repeated_byte_equip_bind_attr.writeBytes(t2_equip_bind_attr);
			}
			output.writeInt(temp_repeated_byte_equip_bind_attr.length);
			output.writeBytes(temp_repeated_byte_equip_bind_attr);
			output.writeInt(this.refining_index);
			output.writeInt(this.sign_role_id);
			var tmp_five_ele_attr:ByteArray = new ByteArray;
			this.five_ele_attr.writeToDataOutput(tmp_five_ele_attr);
			var size_tmp_five_ele_attr:int = tmp_five_ele_attr.length;
			output.writeInt(size_tmp_five_ele_attr);
			output.writeBytes(tmp_five_ele_attr);
			var tmp_whole_attr:ByteArray = new ByteArray;
			this.whole_attr.writeToDataOutput(tmp_whole_attr);
			var size_tmp_whole_attr:int = tmp_whole_attr.length;
			output.writeInt(size_tmp_whole_attr);
			output.writeBytes(tmp_whole_attr);
			var size_reinforce_result_list:int = this.reinforce_result_list.length;
			output.writeShort(size_reinforce_result_list);
			var temp_repeated_byte_reinforce_result_list:ByteArray= new ByteArray;
			for(i=0; i<size_reinforce_result_list; i++) {
				temp_repeated_byte_reinforce_result_list.writeInt(this.reinforce_result_list[i]);
			}
			output.writeInt(temp_repeated_byte_reinforce_result_list.length);
			output.writeBytes(temp_repeated_byte_reinforce_result_list);
			output.writeInt(this.use_bind);
			output.writeInt(this.sub_quality);
			output.writeInt(this.quality_rate);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type = input.readInt();
			this.roleid = input.readInt();
			this.bagposition = input.readInt();
			this.current_num = input.readInt();
			this.bagid = input.readInt();
			this.sell_type = input.readInt();
			this.sell_price = input.readInt();
			this.typeid = input.readInt();
			this.bind = input.readBoolean();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.current_colour = input.readInt();
			this.state = input.readInt();
			this.name = input.readUTF();
			this.level = input.readInt();
			this.embe_pos = input.readInt();
			this.embe_equipid = input.readInt();
			this.loadposition = input.readInt();
			this.quality = input.readInt();
			this.current_endurance = input.readInt();
			this.forge_num = input.readInt();
			this.reinforce_result = input.readInt();
			this.punch_num = input.readInt();
			this.stone_num = input.readInt();
			var byte_add_property_size:int = input.readInt();
			if (byte_add_property_size > 0) {				this.add_property = new p_property_add;
				var byte_add_property:ByteArray = new ByteArray;
				input.readBytes(byte_add_property, 0, byte_add_property_size);
				this.add_property.readFromDataOutput(byte_add_property);
			}
			var size_stones:int = input.readShort();
			var length_stones:int = input.readInt();
			if (length_stones > 0) {
				var byte_stones:ByteArray = new ByteArray; 
				input.readBytes(byte_stones, 0, length_stones);
				for(i=0; i<size_stones; i++) {
					var tmp_stones:p_goods = new p_goods;
					var tmp_stones_length:int = byte_stones.readInt();
					var tmp_stones_byte:ByteArray = new ByteArray;
					byte_stones.readBytes(tmp_stones_byte, 0, tmp_stones_length);
					tmp_stones.readFromDataOutput(tmp_stones_byte);
					this.stones.push(tmp_stones);
				}
			}
			this.reinforce_rate = input.readInt();
			this.endurance = input.readInt();
			this.signature = input.readUTF();
			var size_equip_bind_attr:int = input.readShort();
			var length_equip_bind_attr:int = input.readInt();
			if (length_equip_bind_attr > 0) {
				var byte_equip_bind_attr:ByteArray = new ByteArray; 
				input.readBytes(byte_equip_bind_attr, 0, length_equip_bind_attr);
				for(i=0; i<size_equip_bind_attr; i++) {
					var tmp_equip_bind_attr:p_equip_bind_attr = new p_equip_bind_attr;
					var tmp_equip_bind_attr_length:int = byte_equip_bind_attr.readInt();
					var tmp_equip_bind_attr_byte:ByteArray = new ByteArray;
					byte_equip_bind_attr.readBytes(tmp_equip_bind_attr_byte, 0, tmp_equip_bind_attr_length);
					tmp_equip_bind_attr.readFromDataOutput(tmp_equip_bind_attr_byte);
					this.equip_bind_attr.push(tmp_equip_bind_attr);
				}
			}
			this.refining_index = input.readInt();
			this.sign_role_id = input.readInt();
			var byte_five_ele_attr_size:int = input.readInt();
			if (byte_five_ele_attr_size > 0) {				this.five_ele_attr = new p_equip_five_ele;
				var byte_five_ele_attr:ByteArray = new ByteArray;
				input.readBytes(byte_five_ele_attr, 0, byte_five_ele_attr_size);
				this.five_ele_attr.readFromDataOutput(byte_five_ele_attr);
			}
			var byte_whole_attr_size:int = input.readInt();
			if (byte_whole_attr_size > 0) {				this.whole_attr = new p_equip_whole_attr;
				var byte_whole_attr:ByteArray = new ByteArray;
				input.readBytes(byte_whole_attr, 0, byte_whole_attr_size);
				this.whole_attr.readFromDataOutput(byte_whole_attr);
			}
			var size_reinforce_result_list:int = input.readShort();
			var length_reinforce_result_list:int = input.readInt();
			var byte_reinforce_result_list:ByteArray = new ByteArray; 
			if (size_reinforce_result_list > 0) {
				input.readBytes(byte_reinforce_result_list, 0, size_reinforce_result_list * 4);
				for(i=0; i<size_reinforce_result_list; i++) {
					var tmp_reinforce_result_list:int = byte_reinforce_result_list.readInt();
					this.reinforce_result_list.push(tmp_reinforce_result_list);
				}
			}
			this.use_bind = input.readInt();
			this.sub_quality = input.readInt();
			this.quality_rate = input.readInt();
		}
	}
}
