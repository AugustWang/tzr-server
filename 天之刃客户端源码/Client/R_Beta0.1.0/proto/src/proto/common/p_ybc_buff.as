package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_ybc_buff extends Message
	{
		public var type:int = 0;
		public var begin_time:int = 0;
		public var end_time:int = 0;
		public function p_ybc_buff() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_ybc_buff", p_ybc_buff);
		}
		public override function getMethodName():String {
			return 'ybc_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.begin_time);
			output.writeInt(this.end_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.begin_time = input.readInt();
			this.end_time = input.readInt();
		}
	}
}
