package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_list_goods_tos extends Message
	{
		public function m_fmldepot_list_goods_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_list_goods_tos", m_fmldepot_list_goods_tos);
		}
		public override function getMethodName():String {
			return 'fmldepot_list_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
