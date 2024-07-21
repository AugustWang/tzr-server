package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_invite_tos extends Message
	{
		public var role_id:int = 0;
		public var type:int = 0;
		public var team_id:int = 0;
		public function m_team_invite_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_invite_tos", m_team_invite_tos);
		}
		public override function getMethodName():String {
			return 'team_invite';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.type);
			output.writeInt(this.team_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.type = input.readInt();
			this.team_id = input.readInt();
		}
	}
}
