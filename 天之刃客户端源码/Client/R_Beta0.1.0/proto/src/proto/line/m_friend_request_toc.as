package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_request_toc extends Message
	{
		public var succ:Boolean = true;
		public var name:String = "";
		public var reason:String = "";
		public var return_self:Boolean = true;
		public function m_friend_request_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_request_toc", m_friend_request_toc);
		}
		public override function getMethodName():String {
			return 'friend_request';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.name = input.readUTF();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
		}
	}
}
