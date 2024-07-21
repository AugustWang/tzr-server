package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_refining_compose_toc extends Message
	{
		public var succ:Boolean = true;
		public var normal_goods:p_goods = null;
		public var bind_goods:p_goods = null;
		public var reason:String = "";
		public function m_refining_compose_toc() {
			super();
			this.normal_goods = new p_goods;
			this.bind_goods = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_refining_compose_toc", m_refining_compose_toc);
		}
		public override function getMethodName():String {
			return 'refining_compose';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_normal_goods:ByteArray = new ByteArray;
			this.normal_goods.writeToDataOutput(tmp_normal_goods);
			var size_tmp_normal_goods:int = tmp_normal_goods.length;
			output.writeInt(size_tmp_normal_goods);
			output.writeBytes(tmp_normal_goods);
			var tmp_bind_goods:ByteArray = new ByteArray;
			this.bind_goods.writeToDataOutput(tmp_bind_goods);
			var size_tmp_bind_goods:int = tmp_bind_goods.length;
			output.writeInt(size_tmp_bind_goods);
			output.writeBytes(tmp_bind_goods);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_normal_goods_size:int = input.readInt();
			if (byte_normal_goods_size > 0) {				this.normal_goods = new p_goods;
				var byte_normal_goods:ByteArray = new ByteArray;
				input.readBytes(byte_normal_goods, 0, byte_normal_goods_size);
				this.normal_goods.readFromDataOutput(byte_normal_goods);
			}
			var byte_bind_goods_size:int = input.readInt();
			if (byte_bind_goods_size > 0) {				this.bind_goods = new p_goods;
				var byte_bind_goods:ByteArray = new ByteArray;
				input.readBytes(byte_bind_goods, 0, byte_bind_goods_size);
				this.bind_goods.readFromDataOutput(byte_bind_goods);
			}
			this.reason = input.readUTF();
		}
	}
}
