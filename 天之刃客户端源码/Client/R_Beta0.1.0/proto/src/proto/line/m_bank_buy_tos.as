package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_bank_buy_tos extends Message
	{
		public var price:int = 0;
		public var num:int = 0;
		public function m_bank_buy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_bank_buy_tos", m_bank_buy_tos);
		}
		public override function getMethodName():String {
			return 'bank_buy';
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
