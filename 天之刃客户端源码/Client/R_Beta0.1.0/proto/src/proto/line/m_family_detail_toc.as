package proto.line {
	import proto.common.p_family_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_detail_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var content:p_family_info = null;
		public function m_family_detail_toc() {
			super();
			this.content = new p_family_info;

			flash.net.registerClassAlias("copy.proto.line.m_family_detail_toc", m_family_detail_toc);
		}
		public override function getMethodName():String {
			return 'family_detail';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			var tmp_content:ByteArray = new ByteArray;
			this.content.writeToDataOutput(tmp_content);
			var size_tmp_content:int = tmp_content.length;
			output.writeInt(size_tmp_content);
			output.writeBytes(tmp_content);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			var byte_content_size:int = input.readInt();
			if (byte_content_size > 0) {				this.content = new p_family_info;
				var byte_content:ByteArray = new ByteArray;
				input.readBytes(byte_content, 0, byte_content_size);
				this.content.readFromDataOutput(byte_content);
			}
		}
	}
}
