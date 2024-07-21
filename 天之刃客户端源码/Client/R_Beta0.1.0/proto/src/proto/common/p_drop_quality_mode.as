package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_drop_quality_mode extends Message
	{
		public var quality:int = 0;
		public var rate:int = 0;
		public function p_drop_quality_mode() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_drop_quality_mode", p_drop_quality_mode);
		}
		public override function getMethodName():String {
			return 'drop_quality_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.quality);
			output.writeInt(this.rate);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.quality = input.readInt();
			this.rate = input.readInt();
		}
	}
}
