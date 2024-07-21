package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_depot_swap_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goods1:p_goods = null;
		public var goods2:p_goods = null;
		public function m_depot_swap_toc() {
			super();
			this.goods1 = new p_goods;
			this.goods2 = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_depot_swap_toc", m_depot_swap_toc);
		}
		public override function getMethodName():String {
			return 'depot_swap';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_goods1:ByteArray = new ByteArray;
			this.goods1.writeToDataOutput(tmp_goods1);
			var size_tmp_goods1:int = tmp_goods1.length;
			output.writeInt(size_tmp_goods1);
			output.writeBytes(tmp_goods1);
			var tmp_goods2:ByteArray = new ByteArray;
			this.goods2.writeToDataOutput(tmp_goods2);
			var size_tmp_goods2:int = tmp_goods2.length;
			output.writeInt(size_tmp_goods2);
			output.writeBytes(tmp_goods2);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_goods1_size:int = input.readInt();
			if (byte_goods1_size > 0) {				this.goods1 = new p_goods;
				var byte_goods1:ByteArray = new ByteArray;
				input.readBytes(byte_goods1, 0, byte_goods1_size);
				this.goods1.readFromDataOutput(byte_goods1);
			}
			var byte_goods2_size:int = input.readInt();
			if (byte_goods2_size > 0) {				this.goods2 = new p_goods;
				var byte_goods2:ByteArray = new ByteArray;
				input.readBytes(byte_goods2, 0, byte_goods2_size);
				this.goods2.readFromDataOutput(byte_goods2);
			}
		}
	}
}
