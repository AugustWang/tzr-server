package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_five_ele extends Message
	{
		public var id:int = 0;
		public var type_id:Array = new Array;
		public var equip_name:Array = new Array;
		public var level:int = 0;
		public var active:int = 0;
		public var phy_anti:int = 0;
		public var magic_anti:int = 0;
		public var hurt:int = 0;
		public var no_defence:int = 0;
		public var hurt_rebound:int = 0;
		public var link_slot_num:int = 0;
		public var whole_name:String = "";
		public function p_equip_five_ele() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_five_ele", p_equip_five_ele);
		}
		public override function getMethodName():String {
			return 'equip_five';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			var size_type_id:int = this.type_id.length;
			output.writeShort(size_type_id);
			var temp_repeated_byte_type_id:ByteArray= new ByteArray;
			for(i=0; i<size_type_id; i++) {
				temp_repeated_byte_type_id.writeInt(this.type_id[i]);
			}
			output.writeInt(temp_repeated_byte_type_id.length);
			output.writeBytes(temp_repeated_byte_type_id);
			var size_equip_name:int = this.equip_name.length;
			output.writeShort(size_equip_name);
			var temp_repeated_byte_equip_name:ByteArray= new ByteArray;
			for(i=0; i<size_equip_name; i++) {
				if (this.equip_name != null) {					temp_repeated_byte_equip_name.writeUTF(this.equip_name[i].toString());
				} else {
					temp_repeated_byte_equip_name.writeUTF("");
				}
			}
			output.writeInt(temp_repeated_byte_equip_name.length);
			output.writeBytes(temp_repeated_byte_equip_name);
			output.writeInt(this.level);
			output.writeInt(this.active);
			output.writeInt(this.phy_anti);
			output.writeInt(this.magic_anti);
			output.writeInt(this.hurt);
			output.writeInt(this.no_defence);
			output.writeInt(this.hurt_rebound);
			output.writeInt(this.link_slot_num);
			if (this.whole_name != null) {				output.writeUTF(this.whole_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			var size_type_id:int = input.readShort();
			var length_type_id:int = input.readInt();
			var byte_type_id:ByteArray = new ByteArray; 
			if (size_type_id > 0) {
				input.readBytes(byte_type_id, 0, size_type_id * 4);
				for(i=0; i<size_type_id; i++) {
					var tmp_type_id:int = byte_type_id.readInt();
					this.type_id.push(tmp_type_id);
				}
			}
			var size_equip_name:int = input.readShort();
			var length_equip_name:int = input.readInt();
			if (size_equip_name>0) {
				var byte_equip_name:ByteArray = new ByteArray; 
				input.readBytes(byte_equip_name, 0, length_equip_name);
				for(i=0; i<size_equip_name; i++) {
					var tmp_equip_name:String = byte_equip_name.readUTF(); 
					this.equip_name.push(tmp_equip_name);
				}
			}
			this.level = input.readInt();
			this.active = input.readInt();
			this.phy_anti = input.readInt();
			this.magic_anti = input.readInt();
			this.hurt = input.readInt();
			this.no_defence = input.readInt();
			this.hurt_rebound = input.readInt();
			this.link_slot_num = input.readInt();
			this.whole_name = input.readUTF();
		}
	}
}
