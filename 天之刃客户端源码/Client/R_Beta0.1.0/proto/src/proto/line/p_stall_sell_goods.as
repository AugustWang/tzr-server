package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_stall_sell_goods extends Message
	{
		public var good_id:int = 0;
		public var silver:int = 0;
		public var pos:int = 0;
		public function p_stall_sell_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_stall_sell_goods", p_stall_sell_goods);
		}
		public override function getMethodName():String {
			return 'stall_sell_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.good_id);
			output.writeInt(this.silver);
			output.writeInt(this.pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.good_id = input.readInt();
			this.silver = input.readInt();
			this.pos = input.readInt();
		}
	}
}
