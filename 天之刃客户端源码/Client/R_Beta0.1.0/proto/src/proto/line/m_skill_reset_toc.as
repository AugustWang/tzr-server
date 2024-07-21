package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_skill_reset_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var skill_points:int = 0;
		public function m_skill_reset_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_skill_reset_toc", m_skill_reset_toc);
		}
		public override function getMethodName():String {
			return 'skill_reset';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.skill_points);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.skill_points = input.readInt();
		}
	}
}
