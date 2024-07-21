package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_waroffaction_convene_toc extends Message
	{
		public var is_self:Boolean = true;
		public var succ:Boolean = true;
		public var reason:String = "";
		public var convene_id:int = 0;
		public var convene_role_name:String = "";
		public var convene_title:String = "";
		public var faction_id:int = 0;
		public var convene_type:int = 0;
		public function m_waroffaction_convene_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_waroffaction_convene_toc", m_waroffaction_convene_toc);
		}
		public override function getMethodName():String {
			return 'waroffaction_convene';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.is_self);
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.convene_id);
			if (this.convene_role_name != null) {				output.writeUTF(this.convene_role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.convene_title != null) {				output.writeUTF(this.convene_title.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.faction_id);
			output.writeInt(this.convene_type);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.is_self = input.readBoolean();
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.convene_id = input.readInt();
			this.convene_role_name = input.readUTF();
			this.convene_title = input.readUTF();
			this.faction_id = input.readInt();
			this.convene_type = input.readInt();
		}
	}
}
