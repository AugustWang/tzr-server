package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_swap_tos extends Message
	{
		public var equipid1:int = 0;
		public var position2:int = 0;
		public function m_equip_swap_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_equip_swap_tos", m_equip_swap_tos);
		}
		public override function getMethodName():String {
			return 'equip_swap';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.equipid1);
			output.writeInt(this.position2);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.equipid1 = input.readInt();
			this.position2 = input.readInt();
		}
	}
}
