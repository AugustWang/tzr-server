package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_leave_tos extends Message
	{
		public var team_id:int = 0;
		public function m_team_leave_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_leave_tos", m_team_leave_tos);
		}
		public override function getMethodName():String {
			return 'team_leave';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.team_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.team_id = input.readInt();
		}
	}
}
