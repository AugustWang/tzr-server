package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_load_tos extends Message
	{
		public var equip_slot_num:int = 0;
		public var equipid:int = 0;
		public function m_equip_load_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_load_tos", m_equip_load_tos);
		}
		public override function getMethodName():String {
			return 'equip_load';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equip_slot_num);
			output.writeInt(this.equipid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equip_slot_num = input.readInt();
			this.equipid = input.readInt();
		}
	}
}
