package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_hero_fb_barrier extends Message
	{
		public var barrier_id:int = 0;
		public var time_used:int = 0;
		public var star_level:int = 0;
		public var score:int = 0;
		public var fight_times:int = 0;
		public var order:int = 0;
		public function p_hero_fb_barrier() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_hero_fb_barrier", p_hero_fb_barrier);
		}
		public override function getMethodName():String {
			return 'hero_fb_bar';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.barrier_id);
			output.writeInt(this.time_used);
			output.writeInt(this.star_level);
			output.writeInt(this.score);
			output.writeInt(this.fight_times);
			output.writeInt(this.order);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.barrier_id = input.readInt();
			this.time_used = input.readInt();
			this.star_level = input.readInt();
			this.score = input.readInt();
			this.fight_times = input.readInt();
			this.order = input.readInt();
		}
	}
}
