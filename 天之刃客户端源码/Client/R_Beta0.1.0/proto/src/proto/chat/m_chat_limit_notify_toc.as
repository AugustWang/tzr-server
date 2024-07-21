package proto.chat {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_chat_limit_notify_toc extends Message
	{
		public var limit_type:String = "";
		public var reason:String = "";
		public function m_chat_limit_notify_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.chat.m_chat_limit_notify_toc", m_chat_limit_notify_toc);
		}
		public override function getMethodName():String {
			return 'chat_limit_notify';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.limit_type != null) {				output.writeUTF(this.limit_type.toString());
			} else {
				output.writeUTF("");
			}
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.limit_type = input.readUTF();
			this.reason = input.readUTF();
		}
	}
}
