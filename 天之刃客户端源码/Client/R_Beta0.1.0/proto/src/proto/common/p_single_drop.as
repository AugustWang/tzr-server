package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_single_drop extends Message
	{
		public var type:int = 0;
		public var typeid:int = 0;
		public var weight:int = 0;
		public function p_single_drop() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_single_drop", p_single_drop);
		}
		public override function getMethodName():String {
			return 'single_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.type);
			output.writeInt(this.typeid);
			output.writeInt(this.weight);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.type = input.readInt();
			this.typeid = input.readInt();
			this.weight = input.readInt();
		}
	}
}
