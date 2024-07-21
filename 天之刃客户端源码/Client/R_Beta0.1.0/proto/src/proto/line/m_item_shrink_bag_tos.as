package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_shrink_bag_tos extends Message
	{
		public var bagid:int = 0;
		public var bag:int = 0;
		public var position:int = 0;
		public function m_item_shrink_bag_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_shrink_bag_tos", m_item_shrink_bag_tos);
		}
		public override function getMethodName():String {
			return 'item_shrink_bag';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bagid);
			output.writeInt(this.bag);
			output.writeInt(this.position);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bagid = input.readInt();
			this.bag = input.readInt();
			this.position = input.readInt();
		}
	}
}
