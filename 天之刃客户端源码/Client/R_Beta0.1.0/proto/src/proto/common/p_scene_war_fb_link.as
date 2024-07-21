package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_scene_war_fb_link extends Message
	{
		public var fb_type:int = 0;
		public var fb_level:int = 0;
		public var fb_id:int = 0;
		public var fb_seconds:int = 0;
		public var enter_fee:int = 0;
		public var fb_times:int = 0;
		public var fb_max_times:int = 0;
		public function p_scene_war_fb_link() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_scene_war_fb_link", p_scene_war_fb_link);
		}
		public override function getMethodName():String {
			return 'scene_war_fb_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.fb_type);
			output.writeInt(this.fb_level);
			output.writeInt(this.fb_id);
			output.writeInt(this.fb_seconds);
			output.writeInt(this.enter_fee);
			output.writeInt(this.fb_times);
			output.writeInt(this.fb_max_times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.fb_type = input.readInt();
			this.fb_level = input.readInt();
			this.fb_id = input.readInt();
			this.fb_seconds = input.readInt();
			this.enter_fee = input.readInt();
			this.fb_times = input.readInt();
			this.fb_max_times = input.readInt();
		}
	}
}
