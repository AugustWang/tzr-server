package proto.common {
	import proto.common.p_use_requirement;
	import proto.common.p_item_effect;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_item_base_info extends Message
	{
		public var typeid:int = 0;
		public var itemname:String = "";
		public var kind:int = 0;
		public var colour:int = 0;
		public var usenum:int = 0;
		public var sell_type:int = 1;
		public var sell_price:int = 0;
		public var requirement:p_use_requirement = null;
		public var effects:Array = new Array;
		public var cd_type:int = 0;
		public var is_overlap:int = 0;
		public function p_item_base_info() {
			super();
			this.requirement = new p_use_requirement;

			flash.net.registerClassAlias("copy.proto.common.p_item_base_info", p_item_base_info);
		}
		public override function getMethodName():String {
			return 'item_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.typeid);
			if (this.itemname != null) {				output.writeUTF(this.itemname.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.kind);
			output.writeInt(this.colour);
			output.writeInt(this.usenum);
			output.writeInt(this.sell_type);
			output.writeInt(this.sell_price);
			var tmp_requirement:ByteArray = new ByteArray;
			this.requirement.writeToDataOutput(tmp_requirement);
			var size_tmp_requirement:int = tmp_requirement.length;
			output.writeInt(size_tmp_requirement);
			output.writeBytes(tmp_requirement);
			var size_effects:int = this.effects.length;
			output.writeShort(size_effects);
			var temp_repeated_byte_effects:ByteArray= new ByteArray;
			for(i=0; i<size_effects; i++) {
				var t2_effects:ByteArray = new ByteArray;
				var tVo_effects:p_item_effect = this.effects[i] as p_item_effect;
				tVo_effects.writeToDataOutput(t2_effects);
				var len_tVo_effects:int = t2_effects.length;
				temp_repeated_byte_effects.writeInt(len_tVo_effects);
				temp_repeated_byte_effects.writeBytes(t2_effects);
			}
			output.writeInt(temp_repeated_byte_effects.length);
			output.writeBytes(temp_repeated_byte_effects);
			output.writeInt(this.cd_type);
			output.writeInt(this.is_overlap);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.typeid = input.readInt();
			this.itemname = input.readUTF();
			this.kind = input.readInt();
			this.colour = input.readInt();
			this.usenum = input.readInt();
			this.sell_type = input.readInt();
			this.sell_price = input.readInt();
			var byte_requirement_size:int = input.readInt();
			if (byte_requirement_size > 0) {				this.requirement = new p_use_requirement;
				var byte_requirement:ByteArray = new ByteArray;
				input.readBytes(byte_requirement, 0, byte_requirement_size);
				this.requirement.readFromDataOutput(byte_requirement);
			}
			var size_effects:int = input.readShort();
			var length_effects:int = input.readInt();
			if (length_effects > 0) {
				var byte_effects:ByteArray = new ByteArray; 
				input.readBytes(byte_effects, 0, length_effects);
				for(i=0; i<size_effects; i++) {
					var tmp_effects:p_item_effect = new p_item_effect;
					var tmp_effects_length:int = byte_effects.readInt();
					var tmp_effects_byte:ByteArray = new ByteArray;
					byte_effects.readBytes(tmp_effects_byte, 0, tmp_effects_length);
					tmp_effects.readFromDataOutput(tmp_effects_byte);
					this.effects.push(tmp_effects);
				}
			}
			this.cd_type = input.readInt();
			this.is_overlap = input.readInt();
		}
	}
}
