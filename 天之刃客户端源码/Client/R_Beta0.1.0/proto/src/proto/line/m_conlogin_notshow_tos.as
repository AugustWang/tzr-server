package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_conlogin_notshow_tos extends Message
	{
		public function m_conlogin_notshow_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_conlogin_notshow_tos", m_conlogin_notshow_tos);
		}
		public override function getMethodName():String {
			return 'conlogin_notshow';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
