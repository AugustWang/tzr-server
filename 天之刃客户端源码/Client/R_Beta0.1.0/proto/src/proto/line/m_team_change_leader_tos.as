package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_change_leader_tos extends Message
	{
		public var team_id:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public function m_team_change_leader_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_change_leader_tos", m_team_change_leader_tos);
		}
		public override function getMethodName():String {
			return 'team_change_leader';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.team_id);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.team_id = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
		}
	}
}
