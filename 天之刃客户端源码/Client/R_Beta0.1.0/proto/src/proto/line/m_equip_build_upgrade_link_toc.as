package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_build_upgrade_link_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var new_equip:p_goods = null;
		public function m_equip_build_upgrade_link_toc() {
			super();
			this.new_equip = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_build_upgrade_link_toc", m_equip_build_upgrade_link_toc);
		}
		public override function getMethodName():String {
			return 'equip_build_upgrade_link';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_new_equip:ByteArray = new ByteArray;
			this.new_equip.writeToDataOutput(tmp_new_equip);
			var size_tmp_new_equip:int = tmp_new_equip.length;
			output.writeInt(size_tmp_new_equip);
			output.writeBytes(tmp_new_equip);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_new_equip_size:int = input.readInt();
			if (byte_new_equip_size > 0) {				this.new_equip = new p_goods;
				var byte_new_equip:ByteArray = new ByteArray;
				input.readBytes(byte_new_equip, 0, byte_new_equip_size);
				this.new_equip.readFromDataOutput(byte_new_equip);
			}
		}
	}
}
