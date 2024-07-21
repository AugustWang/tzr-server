package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_whole_attr extends Message
	{
		public var id:int = 0;
		public var sub_id:int = 0;
		public var active:int = 0;
		public var index:int = 0;
		public var name:String = "";
		public var desc:String = "";
		public var number:int = 0;
		public function p_equip_whole_attr() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_whole_attr", p_equip_whole_attr);
		}
		public override function getMethodName():String {
			return 'equip_whole_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.sub_id);
			output.writeInt(this.active);
			output.writeInt(this.index);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.desc != null) {				output.writeUTF(this.desc.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.sub_id = input.readInt();
			this.active = input.readInt();
			this.index = input.readInt();
			this.name = input.readUTF();
			this.desc = input.readUTF();
			this.number = input.readInt();
		}
	}
}
