package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofking_agree_enter_tos extends Message
	{
		public function m_warofking_agree_enter_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofking_agree_enter_tos", m_warofking_agree_enter_tos);
		}
		public override function getMethodName():String {
			return 'warofking_agree_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
