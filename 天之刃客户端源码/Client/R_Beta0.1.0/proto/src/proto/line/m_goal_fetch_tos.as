package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goal_fetch_tos extends Message
	{
		public var goal_id:int = 0;
		public function m_goal_fetch_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goal_fetch_tos", m_goal_fetch_tos);
		}
		public override function getMethodName():String {
			return 'goal_fetch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goal_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goal_id = input.readInt();
		}
	}
}
