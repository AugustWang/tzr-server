package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_refresh extends Message
	{
		public var type:int = 0;
		public var interval:int = 0;
		public var start_time:int = 0;
		public var end_time:int = 0;
		public function p_collect_refresh() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_collect_refresh", p_collect_refresh);
		}
		public override function getMethodName():String {
			return 'collect_ref';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.interval);
			output.writeInt(this.start_time);
			output.writeInt(this.end_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.interval = input.readInt();
			this.start_time = input.readInt();
			this.end_time = input.readInt();
		}
	}
}
