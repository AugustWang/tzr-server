package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_ranking_get_rankinfo_tos extends Message
	{
		public var rank_id:int = 0;
		public function m_ranking_get_rankinfo_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_ranking_get_rankinfo_tos", m_ranking_get_rankinfo_tos);
		}
		public override function getMethodName():String {
			return 'ranking_get_rankinfo';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.rank_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rank_id = input.readInt();
		}
	}
}
