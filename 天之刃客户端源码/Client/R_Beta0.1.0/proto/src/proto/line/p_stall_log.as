package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stall_log extends Message
	{
		public var type:int = 0;
		public var src_role_id:int = 0;
		public var src_role_name:String = "";
		public var dest_role_id:int = 0;
		public var dest_role_name:String = "";
		public var goods_info:p_goods = null;
		public var number:int = 0;
		public var price:int = 0;
		public var content:String = "";
		public var time:int = 0;
		public var price_type:int = 0;
		public function p_stall_log() {
			super();
			this.goods_info = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.p_stall_log", p_stall_log);
		}
		public override function getMethodName():String {
			return 'stall';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.src_role_id);
			if (this.src_role_name != null) {				output.writeUTF(this.src_role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.dest_role_id);
			if (this.dest_role_name != null) {				output.writeUTF(this.dest_role_name.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_goods_info:ByteArray = new ByteArray;
			this.goods_info.writeToDataOutput(tmp_goods_info);
			var size_tmp_goods_info:int = tmp_goods_info.length;
			output.writeInt(size_tmp_goods_info);
			output.writeBytes(tmp_goods_info);
			output.writeInt(this.number);
			output.writeInt(this.price);
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.time);
			output.writeInt(this.price_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.src_role_id = input.readInt();
			this.src_role_name = input.readUTF();
			this.dest_role_id = input.readInt();
			this.dest_role_name = input.readUTF();
			var byte_goods_info_size:int = input.readInt();
			if (byte_goods_info_size > 0) {				this.goods_info = new p_goods;
				var byte_goods_info:ByteArray = new ByteArray;
				input.readBytes(byte_goods_info, 0, byte_goods_info_size);
				this.goods_info.readFromDataOutput(byte_goods_info);
			}
			this.number = input.readInt();
			this.price = input.readInt();
			this.content = input.readUTF();
			this.time = input.readInt();
			this.price_type = input.readInt();
		}
	}
}
