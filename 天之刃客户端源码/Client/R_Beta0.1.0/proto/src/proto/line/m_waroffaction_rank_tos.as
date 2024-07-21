package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_rank_tos extends Message
	{
		public function m_waroffaction_rank_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_rank_tos", m_waroffaction_rank_tos);
		}
		public override function getMethodName():String {
			return 'waroffaction_rank';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
