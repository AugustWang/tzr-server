package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_punch_tos extends Message
	{
		public function m_refining_punch_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_refining_punch_tos", m_refining_punch_tos);
		}
		public override function getMethodName():String {
			return 'refining_punch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
