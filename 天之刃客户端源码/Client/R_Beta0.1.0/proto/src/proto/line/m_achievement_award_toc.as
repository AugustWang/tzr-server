package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_achievement_award_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var achieve_id:int = 0;
		public var group_id:int = 0;
		public var class_id:int = 0;
		public function m_achievement_award_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_achievement_award_toc", m_achievement_award_toc);
		}
		public override function getMethodName():String {
			return 'achievement_award';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.achieve_id);
			output.writeInt(this.group_id);
			output.writeInt(this.class_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.achieve_id = input.readInt();
			this.group_id = input.readInt();
			this.class_id = input.readInt();
		}
	}
}
