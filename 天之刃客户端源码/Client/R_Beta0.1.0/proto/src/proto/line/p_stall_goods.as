package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stall_goods extends Message
	{
		public var goods:p_goods = null;
		public var price:int = 0;
		public var price_type:int = 0;
		public var pos:int = 0;
		public function p_stall_goods() {
			super();
			this.goods = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.p_stall_goods", p_stall_goods);
		}
		public override function getMethodName():String {
			return 'stall_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_goods:ByteArray = new ByteArray;
			this.goods.writeToDataOutput(tmp_goods);
			var size_tmp_goods:int = tmp_goods.length;
			output.writeInt(size_tmp_goods);
			output.writeBytes(tmp_goods);
			output.writeInt(this.price);
			output.writeInt(this.price_type);
			output.writeInt(this.pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_goods_size:int = input.readInt();
			if (byte_goods_size > 0) {				this.goods = new p_goods;
				var byte_goods:ByteArray = new ByteArray;
				input.readBytes(byte_goods, 0, byte_goods_size);
				this.goods.readFromDataOutput(byte_goods);
			}
			this.price = input.readInt();
			this.price_type = input.readInt();
			this.pos = input.readInt();
		}
	}
}
