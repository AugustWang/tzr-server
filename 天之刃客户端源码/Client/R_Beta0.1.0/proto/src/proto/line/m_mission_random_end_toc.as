package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_random_end_toc extends Message
	{
		public var mission_id:int = 0;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var val:int = 0;
		public function m_mission_random_end_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_random_end_toc", m_mission_random_end_toc);
		}
		public override function getMethodName():String {
			return 'mission_random_end';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.mission_id);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.val);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.mission_id = input.readInt();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.val = input.readInt();
		}
	}
}
