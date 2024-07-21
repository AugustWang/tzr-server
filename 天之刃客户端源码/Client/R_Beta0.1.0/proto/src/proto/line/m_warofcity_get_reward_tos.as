package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_warofcity_get_reward_tos extends Message
	{
		public var type:int = 0;
		public function m_warofcity_get_reward_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_warofcity_get_reward_tos", m_warofcity_get_reward_tos);
		}
		public override function getMethodName():String {
			return 'warofcity_get_reward';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
		}
	}
}
