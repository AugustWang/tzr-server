package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_shop_currency extends Message
	{
		public var id:int = 0;
		public var amount:int = 0;
		public function p_shop_currency() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_shop_currency", p_shop_currency);
		}
		public override function getMethodName():String {
			return 'shop_curr';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.amount);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.amount = input.readInt();
		}
	}
}
