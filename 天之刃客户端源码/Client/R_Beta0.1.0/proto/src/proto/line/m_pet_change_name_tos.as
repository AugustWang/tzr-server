package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_pet_change_name_tos extends Message
	{
		public var pet_id:int = 0;
		public var pet_name:String = "";
		public function m_pet_change_name_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_pet_change_name_tos", m_pet_change_name_tos);
		}
		public override function getMethodName():String {
			return 'pet_change_name';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pet_id);
			if (this.pet_name != null) {				output.writeUTF(this.pet_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pet_id = input.readInt();
			this.pet_name = input.readUTF();
		}
	}
}
