package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_disband_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var team_id:int = 0;
		public var reason:String = "";
		public function m_team_disband_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_disband_toc", m_team_disband_toc);
		}
		public override function getMethodName():String {
			return 'team_disband';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			output.writeInt(this.team_id);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.team_id = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
