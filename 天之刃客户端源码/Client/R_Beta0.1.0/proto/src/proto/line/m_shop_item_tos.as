package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_item_tos extends Message
	{
		public var shop_id:int = 0;
		public var item_type_id:int = 0;
		public function m_shop_item_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_item_tos", m_shop_item_tos);
		}
		public override function getMethodName():String {
			return 'shop_item';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.shop_id);
			output.writeInt(this.item_type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.shop_id = input.readInt();
			this.item_type_id = input.readInt();
		}
	}
}
