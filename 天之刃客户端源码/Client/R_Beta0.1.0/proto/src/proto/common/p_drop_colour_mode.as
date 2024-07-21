package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_drop_colour_mode extends Message
	{
		public var colour:int = 0;
		public var rate:int = 0;
		public function p_drop_colour_mode() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_drop_colour_mode", p_drop_colour_mode);
		}
		public override function getMethodName():String {
			return 'drop_colour_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.colour);
			output.writeInt(this.rate);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.colour = input.readInt();
			this.rate = input.readInt();
		}
	}
}
