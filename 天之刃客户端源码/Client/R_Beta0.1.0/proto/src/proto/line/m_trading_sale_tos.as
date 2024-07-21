package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_trading_sale_tos extends Message
	{
		public var npc_id:int = 0;
		public var map_id:int = 0;
		public function m_trading_sale_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_trading_sale_tos", m_trading_sale_tos);
		}
		public override function getMethodName():String {
			return 'trading_sale';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
			output.writeInt(this.map_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
			this.map_id = input.readInt();
		}
	}
}
