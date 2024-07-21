package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_npc_deal_tos extends Message
	{
		public var deal_id:int = 0;
		public var sub_id:int = 1;
		public function m_exchange_npc_deal_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_npc_deal_tos", m_exchange_npc_deal_tos);
		}
		public override function getMethodName():String {
			return 'exchange_npc_deal';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.deal_id);
			output.writeInt(this.sub_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.deal_id = input.readInt();
			this.sub_id = input.readInt();
		}
	}
}
