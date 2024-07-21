package proto.common {
	import proto.common.p_use_requirement;
	import proto.common.p_property_add;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stone_base_info extends Message
	{
		public var typeid:int = 0;
		public var stonename:String = "";
		public var colour:int = 0;
		public var requirement:p_use_requirement = null;
		public var level_prop:p_property_add = null;
		public var level:int = 0;
		public var sell_type:int = 1;
		public var sell_price:int = 0;
		public var embe_equip_list:Array = new Array;
		public var kind:int = 0;
		public function p_stone_base_info() {
			super();
			this.requirement = new p_use_requirement;
			this.level_prop = new p_property_add;

			flash.net.registerClassAlias("copy.proto.common.p_stone_base_info", p_stone_base_info);
		}
		public override function getMethodName():String {
			return 'stone_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.typeid);
			if (this.stonename != null) {				output.writeUTF(this.stonename.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.colour);
			var tmp_requirement:ByteArray = new ByteArray;
			this.requirement.writeToDataOutput(tmp_requirement);
			var size_tmp_requirement:int = tmp_requirement.length;
			output.writeInt(size_tmp_requirement);
			output.writeBytes(tmp_requirement);
			var tmp_level_prop:ByteArray = new ByteArray;
			this.level_prop.writeToDataOutput(tmp_level_prop);
			var size_tmp_level_prop:int = tmp_level_prop.length;
			output.writeInt(size_tmp_level_prop);
			output.writeBytes(tmp_level_prop);
			output.writeInt(this.level);
			output.writeInt(this.sell_type);
			output.writeInt(this.sell_price);
			var size_embe_equip_list:int = this.embe_equip_list.length;
			output.writeShort(size_embe_equip_list);
			var temp_repeated_byte_embe_equip_list:ByteArray= new ByteArray;
			for(i=0; i<size_embe_equip_list; i++) {
				temp_repeated_byte_embe_equip_list.writeInt(this.embe_equip_list[i]);
			}
			output.writeInt(temp_repeated_byte_embe_equip_list.length);
			output.writeBytes(temp_repeated_byte_embe_equip_list);
			output.writeInt(this.kind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.typeid = input.readInt();
			this.stonename = input.readUTF();
			this.colour = input.readInt();
			var byte_requirement_size:int = input.readInt();
			if (byte_requirement_size > 0) {				this.requirement = new p_use_requirement;
				var byte_requirement:ByteArray = new ByteArray;
				input.readBytes(byte_requirement, 0, byte_requirement_size);
				this.requirement.readFromDataOutput(byte_requirement);
			}
			var byte_level_prop_size:int = input.readInt();
			if (byte_level_prop_size > 0) {				this.level_prop = new p_property_add;
				var byte_level_prop:ByteArray = new ByteArray;
				input.readBytes(byte_level_prop, 0, byte_level_prop_size);
				this.level_prop.readFromDataOutput(byte_level_prop);
			}
			this.level = input.readInt();
			this.sell_type = input.readInt();
			this.sell_price = input.readInt();
			var size_embe_equip_list:int = input.readShort();
			var length_embe_equip_list:int = input.readInt();
			var byte_embe_equip_list:ByteArray = new ByteArray; 
			if (size_embe_equip_list > 0) {
				input.readBytes(byte_embe_equip_list, 0, size_embe_equip_list * 4);
				for(i=0; i<size_embe_equip_list; i++) {
					var tmp_embe_equip_list:int = byte_embe_equip_list.readInt();
					this.embe_equip_list.push(tmp_embe_equip_list);
				}
			}
			this.kind = input.readInt();
		}
	}
}
