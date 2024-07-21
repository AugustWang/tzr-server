package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_kick_tos extends Message
	{
		public var role_id:int = 0;
		public function m_team_kick_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_kick_tos", m_team_kick_tos);
		}
		public override function getMethodName():String {
			return 'team_kick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
		}
	}
}
