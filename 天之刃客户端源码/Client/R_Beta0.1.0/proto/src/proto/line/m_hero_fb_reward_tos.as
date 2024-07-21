package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_reward_tos extends Message
	{
		public var reward_id:int = 0;
		public function m_hero_fb_reward_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_reward_tos", m_hero_fb_reward_tos);
		}
		public override function getMethodName():String {
			return 'hero_fb_reward';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.reward_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.reward_id = input.readInt();
		}
	}
}
