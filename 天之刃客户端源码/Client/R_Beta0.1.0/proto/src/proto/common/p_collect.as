package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect extends Message
	{
		public var rate:int = 0;
		public var typeid:int = 0;
		public function p_collect() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_collect", p_collect);
		}
		public override function getMethodName():String {
			return 'col';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.rate);
			output.writeInt(this.typeid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.rate = input.readInt();
			this.typeid = input.readInt();
		}
	}
}
