package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goods_info_toc extends Message
	{
		public var succ:Boolean = true;
		public var info:p_goods = null;
		public var type:int = 0;
		public var reason:String = "";
		public var goods_id:int = 0;
		public function m_goods_info_toc() {
			super();
			this.info = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_goods_info_toc", m_goods_info_toc);
		}
		public override function getMethodName():String {
			return 'goods_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
			output.writeInt(this.type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_goods;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
			this.type = input.readInt();
			this.reason = input.readUTF();
			this.goods_id = input.readInt();
		}
	}
}
