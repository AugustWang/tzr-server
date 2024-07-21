package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role2_on_hook_status_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var start_time:int = 0;
		public var sun_exp:int = 0;
		public var add_exp:int = 0;
		public var next_time:int = 0;
		public function m_role2_on_hook_status_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_role2_on_hook_status_toc", m_role2_on_hook_status_toc);
		}
		public override function getMethodName():String {
			return 'role2_on_hook_status';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.start_time);
			output.writeInt(this.sun_exp);
			output.writeInt(this.add_exp);
			output.writeInt(this.next_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.start_time = input.readInt();
			this.sun_exp = input.readInt();
			this.add_exp = input.readInt();
			this.next_time = input.readInt();
		}
	}
}
