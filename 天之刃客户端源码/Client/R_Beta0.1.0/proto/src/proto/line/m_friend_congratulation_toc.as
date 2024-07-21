package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_friend_congratulation_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var exp_add:int = 0;
		public var hyd_add:int = 0;
		public var from_friend:String = "";
		public var congratulation:String = "";
		public function m_friend_congratulation_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_friend_congratulation_toc", m_friend_congratulation_toc);
		}
		public override function getMethodName():String {
			return 'friend_congratulation';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.exp_add);
			output.writeInt(this.hyd_add);
			if (this.from_friend != null) {				output.writeUTF(this.from_friend.toString());
			} else {
				output.writeUTF("");
			}
			if (this.congratulation != null) {				output.writeUTF(this.congratulation.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.exp_add = input.readInt();
			this.hyd_add = input.readInt();
			this.from_friend = input.readUTF();
			this.congratulation = input.readUTF();
		}
	}
}
