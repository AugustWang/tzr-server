package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goods_info_tos extends Message
	{
		public var id:int = 0;
		public var target_id:int = 0;
		public var type:int = 0;
		public function m_goods_info_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goods_info_tos", m_goods_info_tos);
		}
		public override function getMethodName():String {
			return 'goods_info';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.id);
			output.writeInt(this.target_id);
			output.writeInt(this.type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.id = input.readInt();
			this.target_id = input.readInt();
			this.type = input.readInt();
		}
	}
}
