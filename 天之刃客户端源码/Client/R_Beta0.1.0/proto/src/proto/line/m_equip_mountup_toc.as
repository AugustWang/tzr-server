package proto.line {
	import proto.common.p_goods;
	import proto.common.p_goods;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_equip_mountup_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var mount_new:p_goods = null;
		public var mount_old:p_goods = null;
		public function m_equip_mountup_toc() {
			super();
			this.mount_new = new p_goods;
			this.mount_old = new p_goods;

			flash.net.registerClassAlias("copy.proto.line.m_equip_mountup_toc", m_equip_mountup_toc);
		}
		public override function getMethodName():String {
			return 'equip_mountup';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_mount_new:ByteArray = new ByteArray;
			this.mount_new.writeToDataOutput(tmp_mount_new);
			var size_tmp_mount_new:int = tmp_mount_new.length;
			output.writeInt(size_tmp_mount_new);
			output.writeBytes(tmp_mount_new);
			var tmp_mount_old:ByteArray = new ByteArray;
			this.mount_old.writeToDataOutput(tmp_mount_old);
			var size_tmp_mount_old:int = tmp_mount_old.length;
			output.writeInt(size_tmp_mount_old);
			output.writeBytes(tmp_mount_old);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_mount_new_size:int = input.readInt();
			if (byte_mount_new_size > 0) {				this.mount_new = new p_goods;
				var byte_mount_new:ByteArray = new ByteArray;
				input.readBytes(byte_mount_new, 0, byte_mount_new_size);
				this.mount_new.readFromDataOutput(byte_mount_new);
			}
			var byte_mount_old_size:int = input.readInt();
			if (byte_mount_old_size > 0) {				this.mount_old = new p_goods;
				var byte_mount_old:ByteArray = new ByteArray;
				input.readBytes(byte_mount_old, 0, byte_mount_old_size);
				this.mount_old.readFromDataOutput(byte_mount_old);
			}
		}
	}
}
