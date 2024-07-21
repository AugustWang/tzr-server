package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_accept_help_tos extends Message
	{
		public function m_family_ybc_accept_help_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_accept_help_tos", m_family_ybc_accept_help_tos);
		}
		public override function getMethodName():String {
			return 'family_ybc_accept_help';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
