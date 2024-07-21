package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_accumulate_exp_view_tos extends Message
	{
		public function m_accumulate_exp_view_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_accumulate_exp_view_tos", m_accumulate_exp_view_tos);
		}
		public override function getMethodName():String {
			return 'accumulate_exp_view';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
