package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_finish_tos extends Message
	{
		public function m_stall_finish_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_finish_tos", m_stall_finish_tos);
		}
		public override function getMethodName():String {
			return 'stall_finish';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
