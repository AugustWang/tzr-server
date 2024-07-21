package proto.line {
	import proto.line.p_equip_build_goods;
	import proto.line.p_equip_build_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_decompose_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var base_goods:p_equip_build_goods = null;
		public var add_goods:p_equip_build_goods = null;
		public function m_equip_build_decompose_toc() {
			super();
			this.base_goods = new p_equip_build_goods;
			this.add_goods = new p_equip_build_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_decompose_toc", m_equip_build_decompose_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_decompose';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_base_goods:ByteArray = new ByteArray;
			this.base_goods.writeToDataOutput(tmp_base_goods);
			var size_tmp_base_goods:int = tmp_base_goods.length;
			output.writeInt(size_tmp_base_goods);
			output.writeBytes(tmp_base_goods);
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
			var byte_base_goods_size:int = input.readInt();
			if (byte_base_goods_size > 0) {				this.base_goods = new p_equip_build_goods;
				var byte_base_goods:ByteArray = new ByteArray;
				input.readBytes(byte_base_goods, 0, byte_base_goods_size);
				this.base_goods.readFromDataOutput(byte_base_goods);
			}
			var byte_add_goods_size:int = input.readInt();
			if (byte_add_goods_size > 0) {				this.add_goods = new p_equip_build_goods;
				var byte_add_goods:ByteArray = new ByteArray;
				input.readBytes(byte_add_goods, 0, byte_add_goods_size);
				this.add_goods.readFromDataOutput(byte_add_goods);
			}
		}
	}
}
