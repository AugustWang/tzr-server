package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_mission_fb_enter_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var barrier_id:int = 0;
		public var error_code:int = 0;
		public function m_mission_fb_enter_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_mission_fb_enter_toc", m_mission_fb_enter_toc);
		}
		public override function getMethodName():String {
			return 'mission_fb_enter';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.barrier_id);
			output.writeInt(this.error_code);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.barrier_id = input.readInt();
			this.error_code = input.readInt();
		}
	}
}
