package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_family_member_info extends Message
	{
		public var role_id:int = 0;
		public var role_name:String = "";
		public var title:String = "";
		public var office_name:String = "";
		public var family_contribution:int = 0;
		public var sex:int = 0;
		public var head:int = 0;
		public var online:Boolean = false;
		public var role_level:int = 0;
		public var last_login_time:int = 0;
		public function p_family_member_info() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_family_member_info", p_family_member_info);
		}
		public override function getMethodName():String {
			return 'family_member_';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			if (this.title != null) {				output.writeUTF(this.title.toString());
			} else {
				output.writeUTF("");
			}
			if (this.office_name != null) {				output.writeUTF(this.office_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_contribution);
			output.writeInt(this.sex);
			output.writeInt(this.head);
			output.writeBoolean(this.online);
			output.writeInt(this.role_level);
			output.writeInt(this.last_login_time);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.role_name = input.readUTF();
			this.title = input.readUTF();
			this.office_name = input.readUTF();
			this.family_contribution = input.readInt();
			this.sex = input.readInt();
			this.head = input.readInt();
			this.online = input.readBoolean();
			this.role_level = input.readInt();
			this.last_login_time = input.readInt();
		}
	}
}
