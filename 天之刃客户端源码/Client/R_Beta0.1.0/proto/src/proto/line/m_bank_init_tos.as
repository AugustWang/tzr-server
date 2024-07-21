package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_init_tos extends Message
	{
		public function m_bank_init_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bank_init_tos", m_bank_init_tos);
		}
		public override function getMethodName():String {
			return 'bank_init';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
