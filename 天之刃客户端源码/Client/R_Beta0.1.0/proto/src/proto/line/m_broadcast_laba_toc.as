package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_broadcast_laba_toc extends Message
	{
		public var succ:Boolean = true;
		public var return_self:Boolean = true;
		public var reason:String = "";
		public var content:String = "";
		public var role_id:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var faction_id:int = 0;
		public function m_broadcast_laba_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_broadcast_laba_toc", m_broadcast_laba_toc);
		}
		public override function getMethodName():String {
			return 'broadcast_laba';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			output.writeBoolean(this.return_self);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.return_self = input.readBoolean();
			this.reason = input.readUTF();
			this.content = input.readUTF();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
		}
	}
}
