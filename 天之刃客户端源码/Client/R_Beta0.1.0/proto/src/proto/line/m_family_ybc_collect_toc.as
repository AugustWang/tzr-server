package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_collect_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var map_id:int = 0;
		public var owner_type:int = 0;
		public var owner_name:String = "";
		public var content:String = "";
		public function m_family_ybc_collect_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_collect_toc", m_family_ybc_collect_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_collect';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.map_id);
			output.writeInt(this.owner_type);
			if (this.owner_name != null) {				output.writeUTF(this.owner_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.content != null) {				output.writeUTF(this.content.toString());
			} else {
				output.writeUTF("");
			}
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.map_id = input.readInt();
			this.owner_type = input.readInt();
			this.owner_name = input.readUTF();
			this.content = input.readUTF();
		}
	}
}
