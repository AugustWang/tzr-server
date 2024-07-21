package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_pet_feed extends Message
	{
		public var role_id:int = 0;
		public var state:int = 1;
		public var star_level:int = 1;
		public var last_feed_day:int = 0;
		public var feed_time:int = 0;
		public var last_feed_exp:Number = 0;
		public var feed_over_flag:Boolean = false;
		public var feed_over_tick:int = 0;
		public var feed_tick:int = 0;
		public var free_star_up_flag:Boolean = true;
		public var feed_type:int = 0;
		public var pet_id:int = 0;
		public var star_up_fail_time:int = 0;
		public var last_clear_star_week:int = 0;
		public var star_up_flag:Boolean = false;
		public function p_pet_feed() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_pet_feed", p_pet_feed);
		}
		public override function getMethodName():String {
			return 'pet_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			output.writeInt(this.state);
			output.writeInt(this.star_level);
			output.writeInt(this.last_feed_day);
			output.writeInt(this.feed_time);
			output.writeDouble(this.last_feed_exp);
			output.writeBoolean(this.feed_over_flag);
			output.writeInt(this.feed_over_tick);
			output.writeInt(this.feed_tick);
			output.writeBoolean(this.free_star_up_flag);
			output.writeInt(this.feed_type);
			output.writeInt(this.pet_id);
			output.writeInt(this.star_up_fail_time);
			output.writeInt(this.last_clear_star_week);
			output.writeBoolean(this.star_up_flag);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.state = input.readInt();
			this.star_level = input.readInt();
			this.last_feed_day = input.readInt();
			this.feed_time = input.readInt();
			this.last_feed_exp = input.readDouble();
			this.feed_over_flag = input.readBoolean();
			this.feed_over_tick = input.readInt();
			this.feed_tick = input.readInt();
			this.free_star_up_flag = input.readBoolean();
			this.feed_type = input.readInt();
			this.pet_id = input.readInt();
			this.star_up_fail_time = input.readInt();
			this.last_clear_star_week = input.readInt();
			this.star_up_flag = input.readBoolean();
		}
	}
}
