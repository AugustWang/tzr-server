package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shop_sale_goods extends Message
	{
		public var id:int = 0;
		public var type_id:int = 0;
		public var position:int = 0;
		public var number:int = 0;
		public function p_shop_sale_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_shop_sale_goods", p_shop_sale_goods);
		}
		public override function getMethodName():String {
			return 'shop_sale_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type_id);
			output.writeInt(this.position);
			output.writeInt(this.number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type_id = input.readInt();
			this.position = input.readInt();
			this.number = input.readInt();
		}
	}
}
