package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_activity_prize_goods extends Message
	{
		public var type_id:int = 0;
		public var num:int = 0;
		public var color:int = 0;
		public var quality:int = 0;
		public var bind:Boolean = true;
		public var last_time:int = 0;
		public function p_activity_prize_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_activity_prize_goods", p_activity_prize_goods);
		}
		public override function getMethodName():String {
			return 'activity_prize_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type_id);
			output.writeInt(this.num);
			output.writeInt(this.color);
			output.writeInt(this.quality);
			output.writeBoolean(this.bind);
			output.writeInt(this.last_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type_id = input.readInt();
			this.num = input.readInt();
			this.color = input.readInt();
			this.quality = input.readInt();
			this.bind = input.readBoolean();
			this.last_time = input.readInt();
		}
	}
}
