package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_office_equip extends Message
	{
		public var office_id:int = 0;
		public var office_name:String = "";
		public var type:int = 3;
		public var type_id:int = 0;
		public var equip_num:int = 0;
		public function p_office_equip() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_office_equip", p_office_equip);
		}
		public override function getMethodName():String {
			return 'office_e';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.office_id);
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeInt(this.type_id);
			output.writeInt(this.equip_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.office_id = input.readInt();
			this.office_name = input.readUTF();
			this.type = input.readInt();
			this.type_id = input.readInt();
			this.equip_num = input.readInt();
		}
	}
}
