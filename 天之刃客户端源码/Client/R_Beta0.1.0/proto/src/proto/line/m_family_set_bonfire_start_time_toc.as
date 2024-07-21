package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_set_bonfire_start_time_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var hour:int = 0;
		public var minute:int = 0;
		public var seconds:int = 0;
		public function m_family_set_bonfire_start_time_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_set_bonfire_start_time_toc", m_family_set_bonfire_start_time_toc);
		}
		public override function getMethodName():String {
			return 'family_set_bonfire_start_time';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.hour);
			output.writeInt(this.minute);
			output.writeInt(this.seconds);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.hour = input.readInt();
			this.minute = input.readInt();
			this.seconds = input.readInt();
		}
	}
}
