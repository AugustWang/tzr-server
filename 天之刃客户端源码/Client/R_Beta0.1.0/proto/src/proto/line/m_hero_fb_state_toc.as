package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_hero_fb_state_toc extends Message
	{
		public var total_monsters:int = 0;
		public var remain_monsters:int = 0;
		public var time_used:int = 0;
		public function m_hero_fb_state_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_hero_fb_state_toc", m_hero_fb_state_toc);
		}
		public override function getMethodName():String {
			return 'hero_fb_state';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.total_monsters);
			output.writeInt(this.remain_monsters);
			output.writeInt(this.time_used);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.total_monsters = input.readInt();
			this.remain_monsters = input.readInt();
			this.time_used = input.readInt();
		}
	}
}
