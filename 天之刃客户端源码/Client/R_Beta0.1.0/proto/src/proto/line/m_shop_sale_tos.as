package proto.line {
	import proto.line.p_shop_sale_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_sale_tos extends Message
	{
		public var goods:Array = new Array;
		public function m_shop_sale_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_shop_sale_tos", m_shop_sale_tos);
		}
		public override function getMethodName():String {
			return 'shop_sale';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var size_goods:int = this.goods.length;
			output.writeShort(size_goods);
			var temp_repeated_byte_goods:ByteArray= new ByteArray;
			for(i=0; i<size_goods; i++) {
				var t2_goods:ByteArray = new ByteArray;
				var tVo_goods:p_shop_sale_goods = this.goods[i] as p_shop_sale_goods;
				tVo_goods.writeToDataOutput(t2_goods);
				var len_tVo_goods:int = t2_goods.length;
				temp_repeated_byte_goods.writeInt(len_tVo_goods);
				temp_repeated_byte_goods.writeBytes(t2_goods);
			}
			output.writeInt(temp_repeated_byte_goods.length);
			output.writeBytes(temp_repeated_byte_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var size_goods:int = input.readShort();
			var length_goods:int = input.readInt();
			if (length_goods > 0) {
				var byte_goods:ByteArray = new ByteArray; 
				input.readBytes(byte_goods, 0, length_goods);
				for(i=0; i<size_goods; i++) {
					var tmp_goods:p_shop_sale_goods = new p_shop_sale_goods;
					var tmp_goods_length:int = byte_goods.readInt();
					var tmp_goods_byte:ByteArray = new ByteArray;
					byte_goods.readBytes(tmp_goods_byte, 0, tmp_goods_length);
					tmp_goods.readFromDataOutput(tmp_goods_byte);
					this.goods.push(tmp_goods);
				}
			}
		}
	}
}
