package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_spy_time_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var start_hour:int = 0;
		public var start_min:int = 0;
		public var can_start_now:Boolean = true;
		public var has_publish:Boolean = true;
		public function m_spy_time_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_spy_time_toc", m_spy_time_toc);
		}
		public override function getMethodName():String {
			return 'spy_time';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.start_hour);
			output.writeInt(this.start_min);
			output.writeBoolean(this.can_start_now);
			output.writeBoolean(this.has_publish);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.start_hour = input.readInt();
			this.start_min = input.readInt();
			this.can_start_now = input.readBoolean();
			this.has_publish = input.readBoolean();
		}
	}
}
