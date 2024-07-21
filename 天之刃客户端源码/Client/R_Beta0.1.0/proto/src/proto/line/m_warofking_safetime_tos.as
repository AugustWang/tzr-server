package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofking_safetime_tos extends Message
	{
		public function m_warofking_safetime_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofking_safetime_tos", m_warofking_safetime_tos);
		}
		public override function getMethodName():String {
			return 'warofking_safetime';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
