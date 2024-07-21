package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_pick_tos extends Message
	{
		public var pick_type:int = 1;
		public function m_team_pick_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_pick_tos", m_team_pick_tos);
		}
		public override function getMethodName():String {
			return 'team_pick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.pick_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.pick_type = input.readInt();
		}
	}
}
