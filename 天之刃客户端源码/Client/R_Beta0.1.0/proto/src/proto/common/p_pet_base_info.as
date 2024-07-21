package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_base_info extends Message
	{
		public var type_id:int = 0;
		public var pet_name:String = "";
		public var carry_level:int = 0;
		public var attack_type:int = 0;
		public function p_pet_base_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_base_info", p_pet_base_info);
		}
		public override function getMethodName():String {
			return 'pet_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			if (this.pet_name != null) {				output.writeUTF(this.pet_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.carry_level);
			output.writeInt(this.attack_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.pet_name = input.readUTF();
			this.carry_level = input.readInt();
			this.attack_type = input.readInt();
		}
	}
}
