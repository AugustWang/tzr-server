package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_depot_swap_tos extends Message
	{
		public var goodsid:int = 0;
		public var position:int = 0;
		public var bagid:int = 0;
		public function m_depot_swap_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_depot_swap_tos", m_depot_swap_tos);
		}
		public override function getMethodName():String {
			return 'depot_swap';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.goodsid);
			output.writeInt(this.position);
			output.writeInt(this.bagid);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.goodsid = input.readInt();
			this.position = input.readInt();
			this.bagid = input.readInt();
		}
	}
}
