package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_collect_demand extends Message
	{
		public var min_level:int = 0;
		public var max_level:int = 0;
		public function p_collect_demand() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_collect_demand", p_collect_demand);
		}
		public override function getMethodName():String {
			return 'collect_de';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.min_level);
			output.writeInt(this.max_level);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.min_level = input.readInt();
			this.max_level = input.readInt();
		}
	}
}
