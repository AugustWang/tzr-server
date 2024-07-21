package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_system_message_toc extends Message
	{
		public var message:String = "";
		public function m_system_message_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_system_message_toc", m_system_message_toc);
		}
		public override function getMethodName():String {
			return 'system_message';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.message != null) {				output.writeUTF(this.message.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.message = input.readUTF();
		}
	}
}
