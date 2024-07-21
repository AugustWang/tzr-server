package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_activity_benefit_buy_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var act_task_id:int = 0;
		public function m_activity_benefit_buy_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_activity_benefit_buy_toc", m_activity_benefit_buy_toc);
		}
		public override function getMethodName():String {
			return 'activity_benefit_buy';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.act_task_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.act_task_id = input.readInt();
		}
	}
}
