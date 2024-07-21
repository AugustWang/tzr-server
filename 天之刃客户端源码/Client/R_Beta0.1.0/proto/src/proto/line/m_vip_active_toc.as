package proto.line {
	import proto.common.p_role_vip;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_vip_active_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var vip_info:p_role_vip = null;
		public var gold:int = 0;
		public var item:int = 0;
		public function m_vip_active_toc() {
			super();
			this.vip_info = new p_role_vip;

			flash.net.registerClassAlias("copy.proto.line.m_vip_active_toc", m_vip_active_toc);
		}
		public override function getMethodName():String {
			return 'vip_active';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_vip_info:ByteArray = new ByteArray;
			this.vip_info.writeToDataOutput(tmp_vip_info);
			var size_tmp_vip_info:int = tmp_vip_info.length;
			output.writeInt(size_tmp_vip_info);
			output.writeBytes(tmp_vip_info);
			output.writeInt(this.gold);
			output.writeInt(this.item);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_vip_info_size:int = input.readInt();
			if (byte_vip_info_size > 0) {				this.vip_info = new p_role_vip;
				var byte_vip_info:ByteArray = new ByteArray;
				input.readBytes(byte_vip_info, 0, byte_vip_info_size);
				this.vip_info.readFromDataOutput(byte_vip_info);
			}
			this.gold = input.readInt();
			this.item = input.readInt();
		}
	}
}
