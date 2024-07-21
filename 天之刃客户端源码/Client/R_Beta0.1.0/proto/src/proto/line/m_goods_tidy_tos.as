package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goods_tidy_tos extends Message
	{
		public var bagid:int = 0;
		public function m_goods_tidy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goods_tidy_tos", m_goods_tidy_tos);
		}
		public override function getMethodName():String {
			return 'goods_tidy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bagid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bagid = input.readInt();
		}
	}
}
