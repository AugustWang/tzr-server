package proto.line {
	import proto.common.p_family_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_agree_f_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var family_info:p_family_info = null;
		public var admit_role_id:int = 0;
		public function m_family_agree_f_toc() {
			super();
			this.family_info = new p_family_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_agree_f_toc", m_family_agree_f_toc);
		}
		public override function getMethodName():String {
			return 'family_agree_f';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			var tmp_family_info:ByteArray = new ByteArray;
			this.family_info.writeToDataOutput(tmp_family_info);
			var size_tmp_family_info:int = tmp_family_info.length;
			output.writeInt(size_tmp_family_info);
			output.writeBytes(tmp_family_info);
			output.writeInt(this.admit_role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			var byte_family_info_size:int = input.readInt();
			if (byte_family_info_size > 0) {				this.family_info = new p_family_info;
				var byte_family_info:ByteArray = new ByteArray;
				input.readBytes(byte_family_info, 0, byte_family_info_size);
				this.family_info.readFromDataOutput(byte_family_info);
			}
			this.admit_role_id = input.readInt();
		}
	}
}
