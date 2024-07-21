package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_member_invite_toc extends Message
	{
		public var op_status:int = 0;
		public var member_id:int = 0;
		public var member_name:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var op_type:int = 0;
		public function m_team_member_invite_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_member_invite_toc", m_team_member_invite_toc);
		}
		public override function getMethodName():String {
			return 'team_member_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_status);
			output.writeInt(this.member_id);
			if (this.member_name != null) {				output.writeUTF(this.member_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.op_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_status = input.readInt();
			this.member_id = input.readInt();
			this.member_name = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.op_type = input.readInt();
		}
	}
}
