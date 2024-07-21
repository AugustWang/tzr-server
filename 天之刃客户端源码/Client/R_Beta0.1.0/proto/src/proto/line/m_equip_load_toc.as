package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_load_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var equip1:p_goods = null;
		public var equip2:p_goods = null;
		public function m_equip_load_toc() {
			super();
			this.equip1 = new p_goods;
			this.equip2 = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_load_toc", m_equip_load_toc);
		}
		public override function getMethodName():String {
			return 'equip_load';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_equip1:ByteArray = new ByteArray;
			this.equip1.writeToDataOutput(tmp_equip1);
			var size_tmp_equip1:int = tmp_equip1.length;
			output.writeInt(size_tmp_equip1);
			output.writeBytes(tmp_equip1);
			var tmp_equip2:ByteArray = new ByteArray;
			this.equip2.writeToDataOutput(tmp_equip2);
			var size_tmp_equip2:int = tmp_equip2.length;
			output.writeInt(size_tmp_equip2);
			output.writeBytes(tmp_equip2);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_equip1_size:int = input.readInt();
			if (byte_equip1_size > 0) {				this.equip1 = new p_goods;
				var byte_equip1:ByteArray = new ByteArray;
				input.readBytes(byte_equip1, 0, byte_equip1_size);
				this.equip1.readFromDataOutput(byte_equip1);
			}
			var byte_equip2_size:int = input.readInt();
			if (byte_equip2_size > 0) {				this.equip2 = new p_goods;
				var byte_equip2:ByteArray = new ByteArray;
				input.readBytes(byte_equip2, 0, byte_equip2_size);
				this.equip2.readFromDataOutput(byte_equip2);
			}
		}
	}
}
