package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_letter_family_send_tos extends Message
	{
		public var text:String = "";
		public var range:int = 0;
		public function m_letter_family_send_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_letter_family_send_tos", m_letter_family_send_tos);
		}
		public override function getMethodName():String {
			return 'letter_family_send';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.text != null) {				output.writeUTF(this.text.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.range);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.text = input.readUTF();
			this.range = input.readInt();
		}
	}
}
