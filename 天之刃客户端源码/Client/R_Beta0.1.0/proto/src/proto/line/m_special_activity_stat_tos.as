package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_special_activity_stat_tos extends Message
	{
		public var activity_key:int = 0;
		public var goods_id:int = 0;
		public function m_special_activity_stat_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_special_activity_stat_tos", m_special_activity_stat_tos);
		}
		public override function getMethodName():String {
			return 'special_activity_stat';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.activity_key);
			output.writeInt(this.goods_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.activity_key = input.readInt();
			this.goods_id = input.readInt();
		}
	}
}
