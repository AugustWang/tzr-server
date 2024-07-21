package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_equip_onekey_simple extends Message
	{
		public var slot_num:int = 0;
		public var equip_id:int = 0;
		public var equip_typeid:int = 0;
		public function p_equip_onekey_simple() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_equip_onekey_simple", p_equip_onekey_simple);
		}
		public override function getMethodName():String {
			return 'equip_onekey_si';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.slot_num);
			output.writeInt(this.equip_id);
			output.writeInt(this.equip_typeid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.slot_num = input.readInt();
			this.equip_id = input.readInt();
			this.equip_typeid = input.readInt();
		}
	}
}
