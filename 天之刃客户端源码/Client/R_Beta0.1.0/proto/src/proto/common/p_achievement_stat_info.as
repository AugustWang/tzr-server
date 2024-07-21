package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_achievement_stat_info extends Message
	{
		public var type:int = 0;
		public var cur_progress:int = 0;
		public var total_progress:int = 0;
		public var award_point:int = 0;
		public function p_achievement_stat_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_achievement_stat_info", p_achievement_stat_info);
		}
		public override function getMethodName():String {
			return 'achievement_stat_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.cur_progress);
			output.writeInt(this.total_progress);
			output.writeInt(this.award_point);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.cur_progress = input.readInt();
			this.total_progress = input.readInt();
			this.award_point = input.readInt();
		}
	}
}
