package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_spy_time_tos extends Message
	{
		public var request_type:int = 0;
		public var start_hour:int = 0;
		public var start_min:int = 0;
		public function m_spy_time_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_spy_time_tos", m_spy_time_tos);
		}
		public override function getMethodName():String {
			return 'spy_time';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.request_type);
			output.writeInt(this.start_hour);
			output.writeInt(this.start_min);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.request_type = input.readInt();
			this.start_hour = input.readInt();
			this.start_min = input.readInt();
		}
	}
}
