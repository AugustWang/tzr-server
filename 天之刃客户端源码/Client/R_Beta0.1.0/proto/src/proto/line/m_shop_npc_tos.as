package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_npc_tos extends Message
	{
		public var npc_id:int = 0;
		public function m_shop_npc_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_npc_tos", m_shop_npc_tos);
		}
		public override function getMethodName():String {
			return 'shop_npc';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npc_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npc_id = input.readInt();
		}
	}
}
