package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_status_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var type:int = 0;
		public var towner_destroyed:Boolean = true;
		public var general_killed:Boolean = true;
		public var flag_destroyed:Boolean = true;
		public function m_waroffaction_status_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_status_toc", m_waroffaction_status_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_status';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.type);
			output.writeBoolean(this.towner_destroyed);
			output.writeBoolean(this.general_killed);
			output.writeBoolean(this.flag_destroyed);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.type = input.readInt();
			this.towner_destroyed = input.readBoolean();
			this.general_killed = input.readBoolean();
			this.flag_destroyed = input.readBoolean();
		}
	}
}
