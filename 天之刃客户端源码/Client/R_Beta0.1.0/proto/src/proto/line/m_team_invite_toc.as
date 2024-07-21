package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_invite_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public var team_id:int = 0;
		public var pick_type:int = 1;
		public var leader_id:int = 0;
		public var type_id:int = 0;
		public function m_team_invite_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_invite_toc", m_team_invite_toc);
		}
		public override function getMethodName():String {
			return 'team_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.team_id);
			output.writeInt(this.pick_type);
			output.writeInt(this.leader_id);
			output.writeInt(this.type_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.team_id = input.readInt();
			this.pick_type = input.readInt();
			this.leader_id = input.readInt();
			this.type_id = input.readInt();
		}
	}
}
