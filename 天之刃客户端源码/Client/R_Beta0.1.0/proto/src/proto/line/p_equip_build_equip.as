package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_build_equip extends Message
	{
		public var type_id:int = 0;
		public var equip_name:String = "";
		public var level:int = 0;
		public var slot_num:int = 0;
		public var kind:int = 0;
		public var material:int = 0;
		public function p_equip_build_equip() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_equip_build_equip", p_equip_build_equip);
		}
		public override function getMethodName():String {
			return 'equip_build_e';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			if (this.equip_name != null) {				output.writeUTF(this.equip_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.level);
			output.writeInt(this.slot_num);
			output.writeInt(this.kind);
			output.writeInt(this.material);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.equip_name = input.readUTF();
			this.level = input.readInt();
			this.slot_num = input.readInt();
			this.kind = input.readInt();
			this.material = input.readInt();
		}
	}
}
