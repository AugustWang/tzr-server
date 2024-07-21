package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_refuse_toc extends Message
	{
		public var succ:Boolean = true;
		public var name:String = "";
		public var return_self:Boolean = true;
		public var reason:String = "";
		public function m_friend_refuse_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_refuse_toc", m_friend_refuse_toc);
		}
		public override function getMethodName():String {
			return 'friend_refuse';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.name != null) {				output.writeUTF(this.name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.name = input.readUTF();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
		}
	}
}
