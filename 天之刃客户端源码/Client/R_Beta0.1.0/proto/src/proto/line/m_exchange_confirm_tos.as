package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_exchange_confirm_tos extends Message
	{
		public function m_exchange_confirm_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_exchange_confirm_tos", m_exchange_confirm_tos);
		}
		public override function getMethodName():String {
			return 'exchange_confirm';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
