package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_pk_not_agree_tos extends Message
	{
		public function m_system_pk_not_agree_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_system_pk_not_agree_tos", m_system_pk_not_agree_tos);
		}
		public override function getMethodName():String {
			return 'system_pk_not_agree';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
