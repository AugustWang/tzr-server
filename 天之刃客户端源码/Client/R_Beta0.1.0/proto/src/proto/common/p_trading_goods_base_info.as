package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_trading_goods_base_info extends Message
	{
		public var type_id:int = 0;
		public var order_index:int = 0;
		public var name:String = "";
		public var prices:Array = new Array;
		public var number:int = 0;
		public function p_trading_goods_base_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_trading_goods_base_info", p_trading_goods_base_info);
		}
		public override function getMethodName():String {
			return 'trading_goods_base_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			output.writeInt(this.order_index);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			var size_prices:int = this.prices.length;
			output.writeShort(size_prices);
			var temp_repeated_byte_prices:ByteArray= new ByteArray;
			for(i=0; i<size_prices; i++) {
				temp_repeated_byte_prices.writeInt(this.prices[i]);
			}
			output.writeInt(temp_repeated_byte_prices.length);
			output.writeBytes(temp_repeated_byte_prices);
			output.writeInt(this.number);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.order_index = input.readInt();
			this.name = input.readUTF();
			var size_prices:int = input.readShort();
			var length_prices:int = input.readInt();
			var byte_prices:ByteArray = new ByteArray; 
			if (size_prices > 0) {
				input.readBytes(byte_prices, 0, size_prices * 4);
				for(i=0; i<size_prices; i++) {
					var tmp_prices:int = byte_prices.readInt();
					this.prices.push(tmp_prices);
				}
			}
			this.number = input.readInt();
		}
	}
}
