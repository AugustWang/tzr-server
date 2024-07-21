package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personybc_commit_tos extends Message
	{
		public function m_personybc_commit_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personybc_commit_tos", m_personybc_commit_tos);
		}
		public override function getMethodName():String {
			return 'personybc_commit';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
