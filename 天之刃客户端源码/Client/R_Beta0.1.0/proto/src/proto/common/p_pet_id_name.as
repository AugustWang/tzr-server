package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_id_name extends Message
	{
		public var pet_id:int = 0;
		public var name:String = "";
		public var color:int = 2;
		public var type_id:int = 0;
		public var index:int = 0;
		public var exp:Number = 0;
		public var next_level_exp:Number = 0;
		public function p_pet_id_name() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_id_name", p_pet_id_name);
		}
		public override function getMethodName():String {
			return 'pet_id_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.color);
			output.writeInt(this.type_id);
			output.writeInt(this.index);
			output.writeDouble(this.exp);
			output.writeDouble(this.next_level_exp);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.name = input.readUTF();
			this.color = input.readInt();
			this.type_id = input.readInt();
			this.index = input.readInt();
			this.exp = input.readDouble();
			this.next_level_exp = input.readDouble();
		}
	}
}
