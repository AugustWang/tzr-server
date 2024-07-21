package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_event_toc extends Message
	{
		public var succ:Boolean = true;
		public var event_id:int = 0;
		public var reason:String = "";
		public function m_role2_event_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_event_toc", m_role2_event_toc);
		}
		public override function getMethodName():String {
			return 'role2_event';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeInt(this.event_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.event_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
