package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_benefit_buy_tos extends Message
	{
		public var act_task_id:int = 0;
		public function m_activity_benefit_buy_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_benefit_buy_tos", m_activity_benefit_buy_tos);
		}
		public override function getMethodName():String {
			return 'activity_benefit_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.act_task_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.act_task_id = input.readInt();
		}
	}
}
