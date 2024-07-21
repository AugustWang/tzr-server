package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_putin_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var add_goods:p_goods = null;
		public function m_fmldepot_putin_toc() {
			super();
			this.add_goods = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_putin_toc", m_fmldepot_putin_toc);
		}
		public override function getMethodName():String {
			return 'fmldepot_putin';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_add_goods:ByteArray = new ByteArray;
			this.add_goods.writeToDataOutput(tmp_add_goods);
			var size_tmp_add_goods:int = tmp_add_goods.length;
			output.writeInt(size_tmp_add_goods);
			output.writeBytes(tmp_add_goods);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_add_goods_size:int = input.readInt();
			if (byte_add_goods_size > 0) {				this.add_goods = new p_goods;
				var byte_add_goods:ByteArray = new ByteArray;
				input.readBytes(byte_add_goods, 0, byte_add_goods_size);
				this.add_goods.readFromDataOutput(byte_add_goods);
			}
		}
	}
}
