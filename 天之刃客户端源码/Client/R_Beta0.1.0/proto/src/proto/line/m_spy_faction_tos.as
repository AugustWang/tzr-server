package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_spy_faction_tos extends Message
	{
		public function m_spy_faction_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_spy_faction_tos", m_spy_faction_tos);
		}
		public override function getMethodName():String {
			return 'spy_faction';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
