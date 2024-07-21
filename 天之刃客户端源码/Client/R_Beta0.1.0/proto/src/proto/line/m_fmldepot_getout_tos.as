package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_fmldepot_getout_tos extends Message
	{
		public var bag_id:int = 0;
		public var goods_id:int = 0;
		public var num:int = 0;
		public function m_fmldepot_getout_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_fmldepot_getout_tos", m_fmldepot_getout_tos);
		}
		public override function getMethodName():String {
			return 'fmldepot_getout';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.bag_id);
			output.writeInt(this.goods_id);
			output.writeInt(this.num);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.bag_id = input.readInt();
			this.goods_id = input.readInt();
			this.num = input.readInt();
		}
	}
}
