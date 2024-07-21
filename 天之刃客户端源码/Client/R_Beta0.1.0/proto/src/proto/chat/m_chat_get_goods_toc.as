package proto.chat {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_get_goods_toc extends Message
	{
		public var succ:Boolean = true;
		public var goods_id:int = 0;
		public var goods_info:p_goods = null;
		public var reason:String = "";
		public function m_chat_get_goods_toc() {
			super();
			this.goods_info = new p_goods;

			flash.net.registerClassAlias("copy.proto.chat.m_chat_get_goods_toc", m_chat_get_goods_toc);
		}
		public override function getMethodName():String {
			return 'chat_get_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.goods_id);
			var tmp_goods_info:ByteArray = new ByteArray;
			this.goods_info.writeToDataOutput(tmp_goods_info);
			var size_tmp_goods_info:int = tmp_goods_info.length;
			output.writeInt(size_tmp_goods_info);
			output.writeBytes(tmp_goods_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.goods_id = input.readInt();
			var byte_goods_info_size:int = input.readInt();
			if (byte_goods_info_size > 0) {				this.goods_info = new p_goods;
				var byte_goods_info:ByteArray = new ByteArray;
				input.readBytes(byte_goods_info, 0, byte_goods_info_size);
				this.goods_info.readFromDataOutput(byte_goods_info);
			}
			this.reason = input.readUTF();
		}
	}
}
