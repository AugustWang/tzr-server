package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_invite_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var type:int = 0;
		public var role_id:int = 0;
		public function m_family_ybc_invite_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_invite_toc", m_family_ybc_invite_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.type);
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.type = input.readInt();
			this.role_id = input.readInt();
		}
	}
}
