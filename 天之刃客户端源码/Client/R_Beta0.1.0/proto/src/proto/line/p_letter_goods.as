package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_letter_goods extends Message
	{
		public var goods_id:int = 0;
		public var num:int = 0;
		public function p_letter_goods() {
			super();

			flash.net.registerClassAlias("copy.proto.line.p_letter_goods", p_letter_goods);
		}
		public override function getMethodName():String {
			return 'letter_g';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goods_id);
			output.writeInt(this.num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goods_id = input.readInt();
			this.num = input.readInt();
		}
	}
}
