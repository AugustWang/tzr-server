package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_pointassign_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public function m_role2_pointassign_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_pointassign_toc", m_role2_pointassign_toc);
		}
		public override function getMethodName():String {
			return 'role2_pointassign';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
		}
	}
}
