package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_boss_group extends Message
	{
		public var boss_id:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public var last_time:int = 0;
		public var space_time:int = 0;
		public var map_id:int = 0;
		public var tx:int = 0;
		public var ty:int = 0;
		public function p_boss_group() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_boss_group", p_boss_group);
		}
		public override function getMethodName():String {
			return 'boss_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.boss_id);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
			output.writeInt(this.last_time);
			output.writeInt(this.space_time);
			output.writeInt(this.map_id);
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.boss_id = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
			this.last_time = input.readInt();
			this.space_time = input.readInt();
			this.map_id = input.readInt();
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
