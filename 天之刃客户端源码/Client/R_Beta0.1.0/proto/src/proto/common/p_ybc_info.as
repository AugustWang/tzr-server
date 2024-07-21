package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_ybc_info extends Message
	{
		public function p_ybc_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_ybc_info", p_ybc_info);
		}
		public override function getMethodName():String {
			return 'ybc_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
