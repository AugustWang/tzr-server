package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_declare_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var attack_faction_id:int = 0;
		public var defence_faction_id:int = 0;
		public var role_name:String = "";
		public var silver:int = 0;
		public function m_waroffaction_declare_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_declare_toc", m_waroffaction_declare_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_declare';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.attack_faction_id);
			output.writeInt(this.defence_faction_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.attack_faction_id = input.readInt();
			this.defence_faction_id = input.readInt();
			this.role_name = input.readUTF();
			this.silver = input.readInt();
		}
	}
}
