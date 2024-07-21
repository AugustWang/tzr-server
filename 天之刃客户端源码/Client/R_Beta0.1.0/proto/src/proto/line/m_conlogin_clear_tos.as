package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_conlogin_clear_tos extends Message
	{
		public function m_conlogin_clear_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_conlogin_clear_tos", m_conlogin_clear_tos);
		}
		public override function getMethodName():String {
			return 'conlogin_clear';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
