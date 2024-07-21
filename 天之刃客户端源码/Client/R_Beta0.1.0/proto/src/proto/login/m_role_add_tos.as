package proto.login {
	import flash.net.registerClassAlias;
	import com.Message;
	import flash.utils.ByteArray;
	public class m_role_add_tos extends Message
	{
		public var role_name:String = "";
		public var sex:int = 0;
		public var faction_id:int = 0;
		public var head:int = 0;
		public var hair_type:int = 0;
		public var hair_color:int = 0;
		public function m_role_add_tos() {
			super();

			flash.net.registerClassAlias("copy.proto.login.m_role_add_tos", m_role_add_tos);
		}
		public override function getMethodName():String {
			return 'role_add';
		}
		public override function writeToDataOutput(output:ByteArray):void {
			var i:int;
			if (this.role_name != null) {				output.writeUTF(this.role_name.toString());
			} else {
				output.writeUTF("");
			}
			output.writeInt(this.sex);
			output.writeInt(this.faction_id);
			output.writeInt(this.head);
			output.writeInt(this.hair_type);
			output.writeInt(this.hair_color);
		}
		public override function readFromDataOutput(input:ByteArray):void {
			var i:int;
			this.role_name = input.readUTF();
			this.sex = input.readInt();
			this.faction_id = input.readInt();
			this.head = input.readInt();
			this.hair_type = input.readInt();
			this.hair_color = input.readInt();
		}
	}
}
