package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofking_collect_toc extends Message
	{
		public function m_warofking_collect_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofking_collect_toc", m_warofking_collect_toc);
		}
		public override function getMethodName():String {
			return 'warofking_collect';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
