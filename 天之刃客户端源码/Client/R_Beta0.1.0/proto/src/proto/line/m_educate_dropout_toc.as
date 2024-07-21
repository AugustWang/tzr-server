package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_educate_dropout_toc extends Message
	{
		public var succ:Boolean = true;
		public var roleid:int = 0;
		public var info:p_educate_role_info = null;
		public var reason:String = "";
		public var is_teacher:Boolean = true;
		public function m_educate_dropout_toc() {
			super();
			this.info = new p_educate_role_info;

			flash.net.registerClassAlias("copy.proto.line.m_educate_dropout_toc", m_educate_dropout_toc);
		}
		public override function getMethodName():String {
			return 'educate_dropout';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.roleid);
			var tmp_info:ByteArray = new ByteArray;
			this.info.writeToDataOutput(tmp_info);
			var size_tmp_info:int = tmp_info.length;
			output.writeInt(size_tmp_info);
			output.writeBytes(tmp_info);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_teacher);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.roleid = input.readInt();
			var byte_info_size:int = input.readInt();
			if (byte_info_size > 0) {				this.info = new p_educate_role_info;
				var byte_info:ByteArray = new ByteArray;
				input.readBytes(byte_info, 0, byte_info_size);
				this.info.readFromDataOutput(byte_info);
			}
			this.reason = input.readUTF();
			this.is_teacher = input.readBoolean();
		}
	}
}
