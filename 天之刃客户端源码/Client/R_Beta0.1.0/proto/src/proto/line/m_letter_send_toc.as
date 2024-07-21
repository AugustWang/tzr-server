package proto.line {
	import proto.line.p_letter_simple_info;
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_send_toc extends Message
	{
		public var succ:Boolean = true;
		public var letter:p_letter_simple_info = null;
		public var reason:String = "";
		public function m_letter_send_toc() {
			super();
			this.letter = new p_letter_simple_info;

			flash.net.registerClassAlias("copy.proto.line.m_letter_send_toc", m_letter_send_toc);
		}
		public override function getMethodName():String {
			return 'letter_send';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			var tmp_letter:ByteArray = new ByteArray;
			this.letter.writeToDataOutput(tmp_letter);
			var size_tmp_letter:int = tmp_letter.length;
			output.writeInt(size_tmp_letter);
			output.writeBytes(tmp_letter);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			var byte_letter_size:int = input.readInt();
			if (byte_letter_size > 0) {				this.letter = new p_letter_simple_info;
				var byte_letter:ByteArray = new ByteArray;
				input.readBytes(byte_letter, 0, byte_letter_size);
				this.letter.readFromDataOutput(byte_letter);
			}
			this.reason = input.readUTF();
		}
	}
}
