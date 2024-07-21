package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_bank_simple_sheet extends Message
	{
		public var price:int = 0;
		public var num:int = 0;
		public function p_bank_simple_sheet() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_bank_simple_sheet", p_bank_simple_sheet);
		}
		public override function getMethodName():String {
			return 'bank_simple_s';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.price);
			output.writeInt(this.num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.price = input.readInt();
			this.num = input.readInt();
		}
	}
}
