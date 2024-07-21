package proto.line {
	import proto.common.p_family_member_info;
	import proto.common.p_family_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_agree_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var member_info:p_family_member_info = null;
		public var family_info:p_family_info = null;
		public function m_family_agree_toc() {
			super();
			this.member_info = new p_family_member_info;
			this.family_info = new p_family_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_agree_toc", m_family_agree_toc);
		}
		public override function getMethodName():String {
			return 'family_agree';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			var tmp_member_info:ByteArray = new ByteArray;
			this.member_info.writeToDataOutput(tmp_member_info);
			var size_tmp_member_info:int = tmp_member_info.length;
			output.writeInt(size_tmp_member_info);
			output.writeBytes(tmp_member_info);
			var tmp_family_info:ByteArray = new ByteArray;
			this.family_info.writeToDataOutput(tmp_family_info);
			var size_tmp_family_info:int = tmp_family_info.length;
			output.writeInt(size_tmp_family_info);
			output.writeBytes(tmp_family_info);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			var byte_member_info_size:int = input.readInt();
			if (byte_member_info_size > 0) {				this.member_info = new p_family_member_info;
				var byte_member_info:ByteArray = new ByteArray;
				input.readBytes(byte_member_info, 0, byte_member_info_size);
				this.member_info.readFromDataOutput(byte_member_info);
			}
			var byte_family_info_size:int = input.readInt();
			if (byte_family_info_size > 0) {				this.family_info = new p_family_info;
				var byte_family_info:ByteArray = new ByteArray;
				input.readBytes(byte_family_info, 0, byte_family_info_size);
				this.family_info.readFromDataOutput(byte_family_info);
			}
		}
	}
}
