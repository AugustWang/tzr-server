package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_collect_refresh_prize_tos extends Message
	{
		public function m_family_collect_refresh_prize_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_collect_refresh_prize_tos", m_family_collect_refresh_prize_tos);
		}
		public override function getMethodName():String {
			return 'family_collect_refresh_prize';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
