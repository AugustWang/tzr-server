package proto.line {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_family_ybc_publish_toc extends Message
	{
		public var succ:Boolean = true;
		public var reason:String = "";
		public var return_self:Boolean = true;
		public var type:int = 0;
		public var remain_time:int = 0;
		public var owner_type:int = 0;
		public var owner_name:String = "";
		public var silver:int = 0;
		public var owner_id:int = 0;
		public var is_alert:Boolean = true;
		public function m_family_ybc_publish_toc() {
			super();

			flash.net.registerClassAlias("copy.proto.line.m_family_ybc_publish_toc", m_family_ybc_publish_toc);
		}
		public override function getMethodName():String {
			return 'family_ybc_publish';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeBoolean(this.succ);
			if (this.reason != null) {				output.writeUTF(this.reason.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.return_self);
			output.writeInt(this.type);
			output.writeInt(this.remain_time);
			output.writeInt(this.owner_type);
			if (this.owner_name != null) {				output.writeUTF(this.owner_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.silver);
			output.writeInt(this.owner_id);
			output.writeBoolean(this.is_alert);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.succ = input.readBoolean();
			this.reason = input.readUTF();
			this.return_self = input.readBoolean();
			this.type = input.readInt();
			this.remain_time = input.readInt();
			this.owner_type = input.readInt();
			this.owner_name = input.readUTF();
			this.silver = input.readInt();
			this.owner_id = input.readInt();
			this.is_alert = input.readBoolean();
		}
	}
}
