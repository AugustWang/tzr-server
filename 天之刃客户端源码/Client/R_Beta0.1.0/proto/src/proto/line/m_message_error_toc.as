package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_message_error_toc extends Message
	{
		public var error_msg:String = "";
		public var error_no:int = 0;
		public function m_message_error_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_message_error_toc", m_message_error_toc);
		}
		public override function getMethodName():String {
			return 'message_error';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.error_msg != null) {				output.writeUTF(this.error_msg.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.error_no);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.error_msg = input.readUTF();
			this.error_no = input.readInt();
		}
	}
}
