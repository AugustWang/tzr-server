package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_query_faction_online_rank_tos extends Message
	{
		public var op_type:int = 0;
		public var faction_id:int = 0;
		public function m_role2_query_faction_online_rank_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_query_faction_online_rank_tos", m_role2_query_faction_online_rank_tos);
		}
		public override function getMethodName():String {
			return 'role2_query_faction_online_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.faction_id = input.readInt();
		}
	}
}
