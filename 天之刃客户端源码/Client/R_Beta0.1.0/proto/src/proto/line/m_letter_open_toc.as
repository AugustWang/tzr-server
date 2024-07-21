package proto.line {
	import proto.line.p_letter_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_open_toc extends Message
	{
		public var succ:Boolean = true;
		public var result:p_letter_info = null;
		public var reason:String = "";
		public function m_letter_open_toc() {
			super();
			this.result = new p_letter_info;

			flash.net.registerClassAlias("copy.proto.line.m_letter_open_toc", m_letter_open_toc);
		}
		public override function getMethodName():String {
			return 'letter_open';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_result:ByteArray = new ByteArray;
			this.result.writeToDataOutput(tmp_result);
			var size_tmp_result:int = tmp_result.length;
			output.writeInt(size_tmp_result);
			output.writeBytes(tmp_result);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_result_size:int = input.readInt();
			if (byte_result_size > 0) {				this.result = new p_letter_info;
				var byte_result:ByteArray = new ByteArray;
				input.readBytes(byte_result, 0, byte_result_size);
				this.result.readFromDataOutput(byte_result);
			}
			this.reason = input.readUTF();
		}
	}
}
