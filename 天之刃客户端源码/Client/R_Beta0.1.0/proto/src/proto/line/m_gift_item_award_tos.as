package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_gift_item_award_tos extends Message
	{
		public function m_gift_item_award_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_gift_item_award_tos", m_gift_item_award_tos);
		}
		public override function getMethodName():String {
			return 'gift_item_award';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
