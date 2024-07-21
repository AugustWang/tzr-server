package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_delete_toc extends Message
	{
		public var succ:Boolean = true;
		public var type:int = 0;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var roleid:int = 0;
		public function m_friend_delete_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_delete_toc", m_friend_delete_toc);
		}
		public override function getMethodName():String {
			return 'friend_delete';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.roleid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.type = input.readInt();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.roleid = input.readInt();
		}
	}
}
