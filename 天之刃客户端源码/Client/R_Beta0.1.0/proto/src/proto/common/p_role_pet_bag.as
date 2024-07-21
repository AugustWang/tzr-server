package proto.common {
	import proto.common.p_pet_id_name;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_pet_bag extends Message
	{
		public var role_id:int = 0;
		public var content:int = 0;
		public var pets:Array = new Array;
		public function p_role_pet_bag() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_pet_bag", p_role_pet_bag);
		}
		public override function getMethodName():String {
			return 'role_pet';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.content);
			var size_pets:int = this.pets.length;
			output.writeShort(size_pets);
			var temp_repeated_byte_pets:ByteArray= new ByteArray;
			for(i=0; i<size_pets; i++) {
				var t2_pets:ByteArray = new ByteArray;
				var tVo_pets:p_pet_id_name = this.pets[i] as p_pet_id_name;
				tVo_pets.writeToDataOutput(t2_pets);
				var len_tVo_pets:int = t2_pets.length;
				temp_repeated_byte_pets.writeInt(len_tVo_pets);
				temp_repeated_byte_pets.writeBytes(t2_pets);
			}
			output.writeInt(temp_repeated_byte_pets.length);
			output.writeBytes(temp_repeated_byte_pets);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.content = input.readInt();
			var size_pets:int = input.readShort();
			var length_pets:int = input.readInt();
			if (length_pets > 0) {
				var byte_pets:ByteArray = new ByteArray; 
				input.readBytes(byte_pets, 0, length_pets);
				for(i=0; i<size_pets; i++) {
					var tmp_pets:p_pet_id_name = new p_pet_id_name;
					var tmp_pets_length:int = byte_pets.readInt();
					var tmp_pets_byte:ByteArray = new ByteArray;
					byte_pets.readBytes(tmp_pets_byte, 0, tmp_pets_length);
					tmp_pets.readFromDataOutput(tmp_pets_byte);
					this.pets.push(tmp_pets);
				}
			}
		}
	}
}
