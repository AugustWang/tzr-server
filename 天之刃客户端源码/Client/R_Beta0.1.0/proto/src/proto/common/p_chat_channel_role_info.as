package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_chat_channel_role_info extends Message
	{
		public var channel_sign:String = "";
		public var channel_type:int = 0;
		public var role_id:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var faction_id:int = 0;
		public var office_name:String = "";
		public var head:int = 0;
		public var sign:String = "";
		public var is_online:Boolean = true;
		public function p_chat_channel_role_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_chat_channel_role_info", p_chat_channel_role_info);
		}
		public override function getMethodName():String {
			return 'chat_channel_role_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.channel_sign != null) {				output.writeUTF(this.channel_sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.channel_type);
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.head);
			if (this.sign != null) {				output.writeUTF(this.sign.toString());
			} else {
				output.writeUTF("");
			}
			output.writeBoolean(this.is_online);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.channel_sign = input.readUTF();
			this.channel_type = input.readInt();
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
			this.office_name = input.readUTF();
			this.head = input.readInt();
			this.sign = input.readUTF();
			this.is_online = input.readBoolean();
		}
	}
}
