package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_activity_info extends Message
	{
		public var id:int = 0;
		public var type:int = 0;
		public var order_id:int = 0;
		public var status:int = 0;
		public var done_times:int = 0;
		public var total_times:int = 0;
		public function p_activity_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_activity_info", p_activity_info);
		}
		public override function getMethodName():String {
			return 'activity_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.type);
			output.writeInt(this.order_id);
			output.writeInt(this.status);
			output.writeInt(this.done_times);
			output.writeInt(this.total_times);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.type = input.readInt();
			this.order_id = input.readInt();
			this.status = input.readInt();
			this.done_times = input.readInt();
			this.total_times = input.readInt();
		}
	}
}
