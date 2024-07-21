package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_shops_tos extends Message
	{
		public function m_shop_shops_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_shops_tos", m_shop_shops_tos);
		}
		public override function getMethodName():String {
			return 'shop_shops';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
