package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_team_pick_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var pick_type:int = 1;
		public var reason:String = "";
		public function m_team_pick_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_team_pick_toc", m_team_pick_toc);
		}
		public override function getMethodName():String {
			return 'team_pick';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			output.writeInt(this.pick_type);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.pick_type = input.readInt();
			this.reason = input.readUTF();
		}
	}
}
