package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_actpoint_reward_tos extends Message
	{
		public function m_activity_actpoint_reward_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_actpoint_reward_tos", m_activity_actpoint_reward_tos);
		}
		public override function getMethodName():String {
			return 'activity_actpoint_reward';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
		}
	}
}
