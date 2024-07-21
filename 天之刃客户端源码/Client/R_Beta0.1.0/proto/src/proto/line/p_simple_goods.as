package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_simple_goods extends Message
	{
		public var goodsid:int = 0;
		public var bagid:int = 0;
		public var pos:int = 0;
		public function p_simple_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_simple_goods", p_simple_goods);
		}
		public override function getMethodName():String {
			return 'simple_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goodsid);
			output.writeInt(this.bagid);
			output.writeInt(this.pos);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goodsid = input.readInt();
			this.bagid = input.readInt();
			this.pos = input.readInt();
		}
	}
}
