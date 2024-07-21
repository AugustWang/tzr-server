package proto.common {
	import proto.common.p_use_requirement;
	import proto.common.p_property_add;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_base_info extends Message
	{
		public var typeid:int = 0;
		public var equipname:String = "";
		public var slot_num:int = 0;
		public var kind:int = 0;
		public var colour:int = 0;
		public var endurance:int = 0;
		public var requirement:p_use_requirement = null;
		public var property:p_property_add = null;
		public var loss_endu:int = 0;
		public var sell_type:int = 1;
		public var sell_price:int = 0;
		public var material:int = 0;
		public var protype:int = 0;
		public function p_equip_base_info() {
			super();
			this.requirement = new p_use_requirement;
			this.property = new p_property_add;

			flash.net.registerClassAlias("copy.proto.common.p_equip_base_info", p_equip_base_info);
		}
		public override function getMethodName():String {
			return 'equip_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.typeid);
			if (this.equipname != null) {				output.writeUTF(this.equipname.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.slot_num);
			output.writeInt(this.kind);
			output.writeInt(this.colour);
			output.writeInt(this.endurance);
			var tmp_requirement:ByteArray = new ByteArray;
			this.requirement.writeToDataOutput(tmp_requirement);
			var size_tmp_requirement:int = tmp_requirement.length;
			output.writeInt(size_tmp_requirement);
			output.writeBytes(tmp_requirement);
			var tmp_property:ByteArray = new ByteArray;
			this.property.writeToDataOutput(tmp_property);
			var size_tmp_property:int = tmp_property.length;
			output.writeInt(size_tmp_property);
			output.writeBytes(tmp_property);
			output.writeInt(this.loss_endu);
			output.writeInt(this.sell_type);
			output.writeInt(this.sell_price);
			output.writeInt(this.material);
			output.writeInt(this.protype);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.typeid = input.readInt();
			this.equipname = input.readUTF();
			this.slot_num = input.readInt();
			this.kind = input.readInt();
			this.colour = input.readInt();
			this.endurance = input.readInt();
			var byte_requirement_size:int = input.readInt();
			if (byte_requirement_size > 0) {				this.requirement = new p_use_requirement;
				var byte_requirement:ByteArray = new ByteArray;
				input.readBytes(byte_requirement, 0, byte_requirement_size);
				this.requirement.readFromDataOutput(byte_requirement);
			}
			var byte_property_size:int = input.readInt();
			if (byte_property_size > 0) {				this.property = new p_property_add;
				var byte_property:ByteArray = new ByteArray;
				input.readBytes(byte_property, 0, byte_property_size);
				this.property.readFromDataOutput(byte_property);
			}
			this.loss_endu = input.readInt();
			this.sell_type = input.readInt();
			this.sell_price = input.readInt();
			this.material = input.readInt();
			this.protype = input.readInt();
		}
	}
}
