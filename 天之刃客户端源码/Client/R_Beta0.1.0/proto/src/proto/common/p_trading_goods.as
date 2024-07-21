package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_trading_goods extends Message
	{
		public var type_id:int = 0;
		public var order_index:int = 0;
		public var name:String = "";
		public var price:int = 0;
		public var number:int = 0;
		public var sale_price:int = 0;
		public function p_trading_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_trading_goods", p_trading_goods);
		}
		public override function getMethodName():String {
			return 'trading_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			output.writeInt(this.order_index);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.price);
			output.writeInt(this.number);
			output.writeInt(this.sale_price);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.order_index = input.readInt();
			this.name = input.readUTF();
			this.price = input.readInt();
			this.number = input.readInt();
			this.sale_price = input.readInt();
		}
	}
}
