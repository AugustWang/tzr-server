package proto.line {
	import proto.line.p_shop_goods_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_shop_item_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var shop_id:int = 0;
		public var goods:p_shop_goods_info = null;
		public function m_shop_item_toc() {
			super();
			this.goods = new p_shop_goods_info;

			flash.net.registerClassAlias("copy.proto.line.m_shop_item_toc", m_shop_item_toc);
		}
		public override function getMethodName():String {
			return 'shop_item';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.shop_id);
			var tmp_goods:ByteArray = new ByteArray;
			this.goods.writeToDataOutput(tmp_goods);
			var size_tmp_goods:int = tmp_goods.length;
			output.writeInt(size_tmp_goods);
			output.writeBytes(tmp_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.shop_id = input.readInt();
			var byte_goods_size:int = input.readInt();
			if (byte_goods_size > 0) {				this.goods = new p_shop_goods_info;
				var byte_goods:ByteArray = new ByteArray;
				input.readBytes(byte_goods, 0, byte_goods_size);
				this.goods.readFromDataOutput(byte_goods);
			}
		}
	}
}
