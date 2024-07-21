package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_goal_fetch_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var goal_id:int = 0;
		public function m_goal_fetch_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_goal_fetch_toc", m_goal_fetch_toc);
		}
		public override function getMethodName():String {
			return 'goal_fetch';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.goal_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.goal_id = input.readInt();
		}
	}
}
