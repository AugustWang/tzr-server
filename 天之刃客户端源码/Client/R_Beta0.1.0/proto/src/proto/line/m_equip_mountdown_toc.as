package proto.line {
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_mountdown_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var mount:p_goods = null;
		public function m_equip_mountdown_toc() {
			super();
			this.mount = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_mountdown_toc", m_equip_mountdown_toc);
		}
		public override function getMethodName():String {
			return 'equip_mountdown';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_mount:ByteArray = new ByteArray;
			this.mount.writeToDataOutput(tmp_mount);
			var size_tmp_mount:int = tmp_mount.length;
			output.writeInt(size_tmp_mount);
			output.writeBytes(tmp_mount);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_mount_size:int = input.readInt();
			if (byte_mount_size > 0) {				this.mount = new p_goods;
				var byte_mount:ByteArray = new ByteArray;
				input.readBytes(byte_mount, 0, byte_mount_size);
				this.mount.readFromDataOutput(byte_mount);
			}
		}
	}
}
