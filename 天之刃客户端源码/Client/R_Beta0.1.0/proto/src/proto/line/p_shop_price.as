package proto.line {
	import proto.line.p_shop_currency;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shop_price extends Message
	{
		public var id:int = 0;
		public var currency:Array = new Array;
		public function p_shop_price() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_shop_price", p_shop_price);
		}
		public override function getMethodName():String {
			return 'shop_p';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			var size_currency:int = this.currency.length;
			output.writeShort(size_currency);
			var temp_repeated_byte_currency:ByteArray= new ByteArray;
			for(i=0; i<size_currency; i++) {
				var t2_currency:ByteArray = new ByteArray;
				var tVo_currency:p_shop_currency = this.currency[i] as p_shop_currency;
				tVo_currency.writeToDataOutput(t2_currency);
				var len_tVo_currency:int = t2_currency.length;
				temp_repeated_byte_currency.writeInt(len_tVo_currency);
				temp_repeated_byte_currency.writeBytes(t2_currency);
			}
			output.writeInt(temp_repeated_byte_currency.length);
			output.writeBytes(temp_repeated_byte_currency);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			var size_currency:int = input.readShort();
			var length_currency:int = input.readInt();
			if (length_currency > 0) {
				var byte_currency:ByteArray = new ByteArray; 
				input.readBytes(byte_currency, 0, length_currency);
				for(i=0; i<size_currency; i++) {
					var tmp_currency:p_shop_currency = new p_shop_currency;
					var tmp_currency_length:int = byte_currency.readInt();
					var tmp_currency_byte:ByteArray = new ByteArray;
					byte_currency.readBytes(tmp_currency_byte, 0, tmp_currency_length);
					tmp_currency.readFromDataOutput(tmp_currency_byte);
					this.currency.push(tmp_currency);
				}
			}
		}
	}
}
