package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_item_use_tos extends Message
	{
		public var itemid:int = 0;
		public var usenum:int = 0;
		public var effect_id:int = 0;
		public function m_item_use_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_item_use_tos", m_item_use_tos);
		}
		public override function getMethodName():String {
			return 'item_use';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.itemid);
			output.writeInt(this.usenum);
			output.writeInt(this.effect_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.itemid = input.readInt();
			this.usenum = input.readInt();
			this.effect_id = input.readInt();
		}
	}
}
