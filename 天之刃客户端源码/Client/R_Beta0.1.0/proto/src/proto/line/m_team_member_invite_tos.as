package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_member_invite_tos extends Message
	{
		public var op_type:int = 0;
		public var member_id:int = 0;
		public var member_name:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public function m_team_member_invite_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_member_invite_tos", m_team_member_invite_tos);
		}
		public override function getMethodName():String {
			return 'team_member_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.op_type);
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
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.op_type = input.readInt();
			this.member_id = input.readInt();
			this.member_name = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
		}
	}
}
