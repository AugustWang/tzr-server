package proto.line {
	import proto.common.p_family_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_self_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var family_info:p_family_info = null;
		public function m_family_self_toc() {
			super();
			this.family_info = new p_family_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_self_toc", m_family_self_toc);
		}
		public override function getMethodName():String {
			return 'family_self';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
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
			var byte_family_info_size:int = input.readInt();
			if (byte_family_info_size > 0) {				this.family_info = new p_family_info;
				var byte_family_info:ByteArray = new ByteArray;
				input.readBytes(byte_family_info, 0, byte_family_info_size);
				this.family_info.readFromDataOutput(byte_family_info);
			}
		}
	}
}
