package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_map_tile extends Message
	{
		public var tx:int = 0;
		public var ty:int = 0;
		public function p_map_tile() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_map_tile", p_map_tile);
		}
		public override function getMethodName():String {
			return 'map_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.tx);
			output.writeInt(this.ty);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.tx = input.readInt();
			this.ty = input.readInt();
		}
	}
}
