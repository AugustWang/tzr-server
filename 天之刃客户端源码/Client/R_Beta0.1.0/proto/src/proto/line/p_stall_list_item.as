package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stall_list_item extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var price:int = 0;
		public var price_type:int = 0;
		public var goods_detail:p_goods = null;
		public function p_stall_list_item() {
			super();
			this.goods_detail = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.p_stall_list_item", p_stall_list_item);
		}
		public override function getMethodName():String {
			return 'stall_list_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.price);
			output.writeInt(this.price_type);
			var tmp_goods_detail:ByteArray = new ByteArray;
			this.goods_detail.writeToDataOutput(tmp_goods_detail);
			var size_tmp_goods_detail:int = tmp_goods_detail.length;
			output.writeInt(size_tmp_goods_detail);
			output.writeBytes(tmp_goods_detail);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.price = input.readInt();
			this.price_type = input.readInt();
			var byte_goods_detail_size:int = input.readInt();
			if (byte_goods_detail_size > 0) {				this.goods_detail = new p_goods;
				var byte_goods_detail:ByteArray = new ByteArray;
				input.readBytes(byte_goods_detail, 0, byte_goods_detail_size);
				this.goods_detail.readFromDataOutput(byte_goods_detail);
			}
		}
	}
}
