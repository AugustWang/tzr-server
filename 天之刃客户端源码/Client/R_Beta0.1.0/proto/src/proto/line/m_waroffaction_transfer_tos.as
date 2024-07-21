package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_transfer_tos extends Message
	{
		public var convene_id:int = 0;
		public var faction_id:int = 0;
		public var type:int = 0;
		public function m_waroffaction_transfer_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_transfer_tos", m_waroffaction_transfer_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_transfer';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.convene_id);
			output.writeInt(this.faction_id);
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.convene_id = input.readInt();
			this.faction_id = input.readInt();
			this.type = input.readInt();
		}
	}
}
