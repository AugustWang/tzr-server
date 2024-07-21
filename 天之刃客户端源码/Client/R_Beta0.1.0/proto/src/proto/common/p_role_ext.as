package proto.common {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class p_role_ext extends Message
	{
		public var role_id:int = 0;
		public var signature:String = "";
		public var birthday:int = 0;
		public var constellation:int = 0;
		public var country:int = 0;
		public var province:int = 0;
		public var city:int = 0;
		public var blog:String = "";
		public var family_last_op_time:int = 0;
		public var last_login_time:int = 0;
		public var last_offline_time:int = 0;
		public var role_name:String = "";
		public var sex:int = 0;
		public var ever_leave_xsc:Boolean = false;
		public function p_role_ext() {
			super();

			flash.net.registerClassAlias("copy.proto.common.p_role_ext", p_role_ext);
		}
		public override function getMethodName():String {
			return 'role';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			output.writeInt(this.role_id);
			if (this.signature != null) {				output.writeUTF(this.signature.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.birthday);
			output.writeInt(this.constellation);
			output.writeInt(this.country);
			output.writeInt(this.province);
			output.writeInt(this.city);
			if (this.blog != null) {				output.writeUTF(this.blog.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.family_last_op_time);
			output.writeInt(this.last_login_time);
			output.writeInt(this.last_offline_time);
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeBoolean(this.ever_leave_xsc);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_id = input.readInt();
			this.signature = input.readUTF();
			this.birthday = input.readInt();
			this.constellation = input.readInt();
			this.country = input.readInt();
			this.province = input.readInt();
			this.city = input.readInt();
			this.blog = input.readUTF();
			this.family_last_op_time = input.readInt();
			this.last_login_time = input.readInt();
			this.last_offline_time = input.readInt();
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			this.ever_leave_xsc = input.readBoolean();
		}
	}
}
