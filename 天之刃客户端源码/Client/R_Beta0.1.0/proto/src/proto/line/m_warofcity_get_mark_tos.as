package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_get_mark_tos extends Message
	{
		public function m_warofcity_get_mark_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_get_mark_tos", m_warofcity_get_mark_tos);
		}
		public override function getMethodName():String {
			return 'warofcity_get_mark';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
