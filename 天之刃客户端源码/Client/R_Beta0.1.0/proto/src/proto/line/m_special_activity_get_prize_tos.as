package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_special_activity_get_prize_tos extends Message
	{
		public var activity_key:int = 0;
		public var condition_id:int = 0;
		public function m_special_activity_get_prize_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_special_activity_get_prize_tos", m_special_activity_get_prize_tos);
		}
		public override function getMethodName():String {
			return 'special_activity_get_prize';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.activity_key);
			output.writeInt(this.condition_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.activity_key = input.readInt();
			this.condition_id = input.readInt();
		}
	}
}
