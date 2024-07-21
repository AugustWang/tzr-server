package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_jail_out_force_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var silver:int = 0;
		public var silver_bind:int = 0;
		public function m_jail_out_force_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_jail_out_force_toc", m_jail_out_force_toc);
		}
		public override function getMethodName():String {
			return 'jail_out_force';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeInt(this.silver_bind);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.silver = input.readInt();
			this.silver_bind = input.readInt();
		}
	}
}
