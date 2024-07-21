package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_depot_get_goods_tos extends Message
	{
		public var npcid:int = 0;
		public var depot_id:int = 0;
		public function m_depot_get_goods_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_depot_get_goods_tos", m_depot_get_goods_tos);
		}
		public override function getMethodName():String {
			return 'depot_get_goods';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.npcid);
			output.writeInt(this.depot_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.npcid = input.readInt();
			this.depot_id = input.readInt();
		}
	}
}
