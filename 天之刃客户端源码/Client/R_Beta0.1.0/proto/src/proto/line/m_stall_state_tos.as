package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_stall_state_tos extends Message
	{
		public function m_stall_state_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_stall_state_tos", m_stall_state_tos);
		}
		public override function getMethodName():String {
			return 'stall_state';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
