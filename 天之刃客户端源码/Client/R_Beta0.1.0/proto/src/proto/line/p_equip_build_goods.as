package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_build_goods extends Message
	{
		public var type_id:int = 0;
		public var name:String = "";
		public var current_num:int = 0;
		public var needed_num:int = 0;
		public function p_equip_build_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_equip_build_goods", p_equip_build_goods);
		}
		public override function getMethodName():String {
			return 'equip_build_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.current_num);
			output.writeInt(this.needed_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.name = input.readUTF();
			this.current_num = input.readInt();
			this.needed_num = input.readInt();
		}
	}
}
