package proto.line {
	import proto.line.p_shop_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_shops_toc extends Message
	{
		public var shops:Array = new Array;
		public function m_shop_shops_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_shops_toc", m_shop_shops_toc);
		}
		public override function getMethodName():String {
			return 'shop_shops';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_shops:int = this.shops.length;
			output.writeShort(size_shops);
			var temp_repeated_byte_shops:ByteArray= new ByteArray;
			for(i=0; i<size_shops; i++) {
				var t2_shops:ByteArray = new ByteArray;
				var tVo_shops:p_shop_info = this.shops[i] as p_shop_info;
				tVo_shops.writeToDataOutput(t2_shops);
				var len_tVo_shops:int = t2_shops.length;
				temp_repeated_byte_shops.writeInt(len_tVo_shops);
				temp_repeated_byte_shops.writeBytes(t2_shops);
			}
			output.writeInt(temp_repeated_byte_shops.length);
			output.writeBytes(temp_repeated_byte_shops);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_shops:int = input.readShort();
			var length_shops:int = input.readInt();
			if (length_shops > 0) {
				var byte_shops:ByteArray = new ByteArray; 
				input.readBytes(byte_shops, 0, length_shops);
				for(i=0; i<size_shops; i++) {
					var tmp_shops:p_shop_info = new p_shop_info;
					var tmp_shops_length:int = byte_shops.readInt();
					var tmp_shops_byte:ByteArray = new ByteArray;
					byte_shops.readBytes(tmp_shops_byte, 0, tmp_shops_length);
					tmp_shops.readFromDataOutput(tmp_shops_byte);
					this.shops.push(tmp_shops);
				}
			}
		}
	}
}
