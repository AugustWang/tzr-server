package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_pet_egg_type_list extends Message
	{
		public var role_id:int = 0;
		public var type_id_list:Array = new Array;
		public function p_role_pet_egg_type_list() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_pet_egg_type_list", p_role_pet_egg_type_list);
		}
		public override function getMethodName():String {
			return 'role_pet_egg_type_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			var size_type_id_list:int = this.type_id_list.length;
			output.writeShort(size_type_id_list);
			var temp_repeated_byte_type_id_list:ByteArray= new ByteArray;
			for(i=0; i<size_type_id_list; i++) {
				temp_repeated_byte_type_id_list.writeInt(this.type_id_list[i]);
			}
			output.writeInt(temp_repeated_byte_type_id_list.length);
			output.writeBytes(temp_repeated_byte_type_id_list);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			var size_type_id_list:int = input.readShort();
			var length_type_id_list:int = input.readInt();
			var byte_type_id_list:ByteArray = new ByteArray; 
			if (size_type_id_list > 0) {
				input.readBytes(byte_type_id_list, 0, size_type_id_list * 4);
				for(i=0; i<size_type_id_list; i++) {
					var tmp_type_id_list:int = byte_type_id_list.readInt();
					this.type_id_list.push(tmp_type_id_list);
				}
			}
		}
	}
}
