package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_office_take_equip_tos extends Message
	{
		public var take_office_id:int = 0;
		public var take_num:int = 0;
		public function m_office_take_equip_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_office_take_equip_tos", m_office_take_equip_tos);
		}
		public override function getMethodName():String {
			return 'office_take_equip';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.take_office_id);
			output.writeInt(this.take_num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.take_office_id = input.readInt();
			this.take_num = input.readInt();
		}
	}
}
