package proto.line {
	import proto.common.p_goods;
	import proto.common.p_pos;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stall_search_goods extends Message
	{
		public var goods:p_goods = null;
		public var stall_name:String = "";
		public var role_name:String = "";
		public var pos:p_pos = null;
		public function p_stall_search_goods() {
			super();
			this.goods = new p_goods;
			this.pos = new p_pos;

			flash.net.registerClassAlias("copy.proto.line.p_stall_search_goods", p_stall_search_goods);
		}
		public override function getMethodName():String {
			return 'stall_search_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			var tmp_goods:ByteArray = new ByteArray;
			this.goods.writeToDataOutput(tmp_goods);
			var size_tmp_goods:int = tmp_goods.length;
			output.writeInt(size_tmp_goods);
			output.writeBytes(tmp_goods);
			if (this.stall_name != null) {				output.writeUTF(this.stall_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_pos:ByteArray = new ByteArray;
			this.pos.writeToDataOutput(tmp_pos);
			var size_tmp_pos:int = tmp_pos.length;
			output.writeInt(size_tmp_pos);
			output.writeBytes(tmp_pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			var byte_goods_size:int = input.readInt();
			if (byte_goods_size > 0) {				this.goods = new p_goods;
				var byte_goods:ByteArray = new ByteArray;
				input.readBytes(byte_goods, 0, byte_goods_size);
				this.goods.readFromDataOutput(byte_goods);
			}
			this.stall_name = input.readUTF();
			this.role_name = input.readUTF();
			var byte_pos_size:int = input.readInt();
			if (byte_pos_size > 0) {				this.pos = new p_pos;
				var byte_pos:ByteArray = new ByteArray;
				input.readBytes(byte_pos, 0, byte_pos_size);
				this.pos.readFromDataOutput(byte_pos);
			}
		}
	}
}
