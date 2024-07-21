package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_add_energy_tos extends Message
	{
		public var gold_exchange:int = 0;
		public function m_role2_add_energy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_add_energy_tos", m_role2_add_energy_tos);
		}
		public override function getMethodName():String {
			return 'role2_add_energy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.gold_exchange);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.gold_exchange = input.readInt();
		}
	}
}
