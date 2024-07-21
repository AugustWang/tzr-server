package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_personal_fb_state_toc extends Message
	{
		public var total_monsters:int = 0;
		public var killed_count:int = 0;
		public var exp_get:int = 0;
		public var time_used:int = 0;
		public var is_boss_killed:Boolean = true;
		public var self_best:int = 0;
		public function m_personal_fb_state_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_personal_fb_state_toc", m_personal_fb_state_toc);
		}
		public override function getMethodName():String {
			return 'personal_fb_state';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.total_monsters);
			output.writeInt(this.killed_count);
			output.writeInt(this.exp_get);
			output.writeInt(this.time_used);
			output.writeBoolean(this.is_boss_killed);
			output.writeInt(this.self_best);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.total_monsters = input.readInt();
			this.killed_count = input.readInt();
			this.exp_get = input.readInt();
			this.time_used = input.readInt();
			this.is_boss_killed = input.readBoolean();
			this.self_best = input.readInt();
		}
	}
}
