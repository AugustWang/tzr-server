package proto.line {
	import proto.common.p_role_family_donate_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_donate_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var reason_code:int = 0;
		public var donate_type:int = 0;
		public var donate_info:p_role_family_donate_info = null;
		public function m_family_donate_toc() {
			super();
			this.donate_info = new p_role_family_donate_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_donate_toc", m_family_donate_toc);
		}
		public override function getMethodName():String {
			return 'family_donate';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.reason_code);
			output.writeInt(this.donate_type);
			var tmp_donate_info:ByteArray = new ByteArray;
			this.donate_info.writeToDataOutput(tmp_donate_info);
			var size_tmp_donate_info:int = tmp_donate_info.length;
			output.writeInt(size_tmp_donate_info);
			output.writeBytes(tmp_donate_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.reason_code = input.readInt();
			this.donate_type = input.readInt();
			var byte_donate_info_size:int = input.readInt();
			if (byte_donate_info_size > 0) {				this.donate_info = new p_role_family_donate_info;
				var byte_donate_info:ByteArray = new ByteArray;
				input.readBytes(byte_donate_info, 0, byte_donate_info_size);
				this.donate_info.readFromDataOutput(byte_donate_info);
			}
		}
	}
}
