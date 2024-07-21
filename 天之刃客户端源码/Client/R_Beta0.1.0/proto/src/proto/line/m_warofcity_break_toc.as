package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_break_toc extends Message
	{
		public function m_warofcity_break_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_break_toc", m_warofcity_break_toc);
		}
		public override function getMethodName():String {
			return 'warofcity_break';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
