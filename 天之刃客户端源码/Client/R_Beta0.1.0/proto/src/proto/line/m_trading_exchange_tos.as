package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trading_exchange_tos extends Message
	{
		public var npc_id:int = 0;
		public var map_id:int = 0;
		public var family_contribution:int = 0;
		public function m_trading_exchange_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trading_exchange_tos", m_trading_exchange_tos);
		}
		public override function getMethodName():String {
			return 'trading_exchange';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.map_id);
			output.writeInt(this.family_contribution);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.map_id = input.readInt();
			this.family_contribution = input.readInt();
		}
	}
}
